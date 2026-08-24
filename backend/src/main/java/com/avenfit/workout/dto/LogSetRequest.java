package com.avenfit.workout.dto;

import com.avenfit.workout.entity.SetType;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.PositiveOrZero;

import java.math.BigDecimal;

/**
 * All load fields optional (bodyweight sets carry reps only). setType
 * defaults to NORMAL when omitted.
 */
public record LogSetRequest(
        SetType setType,

        @PositiveOrZero(message = "weightKg must not be negative")
        @DecimalMax(value = "9999.99", message = "weightKg must be realistic")
        BigDecimal weightKg,

        @PositiveOrZero(message = "reps must not be negative")
        Integer reps,

        @DecimalMin(value = "1.0", message = "rpe must be between 1 and 10")
        @DecimalMax(value = "10.0", message = "rpe must be between 1 and 10")
        BigDecimal rpe
) {
}
