package com.avenfit.auth.service;

import com.avenfit.auth.config.JwtProperties;
import com.avenfit.auth.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;

@Service
public class JwtService {

    private final SecretKey signingKey;
    private final long accessTokenExpirationMs;
    private final long refreshTokenExpirationMs;

    public JwtService(JwtProperties properties) {
        this.signingKey = Keys.hmacShaKeyFor(properties.secret().getBytes(StandardCharsets.UTF_8));
        this.accessTokenExpirationMs = properties.accessTokenExpirationMs();
        this.refreshTokenExpirationMs = properties.refreshTokenExpirationMs();
    }

    public String generateAccessToken(User user) {
        return buildToken(user, accessTokenExpirationMs);
    }

    public String generateRefreshToken(User user) {
        return buildToken(user, refreshTokenExpirationMs);
    }

    /**
     * Extracts the subject (user id) from a token with a verified signature.
     * Throws JwtException if the token is invalid or expired.
     */
    public UUID extractUserId(String token) {
        Claims claims = parseClaims(token);
        return UUID.fromString(claims.getSubject());
    }

    /**
     * True only when the signature is valid and the token has not expired.
     */
    public boolean isTokenValid(String token) {
        try {
            parseClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    public Instant extractExpiration(String token) {
        return parseClaims(token).getExpiration().toInstant();
    }

    public long getRefreshTokenExpirationMs() {
        return refreshTokenExpirationMs;
    }

    private String buildToken(User user, long expirationMs) {
        Instant now = Instant.now();
        return Jwts.builder()
                .subject(user.getId().toString())
                .id(UUID.randomUUID().toString())
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusMillis(expirationMs)))
                .signWith(signingKey)
                .compact();
    }

    private Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(signingKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
