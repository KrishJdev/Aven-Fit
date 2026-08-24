package com.avenfit.auth.service;

import com.avenfit.auth.config.JwtProperties;
import com.avenfit.auth.entity.User;
import io.jsonwebtoken.JwtException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class JwtServiceTest {

    private JwtService jwtService;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService(new JwtProperties(
                "unit-test-secret-key-for-hs256-must-be-at-least-256-bits-long-0123456789abcdef",
                900_000L,
                2_592_000_000L
        ));
    }

    private User user() {
        User user = new User();
        user.setId(UUID.randomUUID());
        user.setDisplayName("Test User");
        return user;
    }

    @Test
    void accessTokenRoundTrip() {
        User user = user();
        String token = jwtService.generateAccessToken(user);

        assertThat(jwtService.isTokenValid(token)).isTrue();
        assertThat(jwtService.extractUserId(token)).isEqualTo(user.getId());
    }

    @Test
    void refreshTokenRoundTrip() {
        User user = user();
        String token = jwtService.generateRefreshToken(user);

        assertThat(jwtService.isTokenValid(token)).isTrue();
        assertThat(jwtService.extractUserId(token)).isEqualTo(user.getId());
    }

    @Test
    void tamperedTokenIsInvalid() {
        String token = jwtService.generateAccessToken(user());
        String tampered = token.substring(0, token.length() - 4) + "AAAA";

        assertThat(jwtService.isTokenValid(tampered)).isFalse();
        assertThatThrownBy(() -> jwtService.extractUserId(tampered)).isInstanceOf(JwtException.class);
    }

    @Test
    void garbageStringIsInvalid() {
        assertThat(jwtService.isTokenValid("not-a-jwt")).isFalse();
    }

    @Test
    void expiredTokenIsInvalid() {
        JwtService expiredService = new JwtService(new JwtProperties(
                "unit-test-secret-key-for-hs256-must-be-at-least-256-bits-long-0123456789abcdef",
                -1_000L,
                2_592_000_000L
        ));
        String token = expiredService.generateAccessToken(user());

        assertThat(expiredService.isTokenValid(token)).isFalse();
        assertThatThrownBy(() -> expiredService.extractUserId(token)).isInstanceOf(JwtException.class);
    }
}
