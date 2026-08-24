package com.avenfit.user.dto;

import com.avenfit.auth.entity.UnitPreference;
import com.avenfit.auth.entity.User;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

/**
 * Public profile shape per DEVELOPMENT_PLAN.md Task 2.3.
 */
public record UserProfileDto(
        UUID id,
        String phoneNumber,
        String email,
        String displayName,
        String avatarUrl,
        BigDecimal heightCm,
        BigDecimal weightKg,
        LocalDate dateOfBirth,
        String gender,
        UnitPreference unitPreference,
        Instant createdAt
) {
    public static UserProfileDto from(User user) {
        return new UserProfileDto(
                user.getId(),
                user.getPhoneNumber(),
                user.getEmail(),
                user.getDisplayName(),
                user.getAvatarUrl(),
                user.getHeightCm(),
                user.getWeightKg(),
                user.getDateOfBirth(),
                user.getGender() == null ? null : user.getGender().name(),
                user.getUnitPreference(),
                user.getCreatedAt()
        );
    }
}
