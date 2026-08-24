package com.avenfit.auth;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

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
class AuthFlowIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private String uniquePhone() {
        return "+919" + UUID.randomUUID().toString().replaceAll("\\D", "").substring(0, 9);
    }

    private AuthTokens signIn(String phoneNumber) throws Exception {
        mockMvc.perform(post("/api/auth/phone/request-otp")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phoneNumber\": \"%s\"}".formatted(phoneNumber)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.message").value("OTP sent"))
                .andExpect(jsonPath("$.data.expiresInSeconds").value(300));

        MvcResult result = mockMvc.perform(post("/api/auth/phone/verify-otp")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phoneNumber\": \"%s\", \"otp\": \"123456\"}".formatted(phoneNumber)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.user.displayName").value("Gym User"))
                .andReturn();

        JsonNode body = objectMapper.readTree(result.getResponse().getContentAsString());
        return new AuthTokens(
                body.path("data").path("accessToken").asText(),
                body.path("data").path("refreshToken").asText(),
                body.path("data").path("user").path("id").asText()
        );
    }

    private record AuthTokens(String accessToken, String refreshToken, String userId) {
    }

    @Test
    void wrongOtpIsRejectedWith401() throws Exception {
        mockMvc.perform(post("/api/auth/phone/verify-otp")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phoneNumber\": \"%s\", \"otp\": \"999999\"}".formatted(uniquePhone())))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.error").value("UNAUTHENTICATED"));
    }

    @Test
    void malformedPhoneIsRejectedWith400() throws Exception {
        mockMvc.perform(post("/api/auth/phone/request-otp")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phoneNumber\": \"not-a-phone\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
    }

    @Test
    void unauthenticatedRequestGets401FromRealFilterChain() throws Exception {
        mockMvc.perform(get("/api/users/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.error").value("UNAUTHENTICATED"));
    }

    @Test
    void fullFlowOtpVerifyMeUpdateRefreshLogout() throws Exception {
        String phone = uniquePhone();
        AuthTokens tokens = signIn(phone);

        // Profile is readable with the access token
        mockMvc.perform(get("/api/users/me")
                        .header("Authorization", "Bearer " + tokens.accessToken()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.phoneNumber").value(phone))
                .andExpect(jsonPath("$.data.unitPreference").value("METRIC"));

        // Partial update applies only provided fields
        mockMvc.perform(put("/api/users/me")
                        .header("Authorization", "Bearer " + tokens.accessToken())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"displayName": "Krish", "heightCm": 175.0, "weightKg": 72.5}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.displayName").value("Krish"))
                .andExpect(jsonPath("$.data.heightCm").value(175.0))
                .andExpect(jsonPath("$.data.weightKg").value(72.5));

        // Refresh rotates the token pair
        MvcResult refreshResult = mockMvc.perform(post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\": \"%s\"}".formatted(tokens.refreshToken())))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode refreshBody = objectMapper.readTree(refreshResult.getResponse().getContentAsString());
        String newAccessToken = refreshBody.path("data").path("accessToken").asText();
        String newRefreshToken = refreshBody.path("data").path("refreshToken").asText();
        assertThat(newAccessToken).isNotBlank();
        assertThat(newRefreshToken).isNotEqualTo(tokens.refreshToken());

        // Old refresh token can no longer be used
        mockMvc.perform(post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\": \"%s\"}".formatted(tokens.refreshToken())))
                .andExpect(status().isUnauthorized());

        // Logout invalidates the current refresh token
        mockMvc.perform(post("/api/auth/logout")
                        .header("Authorization", "Bearer " + newAccessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\": \"%s\"}".formatted(newRefreshToken)))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\": \"%s\"}".formatted(newRefreshToken)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void existingUserLogsInAgainWithoutDuplicate() throws Exception {
        String phone = uniquePhone();
        AuthTokens first = signIn(phone);
        AuthTokens second = signIn(phone);

        assertThat(second.userId()).isEqualTo(first.userId());
    }
}
