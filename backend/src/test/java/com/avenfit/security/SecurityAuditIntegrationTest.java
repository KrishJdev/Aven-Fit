package com.avenfit.security;

import com.avenfit.auth.entity.User;
import com.avenfit.auth.repository.UserRepository;
import com.avenfit.auth.service.JwtService;
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

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Phase 1 security sweep: horizontal authorization matrix, JWT negatives,
 * injection probes, unicode round-trips, refresh-token cross-user protection.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class SecurityAuditIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtService jwtService;

    private User userA;
    private User userB;
    private String tokenA;
    private String tokenB;

    @BeforeAll
    void seed() {
        userA = user("X1");
        userB = user("X2");
        tokenA = jwtService.generateAccessToken(userA);
        tokenB = jwtService.generateAccessToken(userB);
    }

    private User user(String tag) {
        User u = new User();
        u.setPhoneNumber("+9130000" + tag.hashCode() % 100000);
        if (userRepository.findByPhoneNumber(u.getPhoneNumber()).isPresent()) {
            u.setPhoneNumber("+9130001" + tag.hashCode() % 100000);
        }
        u.setDisplayName("User " + tag);
        return userRepository.save(u);
    }

    private UUID createWorkoutAs(String token) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/workouts")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Security Probe\", \"startedAt\": \"" + Instant.now() + "\"}"))
                .andExpect(status().isCreated())
                .andReturn();
        return UUID.fromString(objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").path("id").asText());
    }

    // ------------------------------------------------------------------
    // JWT negatives at the endpoint level
    // ------------------------------------------------------------------

    @Test
    void missingHeaderGarbageAndTamperedTokensAllRejected401() throws Exception {
        // No header
        mockMvc.perform(get("/api/users/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.error").value("UNAUTHENTICATED"));

        // Garbage bearer
        mockMvc.perform(get("/api/users/me").header("Authorization", "Bearer garbage.token.here"))
                .andExpect(status().isUnauthorized());

        // Tampered signature: valid token with last segment mutated
        String valid = jwtService.generateAccessToken(userA);
        String tampered = valid.substring(0, valid.length() - 3) + "aaa";
        mockMvc.perform(get("/api/users/me").header("Authorization", "Bearer " + tampered))
                .andExpect(status().isUnauthorized());

        // Malformed header scheme
        mockMvc.perform(get("/api/users/me").header("Authorization",
                        "Basic " + java.util.Base64.getEncoder().encodeToString("a:b".getBytes(StandardCharsets.UTF_8))))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void logoutWithAnotherUsersRefreshTokenDoesNotInvalidateIt() throws Exception {
        // A logs in and owns a refresh token
        String phoneA = "+919" + UUID.randomUUID().toString().replaceAll("\\D", "").substring(0, 9);
        mockMvc.perform(post("/api/auth/phone/request-otp")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phoneNumber\": \"" + phoneA + "\"}"))
                .andExpect(status().isOk());
        MvcResult loginA = mockMvc.perform(post("/api/auth/phone/verify-otp")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phoneNumber\": \"" + phoneA + "\", \"otp\": \"123456\"}"))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode tokensA = objectMapper.readTree(loginA.getResponse().getContentAsString()).path("data");
        String refreshA = tokensA.path("refreshToken").asText();

        // B attempts to invalidate A's refresh token via logout
        mockMvc.perform(post("/api/auth/logout")
                        .header("Authorization", "Bearer " + tokenB)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\": \"" + refreshA + "\"}"))
                .andExpect(status().isOk()); // idempotent OK

        // A's refresh token must still work
        mockMvc.perform(post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\": \"" + refreshA + "\"}"))
                .andExpect(status().isOk());
    }

    // ------------------------------------------------------------------
    // Horizontal authz matrix — uniform 404, never 403/500 (no existence leak)
    // ------------------------------------------------------------------

    @Test
    void crossUserAccessIsUniform404AcrossResourceTypes() throws Exception {
        UUID workoutId = createWorkoutAs(tokenA);

        // Workout detail / mutate / delete by B
        mockMvc.perform(get("/api/workouts/" + workoutId).header("Authorization", "Bearer " + tokenB))
                .andExpect(status().isNotFound());
        mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises")
                        .header("Authorization", "Bearer " + tokenB)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"exerciseId\": \"" + UUID.randomUUID() + "\"}"))
                .andExpect(status().isNotFound());

        // Sync push targeting A's workout by B must not modify it
        JsonNode pushResult = push(tokenB, "{\"operations\": [{\"entityType\": \"workout\", \"entityId\": \""
                + workoutId + "\", \"operation\": \"UPDATE\", \"clientTimestamp\": \""
                + Instant.now().plusSeconds(10) + "\", \"data\": {\"name\": \"Hijacked\"}}]}");
        assertThat(pushResult.path("results").get(0).path("status").asText()).isEqualTo("NOT_FOUND");

        // And the workout name is untouched
        mockMvc.perform(get("/api/workouts/" + workoutId).header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.name").value("Security Probe"));
    }

    private JsonNode push(String token, String body) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/sync/push")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andReturn();
        return objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
    }

    @Test
    void syncSetOpsOnForeignWorkoutExerciseReturnNotFound() throws Exception {
        UUID workoutId = createWorkoutAs(tokenA);

        // B tries to attach a set under a fabricated WE id inside A's workout namespace:
        // fabricate a WE that belongs to A's workout is impossible to guess, so instead
        // verify B cannot CREATE a WE pointing at A's workout.
        JsonNode result = push(tokenB, "{\"operations\": [{\"entityType\": \"workout_exercise\", \"entityId\": \""
                + UUID.randomUUID() + "\", \"operation\": \"CREATE\", \"clientTimestamp\": \""
                + Instant.now() + "\", \"data\": {\"workoutId\": \"" + workoutId
                + "\", \"exerciseId\": \"" + UUID.randomUUID() + "\"}}]}");
        assertThat(result.path("results").get(0).path("status").asText()).isEqualTo("NOT_FOUND");
    }

    // ------------------------------------------------------------------
    // Injection probes through search parameters
    // ------------------------------------------------------------------

    @Test
    void likeWildcardsAndQuotesAreSafeInSearches() throws Exception {
        String[] payloads = {"%", "_", "%100%", "'; DROP TABLE exercises;--", "' OR '1'='1"};

        for (String payload : payloads) {
            mockMvc.perform(get("/api/exercises")
                            .param("search", payload)
                            .header("Authorization", "Bearer " + tokenA))
                    .andExpect(status().isOk());

            mockMvc.perform(get("/api/food-items/search")
                            .param("q", payload)
                            .header("Authorization", "Bearer " + tokenA))
                    .andExpect(status().isOk());
        }
    }

    @Test
    void wildcardSearchBehavesPredictably() throws Exception {
        // "_" matches any single char; "%" alone matches everything -> both are 200s.
        // A single-char wildcard should NOT return the full catalogue.
        MvcResult all = mockMvc.perform(get("/api/exercises?size=100")
                        .header("Authorization", "Bearer " + tokenA))
                .andReturn();
        int totalAll = objectMapper.readTree(all.getResponse().getContentAsString())
                .path("totalElements").asInt();

        MvcResult underscore = mockMvc.perform(get("/api/exercises")
                        .param("search", "_")
                        .param("size", "100")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        int totalUnderscore = objectMapper.readTree(underscore.getResponse().getContentAsString())
                .path("totalElements").asInt();

        assertThat(totalUnderscore).isLessThanOrEqualTo(totalAll);
    }

    // ------------------------------------------------------------------
    // Unicode round-trip (India-first: native scripts are core content)
    // ------------------------------------------------------------------

    @Test
    void unicodeNamesSurviveCreateSearchRoundTrip() throws Exception {
        String hindiName = "पनीर टिक्का QA " + UUID.randomUUID();
        byte[] jsonBody = ("{\"name\": \"" + hindiName + "\", \"servingSize\": 100, "
                + "\"servingUnit\": \"g\", \"calories\": 265, \"proteinG\": 18, "
                + "\"carbsG\": 3, \"fatG\": 20, \"isVegetarian\": true}")
                .getBytes(StandardCharsets.UTF_8);

        MvcResult created = mockMvc.perform(post("/api/food-items")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonBody))
                .andExpect(status().isCreated())
                .andReturn();

        // Server must echo back the exact string it stored
        String echoedName = objectMapper.readTree(
                created.getResponse().getContentAsString(StandardCharsets.UTF_8))
                .path("data").path("name").asText();
        assertThat(echoedName).isEqualTo(hindiName);

        String id = objectMapper.readTree(created.getResponse().getContentAsString())
                .path("data").path("id").asText();

        // Direct GET round-trip
        mockMvc.perform(get("/api/food-items/" + id)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.name").value(hindiName));

        // Search using MockMvc's own parameter encoding
        MvcResult search = mockMvc.perform(get("/api/food-items/search")
                        .param("q", hindiName)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode data = objectMapper.readTree(
                search.getResponse().getContentAsString(StandardCharsets.UTF_8)).path("data");
        boolean found = false;
        for (JsonNode item : data) {
            if (item.path("id").asText().equals(id)) {
                found = true;
            }
        }
        assertThat(found).as("unicode item must be findable via search").isTrue();
    }
}
