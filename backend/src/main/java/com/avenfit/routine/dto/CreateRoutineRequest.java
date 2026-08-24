package com.avenfit.routine.dto;

import com.avenfit.workout.entity.SetType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

/**
 * Used by POST and PUT (full replace) per Task 5.1.
 */
public record CreateRoutineRequest(
        @NotBlank(message = "name is required")
        @Size(max = 200, message = "name must be at most 200 characters")
        String name,

        @Size(max = 2000, message = "description must be at most 2000 characters")
        String description,

        @Valid
        List<RoutineExerciseRequest> exercises
) {

    public record RoutineExerciseRequest(
            @NotNull(message = "exerciseId is required")
            UUID exerciseId,

            @NotNull(message = "position is required")
            @Positive(message = "position must be a positive integer")
            Integer position,

            @Positive(message = "restSeconds must be positive")
            Integer restSeconds,

            @Size(max = 2000, message = "notes must be at most 2000 characters")
            String notes,

            @Valid
            List<RoutineSetRequest> sets
    ) {
    }

    public record RoutineSetRequest(
            @NotNull(message = "position is required")
            @Positive(message = "position must be a positive integer")
            Integer position,

            SetType setType,

            @PositiveOrZero(message = "targetReps must not be negative")
            Integer targetReps,

            @DecimalMin(value = "0", message = "targetWeightKg must not be negative")
            @DecimalMax(value = "9999.99", message = "targetWeightKg must be realistic")
            BigDecimal targetWeightKg,

            @DecimalMin(value = "1.0", message = "targetRpe must be between 1 and 10")
            @DecimalMax(value = "10.0", message = "targetRpe must be between 1 and 10")
            BigDecimal targetRpe
    ) {
    }
}
