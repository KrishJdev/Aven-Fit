package com.avenfit.analytics.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Exercise history per Task 7.1: sets grouped by workout day, best set and
 * daily volume computed over non-warmup completed sets.
 */
public record ExerciseHistoryDto(
        UUID exerciseId,
        String exerciseName,
        List<DayHistory> history
) {

    public record DayHistory(
            LocalDate date,
            List<HistorySetDto> sets,
            HistorySetDto bestSet,
            BigDecimal totalVolumeKg
    ) {
    }

    public record HistorySetDto(BigDecimal weightKg, Integer reps, String setType) {
    }
}
