package com.avenfit.workout.dto;

import com.avenfit.workout.entity.SetType;
import com.avenfit.workout.entity.WorkoutSet;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Set node used inside workout detail responses.
 */
public record WorkoutSetDto(
        UUID id,
        Integer position,
        SetType setType,
        BigDecimal weightKg,
        Integer reps,
        BigDecimal rpe,
        boolean isCompleted,
        Instant completedAt,
        boolean isPr
) {
    public static WorkoutSetDto from(WorkoutSet set) {
        return new WorkoutSetDto(
                set.getId(),
                set.getPosition(),
                set.getSetType(),
                set.getWeightKg(),
                set.getReps(),
                set.getRpe(),
                Boolean.TRUE.equals(set.getIsCompleted()),
                set.getCompletedAt(),
                Boolean.TRUE.equals(set.getIsPr())
        );
    }
}
