package com.avenfit.routine.dto;

import java.time.Instant;
import java.util.UUID;

/**
 * List row per Task 5.1: { id, name, description, exerciseCount, createdAt }.
 */
public record RoutineDto(
        UUID id,
        String name,
        String description,
        long exerciseCount,
        Instant createdAt
) {
}
