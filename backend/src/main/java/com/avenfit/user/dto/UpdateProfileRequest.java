package com.avenfit.user.dto;

import com.avenfit.auth.entity.Gender;
import com.avenfit.auth.entity.UnitPreference;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * All fields optional — only provided fields are updated (Task 2.3).
 */
public record UpdateProfileRequest(
        @Size(min = 1, max = 100, message = "displayName must be 1-100 characters")
        String displayName,

        @DecimalMin(value = "0", message = "heightCm must be positive")
        @DecimalMax(value = "300", message = "heightCm must be realistic")
        BigDecimal heightCm,

        @DecimalMin(value = "0", message = "weightKg must be positive")
        @DecimalMax(value = "500", message = "weightKg must be realistic")
        BigDecimal weightKg,

        LocalDate dateOfBirth,

        Gender gender,

        UnitPreference unitPreference
) {
}
