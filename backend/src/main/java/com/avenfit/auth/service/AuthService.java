package com.avenfit.auth.service;

import com.avenfit.auth.dto.AuthResponse;
import com.avenfit.auth.entity.RefreshToken;
import com.avenfit.auth.entity.User;
import com.avenfit.auth.repository.RefreshTokenRepository;
import com.avenfit.auth.repository.UserRepository;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtService jwtService;
    private final OtpService otpService;
    private final GoogleTokenService googleTokenService;

    public AuthService(
            UserRepository userRepository,
            RefreshTokenRepository refreshTokenRepository,
            JwtService jwtService,
            OtpService otpService,
            GoogleTokenService googleTokenService
    ) {
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.jwtService = jwtService;
        this.otpService = otpService;
        this.googleTokenService = googleTokenService;
    }

    public void requestOtp(String phoneNumber) {
        otpService.sendOtp(phoneNumber);
    }

    @Transactional
    public AuthResponse verifyOtp(String phoneNumber, String otp) {
        if (!otpService.verifyOtp(phoneNumber, otp)) {
            throw new BadCredentialsException("Invalid OTP");
        }
        User user = userRepository.findByPhoneNumber(phoneNumber)
                .orElseGet(() -> createPhoneUser(phoneNumber));
        return issueTokens(user);
    }

    @Transactional
    public AuthResponse signInWithGoogle(String idToken) {
        GoogleTokenService.GoogleUserInfo info = googleTokenService.verify(idToken);
        User user = userRepository.findByGoogleId(info.sub())
                .or(() -> userRepository.findByEmail(info.email()))
                .orElseGet(() -> createGoogleUser(info));

        // Link a pre-existing phone-only account to this Google identity.
        if (user.getGoogleId() == null) {
            user.setGoogleId(info.sub());
        }
        return issueTokens(userRepository.save(user));
    }

    @Transactional
    public AuthResponse refresh(String refreshToken) {
        RefreshToken stored = refreshTokenRepository.findByToken(refreshToken)
                .orElseThrow(() -> badRefreshToken());
        if (stored.getExpiresAt().isBefore(Instant.now()) || !jwtService.isTokenValid(refreshToken)) {
            refreshTokenRepository.delete(stored);
            throw badRefreshToken();
        }
        User user = stored.getUser();
        refreshTokenRepository.delete(stored);
        return issueTokens(user);
    }

    /**
     * Deletes the given refresh token when it belongs to the authenticated
     * user. Idempotent — always returns normally.
     */
    @Transactional
    public void logout(User currentUser, String refreshToken) {
        refreshTokenRepository.findByToken(refreshToken).ifPresent(stored -> {
            if (currentUser.getId().equals(stored.getUser().getId())) {
                refreshTokenRepository.delete(stored);
            }
        });
    }

    private AuthResponse issueTokens(User user) {
        String accessToken = jwtService.generateAccessToken(user);
        String refreshTokenValue = jwtService.generateRefreshToken(user);

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setUser(user);
        refreshToken.setToken(refreshTokenValue);
        refreshToken.setExpiresAt(Instant.now().plusMillis(jwtService.getRefreshTokenExpirationMs()));
        refreshTokenRepository.save(refreshToken);

        return new AuthResponse(accessToken, refreshTokenValue, AuthResponse.AuthUser.from(user));
    }

    private User createPhoneUser(String phoneNumber) {
        User user = new User();
        user.setPhoneNumber(phoneNumber);
        user.setDisplayName("Gym User");
        return userRepository.save(user);
    }

    private User createGoogleUser(GoogleTokenService.GoogleUserInfo info) {
        User user = new User();
        user.setGoogleId(info.sub());
        user.setEmail(info.email());
        user.setDisplayName(info.name() == null || info.name().isBlank() ? "Gym User" : info.name());
        return userRepository.save(user);
    }

    private AuthenticationException badRefreshToken() {
        return new BadCredentialsException("Invalid or expired refresh token");
    }
}
