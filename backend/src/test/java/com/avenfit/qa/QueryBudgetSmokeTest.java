package com.avenfit.qa;

import com.avenfit.auth.entity.User;
import com.avenfit.auth.repository.UserRepository;
import com.avenfit.auth.service.JwtService;
import com.avenfit.exercise.entity.Equipment;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.exercise.entity.ExerciseCategory;
import com.avenfit.exercise.entity.ExerciseMuscleGroup;
import com.avenfit.exercise.entity.MuscleGroup;
import com.avenfit.exercise.entity.MuscleRole;
import com.avenfit.exercise.repository.ExerciseRepository;
import com.avenfit.exercise.repository.MuscleGroupRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.junit.jupiter.api.AfterEach;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Phase 5 QA: query-count smoke tests guarding against N+1 regressions on
 * hot paths. Thresholds are generous upper bounds sized to fail loudly if a
 * per-row query pattern appears, while tolerating framework overhead.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class QueryBudgetSmokeTest {

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
    private MuscleGroupRepository muscleGroupRepository;

    @Autowired
    private EntityManagerFactory entityManagerFactory;

    private User userA;
    private String tokenA;
    private UUID completedWorkoutWithGraph;
    private Exercise linkedProbe;

    @BeforeAll
    void seed() throws Exception {
        User u = new User();
        u.setPhoneNumber("+9187000" + ("P5".hashCode() % 100000));
        if (userRepository.findByPhoneNumber(u.getPhoneNumber()).isPresent()) {
            u.setPhoneNumber("+9187001" + ("P5".hashCode() % 100000));
        }
        u.setDisplayName("User P5");
        userA = userRepository.save(u);
        tokenA = jwtService.generateAccessToken(userA);

        // 30 system exercises, half carrying muscle links (exercises list path)
        MuscleGroup chest = new MuscleGroup();
        chest.setName("QA Chest");
        chest.setDisplayOrder(31);
        chest = muscleGroupRepository.save(chest);

        for (int i = 0; i < 30; i++) {
            Exercise e = new Exercise();
            e.setName("Perf Probe " + i + " " + UUID.randomUUID());
            e.setCategory(ExerciseCategory.BARBELL);
            e.setEquipment(Equipment.BARBELL);
            e.setIsCustom(false);
            if (i % 2 == 0) {
                ExerciseMuscleGroup emg = new ExerciseMuscleGroup();
                emg.setExercise(e);
                emg.setMuscleGroup(chest);
                emg.setRole(MuscleRole.PRIMARY);
                e.getMuscleGroups().add(emg);
            }
            e = exerciseRepository.save(e);
        }

        linkedProbe = new Exercise();
        linkedProbe.setName("Perf Linked " + UUID.randomUUID());
        linkedProbe.setCategory(ExerciseCategory.BARBELL);
        linkedProbe.setEquipment(Equipment.BARBELL);
        linkedProbe.setIsCustom(true);
        linkedProbe.setCreatedBy(userA);
        ExerciseMuscleGroup link = new ExerciseMuscleGroup();
        link.setExercise(linkedProbe);
        link.setMuscleGroup(chest);
        link.setRole(MuscleRole.PRIMARY);
        linkedProbe.getMuscleGroups().add(link);
        linkedProbe = exerciseRepository.save(linkedProbe);

        completedWorkoutWithGraph = buildCompletedWorkoutWithSets();
    }

    private com.avenfit.workout.entity.WorkoutSet unused() { return null; }

    private java.util.UUID buildCompletedWorkoutWithSets() throws Exception {
        MvcResult workout = mockMvc.perform(post("/api/workouts")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Perf Session\", \"startedAt\": \"" + Instant.now() + "\"}"))
                .andExpect(status().isCreated())
                .andReturn();
        String wid = objectMapper.readTree(workout.getResponse().getContentAsString())
                .path("data").path("id").asText();

        MvcResult we = mockMvc.perform(post("/api/workouts/" + wid + "/exercises")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"exerciseId\": \"" + linkedProbe.getId() + "\"}"))
                .andExpect(status().isCreated())
                .andReturn();
        String weId = objectMapper.readTree(we.getResponse().getContentAsString())
                .path("data").path("id").asText();

        for (int rep = 5; rep <= 6; rep++) {
            mockMvc.perform(post("/api/workouts/" + wid + "/exercises/" + weId + "/sets")
                            .header("Authorization", "Bearer " + tokenA)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"weightKg\": 100, \"reps\": " + rep + "}"))
                    .andExpect(status().isOk());
        }

        mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                        .put("/api/workouts/" + wid + "/complete")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isOk());
        return java.util.UUID.fromString(wid);
    }

    private Statistics stats() {
        Statistics s = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        s.setStatisticsEnabled(true);
        s.clear();
        return s;
    }

    @AfterEach
    void resetStats() {
        stats().clear();
    }

    private long performCounting(Runnable call) {
        Statistics s = stats();
        long before = s.getQueryExecutionCount();
        long startNanos = System.nanoTime();
        call.run();
        long elapsedMs = (System.nanoTime() - startNanos) / 1_000_000;
        long queries = s.getQueryExecutionCount() - before;
        System.out.println("[PERF] queries=" + queries + " wallMs=" + elapsedMs);
        return queries;
    }

    @Test
    void exerciseListPageDoesNotExplodeQueries() {
        long queries = performCounting(() -> {
            try {
                mockMvc.perform(get("/api/exercises")
                                .param("size", "50")
                                .header("Authorization", "Bearer " + tokenA))
                        .andExpect(status().isOk());
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        });
        assertThat(queries).as("exercise list page (50 rows, muscle graphs)").isLessThanOrEqualTo(8);
    }

    @Test
    void workoutDetailGraphStaysBounded() {
        long queries = performCounting(() -> {
            try {
                mockMvc.perform(get("/api/workouts/" + completedWorkoutWithGraph)
                                .header("Authorization", "Bearer " + tokenA))
                        .andExpect(status().isOk());
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        });
        assertThat(queries).as("workout detail (1 exercise, 2 sets)").isLessThanOrEqualTo(8);
    }

    @Test
    void dailyNutritionSummaryStaysBounded() throws Exception {
        // Log one meal so the summary has data to fetch
        MvcResult food = mockMvc.perform(post("/api/food-items")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Perf Food " + UUID.randomUUID()
                                + "\", \"servingSize\": 100, \"servingUnit\": \"g\", \"calories\": 100}"))
                .andExpect(status().isCreated())
                .andReturn();
        String foodId = objectMapper.readTree(food.getResponse().getContentAsString())
                .path("data").path("id").asText();

        mockMvc.perform(post("/api/nutrition/entries")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"mealType\": \"LUNCH\", \"items\": [" +
                                "{\"foodItemId\": \"" + foodId + "\", \"quantity\": 1}]}"))
                .andExpect(status().isCreated());

        long queries = performCounting(() -> {
            try {
                mockMvc.perform(get("/api/nutrition/entries")
                                .header("Authorization", "Bearer " + tokenA))
                        .andExpect(status().isOk());
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        });
        assertThat(queries).as("daily nutrition summary").isLessThanOrEqualTo(8);
    }

    @Test
    void syncPullSmallDeltaStaysBounded() {
        long queries = performCounting(() -> {
            try {
                mockMvc.perform(get("/api/sync/pull")
                                .param("since", Instant.EPOCH.toString())
                                .header("Authorization", "Bearer " + tokenA))
                        .andExpect(status().isOk());
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        });
        // Pull touches four entity families plus auth-user resolution.
        assertThat(queries).as("sync pull (small delta)").isLessThanOrEqualTo(20);
    }
}
