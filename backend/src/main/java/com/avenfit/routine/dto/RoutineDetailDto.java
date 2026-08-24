package com.avenfit.routine.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Detail shape per Task 5.1 example: exercises carry ids and names, sets
 * carry { position, setType, targetReps, targetWeightKg } (no set ids —
 * exactly as specified).
 */
public record RoutineDetailDto(
        UUID id,
        String name,
        String description,
        Instant createdAt,
        Instant updatedAt,
        List<RoutineExerciseDto> exercises
) {

    public record RoutineExerciseDto(
            UUID id,
            UUID exerciseId,
            String exerciseName,
            Integer position,
            Integer restSeconds,
            List<RoutineSetDto> sets
    ) {
    }

    public record RoutineSetDto(
            Integer position,
            String setType,
            Integer targetReps,
            BigDecimal targetWeightKg
    ) {
    }
}
