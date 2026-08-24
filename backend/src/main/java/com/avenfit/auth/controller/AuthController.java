package com.avenfit.auth.controller;

import com.avenfit.auth.dto.AuthResponse;
import com.avenfit.auth.dto.GoogleAuthRequest;
import com.avenfit.auth.dto.OtpRequest;
import com.avenfit.auth.dto.RefreshTokenRequest;
import com.avenfit.auth.entity.User;
import com.avenfit.auth.service.AuthService;
import com.avenfit.auth.service.OtpService;
import com.avenfit.common.dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/phone/request-otp")
    public ResponseEntity<ApiResponse<Map<String, Object>>> requestOtp(@Valid @RequestBody OtpRequest request) {
        authService.requestOtp(request.phoneNumber());
        return ResponseEntity.ok(ApiResponse.of(
                Map.of(
                        "message", "OTP sent",
                        "expiresInSeconds", OtpService.OTP_EXPIRES_IN_SECONDS
                ),
                "OK"
        ));
    }

    @PostMapping("/phone/verify-otp")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyOtp(@Valid @RequestBody OtpRequest request) {
        AuthResponse response = authService.verifyOtp(request.phoneNumber(), request.otp());
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @PostMapping("/google")
    public ResponseEntity<ApiResponse<AuthResponse>> signInWithGoogle(@Valid @RequestBody GoogleAuthRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(authService.signInWithGoogle(request.idToken())));
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(authService.refresh(request.refreshToken())));
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody RefreshTokenRequest request
    ) {
        authService.logout(currentUser, request.refreshToken());
        return ResponseEntity.ok().build();
    }
}
