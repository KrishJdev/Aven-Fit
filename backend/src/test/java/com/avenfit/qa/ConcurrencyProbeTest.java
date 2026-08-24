package com.avenfit.qa;

import com.avenfit.auth.entity.User;
import com.avenfit.auth.repository.RefreshTokenRepository;
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
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Phase 4 QA: concurrency probes.
 *
 * 4.1 Double-refresh race — exactly one concurrent rotation may win.
 * 4.2 Parallel set logging — positions stay unique under contention.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class ConcurrencyProbeTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Autowired
    private ExerciseRepository exerciseRepository;

    private User userA;
    private String tokenA;

    @BeforeAll
    void seed() {
        userA = user("C1");
        tokenA = jwtService.generateAccessToken(userA);
    }

    private User user(String tag) {
        User u = new User();
        u.setPhoneNumber("+9199000" + tag.hashCode() % 100000);
        if (userRepository.findByPhoneNumber(u.getPhoneNumber()).isPresent()) {
            u.setPhoneNumber("+9199001" + tag.hashCode() % 100000);
        }
        u.setDisplayName("User " + tag);
        return userRepository.save(u);
    }

    // ------------------------------------------------------------------
    // 4.1 — refresh rotation race
    // ------------------------------------------------------------------

    @Test
    void concurrentRefreshOfSameTokenHasExactlyOneWinner() throws Exception {
        // Fresh login for an isolated user
        String phone = "+919" + UUID.randomUUID().toString().replaceAll("\\D", "").substring(0, 9);
        mockMvc.perform(post("/api/auth/phone/request-otp")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phoneNumber\": \"" + phone + "\"}"))
                .andExpect(status().isOk());
        MvcResult login = mockMvc.perform(post("/api/auth/phone/verify-otp")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phoneNumber\": \"" + phone + "\", \"otp\": \"123456\"}"))
                .andExpect(status().isOk())
                .andReturn();

        JsonNode tokens = objectMapper.readTree(login.getResponse().getContentAsString()).path("data");
        String sharedRefresh = tokens.path("refreshToken").asText();
        UUID userId = UUID.fromString(tokens.path("user").path("id").asText());

        ExecutorService pool = Executors.newFixedThreadPool(2);
        Callable<Integer> rotate = () -> mockMvc.perform(post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\": \"" + sharedRefresh + "\"}"))
                .andReturn().getResponse().getStatus();
        Future<Integer> first = pool.submit(rotate);
        Future<Integer> second = pool.submit(rotate);
        List<Integer> statuses = List.of(first.get(), second.get());
        pool.shutdown();

        // Exactly one winner; the loser must be 401, never a second 200
        assertThat(statuses).containsExactlyInAnyOrder(200, 401);

        // And the user ends up with exactly one live refresh token row
        long liveTokens = refreshTokenRepository.countByUser_Id(userId);
        assertThat(liveTokens).isEqualTo(1);
    }

    // ------------------------------------------------------------------
    // 4.2 — parallel set logging on one exercise
    // ------------------------------------------------------------------

    @Test
    void parallelSetLoggingKeepsPositionsUniqueWithoutServerErrors() throws Exception {
        Exercise e = new Exercise();
        e.setName("Parallel Log Probe " + UUID.randomUUID());
        e.setCategory(ExerciseCategory.BARBELL);
        e.setEquipment(Equipment.BARBELL);
        e.setIsCustom(false);
        e = exerciseRepository.save(e);

        MvcResult workout = mockMvc.perform(post("/api/workouts")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Race Session\", \"startedAt\": \"" + Instant.now() + "\"}"))
                .andExpect(status().isCreated())
                .andReturn();
        String workoutId = objectMapper.readTree(workout.getResponse().getContentAsString())
                .path("data").path("id").asText();

        MvcResult we = mockMvc.perform(post("/api/workouts/" + workoutId + "/exercises")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"exerciseId\": \"" + e.getId() + "\"}"))
                .andExpect(status().isCreated())
                .andReturn();
        String weId = objectMapper.readTree(we.getResponse().getContentAsString())
                .path("data").path("id").asText();

        int racers = 5;
        ExecutorService pool = Executors.newFixedThreadPool(racers);
        List<Future<Integer>> futures = new ArrayList<>();
        List<String> responseBodies = new ArrayList<>();
        for (int i = 0; i < racers; i++) {
            final int weight = 100 + i;
            futures.add(pool.submit((Callable<Integer>) () -> {
                MvcResult r = mockMvc.perform(
                                post("/api/workouts/" + workoutId + "/exercises/" + weId + "/sets")
                                        .header("Authorization", "Bearer " + tokenA)
                                        .contentType(MediaType.APPLICATION_JSON)
                                        .content("{\"weightKg\": " + weight + ", \"reps\": 5}"))
                        .andReturn();
                synchronized (responseBodies) {
                    responseBodies.add(r.getResponse().getContentAsString());
                }
                return r.getResponse().getStatus();
            }));
        }

        Set<Integer> statuses = new HashSet<>();
        for (Future<Integer> f : futures) {
            statuses.add(f.get());
        }
        pool.shutdown();
        System.out.println("[RACE-DIAG] statuses=" + statuses);
        for (String b : responseBodies) {
            System.out.println("[RACE-DIAG] body=" + b.substring(0, Math.min(160, b.length())));
        }

        // No server errors under contention — every racer either logged or got
        // a graceful client-level rejection, never a 500.
        assertThat(statuses).doesNotContain(500);

        // Every successful log carries a unique position
        Set<Integer> positions = new HashSet<>();
        int successCount = 0;
        for (String body : responseBodies) {
            if (!body.isBlank() && body.contains("\"position\"")) {
                JsonNode data = objectMapper.readTree(body).path("data");
                positions.add(data.path("position").asInt());
                successCount++;
            }
        }
        assertThat(successCount).isEqualTo(racers);
        assertThat(positions).hasSize(racers); // all distinct
    }
}
