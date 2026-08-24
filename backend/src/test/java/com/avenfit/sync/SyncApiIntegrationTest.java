package com.avenfit.sync;

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

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class SyncApiIntegrationTest {

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
    private User userB;
    private String tokenA;
    private String tokenB;
    private Exercise bench;

    @BeforeAll
    void seed() {
        userA = user("SA");
        userB = user("SB");
        tokenA = jwtService.generateAccessToken(userA);
        tokenB = jwtService.generateAccessToken(userB);
        bench = systemExercise("Sync Bench Source");
    }

    private User user(String tag) {
        User u = new User();
        u.setPhoneNumber("+9140000" + tag.hashCode() % 100000);
        if (userRepository.findByPhoneNumber(u.getPhoneNumber()).isPresent()) {
            u.setPhoneNumber("+9140001" + tag.hashCode() % 100000);
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

    // ------------------------------------------------------------------

    private JsonNode push(String token, String body, int expectedStatus) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/sync/push")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().is(expectedStatus))
                .andReturn();
        return objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
    }

    /** Offline-style batch: workout -> its exercise -> a completed set. */
    private String offlineBatch(String clientPrefix, Instant clientTs) {
        UUID workoutId = UUID.randomUUID();
        UUID weId = UUID.randomUUID();
        UUID setId = UUID.randomUUID();
        return "{\"operations\": [" +
                "{\"entityType\": \"workout\", \"entityId\": \"" + workoutId + "\", \"operation\": \"CREATE\", " +
                "\"clientTimestamp\": \"" + clientTs + "\", \"data\": {\"name\": \"" + clientPrefix
                + " Workout\", \"startedAt\": \"" + Instant.now() + "\"}}," +
                "{\"entityType\": \"workout_exercise\", \"entityId\": \"" + weId + "\", \"operation\": \"CREATE\", " +
                "\"clientTimestamp\": \"" + clientTs + "\", \"data\": {\"workoutId\": \"" + workoutId
                + "\", \"exerciseId\": \"" + bench.getId() + "\", \"position\": 1, \"restSeconds\": 120}}," +
                "{\"entityType\": \"workout_set\", \"entityId\": \"" + setId + "\", \"operation\": \"CREATE\", " +
                "\"clientTimestamp\": \"" + clientTs + "\", \"data\": {\"workoutExerciseId\": \"" + weId
                + "\", \"weightKg\": 100, \"reps\": 8}}" +
                "]}";
    }

    // ------------------------------------------------------------------
    // Push: batch creation, idempotency, isolation
    // ------------------------------------------------------------------

    @Test
    void offlineBatchCreatesAllEntitiesAndReplayIsIgnored() throws Exception {
        Instant ts = Instant.now();
        String body = offlineBatch("Offline", ts);

        JsonNode first = push(tokenA, body, 200);
        assertThat(first.path("processed").asInt()).isEqualTo(3);
        assertThat(first.path("conflicts").asInt()).isEqualTo(0);
        assertThat(first.path("results")).hasSize(3);
        for (JsonNode r : first.path("results")) {
            assertThat(r.path("status").asText()).isEqualTo("CREATED");
        }

        // Replay the exact same batch — everything must be IGNORED_DUPLICATE
        JsonNode replay = push(tokenA, body, 200);
        System.out.println("[SYNC-REPLAY] " + replay.toString());
        assertThat(replay.path("processed").asInt()).isEqualTo(3);
        for (JsonNode r : replay.path("results")) {
            assertThat(r.path("status").asText()).isEqualTo("IGNORED_DUPLICATE");
        }
    }

    @Test
    void unsupportedTypeDoesNotPoisonTheBatch() throws Exception {
        UUID goodId = UUID.randomUUID();
        String body = "{\"operations\": [" +
                "{\"entityType\": \"alien\", \"entityId\": \"" + UUID.randomUUID()
                + "\", \"operation\": \"CREATE\", \"data\": {}}, " +
                "{\"entityType\": \"exercise\", \"entityId\": \"" + goodId
                + "\", \"operation\": \"CREATE\", \"clientTimestamp\": \"" + Instant.now() + "\", " +
                "\"data\": {\"name\": \"Synced Custom Move\", \"category\": \"CABLE\", \"equipment\": \"CABLE\"}}" +
                "]}";

        JsonNode data = push(tokenA, body, 200);
        assertThat(data.path("results").get(0).path("status").asText()).isEqualTo("UNSUPPORTED_TYPE");
        assertThat(data.path("results").get(1).path("status").asText()).isEqualTo("CREATED");
        assertThat(exerciseRepository.findById(goodId)).isPresent();
    }

    @Test
    void staleClientUpdateIsConflictFreshUpdateApplies() throws Exception {
        UUID id = UUID.randomUUID();
        Instant created = Instant.now();

        push(tokenA, "{\"operations\": [{\"entityType\": \"exercise\", \"entityId\": \"" + id
                + "\", \"operation\": \"CREATE\", \"clientTimestamp\": \"" + created
                + "\", \"data\": {\"name\": \"Conflict Probe\", \"category\": \"OTHER\", \"equipment\": \"OTHER\"}}]}", 200);

        // Stale snapshot (older than the row's updated_at) -> CONFLICT
        JsonNode stale = push(tokenA, "{\"operations\": [{\"entityType\": \"exercise\", \"entityId\": \"" + id
                + "\", \"operation\": \"UPDATE\", \"clientTimestamp\": \""
                + created.minusSeconds(60)
                + "\", \"data\": {\"name\": \"Should Not Apply\"}}]}", 200);
        assertThat(stale.path("results").get(0).path("status").asText()).isEqualTo("CONFLICT");
        assertThat(stale.path("conflicts").asInt()).isEqualTo(1);

        // Fresh timestamp -> applies
        JsonNode fresh = push(tokenA, "{\"operations\": [{\"entityType\": \"exercise\", \"entityId\": \"" + id
                + "\", \"operation\": \"UPDATE\", \"clientTimestamp\": \""
                + Instant.now().plusSeconds(5)
                + "\", \"data\": {\"name\": \"Applied Rename\"}}]}", 200);
        assertThat(fresh.path("results").get(0).path("status").asText()).isEqualTo("UPDATED");

        Exercise reloaded = exerciseRepository.findById(id).orElseThrow();
        assertThat(reloaded.getName()).isEqualTo("Applied Rename");
    }

    @Test
    void deleteThenReplayDeleteIsIgnoredDuplicate() throws Exception {
        UUID id = UUID.randomUUID();
        push(tokenA, "{\"operations\": [{\"entityType\": \"exercise\", \"entityId\": \"" + id
                + "\", \"operation\": \"CREATE\", \"clientTimestamp\": \"" + Instant.now()
                + "\", \"data\": {\"name\": \"Doomed\", \"category\": \"OTHER\", \"equipment\": \"OTHER\"}}]}", 200);

        JsonNode del = push(tokenA, "{\"operations\": [{\"entityType\": \"exercise\", \"entityId\": \"" + id
                + "\", \"operation\": \"DELETE\"}]}", 200);
        assertThat(del.path("results").get(0).path("status").asText()).isEqualTo("DELETED");

        JsonNode again = push(tokenA, "{\"operations\": [{\"entityType\": \"exercise\", \"entityId\": \"" + id
                + "\", \"operation\": \"DELETE\"}]}", 200);
        assertThat(again.path("results").get(0).path("status").asText()).isEqualTo("IGNORED_DUPLICATE");
    }

    @Test
    void routineSyncUpsertCreatesFullTemplateAndForeignRoutineConflicts() throws Exception {
        UUID routineId = UUID.randomUUID();
        String payload = "{\"name\": \"Synced Push Template\", \"description\": null, \"exercises\": [" +
                "{\"exerciseId\": \"" + bench.getId() + "\", \"position\": 1, \"restSeconds\": 90, " +
                "\"sets\": [{\"position\": 1, \"setType\": \"NORMAL\", \"targetReps\": 10}]}]}";

        JsonNode created = push(tokenA, "{\"operations\": [{\"entityType\": \"routine\", \"entityId\": \""
                + routineId + "\", \"operation\": \"CREATE\", \"clientTimestamp\": \"" + Instant.now()
                + "\", \"data\": " + payload + "}]}", 200);
        assertThat(created.path("results").get(0).path("status").asText()).isEqualTo("CREATED");

        // User B pushing under A's routine id must not touch it
        JsonNode foreign = push(tokenB, "{\"operations\": [{\"entityType\": \"routine\", \"entityId\": \""
                + routineId + "\", \"operation\": \"UPDATE\", \"clientTimestamp\": \"" + Instant.now()
                + "\", \"data\": " + payload.replace("Synced Push Template", "Hijacked") + "}]}", 200);
        assertThat(foreign.path("results").get(0).path("status").asText()).isEqualTo("NOT_FOUND");
    }

    @Test
    void emptyOperationsAndMissingFieldsAreValidated() throws Exception {
        mockMvc.perform(post("/api/sync/push")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"operations\": []}"))
                .andExpect(status().isBadRequest());

        mockMvc.perform(post("/api/sync/push")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"operations\": [{\"entityId\": \"" + UUID.randomUUID() + "\"}]}"))
                .andExpect(status().isBadRequest());
    }

    // ------------------------------------------------------------------
    // Pull
    // ------------------------------------------------------------------

    @Test
    void pullReturnsChangesSinceWindowIncludingFullGraphs() throws Exception {
        Instant before = Instant.now();
        Thread.sleep(50); // ensure updatedAt strictly greater than `before`

        String body = offlineBatch("PullProbe", Instant.now());
        JsonNode pushData = push(tokenA, body, 200);
        UUID workoutId = pushData.path("results").get(0).path("serverId").asText() == null
                ? null : UUID.fromString(pushData.path("results").get(0).path("clientId").asText());

        MvcResult result = mockMvc.perform(get("/api/sync/pull")
                        .param("since", before.toString())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode data = objectMapper.readTree(result.getResponse().getContentAsString()).path("data");

        assertThat(data.has("lastSyncTimestamp")).isTrue();
        assertThat(data.path("workouts")).hasSizeGreaterThanOrEqualTo(1);
        boolean foundWithSet = false;
        for (JsonNode w : data.path("workouts")) {
            if (w.path("id").asText().equals(workoutId.toString())) {
                foundWithSet = true;
                assertThat(w.path("exercises")).hasSize(1);
                assertThat(w.path("exercises").get(0).path("sets")).hasSize(1);
                assertThat(w.path("exercises").get(0).path("sets").get(0).path("reps").asInt()).isEqualTo(8);
            }
        }
        assertThat(foundWithSet).isTrue();

        // Pull again from "now" — the just-synced entities are outside the window
        MvcResult second = mockMvc.perform(get("/api/sync/pull")
                        .param("since", Instant.now().plusSeconds(2).toString())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode empty = objectMapper.readTree(second.getResponse().getContentAsString()).path("data");
        assertThat(empty.path("workouts")).isEmpty();
    }

    @Test
    void pullIsUserScoped() throws Exception {
        MvcResult result = mockMvc.perform(get("/api/sync/pull")
                        .param("since", Instant.EPOCH.toString())
                        .header("Authorization", "Bearer " + tokenB))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode data = objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
        for (JsonNode w : data.path("workouts")) {
            assertThat(w.path("name").asText()).doesNotContain("Offline");
        }
    }

    @Test
    void malformedSinceParameterReturns400() throws Exception {
        mockMvc.perform(get("/api/sync/pull")
                        .param("since", "not-a-timestamp")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isBadRequest());
    }
}
