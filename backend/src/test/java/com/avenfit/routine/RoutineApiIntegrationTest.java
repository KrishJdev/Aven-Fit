package com.avenfit.routine;

import com.avenfit.auth.entity.User;
import com.avenfit.auth.repository.UserRepository;
import com.avenfit.auth.service.JwtService;
import com.avenfit.exercise.entity.Equipment;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.exercise.entity.ExerciseCategory;
import com.avenfit.exercise.repository.ExerciseRepository;
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
class RoutineApiIntegrationTest {

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
    private Exercise row;

    private String benchId;
    private String rowId;

    @BeforeAll
    void seed() {
        userA = user("RA");
        userB = user("RB");
        tokenA = jwtService.generateAccessToken(userA);
        tokenB = jwtService.generateAccessToken(userB);

        bench = systemExercise("Routine Bench Probe");
        row = systemExercise("Routine Row Probe");
        benchId = bench.getId().toString();
        rowId = row.getId().toString();
    }

    private User user(String tag) {
        User u = new User();
        u.setPhoneNumber("+9170000" + tag.hashCode() % 100000);
        if (userRepository.findByPhoneNumber(u.getPhoneNumber()).isPresent()) {
            u.setPhoneNumber("+9170001" + tag.hashCode() % 100000);
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

    private String createBody(String name, String... exerciseIdAt) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"name\": \"").append(name).append("\", ")
                .append("\"description\": \"Created by test\", ");
        sb.append("\"exercises\": [");
        for (int i = 0; i < exerciseIdAt.length; i += 2) {
            if (i > 0) {
                sb.append(", ");
            }
            int position = Integer.parseInt(exerciseIdAt[i + 1]);
            sb.append("{\"exerciseId\": \"").append(exerciseIdAt[i]).append("\", ")
                    .append("\"position\": ").append(position).append(", ")
                    .append("\"restSeconds\": 150, ")
                    .append("\"sets\": [")
                    .append("{\"position\": 1, \"setType\": \"WARMUP\", \"targetReps\": 10, \"targetWeightKg\": 40}, ")
                    .append("{\"position\": 2, \"setType\": \"NORMAL\", \"targetReps\": 5, \"targetWeightKg\": 100}]")
                    .append("}");
        }
        sb.append("]}");
        return sb.toString();
    }

    private UUID createRoutine(String token, String body, int expectedStatus) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/routines")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().is(expectedStatus))
                .andReturn();
        return UUID.fromString(objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").path("id").asText());
    }

    // ------------------------------------------------------------------
    // Create & detail
    // ------------------------------------------------------------------

    @Test
    void createWithNestedExercisesAndSetsPersistsEverything() throws Exception {
        MvcResult result = mockMvc.perform(post("/api/routines")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody("Push Day", benchId, "1", rowId, "2")))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.name").value("Push Day"))
                .andExpect(jsonPath("$.data.exercises.length()").value(2))
                .andReturn();

        JsonNode dto = objectMapper.readTree(result.getResponse().getContentAsString()).path("data");

        JsonNode firstExercise = dto.path("exercises").get(0);
        assertThat(firstExercise.path("position").asInt()).isEqualTo(1);
        assertThat(firstExercise.path("exerciseName").asText()).isEqualTo("Routine Bench Probe");
        assertThat(firstExercise.path("sets").get(0).path("setType").asText()).isEqualTo("WARMUP");
        assertThat(firstExercise.path("sets").get(1).path("targetWeightKg").asDouble()).isEqualTo(100.0);
        // Spec shape: sets carry no ids in the response
        assertThat(firstExercise.path("sets").get(0).has("id")).isFalse();

        JsonNode secondExercise = dto.path("exercises").get(1);
        assertThat(secondExercise.path("position").asInt()).isEqualTo(2);

        // Reload through the API and verify persistence of the whole graph
        mockMvc.perform(get("/api/routines/" + dto.path("id").asText())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.exercises.length()").value(2))
                .andExpect(jsonPath("$.data.exercises[0].sets.length()").value(2))
                .andExpect(jsonPath("$.data.exercises[1].sets[1].targetReps").value(5));
    }

    @Test
    void createEmptyRoutineIsAllowed() throws Exception {
        mockMvc.perform(post("/api/routines")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Empty Shell\", \"description\": null, \"exercises\": []}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.exercises.length()").value(0));
    }

    @Test
    void createWithUnknownExerciseReturns404() throws Exception {
        mockMvc.perform(post("/api/routines")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody("Ghost Routine", UUID.randomUUID().toString(), "1")))
                .andExpect(status().isNotFound());
    }

    @Test
    void createWithDuplicatePositionsRejectedWith400() throws Exception {
        String body = "{\"name\": \"Dup Positions\", \"exercises\": [" +
                "{\"exerciseId\": \"" + benchId + "\", \"position\": 1, \"sets\": []}," +
                "{\"exerciseId\": \"" + rowId + "\", \"position\": 1, \"sets\": []}]}";

        mockMvc.perform(post("/api/routines")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
    }

    // ------------------------------------------------------------------
    // List & visibility
    // ------------------------------------------------------------------

    @Test
    void listReturnsOwnRoutinesOnlyWithCorrectCounts() throws Exception {
        createRoutine(tokenA, createBody("Mine One", benchId, "1"), 201);
        createRoutine(tokenA, createBody("Mine Two", benchId, "1", rowId, "2"), 201);
        createRoutine(tokenB, createBody("Theirs", benchId, "1"), 201);

        MvcResult result = mockMvc.perform(get("/api/routines")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();

        JsonNode data = objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
        int mineOneCount = 0;
        for (JsonNode r : data) {
            String name = r.path("name").asText();
            assertThat(name).doesNotContain("Theirs");
            if (name.equals("Mine Two")) {
                assertThat(r.path("exerciseCount").asLong()).isEqualTo(2);
                mineOneCount++;
            }
            if (name.equals("Mine One")) {
                assertThat(r.path("exerciseCount").asLong()).isEqualTo(1);
                mineOneCount++;
            }
            assertThat(r.has("createdAt")).isTrue();
        }
        assertThat(mineOneCount).isEqualTo(2);
    }

    @Test
    void foreignRoutineDetailAndDeleteAre404() throws Exception {
        UUID foreignId = createRoutine(tokenB, createBody("B Private", benchId, "1"), 201);

        mockMvc.perform(get("/api/routines/" + foreignId)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNotFound());

        mockMvc.perform(delete("/api/routines/" + foreignId)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNotFound());

        mockMvc.perform(get("/api/routines/" + UUID.randomUUID())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNotFound());
    }

    // ------------------------------------------------------------------
    // Full replace (PUT)
    // ------------------------------------------------------------------

    @Test
    @Transactional
    void replaceSwappingPositionsOnSameExercisesDoesNotViolateUniqueConstraint() throws Exception {
        UUID id = createRoutine(tokenA, createBody("Replace Me", benchId, "1", rowId, "2"), 201);

        // Same two exercises, positions swapped -> keys (routine_id, position)
        // are reused; must UPDATE/INSERT cleanly, never collide mid-flush.
        String swapped = "{\"name\": \"Replaced\", \"description\": \"now different\", \"exercises\": [" +
                "{\"exerciseId\": \"" + rowId + "\", \"position\": 1, \"restSeconds\": 90, \"sets\": []}," +
                "{\"exerciseId\": \"" + benchId + "\", \"position\": 2, \"restSeconds\": 90, \"sets\": []}]}";

        mockMvc.perform(put("/api/routines/" + id)
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(swapped))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.exercises.length()").value(2))
                .andExpect(jsonPath("$.data.exercises[0].exerciseName").value("Routine Row Probe"))
                .andExpect(jsonPath("$.data.exercises[0].position").value(1));

        // Shrink to a single exercise — old children must be gone
        mockMvc.perform(put("/api/routines/" + id)
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody("Shrunk", benchId, "1")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.exercises.length()").value(1));

        MvcResult verify = mockMvc.perform(get("/api/routines/" + id)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode exercises = objectMapper.readTree(verify.getResponse().getContentAsString())
                .path("data").path("exercises");
        assertThat(exercises).hasSize(1);
        assertThat(exercises.get(0).path("exerciseId").asText()).isEqualTo(benchId);
    }

    // ------------------------------------------------------------------
    // Delete
    // ------------------------------------------------------------------

    @Test
    void deleteOwnRoutineRemovesItEverywhere() throws Exception {
        UUID id = createRoutine(tokenA, createBody("Doomed Routine", benchId, "1"), 201);

        mockMvc.perform(delete("/api/routines/" + id)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNoContent());

        mockMvc.perform(get("/api/routines/" + id)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNotFound());
    }

    // ------------------------------------------------------------------
    // Validation
    // ------------------------------------------------------------------

    @Test
    void blankNameRejectedWith400() throws Exception {
        mockMvc.perform(post("/api/routines")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"\", \"exercises\": []}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
    }

    @Test
    void invalidSetTypeRejectedWith400() throws Exception {
        String body = "{\"name\": \"Bad Type\", \"exercises\": [{" +
                "\"exerciseId\": \"" + benchId + "\", \"position\": 1, " +
                "\"sets\": [{\"position\": 1, \"setType\": \"SUPERSET\"}]}]}";

        mockMvc.perform(post("/api/routines")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
    }
}
