package com.avenfit.auth.service;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

/**
 * Verifies Google ID tokens against Google's tokeninfo endpoint per
 * DEVELOPMENT_PLAN.md Task 2.2. For production, prefer the Google API client
 * library with local signature verification; the tokeninfo call is acceptable
 * for MVP.
 */
@Service
public class GoogleTokenService {

    private static final Logger log = LoggerFactory.getLogger(GoogleTokenService.class);

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record GoogleUserInfo(String sub, String email, boolean emailVerified, String name) {
    }

    private final RestClient restClient;

    public GoogleTokenService(
            @Value("${avenfit.google.tokeninfo-url:https://oauth2.googleapis.com/tokeninfo}") String tokenInfoUrl
    ) {
        this.restClient = RestClient.builder()
                .baseUrl(tokenInfoUrl)
                .build();
    }

    public GoogleUserInfo verify(String idToken) {
        try {
            GoogleUserInfo info = restClient.get()
                    .uri(uri -> uri.queryParam("id_token", idToken).build())
                    .retrieve()
                    .body(GoogleUserInfo.class);
            if (info == null || info.sub() == null || !info.emailVerified()) {
                throw new AuthenticationServiceException("Google ID token is invalid");
            }
            return info;
        } catch (AuthenticationServiceException e) {
            throw e;
        } catch (Exception e) {
            log.warn("Google token verification failed: {}", e.getMessage());
            throw new AuthenticationServiceException("Google ID token could not be verified", e);
        }
    }
}
