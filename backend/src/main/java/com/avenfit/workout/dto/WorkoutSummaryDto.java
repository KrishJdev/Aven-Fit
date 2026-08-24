package com.avenfit.workout.dto;

import com.avenfit.workout.entity.Workout;
import com.avenfit.workout.entity.WorkoutStatus;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * History row per Task 4.1 GET /api/workouts example.
 */
public record WorkoutSummaryDto(
        UUID id,
        String name,
        WorkoutStatus status,
        Instant startedAt,
        Instant completedAt,
        Integer durationSeconds,
        long exerciseCount,
        long setCount,
        BigDecimal totalVolumeKg,
        long prCount
) {
    public static WorkoutSummaryDto of(Workout w, long exerciseCount, long setCount,
                                       BigDecimal totalVolumeKg, long prCount) {
        return new WorkoutSummaryDto(
                w.getId(),
                w.getName(),
                w.getStatus(),
                w.getStartedAt(),
                w.getCompletedAt(),
                w.getDurationSeconds(),
                exerciseCount,
                setCount,
                totalVolumeKg,
                prCount
        );
    }
}
