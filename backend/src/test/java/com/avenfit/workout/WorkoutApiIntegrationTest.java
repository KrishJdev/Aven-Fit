package com.avenfit.workout;

import com.avenfit.auth.entity.User;
import com.avenfit.auth.repository.UserRepository;
import com.avenfit.analytics.entity.RecordType;
import com.avenfit.analytics.repository.PersonalRecordRepository;
import com.avenfit.auth.service.JwtService;
import com.avenfit.exercise.entity.Equipment;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.exercise.entity.ExerciseCategory;
import com.avenfit.exercise.repository.ExerciseRepository;
import com.avenfit.exercise.service.ExerciseService;
import com.avenfit.routine.entity.Routine;
import com.avenfit.routine.entity.RoutineExercise;
import com.avenfit.routine.entity.RoutineSet;
import com.avenfit.routine.repository.RoutineRepository;
import com.avenfit.workout.entity.SetType;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.transaction.Transactional;
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
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class WorkoutApiIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private ExerciseService exerciseService;

    @Autowired
    private ExerciseRepository exerciseRepository;

    @Autowired
    private RoutineRepository routineRepository;

    @Autowired
    private PersonalRecordRepository personalRecordRepository;

    private User userA;
    private User userB;
    private String tokenA;
    private String tokenB;
    private Exercise bench;
    private Routine routineA;

    @BeforeAll
    @Transactional
    void seed() {
        userA = user("WA");
        userB = user("WB");
        tokenA = jwtService.generateAccessToken(userA);
        tokenB = jwtService.generateAccessToken(userB);

        bench = systemExercise("Barbell Bench Press");

        routineA = routineWithTemplate(userA, "Push Template", bench,
                new String[][]{{"WARMUP", "60", "10"}, {"NORMAL", "100", "5"}, {"NORMAL", "100", "5"}});
        routineWithTemplate(userB, "B Private Template", bench, new String[][]{{"NORMAL", "80", "8"}});
    }

    private User user(String tag) {
        User u = new User();
        u.setPhoneNumber("+9180000" + tag.hashCode() % 100000);
        if (userRepository.findByPhoneNumber(u.getPhoneNumber()).isPresent()) {
            u.setPhoneNumber("+9180001" + tag.hashCode() % 100000);
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

    /** Custom probe exercise â€” isolates PR state per test (user+exercise key). */
    private Exercise probe(UUID owner) {
        Exercise e = new Exercise();
        e.setName("Probe " + UUID.randomUUID());
        e.setCategory(ExerciseCategory.BARBELL);
        e.setEquipment(Equipment.BARBELL);
        e.setIsCustom(true);
        e.setCreatedBy(userRepository.findById(owner).orElseThrow());
        return exerciseRepository.save(e);
    }

    private Routine routineWithTemplate(User owner, String name, Exercise exercise, String[][] sets) {
        Routine r = new Routine();
        r.setUser(owner);
        r.setName(name);
        r = routineRepository.save(r);

        RoutineExercise re = new RoutineExercise();
        re.setRoutine(r);
        re.setExercise(exercise);
        re.setPosition(1);
        re.setRestSeconds(120);
        r.getExercises().add(re);
        int position = 1;
        for (String[] s : sets) {
            RoutineSet rs = new RoutineSet();
            rs.setRoutineExercise(re);
            rs.setPosition(position++);
            rs.setSetType(SetType.valueOf(s[0]));
            rs.setTargetWeightKg(new BigDecimal(s[1]));
            rs.setTargetReps(Integer.valueOf(s[2]));
            re.getSets().add(rs);
        }
        return routineRepository.save(r);
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    private UUID startWorkout(String token) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/workouts")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Push Day\", \"startedAt\": \"" + Instant.now() + "\"}"))
                .andExpect(status().isCreated())
                .andReturn();
        return UUID.fromString(objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").path("id").asText());
    }

    private UUID addExercise(String token, UUID workoutId, UUID exerciseId) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"exerciseId\": \"" + exerciseId + "\", \"restSeconds\": 180}"))
                .andExpect(status().isCreated())
                .andReturn();
        return UUID.fromString(objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").path("id").asText());
    }

    private JsonNode logSet(String token, UUID workoutId, UUID weId, String body, int expectedStatus) throws Exception {
        MvcResult result = mockMvc.perform(
                        post("/api/workouts/" + workoutId + "/exercises/" + weId + "/sets")
                                .header("Authorization", "Bearer " + token)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(body))
                .andExpect(status().is(expectedStatus))
                .andReturn();
        if (expectedStatus != 200) {
            return null;
        }
        return objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
    }

    private JsonNode logWorkingSet(String token, UUID workoutId, UUID weId, String weight, String reps) throws Exception {
        return logSet(token, workoutId, weId,
                "{\"setType\": \"NORMAL\", \"weightKg\": " + weight + ", \"reps\": " + reps + "}", 200);
    }

    // ------------------------------------------------------------------
    // Starting workouts
    // ------------------------------------------------------------------

    @Test
    void startWithoutRoutineCreatesEmptyInProgressWorkout() throws Exception {
        mockMvc.perform(post("/api/workouts")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Solo Session\", \"startedAt\": \"" + Instant.now() + "\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.name").value("Solo Session"))
                .andExpect(jsonPath("$.data.status").value("IN_PROGRESS"))
                .andExpect(jsonPath("$.data.exercises.length()").value(0))
                .andExpect(jsonPath("$.data.completedAt").doesNotExist());
    }

    @Test
    @Transactional
    void startFromRoutinePrepopulatesExercisesAndEmptySets() throws Exception {
        MvcResult result = mockMvc.perform(post("/api/workouts")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"From Template\", \"routineId\": \"" + routineA.getId()
                                + "\", \"startedAt\": \"" + Instant.now() + "\"}"))
                .andExpect(status().isCreated())
                .andReturn();

        JsonNode dto = objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
        assertThat(dto.path("exercises")).hasSize(1);
        JsonNode we = dto.path("exercises").get(0);
        assertThat(we.path("exerciseName").asText()).isEqualTo("Barbell Bench Press");
        assertThat(we.path("position").asInt()).isEqualTo(1);
        assertThat(we.path("restSeconds").asInt()).isEqualTo(120);
        assertThat(we.path("sets")).hasSize(3);
        assertThat(we.path("sets").get(0).path("setType").asText()).isEqualTo("WARMUP");
        assertThat(we.path("sets").get(0).path("isCompleted").asBoolean()).isFalse();
        assertThat(we.path("sets").get(1).path("weightKg").isNull()).isTrue(); // targets are not copied
    }

    @Test
    void startFromAnotherUsersRoutineReturns404() throws Exception {
        UUID foreignRoutineId = routineRepository.findAll().stream()
                .filter(r -> r.getUser().getId().equals(userB.getId()))
                .findFirst().orElseThrow().getId();

        mockMvc.perform(post("/api/workouts")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Sneaky\", \"routineId\": \"" + foreignRoutineId
                                + "\", \"startedAt\": \"" + Instant.now() + "\"}"))
                .andExpect(status().isNotFound());
    }

    // ------------------------------------------------------------------
    // Adding / removing exercises
    // ------------------------------------------------------------------

    @Test
    void addExerciseAutoAssignsSequentialPositions() throws Exception {
        UUID workoutId = startWorkout(tokenA);
        UUID we1 = addExercise(tokenA, workoutId, bench.getId());

        mockMvc.perform(get("/api/workouts/" + workoutId)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.exercises[0].id").value(we1.toString()))
                .andExpect(jsonPath("$.data.exercises[0].position").value(1))
                .andExpect(jsonPath("$.data.exercises[0].exerciseName").value("Barbell Bench Press"))
                .andExpect(jsonPath("$.data.exercises[0].sets.length()").value(0));

        Exercise second = systemExercise("Incline Press Probe");
        UUID we2 = addExercise(tokenA, workoutId, second.getId());

        MvcResult result = mockMvc.perform(get("/api/workouts/" + workoutId)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode exercises = objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").path("exercises");
        assertThat(exercises).hasSize(2);
        assertThat(exercises.get(1).path("position").asInt()).isEqualTo(2);
    }

    @Test
    void addUnknownOrForeignExerciseReturns404() throws Exception {
        UUID workoutId = startWorkout(tokenA);
        mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"exerciseId\": \"" + probe(userB.getId()).getId() + "\"}"))
                .andExpect(status().isNotFound());

        mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"exerciseId\": \"" + UUID.randomUUID() + "\"}"))
                .andExpect(status().isNotFound());
    }

    @Test
    void removeMiddleExerciseCompactsPositions() throws Exception {
        UUID workoutId = startWorkout(tokenA);
        UUID first = addExercise(tokenA, workoutId, bench.getId());
        Exercise e2 = systemExercise("Remove Probe A");
        UUID middle = addExercise(tokenA, workoutId, e2.getId());
        Exercise e3 = systemExercise("Remove Probe B");
        UUID last = addExercise(tokenA, workoutId, e3.getId());

        mockMvc.perform(delete("/api/workouts/" + workoutId + "/exercises/" + middle)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNoContent());

        MvcResult result = mockMvc.perform(get("/api/workouts/" + workoutId)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode exercises = objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").path("exercises");
        assertThat(exercises).hasSize(2);
        assertThat(exercises.get(0).path("id").asText()).isEqualTo(first.toString());
        assertThat(exercises.get(0).path("position").asInt()).isEqualTo(1);
        assertThat(exercises.get(1).path("id").asText()).isEqualTo(last.toString());
        assertThat(exercises.get(1).path("position").asInt()).isEqualTo(2); // compacted from 3
    }

    // ------------------------------------------------------------------
    // Set logging & PR detection
    // ------------------------------------------------------------------

    @Test
    void firstLoggedSetBecomesPrOfEveryApplicableType() throws Exception {
        Exercise p = probe(userA.getId());
        UUID workoutId = startWorkout(tokenA);
        UUID weId = addExercise(tokenA, workoutId, p.getId());

        JsonNode set = logWorkingSet(tokenA, workoutId, weId, "100", "5");
        assertThat(set.path("isCompleted").asBoolean()).isTrue();
        assertThat(set.path("position").asInt()).isEqualTo(1);
        assertThat(set.path("isPr").asBoolean()).isTrue();
        assertThat(set.path("prDetails").path("recordType").asText()).isEqualTo("MAX_WEIGHT");
        assertThat(set.path("prDetails").path("previousValue").isNull()).isTrue();
        assertThat(set.path("prDetails").path("newValue").asDouble()).isEqualTo(100.0);

        List<com.avenfit.analytics.entity.PersonalRecord> records =
                personalRecordRepository.findByUserIdAndExerciseIdOrderByAchievedAtDesc(
                        userA.getId(),
                        p.getId());
        assertThat(records).hasSize(4); // weight, reps, volume, est-1rm all seeded
    }

    @Test
    void lighterSetIsNotPrAndCarriesNoDetails() throws Exception {
        Exercise p = probe(userA.getId());
        UUID workoutId = startWorkout(tokenA);
        UUID weId = addExercise(tokenA, workoutId, p.getId());

        logWorkingSet(tokenA, workoutId, weId, "100", "5");
        JsonNode second = logWorkingSet(tokenA, workoutId, weId, "90", "5");

        assertThat(second.path("isPr").asBoolean()).isFalse();
        assertThat(second.path("prDetails").isNull()).isTrue();

        JsonNode third = logWorkingSet(tokenA, workoutId, weId, "110", "5");
        assertThat(third.path("isPr").asBoolean()).isTrue();
        assertThat(third.path("prDetails").path("recordType").asText()).isEqualTo("MAX_WEIGHT");
        assertThat(third.path("prDetails").path("previousValue").asDouble()).isEqualTo(100.0);
        assertThat(third.path("prDetails").path("newValue").asDouble()).isEqualTo(110.0);
    }

    @Test
    void warmupSetsNeverCountAsRecords() throws Exception {
        Exercise p = probe(userA.getId());
        UUID workoutId = startWorkout(tokenA);
        UUID weId = addExercise(tokenA, workoutId, p.getId());

        JsonNode warmup = logSet(tokenA, workoutId, weId,
                "{\"setType\": \"WARMUP\", \"weightKg\": 500, \"reps\": 3}", 200);

        assertThat(warmup.path("isPr").asBoolean()).isFalse();
        assertThat(warmup.path("prDetails").isNull()).isTrue();

        // Record table still empty for this user+exercise
        UUID userId = userA.getId();
        assertThat(personalRecordRepository
                .findByUserIdAndExerciseIdOrderByAchievedAtDesc(userId, p.getId())).isEmpty();
    }

    @Test
    void estOneRmIgnoresRepsAboveTenButMaxRepsImproves() throws Exception {
        Exercise p = probe(userA.getId());
        UUID workoutId = startWorkout(tokenA);
        UUID weId = addExercise(tokenA, workoutId, p.getId());

        JsonNode base = logWorkingSet(tokenA, workoutId, weId, "100", "5"); // 1RM = 112.50
        assertThat(base.path("isPr").asBoolean()).isTrue();

        JsonNode highRep = logWorkingSet(tokenA, workoutId, weId, "140", "12"); // outside Brzycki range

        // 140 also beats the old MAX_WEIGHT — headline priority reports it
        assertThat(highRep.path("isPr").asBoolean()).isTrue();
        assertThat(highRep.path("prDetails").path("recordType").asText()).isEqualTo("MAX_WEIGHT");
        assertThat(highRep.path("prDetails").path("previousValue").asDouble()).isEqualTo(100.0);
        assertThat(highRep.path("prDetails").path("newValue").asDouble()).isEqualTo(140.0);

        UUID userId = userA.getId();
        var records = personalRecordRepository
                .findByUserIdAndExerciseIdOrderByAchievedAtDesc(userId, p.getId());
        BigDecimal est1rm = records.stream()
                .filter(r -> r.getRecordType() == RecordType.EST_1RM).findFirst().orElseThrow().getValue();
        assertThat(est1rm).isEqualByComparingTo(new BigDecimal("112.50")); // unchanged
    }

    @Test
    void updatingSetDownReevaluatesRecordsAndFlags() throws Exception {
        Exercise p = probe(userA.getId());
        UUID workoutId = startWorkout(tokenA);
        UUID weId = addExercise(tokenA, workoutId, p.getId());

        JsonNode s1 = logWorkingSet(tokenA, workoutId, weId, "100", "5"); // best
        JsonNode s2 = logWorkingSet(tokenA, workoutId, weId, "95", "5");

        assertThat(s1.path("isPr").asBoolean()).isTrue();
        assertThat(s2.path("isPr").asBoolean()).isFalse();

        // Lower the former best below s2 -> s2 becomes the record holder
        MvcResult update = mockMvc.perform(put("/api/workouts/" + workoutId + "/sets/" + s1.path("id").asText())
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"weightKg\": 85}"))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode updated = objectMapper.readTree(update.getResponse().getContentAsString()).path("data");
        assertThat(updated.path("weightKg").asDouble()).isEqualTo(85.0);
        assertThat(updated.path("isPr").asBoolean()).isFalse();

        MvcResult detail = mockMvc.perform(get("/api/workouts/" + workoutId)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode sets = objectMapper.readTree(detail.getResponse().getContentAsString())
                .path("data").path("exercises").get(0).path("sets");
        JsonNode s2After = sets.get(1);
        assertThat(s2After.path("isPr").asBoolean()).isTrue(); // flag migrated to new holder

        UUID userId = userA.getId();
        var maxWeight = personalRecordRepository
                .findByUserIdAndExerciseIdOrderByAchievedAtDesc(userId, p.getId()).stream()
                .filter(r -> r.getRecordType() == RecordType.MAX_WEIGHT).findFirst().orElseThrow();
        assertThat(maxWeight.getValue()).isEqualByComparingTo(new BigDecimal("95"));
    }

    @Test
    void deletingTheRecordSetDropsTheRecord() throws Exception {
        Exercise p = probe(userA.getId());
        UUID workoutId = startWorkout(tokenA);
        UUID weId = addExercise(tokenA, workoutId, p.getId());

        JsonNode s1 = logWorkingSet(tokenA, workoutId, weId, "100", "5");
        JsonNode s2 = logWorkingSet(tokenA, workoutId, weId, "90", "5");

        mockMvc.perform(delete("/api/workouts/" + workoutId + "/sets/" + s1.path("id").asText())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNoContent());

        UUID userId = userA.getId();
        var maxWeight = personalRecordRepository
                .findByUserIdAndExerciseIdOrderByAchievedAtDesc(userId, p.getId()).stream()
                .filter(r -> r.getRecordType() == RecordType.MAX_WEIGHT).findFirst().orElseThrow();
        assertThat(maxWeight.getValue()).isEqualByComparingTo(new BigDecimal("90"));

        MvcResult detail = mockMvc.perform(get("/api/workouts/" + workoutId)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode sets = objectMapper.readTree(detail.getResponse().getContentAsString())
                .path("data").path("exercises").get(0).path("sets");
        assertThat(sets).hasSize(1);
        assertThat(sets.get(0).path("id").asText()).isEqualTo(s2.path("id").asText());
        assertThat(sets.get(0).path("isPr").asBoolean()).isTrue();
    }

    @Test
    void invalidSetValueRejectedWith400() throws Exception {
        UUID workoutId = startWorkout(tokenA);
        UUID weId = addExercise(tokenA, workoutId, bench.getId());

        logSet(tokenA, workoutId, weId,
                "{\"weightKg\": -5, \"reps\": 5}", 400);
        logSet(tokenA, workoutId, weId,
                "{\"weightKg\": 100, \"reps\": 5, \"rpe\": 11}", 400);
    }

    // ------------------------------------------------------------------
    // Lifecycle: complete / cancel
    // ------------------------------------------------------------------

    @Test
    void completeCalculatesDurationAndLocksWorkout() throws Exception {
        UUID workoutId = startWorkout(tokenA);
        UUID weId = addExercise(tokenA, workoutId, bench.getId());
        logWorkingSet(tokenA, workoutId, weId, "100", "5");

        MvcResult result = mockMvc.perform(put("/api/workouts/" + workoutId + "/complete")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"notes\": \"Felt strong\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("COMPLETED"))
                .andExpect(jsonPath("$.data.notes").value("Felt strong"))
                .andExpect(jsonPath("$.data.completedAt").exists())
                .andReturn();
        int duration = objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").path("durationSeconds").asInt();
        assertThat(duration).isGreaterThanOrEqualTo(0);

        // Locked: no further mutations allowed
        logSet(tokenA, workoutId, weId, "{\"weightKg\": 100, \"reps\": 5}", 409);
        mockMvc.perform(put("/api/workouts/" + workoutId + "/complete")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isConflict());
        mockMvc.perform(delete("/api/workouts/" + workoutId + "/exercises/" + weId)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isConflict());
    }

    @Test
    void cancelLocksWorkoutAndCompleteAfterCancelConflicts() throws Exception {
        UUID workoutId = startWorkout(tokenA);

        mockMvc.perform(put("/api/workouts/" + workoutId + "/cancel")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("CANCELLED"));

        mockMvc.perform(put("/api/workouts/" + workoutId + "/complete")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isConflict());
    }

    // ------------------------------------------------------------------
    // History, summaries, ownership
    // ------------------------------------------------------------------

    @Test
    @Transactional
    void historyPaginatesFiltersAndSummarizesCorrectly() throws Exception {
        UUID workoutId = startWorkout(tokenA);
        UUID weId = addExercise(tokenA, workoutId, bench.getId());
        logWorkingSet(tokenA, workoutId, weId, "100", "5");   // volume 500, PR
        logWorkingSet(tokenA, workoutId, weId, "100", "5");   // volume 500
        mockMvc.perform(put("/api/workouts/" + workoutId + "/complete")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isOk());

        // Completed filter finds it with aggregates
        MvcResult result = mockMvc.perform(get("/api/workouts")
                        .param("status", "COMPLETED")
                        .param("page", "0")
                        .param("size", "10")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode pageData = objectMapper.readTree(result.getResponse().getContentAsString());
        JsonNode items = pageData.path("data");
        JsonNode match = null;
        for (JsonNode item : items) {
            if (item.path("id").asText().equals(workoutId.toString())) {
                match = item;
            }
        }
        assertThat(match).isNotNull();
        assertThat(match.path("exerciseCount").asLong()).isEqualTo(1);
        assertThat(match.path("setCount").asLong()).isEqualTo(2);
        assertThat(match.path("totalVolumeKg").asDouble()).isEqualTo(1000.0);
        // Both sets hold the identical record -> both are flagged is_pr (ties count)
        assertThat(match.path("prCount").asLong()).isEqualTo(2);

        // IN_PROGRESS filter must not include it
        MvcResult inProgressPage = mockMvc.perform(get("/api/workouts")
                        .param("status", "IN_PROGRESS")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        for (JsonNode item : objectMapper.readTree(inProgressPage.getResponse().getContentAsString()).path("data")) {
            assertThat(item.path("id").asText()).isNotEqualTo(workoutId.toString());
        }

        // User B sees nothing of user A's history
        MvcResult bPage = mockMvc.perform(get("/api/workouts")
                        .header("Authorization", "Bearer " + tokenB))
                .andExpect(status().isOk())
                .andReturn();
        for (JsonNode item : objectMapper.readTree(bPage.getResponse().getContentAsString()).path("data")) {
            assertThat(item.path("id").asText()).isNotEqualTo(workoutId.toString());
        }
    }

    @Test
    void foreignWorkoutDetailIs404() throws Exception {
        UUID workoutId = startWorkout(tokenA);

        mockMvc.perform(get("/api/workouts/" + workoutId)
                        .header("Authorization", "Bearer " + tokenB))
                .andExpect(status().isNotFound());
    }

    @Test
    void unknownStatusFilterRejectedWith400() throws Exception {
        mockMvc.perform(get("/api/workouts")
                        .param("status", "WEIRD")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isBadRequest());
    }

    @Test
    void brzyckiFormulaMatchesSpecification() {
        assertThat(com.avenfit.analytics.service.PersonalRecordService
                .estimateOneRepMax(new BigDecimal("100"), 5))
                .isEqualByComparingTo(new BigDecimal("112.50")); // 100 * 36/32
        assertThat(com.avenfit.analytics.service.PersonalRecordService
                .estimateOneRepMax(new BigDecimal("60"), 1))
                .isEqualByComparingTo(new BigDecimal("60.00")); // single rep = weight
    }
}
