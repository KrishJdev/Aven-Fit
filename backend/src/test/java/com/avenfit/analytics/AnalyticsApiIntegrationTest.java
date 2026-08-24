package com.avenfit.analytics;

import com.avenfit.analytics.entity.RecordType;
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
import java.time.temporal.ChronoUnit;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class AnalyticsApiIntegrationTest {

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

    private User userA;
    private User userB;
    private String tokenA;
    private String tokenB;
    private Exercise chestProbe;   // linked to Chest primary
    private Exercise bareProbe;    // no muscle links

    @BeforeAll
    void seed() {
        userA = user("AA");
        userB = user("AB");
        tokenA = jwtService.generateAccessToken(userA);
        tokenB = jwtService.generateAccessToken(userB);

        MuscleGroup chest = muscleGroup("Chest Analytics", 21);

        chestProbe = customOwnedProbe(userA, "Analytics Chest Probe");
        link(chestProbe, chest);
        bareProbe = customOwnedProbe(userA, "Analytics Bare Probe");
    }

    private User user(String tag) {
        User u = new User();
        u.setPhoneNumber("+9160000" + tag.hashCode() % 100000);
        if (userRepository.findByPhoneNumber(u.getPhoneNumber()).isPresent()) {
            u.setPhoneNumber("+9160001" + tag.hashCode() % 100000);
        }
        u.setDisplayName("User " + tag);
        return userRepository.save(u);
    }

    private Exercise customOwnedProbe(User owner, String name) {
        Exercise e = new Exercise();
        e.setName(name);
        e.setCategory(ExerciseCategory.BARBELL);
        e.setEquipment(Equipment.BARBELL);
        e.setIsCustom(true);
        e.setCreatedBy(owner);
        return exerciseRepository.save(e);
    }

    private void link(Exercise exercise, MuscleGroup group) {
        ExerciseMuscleGroup emg = new ExerciseMuscleGroup();
        emg.setExercise(exercise);
        emg.setMuscleGroup(group);
        emg.setRole(MuscleRole.PRIMARY);
        exercise.getMuscleGroups().add(emg);
        exerciseRepository.save(exercise);
    }

    private MuscleGroup muscleGroup(String name, int order) {
        MuscleGroup mg = new MuscleGroup();
        mg.setName(name);
        mg.setDisplayOrder(order);
        return muscleGroupRepository.save(mg);
    }

    // ------------------------------------------------------------------
    // Helpers driving the real workout API
    // ------------------------------------------------------------------

    private UUID startWorkout(Instant startedAt) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/workouts")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Analytics Session\", \"startedAt\": \"" + startedAt + "\"}"))
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

    private void logSet(UUID workoutId, UUID weId, String body) throws Exception {
        mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises/" + weId + "/sets")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk());
    }

    private void complete(UUID workoutId) throws Exception {
        mockMvc.perform(put("/api/workouts/" + workoutId + "/complete")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isOk());
    }

    /** Builds a completed workout on the given day with the given sets. */
    private UUID buildCompletedSession(Instant startedAt, UUID exerciseId, String[][] sets) throws Exception {
        UUID workoutId = startWorkout(startedAt);
        UUID weId = addExercise(workoutId, exerciseId);
        for (String[] s : sets) {
            logSet(workoutId, weId,
                    "{\"setType\": \"" + s[2] + "\", \"weightKg\": " + s[0] + ", \"reps\": " + s[1] + "}");
        }
        complete(workoutId);
        return workoutId;
    }

    private JsonNode getJson(String url) throws Exception {
        MvcResult result = mockMvc.perform(get(url).header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        return objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
    }

    // ------------------------------------------------------------------
    // Personal records endpoint
    // ------------------------------------------------------------------

    @Test
    void emptyStateReturnsEmptyList() throws Exception {
        MvcResult result = mockMvc.perform(get("/api/analytics/personal-records")
                        .header("Authorization", "Bearer " + tokenB))
                .andExpect(status().isOk())
                .andReturn();
        assertThat(objectMapper.readTree(result.getResponse().getContentAsString()).path("data")).isEmpty();
    }

    @Test
    void recordsGroupedByExerciseWithOnlyExistingTypesAndFilterWorks() throws Exception {
        Instant now = Instant.now();
        Exercise pRecs = customOwnedProbe(userA, "Records Probe " + UUID.randomUUID());
        buildCompletedSession(now.minus(2, ChronoUnit.DAYS), pRecs.getId(),
                new String[][]{{"100", "5", "NORMAL"}, {"110", "3", "NORMAL"}});

        // Global list uses containment (other tests may add their own groups);
        // the exerciseId filter below asserts exactness.
        JsonNode all = getJson("/api/analytics/personal-records");
        JsonNode group = null;
        for (JsonNode candidate : all) {
            if (candidate.path("exerciseId").asText().equals(pRecs.getId().toString())) {
                group = candidate;
            }
        }
        assertThat(group).isNotNull();

        JsonNode records = group.path("records");
        assertThat(records.has("MAX_WEIGHT")).isTrue();
        assertThat(records.path("MAX_WEIGHT").path("value").asDouble()).isEqualTo(110.0);
        assertThat(records.has("MAX_VOLUME")).isTrue();
        assertThat(records.path("MAX_VOLUME").path("value").asDouble()).isEqualTo(500.0); // max(100x5, 110x3)
        assertThat(records.has("EST_1RM")).isTrue();

        // MAX_REPS is stored even though it never badges sets
        assertThat(records.has("MAX_REPS")).isTrue();
        assertThat(records.path("MAX_REPS").path("value").asInt()).isEqualTo(5);

        // achievedAt present
        assertThat(records.path("MAX_WEIGHT").path("achievedAt").isNull()).isFalse();

        // exerciseId filter returns only that group
        JsonNode filtered = getJson("/api/analytics/personal-records?exerciseId=" + pRecs.getId());
        assertThat(filtered).hasSize(1);
        assertThat(filtered.get(0).path("exerciseId").asText()).isEqualTo(pRecs.getId().toString());
    }

    @Test
    void recordsAreIsolatedPerUser() throws Exception {
        // User B logs on their own copy of nothing — B has no records at all
        MvcResult result = mockMvc.perform(get("/api/analytics/personal-records")
                        .header("Authorization", "Bearer " + tokenB))
                .andExpect(status().isOk())
                .andReturn();
        assertThat(objectMapper.readTree(result.getResponse().getContentAsString()).path("data")).isEmpty();
    }

    @Test
    void recordFilterOnForeignCustomExerciseIs404() throws Exception {
        mockMvc.perform(get("/api/analytics/personal-records?exerciseId=" + chestProbe.getId())
                        .header("Authorization", "Bearer " + tokenB))
                .andExpect(status().isNotFound());
    }

    // ------------------------------------------------------------------
    // Exercise history endpoint
    // ------------------------------------------------------------------

    @Test
    void historyGroupsByWorkoutDayExcludingWarmupsFromAggregates() throws Exception {
        Exercise pHist = customOwnedProbe(userA, "History Probe " + UUID.randomUUID());
        // Session 1: two days ago — warmup 60x10 (not aggregated), work sets
        buildCompletedSession(Instant.now().minus(2, ChronoUnit.DAYS), pHist.getId(),
                new String[][]{
                        {"60", "10", "WARMUP"},
                        {"100", "5", "NORMAL"},
                        {"90", "8", "NORMAL"}});
        // Session 2: today
        buildCompletedSession(Instant.now(), pHist.getId(),
                new String[][]{{"105", "5", "NORMAL"}});

        JsonNode history = getJson("/api/analytics/exercise/" + pHist.getId() + "/history");
        assertThat(history.path("exerciseName").asText()).startsWith("History Probe");

        JsonNode days = history.path("history");
        assertThat(days).hasSize(2);

        // Chronological ascending: oldest first
        JsonNode oldest = days.get(0);
        JsonNode newest = days.get(1);
        assertThat(oldest.path("date").asText())
                .isLessThanOrEqualTo(newest.path("date").asText());

        // Oldest day: warmup listed but excluded from aggregates
        assertThat(oldest.path("sets")).hasSize(3); // warmup included in listing
        JsonNode bestOld = oldest.path("bestSet");
        assertThat(bestOld.path("weightKg").asDouble()).isEqualTo(100.0); // not the 60kg warmup
        assertThat(bestOld.path("reps").asInt()).isEqualTo(5);
        double expectedVolume = 100 * 5 + 90 * 8; // warmup excluded
        assertThat(oldest.path("totalVolumeKg").asDouble()).isEqualTo(expectedVolume);

        // Newest day
        assertThat(newest.path("sets")).hasSize(1);
        assertThat(newest.path("totalVolumeKg").asDouble()).isEqualTo(525.0);
    }

    @Test
    void historyUnknownOrForeignExerciseIs404() throws Exception {
        mockMvc.perform(get("/api/analytics/exercise/" + UUID.randomUUID() + "/history")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNotFound());

        mockMvc.perform(get("/api/analytics/exercise/" + chestProbe.getId() + "/history")
                        .header("Authorization", "Bearer " + tokenB))
                .andExpect(status().isNotFound());
    }

    // ------------------------------------------------------------------
    // Summary endpoint
    // ------------------------------------------------------------------

    @Test
    void summaryAggregatesWindowCorrectly() throws Exception {
        Instant now = Instant.now();
        // Two completed sessions within 30d using chestProbe (Chest primary)
        // Session X: 100x5 + 110x3 -> sets=2, volume=500+330=830
        buildCompletedSession(now.minus(3, ChronoUnit.DAYS), chestProbe.getId(),
                new String[][]{{"100", "5", "NORMAL"}, {"110", "3", "NORMAL"}});
        // Session Y: today -> sets=1, volume=105*5=525
        buildCompletedSession(now, chestProbe.getId(), new String[][]{{"105", "5", "NORMAL"}});
        // In-progress workout must NOT count
        startWorkout(now);

        JsonNode summary = getJson("/api/analytics/summary"); // default 30 days

        assertThat(summary.path("period").asText()).isEqualTo("30 days");
        long totalWorkouts = summary.path("totalWorkouts").asLong();
        long totalSets = summary.path("totalSets").asLong();
        double totalVolume = summary.path("totalVolumeKg").asDouble();
        long prs = summary.path("newPRs").asLong();

        // At least this class's sessions are counted (other tests may add data)
        assertThat(totalWorkouts).isGreaterThanOrEqualTo(2L);
        assertThat(totalSets).isGreaterThanOrEqualTo(3L);
        assertThat(totalVolume).isGreaterThanOrEqualTo(830.0 + 525.0 - 0.01);
        assertThat(summary.path("totalDurationMinutes").asLong()).isGreaterThanOrEqualTo(0L);
        assertThat(summary.path("avgWorkoutDurationMinutes").asLong()).isGreaterThanOrEqualTo(0L);

        // Chest primary attribution appears with the right ordering field
        JsonNode mg = summary.path("muscleGroupVolume");
        boolean foundChest = false;
        for (JsonNode entry : mg) {
            if (entry.path("muscleGroup").asText().equals("Chest Analytics")) {
                foundChest = true;
                assertThat(entry.path("volumeKg").asDouble()).isGreaterThanOrEqualTo(1355.0);
                assertThat(entry.path("sets").asLong()).isGreaterThanOrEqualTo(3L);
            }
        }
        assertThat(foundChest).isTrue();

        // PRs recorded during the window include our probe's records
        assertThat(prs).isGreaterThanOrEqualTo(4L); // 4 types x chestProbe

        // Volume-only probe contributed no muscle-group rows (no links)
        boolean bareFound = false;
        for (JsonNode entry : mg) {
            if (entry.path("muscleGroup").asText().contains("Bare")) {
                bareFound = true;
            }
        }
        assertThat(bareFound).isFalse();
    }

    @Test
    void summaryDaysValidation() throws Exception {
        mockMvc.perform(get("/api/analytics/summary?days=0")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isBadRequest());

        mockMvc.perform(get("/api/analytics/summary?days=400")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isBadRequest());

        mockMvc.perform(get("/api/analytics/summary?days=7")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.period").value("7 days"));
    }

    // ------------------------------------------------------------------
    // Record type sanity after multi-type improvements
    // ------------------------------------------------------------------

    @Test
    void recordTypesMatchBrzyckiExpectation() throws Exception {
        Exercise p = customOwnedProbe(userA, "Brzycki Probe " + UUID.randomUUID());

        UUID workoutId = startWorkout(Instant.now());
        UUID weId = addExercise(workoutId, p.getId());
        logSet(workoutId, weId, "{\"weightKg\": 100, \"reps\": 5}");
        complete(workoutId);

        MvcResult result = mockMvc.perform(
                        get("/api/analytics/personal-records?exerciseId=" + p.getId())
                                .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode records = objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").get(0).path("records");

        assertThat(records.path(RecordType.EST_1RM.name()).path("value").asDouble()).isEqualTo(112.50);
        assertThat(records.path(RecordType.MAX_WEIGHT.name()).path("value").asDouble()).isEqualTo(100.0);
        assertThat(records.path(RecordType.MAX_REPS.name()).path("value").asInt()).isEqualTo(5);
        assertThat(records.path(RecordType.MAX_VOLUME.name()).path("value").asDouble()).isEqualTo(500.0);
    }
}
