package com.avenfit.sync.dto;

import com.avenfit.exercise.dto.ExerciseDto;
import com.avenfit.routine.dto.RoutineDetailDto;
import com.avenfit.workout.dto.WorkoutDto;

import java.time.Instant;
import java.util.List;

/**
 * Pull payload per Task 9.1: everything the user changed on the server since
 * their last sync point. Workouts carry full exercise/set graphs; routines
 * carry full templates.
 */
public record SyncPullResponse(
        List<ExerciseDto> exercises,
        List<WorkoutDto> workouts,
        List<RoutineDetailDto> routines,
        List<com.avenfit.nutrition.dto.FoodItemDto> foodItems,
        Instant lastSyncTimestamp
) {
}
