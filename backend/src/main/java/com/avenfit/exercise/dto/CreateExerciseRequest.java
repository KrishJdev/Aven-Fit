package com.avenfit.exercise.dto;

import com.avenfit.exercise.entity.Equipment;
import com.avenfit.exercise.entity.ExerciseCategory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;
import java.util.UUID;

/**
 * Used by both POST and PUT /api/exercises (full replace on update).
 */
public record CreateExerciseRequest(
        @NotBlank(message = "name is required")
        @Size(max = 200, message = "name must be at most 200 characters")
        String name,

        @Size(max = 5000, message = "description must be at most 5000 characters")
        String description,

        @NotNull(message = "category is required")
        ExerciseCategory category,

        @NotNull(message = "equipment is required")
        Equipment equipment,

        @NotEmpty(message = "at least one primary muscle group is required")
        List<UUID> primaryMuscleGroupIds,

        List<UUID> secondaryMuscleGroupIds
) {
}
