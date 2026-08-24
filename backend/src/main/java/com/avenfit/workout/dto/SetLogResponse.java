package com.avenfit.workout.dto;

import com.avenfit.analytics.entity.RecordType;
import com.avenfit.workout.entity.SetType;
import com.avenfit.workout.entity.WorkoutSet;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Response for logging/updating a set, including PR details per Task 4.1.
 */
public record SetLogResponse(
        UUID id,
        Integer position,
        SetType setType,
        BigDecimal weightKg,
        Integer reps,
        BigDecimal rpe,
        boolean isCompleted,
        boolean isPr,
        PrDetails prDetails
) {
    public record PrDetails(RecordType recordType, BigDecimal previousValue, BigDecimal newValue) {
    }

    public static SetLogResponse from(WorkoutSet set, PrDetails prDetails) {
        return new SetLogResponse(
                set.getId(),
                set.getPosition(),
                set.getSetType(),
                set.getWeightKg(),
                set.getReps(),
                set.getRpe(),
                Boolean.TRUE.equals(set.getIsCompleted()),
                Boolean.TRUE.equals(set.getIsPr()),
                prDetails
        );
    }
}
