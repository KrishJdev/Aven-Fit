package com.avenfit.qa;

import com.avenfit.auth.entity.User;
import com.avenfit.auth.repository.UserRepository;
import com.avenfit.analytics.entity.RecordType;
import com.avenfit.analytics.repository.PersonalRecordRepository;
import com.avenfit.auth.service.JwtService;
import com.avenfit.exercise.entity.Equipment;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.exercise.entity.ExerciseCategory;
import com.avenfit.exercise.repository.ExerciseRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Phase 3 QA: referential integrity across deletes and cascades.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class ReferentialIntegrityTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private ExerciseRepository exerciseRepository;

    @Autowired
    private PersonalRecordRepository personalRecordRepository;

    private User userA;
    private String tokenA;
    private String authHeader;

    @BeforeAll
    void seed() {
        userA = user("R1");
        tokenA = jwtService.generateAccessToken(userA);
        authHeader = "Bearer " + tokenA;
    }

    private User user(String tag) {
        User u = new User();
        u.setPhoneNumber("+9110000" + tag.hashCode() % 100000);
        if (userRepository.findByPhoneNumber(u.getPhoneNumber()).isPresent()) {
            u.setPhoneNumber("+9110001" + tag.hashCode() % 100000);
        }
        u.setDisplayName("User " + tag);
        return userRepository.save(u);
    }

    private Exercise systemExercise(String name) {
        Exercise e = new Exercise();
        e.setName(name);
        e.setCategory(ExerciseCategory.BARBELL);
        e.setEquipment(Equipment.BARBELL);
        e.setIsCustom(false);
        return exerciseRepository.save(e);
    }

    private UUID startWorkout() throws Exception {
        MvcResult result = mockMvc.perform(post("/api/workouts")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Ref Probe\", \"startedAt\": \"" + Instant.now() + "\"}"))
                .andExpect(status().isCreated())
                .andReturn();
        return UUID.fromString(objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").path("id").asText());
    }

    // ------------------------------------------------------------------
    // P3.1: deleting an exercise that is referenced by a workout -> 409
    // ------------------------------------------------------------------

    @Test
    void customExerciseReferencedByWorkoutCannotBeDeleted() throws Exception {
        Exercise custom = new Exercise();
        custom.setName("Referenced Custom " + UUID.randomUUID());
        custom.setCategory(ExerciseCategory.CABLE);
        custom.setEquipment(Equipment.CABLE);
        custom.setIsCustom(true);
        custom.setCreatedBy(userA);
        custom = exerciseRepository.save(custom);

        UUID workoutId = startWorkout();
        mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"exerciseId\": \"" + custom.getId() + "\"}"))
                .andExpect(status().isCreated());

        mockMvc.perform(delete("/api/exercises/" + custom.getId())
                        .header("Authorization", authHeader))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("CONFLICT"));

        // Still present
        assertThat(exerciseRepository.findById(custom.getId())).isPresent();
    }

    // ------------------------------------------------------------------
    // P3.2: sync-deleting a food item referenced by a logged meal degrades
    // gracefully (FAILED result), never crashes the batch or the server.
    // ------------------------------------------------------------------

    @Test
    void syncDeleteOfReferencedFoodItemDegradesGracefully() throws Exception {
        String name = "Referenced Food " + UUID.randomUUID();
        MvcResult food = mockMvc.perform(post("/api/food-items")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"" + name + "\", \"servingSize\": 100, "
                                + "\"servingUnit\": \"g\", \"calories\": 100}"))
                .andExpect(status().isCreated())
                .andReturn();
        String foodId = objectMapper.readTree(food.getResponse().getContentAsString())
                .path("data").path("id").asText();

        mockMvc.perform(post("/api/nutrition/entries")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"mealType\": \"LUNCH\", \"items\": [" +
                                "{\"foodItemId\": \"" + foodId + "\", \"quantity\": 1}]}"))
                .andExpect(status().isCreated());

        MvcResult push = mockMvc.perform(post("/api/sync/push")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"operations\": [{\"entityType\": \"food_item\", \"entityId\": \""
                                + foodId + "\", \"operation\": \"DELETE\"}]}"))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode status = objectMapper.readTree(push.getResponse().getContentAsString())
                .path("data").path("results").get(0).path("status");
        assertThat(status.asText()).isEqualTo("FAILED");

        // Food still exists (referenced), batch endpoint stayed healthy
        mockMvc.perform(get("/api/food-items/" + foodId).header("Authorization", authHeader))
                .andExpect(status().isOk());
    }

    // ------------------------------------------------------------------
    // P3.3: deleting a workout whose sets hold PRs downgrades the records
    // ------------------------------------------------------------------

    @Test
    void deletingWorkoutWithPrSetsDowngradesRecords() throws Exception {
        String suffix = UUID.randomUUID().toString();
        Exercise probe = systemExercise("PR Cascade " + suffix);
        UUID workoutId = startWorkout();
        MvcResult we = mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"exerciseId\": \"" + probe.getId() + "\"}"))
                .andExpect(status().isCreated())
                .andReturn();
        String weId = objectMapper.readTree(we.getResponse().getContentAsString())
                .path("data").path("id").asText();

        mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises/" + weId + "/sets")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"weightKg\": 120, \"reps\": 5}"))
                .andExpect(status().isOk());

        UUID userId = userRepository.findById(userA.getId()).orElseThrow().getId();
        assertThat(personalRecordRepository
                .findByUserIdAndExerciseIdOrderByAchievedAtDesc(userId, probe.getId()))
                .hasSize(4); // all four types recorded

        // Workouts have no REST delete (plan: cancel only) — deletion happens
        // through the sync layer, which must also clean up PRs.
        mockMvc.perform(delete("/api/workouts/" + workoutId)
                        .header("Authorization", authHeader))
                .andExpect(status().isMethodNotAllowed());

        MvcResult push = mockMvc.perform(post("/api/sync/push")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"operations\": [{\"entityType\": \"workout\", \"entityId\": \""
                                + workoutId + "\", \"operation\": \"DELETE\"}]}"))
                .andExpect(status().isOk())
                .andReturn();
        String status = objectMapper.readTree(push.getResponse().getContentAsString())
                .path("data").path("results").get(0).path("status").asText();
        assertThat(status).isEqualTo("DELETED");

        assertThat(personalRecordRepository
                .findByUserIdAndExerciseIdOrderByAchievedAtDesc(userId, probe.getId()))
                .isEmpty();
    }

    // ------------------------------------------------------------------
    // P3.4: routine deleted after use -> past workouts keep their data
    // ------------------------------------------------------------------

    @Test
    void routineDeletionAfterWorkoutUseKeepsWorkoutsIntact() throws Exception {
        Exercise bench = systemExercise("Routine FK " + UUID.randomUUID());

        MvcResult created = mockMvc.perform(post("/api/routines")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"FK Template\", \"description\": null, \"exercises\": [" +
                                "{\"exerciseId\": \"" + bench.getId() + "\", \"position\": 1, " +
                                "\"restSeconds\": 90, \"sets\": [{\"position\": 1, \"setType\": \"NORMAL\", " +
                                "\"targetReps\": 10}]}]}"))
                .andExpect(status().isCreated())
                .andReturn();
        String routineId = objectMapper.readTree(created.getResponse().getContentAsString())
                .path("data").path("id").asText();

        MvcResult workout = mockMvc.perform(post("/api/workouts")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"From FK Template\", \"routineId\": \"" + routineId
                                + "\", \"startedAt\": \"" + Instant.now() + "\"}"))
                .andExpect(status().isCreated())
                .andReturn();
        String workoutId = objectMapper.readTree(workout.getResponse().getContentAsString())
                .path("data").path("id").asText();

        mockMvc.perform(delete("/api/routines/" + routineId)
                        .header("Authorization", authHeader))
                .andExpect(status().isNoContent());

        // Workout survives with its pre-populated exercise graph
        mockMvc.perform(get("/api/workouts/" + workoutId)
                        .header("Authorization", authHeader))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.exercises.length()").value(1))
                .andExpect(jsonPath("$.data.exercises[0].sets.length()").value(1));
    }
}
