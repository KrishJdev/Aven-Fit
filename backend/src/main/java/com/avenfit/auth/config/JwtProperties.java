package com.avenfit.auth.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Bound from application.yml:
 * jwt.secret, jwt.access-token-expiration-ms, jwt.refresh-token-expiration-ms
 */
@ConfigurationProperties(prefix = "jwt")
public record JwtProperties(
        String secret,
        long accessTokenExpirationMs,
        long refreshTokenExpirationMs
) {
}
