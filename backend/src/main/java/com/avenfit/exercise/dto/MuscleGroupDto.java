package com.avenfit.exercise.dto;

import com.avenfit.exercise.entity.MuscleGroup;

import java.util.UUID;

/**
 * Shape per Task 3.1: { id, name, displayOrder }.
 */
public record MuscleGroupDto(UUID id, String name, int displayOrder) {

    public static MuscleGroupDto from(MuscleGroup muscleGroup) {
        return new MuscleGroupDto(muscleGroup.getId(), muscleGroup.getName(), muscleGroup.getDisplayOrder());
    }
}
