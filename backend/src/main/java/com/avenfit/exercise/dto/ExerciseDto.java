package com.avenfit.exercise.dto;

import com.avenfit.exercise.entity.Equipment;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.exercise.entity.ExerciseCategory;
import com.avenfit.exercise.entity.ExerciseMuscleGroup;
import com.avenfit.exercise.entity.MuscleRole;

import java.util.Comparator;
import java.util.List;
import java.util.UUID;

/**
 * Exercise shape per DEVELOPMENT_PLAN.md Task 3.1 response examples:
 * muscleGroups is [{name, role}], primaries first.
 */
public record ExerciseDto(
        UUID id,
        String name,
        String description,
        ExerciseCategory category,
        Equipment equipment,
        boolean isCustom,
        List<MuscleGroupRef> muscleGroups
) {

    public record MuscleGroupRef(String name, MuscleRole role) {
    }

    public static ExerciseDto from(Exercise exercise) {
        List<MuscleGroupRef> refs = exercise.getMuscleGroups().stream()
                .sorted(Comparator
                        .comparing((ExerciseMuscleGroup emg) -> emg.getRole())
                        .thenComparing(emg -> emg.getMuscleGroup().getDisplayOrder()))
                .map(emg -> new MuscleGroupRef(emg.getMuscleGroup().getName(), emg.getRole()))
                .toList();
        return new ExerciseDto(
                exercise.getId(),
                exercise.getName(),
                exercise.getDescription(),
                exercise.getCategory(),
                exercise.getEquipment(),
                Boolean.TRUE.equals(exercise.getIsCustom()),
                refs
        );
    }
}
