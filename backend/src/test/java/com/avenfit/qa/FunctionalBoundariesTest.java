package com.avenfit.qa;

import com.avenfit.auth.entity.User;
import com.avenfit.auth.repository.UserRepository;
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

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Phase 2 QA: boundary conditions and documented-behavior pinning that the
 * feature suites did not cover.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class FunctionalBoundariesTest {

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

    private User userA;
    private String tokenA;

    @BeforeAll
    void seed() {
        userA = user("Q1");
        tokenA = jwtService.generateAccessToken(userA);
    }

    private User user(String tag) {
        User u = new User();
        u.setPhoneNumber("+9120000" + tag.hashCode() % 100000);
        if (userRepository.findByPhoneNumber(u.getPhoneNumber()).isPresent()) {
            u.setPhoneNumber("+9120001" + tag.hashCode() % 100000);
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
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Boundary Session\", \"startedAt\": \"" + Instant.now() + "\"}"))
                .andExpect(status().isCreated())
                .andReturn();
        return UUID.fromString(objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").path("id").asText());
    }

    private UUID addExercise(UUID workoutId, UUID exerciseId) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"exerciseId\": \"" + exerciseId + "\"}"))
                .andExpect(status().isCreated())
                .andReturn();
        return UUID.fromString(objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").path("id").asText());
    }

    private JsonNode logSet(UUID workoutId, UUID weId, String body) throws Exception {
        MvcResult result = mockMvc.perform(
                        post("/api/workouts/" + workoutId + "/exercises/" + weId + "/sets")
                                .header("Authorization", "Bearer " + tokenA)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(body))
                .andExpect(status().isOk())
                .andReturn();
        return objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
    }

    // ------------------------------------------------------------------
    // RPE & weight boundaries
    // ------------------------------------------------------------------

    @Test
    void rpeExactBoundsAcceptedAndJustOutsideRejected() throws Exception {
        UUID workoutId = startWorkout();
        UUID weId = addExercise(workoutId, systemExercise("RPE Bounds Probe").getId());

        mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises/" + weId + "/sets")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"weightKg\": 50, \"reps\": 5, \"rpe\": 1.0}"))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises/" + weId + "/sets")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"weightKg\": 50, \"reps\": 5, \"rpe\": 10.0}"))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises/" + weId + "/sets")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"weightKg\": 50, \"reps\": 5, \"rpe\": 10.1}"))
                .andExpect(status().isBadRequest());

        mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises/" + weId + "/sets")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"weightKg\": 50, \"reps\": 5, \"rpe\": 0.9}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void zeroWeightIsValidForMachineBodyweightSets() throws Exception {
        UUID workoutId = startWorkout();
        UUID weId = addExercise(workoutId, systemExercise("Zero Weight Probe").getId());

        logSet(workoutId, weId, "{\"weightKg\": 0, \"reps\": 12}")
                ;
        MvcResult detail = mockMvc.perform(get("/api/workouts/" + workoutId)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode sets = objectMapper.readTree(detail.getResponse().getContentAsString())
                .path("data").path("exercises").get(0).path("sets");
        assertThat(sets.get(0).path("weightKg").asDouble()).isEqualTo(0.0);
    }

    // ------------------------------------------------------------------
    // Pagination edges
    // ------------------------------------------------------------------

    @Test
    void pageBeyondRangeReturnsEmptyDataWithValidMetadata() throws Exception {
        mockMvc.perform(get("/api/exercises")
                        .param("page", "999")
                        .param("size", "20")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(0))
                .andExpect(jsonPath("$.totalElements").isNumber());
    }

    @Test
    void sizeOnePaginationIsConsistentAcrossPages() throws Exception {
        MvcResult p0 = mockMvc.perform(get("/api/exercises")
                        .param("size", "1").param("page", "0")
                        .header("Authorization", "Bearer " + tokenA))
                .andReturn();
        MvcResult p1 = mockMvc.perform(get("/api/exercises")
                        .param("size", "1").param("page", "1")
                        .header("Authorization", "Bearer " + tokenA))
                .andReturn();

        JsonNode page0 = objectMapper.readTree(p0.getResponse().getContentAsString());
        JsonNode page1 = objectMapper.readTree(p1.getResponse().getContentAsString());

        assertThat(page0.path("totalElements").asLong())
                .isEqualTo(page1.path("totalElements").asLong());
        assertThat(page0.path("data").get(0).path("id").asText())
                .isNotEqualTo(page1.path("data").get(0).path("id").asText());
        assertThat(page1.path("page").asInt()).isEqualTo(1);
    }

    // ------------------------------------------------------------------
    // Profile partial update
    // ------------------------------------------------------------------

    @Test
    void profileUpdateWithEmptyObjectChangesNothing() throws Exception {
        mockMvc.perform(put("/api/users/me")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.displayName").value("User Q1"))
                .andExpect(jsonPath("$.data.unitPreference").value("METRIC"));
    }

    // ------------------------------------------------------------------
    // Routine edge cases — pinned behavior
    // ------------------------------------------------------------------

    private String routineBody(String name, int pos1, int pos2) {
        return "{\"name\": \"" + name + "\", \"description\": null, \"exercises\": [" +
                "{\"exerciseId\": \"" + systemExercise("Boundary Sq " + pos1).getId()
                + "\", \"position\": " + pos1 + ", \"restSeconds\": 60, \"sets\": []}," +
                "{\"exerciseId\": \"" + systemExercise("Boundary Rd " + pos2).getId()
                + "\", \"position\": " + pos2 + ", \"restSeconds\": 60, \"sets\": []}]}";
    }

    @Test
    void nonSequentialRoutinePositionsAreStoredVerbatim() throws Exception {
        MvcResult created = mockMvc.perform(post("/api/routines")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(routineBody("Sparse Positions", 5, 9)))
                .andExpect(status().isCreated())
                .andReturn();

        JsonNode exercises = objectMapper.readTree(created.getResponse().getContentAsString())
                .path("data").path("exercises");
        assertThat(exercises.get(0).path("position").asInt()).isEqualTo(5);
        assertThat(exercises.get(1).path("position").asInt()).isEqualTo(9);

        // Detail read preserves them
        String id = objectMapper.readTree(created.getResponse().getContentAsString())
                .path("data").path("id").asText();
        mockMvc.perform(get("/api/routines/" + id).header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.exercises[0].position").value(5))
                .andExpect(jsonPath("$.data.exercises[1].position").value(9));
    }

    @Test
    void routineReplaceToEmptyShrinksToZeroExercises() throws Exception {
        MvcResult created = mockMvc.perform(post("/api/routines")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(routineBody("To Be Emptied", 1, 2)))
                .andExpect(status().isCreated())
                .andReturn();
        String id = objectMapper.readTree(created.getResponse().getContentAsString())
                .path("data").path("id").asText();

        mockMvc.perform(put("/api/routines/" + id)
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Emptied\", \"description\": null, \"exercises\": []}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.exercises.length()").value(0));
    }

    // ------------------------------------------------------------------
    // EST_1RM Brzycki boundary: reps 10 in, 11 out
    // ------------------------------------------------------------------

    @Test
    void brzyckiRepsBoundaryTenInclusiveElevenExclusive() throws Exception {
        Exercise probe = systemExercise("Brzycki Boundary " + UUID.randomUUID());

        UUID workoutId = startWorkout();
        UUID weId = addExercise(workoutId, probe.getId());

        // 100x10 -> EST_1RM = 100 * 36/27 = 133.33
        logSet(workoutId, weId, "{\"weightKg\": 100, \"reps\": 10}");

        MvcResult records = mockMvc.perform(
                        get("/api/analytics/personal-records?exerciseId=" + probe.getId())
                                .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode est1rm = objectMapper.readTree(records.getResponse().getContentAsString())
                .path("data").get(0).path("records").path("EST_1RM");
        assertThat(est1rm.path("value").asDouble()).isEqualTo(133.33);

        // 120x11 -> outside Brzycki range; EST_1RM must not change,
        // but MAX_WEIGHT improves to 120.
        logSet(workoutId, weId, "{\"weightKg\": 120, \"reps\": 11}");
        records = mockMvc.perform(get("/api/analytics/personal-records?exerciseId=" + probe.getId())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode after = objectMapper.readTree(records.getResponse().getContentAsString())
                .path("data").get(0).path("records");
        assertThat(after.path("EST_1RM").path("value").asDouble()).isEqualTo(133.33);
        assertThat(after.path("MAX_WEIGHT").path("value").asDouble()).isEqualTo(120.0);
    }

    // ------------------------------------------------------------------
    // Analytics window clamps
    // ------------------------------------------------------------------

    @Test
    void summaryWindowClampEdgesAccepted() throws Exception {
        mockMvc.perform(get("/api/analytics/summary?days=1")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.period").value("1 days"));

        mockMvc.perform(get("/api/analytics/summary?days=365")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.period").value("365 days"));
    }

    // ------------------------------------------------------------------
    // Nutrition macro rounding: half-up at 2dp
    // ------------------------------------------------------------------

    @Test
    void mealMacroRoundingIsHalfUpAtTwoDecimals() throws Exception {
        String foodName = "Round Probe " + UUID.randomUUID();
        MvcResult food = mockMvc.perform(post("/api/food-items")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"" + foodName + "\", \"servingSize\": 100, "
                                + "\"servingUnit\": \"g\", \"calories\": 265, \"proteinG\": 18.006, "
                                + "\"carbsG\": 3, \"fatG\": 20}"))
                .andExpect(status().isCreated())
                .andReturn();
        String foodId = objectMapper.readTree(food.getResponse().getContentAsString())
                .path("data").path("id").asText();

        // 265 * 0.333 = 88.245 -> 88.25 (HALF_UP); protein 18.006*0.333 = 5.995998 -> 6.00
        MvcResult meal = mockMvc.perform(post("/api/nutrition/entries")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"mealType\": \"SNACK\", \"items\": [" +
                                "{\"foodItemId\": \"" + foodId + "\", \"quantity\": 0.333}]}"))
                .andExpect(status().isCreated())
                .andReturn();

        JsonNode item = objectMapper.readTree(meal.getResponse().getContentAsString())
                .path("data").path("items").get(0);
        assertThat(item.path("calories").asDouble()).isEqualTo(88.25);
        assertThat(item.path("proteinG").asDouble()).isEqualTo(6.00);
    }

    // ------------------------------------------------------------------
    // PINNED SEMANTICS: sync bypasses workout state guards (user decision)
    // Online APIs keep the IN_PROGRESS-only rule; late offline data must land.
    // ------------------------------------------------------------------

    @Test
    void syncMayModifyCompletedWorkoutWhileOnlineApiCannot() throws Exception {
        Exercise e = systemExercise("Sync Guard Pin " + UUID.randomUUID());
        UUID workoutId = startWorkout();
        UUID weId = addExercise(workoutId, e.getId());

        mockMvc.perform(put("/api/workouts/" + workoutId + "/complete")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isOk());

        // Online API: rejected with 409
        mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises/" + weId + "/sets")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"weightKg\": 80, \"reps\": 6}"))
                .andExpect(status().isConflict());

        // Sync: allowed — late offline data lands even on completed workouts
        UUID lateSetId = UUID.randomUUID();
        MvcResult pushed = mockMvc.perform(post("/api/sync/push")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"operations\": [{\"entityType\": \"workout_set\", \"entityId\": \""
                                + lateSetId + "\", \"operation\": \"CREATE\", \"clientTimestamp\": \""
                                + Instant.now() + "\", \"data\": {\"workoutExerciseId\": \"" + weId
                                + "\", \"weightKg\": 80, \"reps\": 6}}]}"))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode status = objectMapper.readTree(pushed.getResponse().getContentAsString())
                .path("data").path("results").get(0).path("status");
        assertThat(status.asText()).isEqualTo("CREATED");

        // And the late set participates in analytics (history shows 1 set)
        mockMvc.perform(get("/api/analytics/exercise/" + e.getId() + "/history")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.history[0].sets.length()").value(1));
    }
}
