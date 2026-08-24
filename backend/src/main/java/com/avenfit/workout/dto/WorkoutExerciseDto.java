package com.avenfit.workout.dto;

import com.avenfit.exercise.entity.Exercise;
import com.avenfit.workout.entity.WorkoutExercise;

import java.util.List;
import java.util.UUID;

public record WorkoutExerciseDto(
        UUID id,
        UUID exerciseId,
        String exerciseName,
        Integer position,
        Integer restSeconds,
        List<WorkoutSetDto> sets
) {
    public static WorkoutExerciseDto from(WorkoutExercise we) {
        Exercise exercise = we.getExercise();
        return new WorkoutExerciseDto(
                we.getId(),
                exercise.getId(),
                exercise.getName(),
                we.getPosition(),
                we.getRestSeconds(),
                we.getSets().stream().map(WorkoutSetDto::from).toList()
        );
    }

    public static WorkoutExerciseDto emptySets(WorkoutExercise we) {
        return new WorkoutExerciseDto(
                we.getId(),
                we.getExercise().getId(),
                we.getExercise().getName(),
                we.getPosition(),
                we.getRestSeconds(),
                List.of()
        );
    }
}
