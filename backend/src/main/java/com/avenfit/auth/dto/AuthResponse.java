package com.avenfit.auth.dto;

import com.avenfit.auth.entity.UnitPreference;
import com.avenfit.auth.entity.User;

import java.util.UUID;

/**
 * Token pair + user returned by verify-otp / google per Task 2.2.
 */
public record AuthResponse(
        String accessToken,
        String refreshToken,
        AuthUser user
) {
    public record AuthUser(
            UUID id,
            String phoneNumber,
            String displayName,
            UnitPreference unitPreference
    ) {
        public static AuthUser from(User user) {
            return new AuthUser(
                    user.getId(),
                    user.getPhoneNumber(),
                    user.getDisplayName(),
                    user.getUnitPreference()
            );
        }
    }
}
