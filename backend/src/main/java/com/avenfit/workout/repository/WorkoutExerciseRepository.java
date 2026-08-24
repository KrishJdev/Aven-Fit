package com.avenfit.workout.repository;

import com.avenfit.workout.entity.WorkoutExercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface WorkoutExerciseRepository extends JpaRepository<WorkoutExercise, UUID> {

    List<WorkoutExercise> findByWorkoutIdOrderByPositionAsc(UUID workoutId);

    Optional<WorkoutExercise> findByIdAndWorkoutId(UUID id, UUID workoutId);

    @Query("select coalesce(max(we.position), 0) from WorkoutExercise we where we.workout.id = :workoutId")
    int findNextPosition(@Param("workoutId") UUID workoutId);

    /**
     * Detail fetch: exercise + sets in one query (single bag per query —
     * fetching Workout.exercises and sets together is a MultipleBagFetch).
     */
    @Query("""
            select distinct we from WorkoutExercise we
            join fetch we.exercise
            left join fetch we.sets
            where we.workout.id = :workoutId
            order by we.position asc
            """)
    List<WorkoutExercise> findWithSetsByWorkoutId(@Param("workoutId") UUID workoutId);
}
