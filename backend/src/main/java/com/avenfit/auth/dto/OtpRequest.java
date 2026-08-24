package com.avenfit.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/**
 * Used by both phone auth endpoints:
 * request-otp requires phoneNumber; verify-otp additionally requires otp.
 */
public record OtpRequest(
        @NotBlank(message = "phoneNumber is required")
        @Pattern(regexp = "^\\+?[0-9]{10,15}$", message = "phoneNumber must be 10-15 digits, optionally prefixed with +")
        String phoneNumber,

        @Pattern(regexp = "^[0-9]{6}$", message = "otp must be exactly 6 digits")
        String otp
) {
}
