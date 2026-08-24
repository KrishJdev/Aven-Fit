package com.avenfit.analytics.dto;

import java.math.BigDecimal;
import java.util.List;

/**
 * Windowed summary per Task 7.1 GET /api/analytics/summary.
 */
public record SummaryDto(
        String period,
        long totalWorkouts,
        long totalSets,
        BigDecimal totalVolumeKg,
        long totalDurationMinutes,
        long avgWorkoutDurationMinutes,
        List<MuscleGroupVolume> muscleGroupVolume,
        long newPRs
) {

    public record MuscleGroupVolume(String muscleGroup, BigDecimal volumeKg, long sets) {
    }
}
