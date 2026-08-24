package com.avenfit.workout.dto;

import com.avenfit.workout.entity.Workout;
import com.avenfit.workout.entity.WorkoutStatus;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Full workout detail per Task 4.1 response example.
 */
public record WorkoutDto(
        UUID id,
        String name,
        WorkoutStatus status,
        Instant startedAt,
        Instant completedAt,
        String notes,
        List<WorkoutExerciseDto> exercises
) {
    public static WorkoutDto from(Workout workout) {
        return from(workout, workout.getExercises());
    }

    public static WorkoutDto from(Workout workout, List<com.avenfit.workout.entity.WorkoutExercise> exercises) {
        return new WorkoutDto(
                workout.getId(),
                workout.getName(),
                workout.getStatus(),
                workout.getStartedAt(),
                workout.getCompletedAt(),
                workout.getNotes(),
                exercises.stream().map(WorkoutExerciseDto::from).toList()
        );
    }
}
