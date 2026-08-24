package com.avenfit.workout.repository;

import com.avenfit.workout.entity.WorkoutSet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface WorkoutSetRepository extends JpaRepository<WorkoutSet, UUID> {

    List<WorkoutSet> findByWorkoutExerciseIdOrderByPositionAsc(UUID workoutExerciseId);

    Optional<WorkoutSet> findByIdAndWorkoutExerciseId(UUID id, UUID workoutExerciseId);

    @Query("select coalesce(max(s.position), 0) from WorkoutSet s where s.workoutExercise.id = :workoutExerciseId")
    int findNextPosition(@Param("workoutExerciseId") UUID workoutExerciseId);

    /**
     * Completed sets for an exercise belonging to a user's workouts,
     * newest first — used by PR detection and exercise history.
     */
    @Query("""
            select s from WorkoutSet s
            join s.workoutExercise we
            join we.workout w
            where w.user.id = :userId
              and we.exercise.id = :exerciseId
              and s.isCompleted = true
            order by s.completedAt desc
            """)
    List<WorkoutSet> findCompletedSetsForExercise(
            @Param("userId") UUID userId,
            @Param("exerciseId") UUID exerciseId);
}
