package com.avenfit.workout.repository;

import com.avenfit.workout.entity.Workout;
import com.avenfit.workout.entity.WorkoutStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface WorkoutRepository extends JpaRepository<Workout, UUID> {

    Optional<Workout> findByIdAndUserId(UUID id, UUID userId);

    Page<Workout> findByUserIdOrderByStartedAtDesc(UUID userId, Pageable pageable);

    Page<Workout> findByUserIdAndStatusOrderByStartedAtDesc(UUID userId, WorkoutStatus status, Pageable pageable);

    List<Workout> findByUserIdAndStartedAtBetween(UUID userId, Instant start, Instant end);

    /**
     * The single in-progress workout for a user (at most one active session).
     */
    Optional<Workout> findFirstByUserIdAndStatus(UUID userId, WorkoutStatus status);

    /**
     * Aggregate projection for history summaries — avoids N+1 counting.
     * setCount counts completed sets; volume counts completed sets only.
     */
    @Query("""
            select we.workout.id as workoutId,
                   count(distinct we.id) as exerciseCount,
                   count(case when s.isCompleted then 1 end) as setCount,
                   coalesce(sum(case when s.isCompleted
                                     then coalesce(s.weightKg, 0) * coalesce(s.reps, 0)
                                     else 0 end), 0) as totalVolumeKg,
                   count(distinct case when s.isPr then s.id end) as prCount
            from WorkoutExercise we
            left join we.sets s
            where we.workout.id in :workoutIds
            group by we.workout.id
            """)
    List<WorkoutSummaryRow> summarize(@Param("workoutIds") List<UUID> workoutIds);

    interface WorkoutSummaryRow {
        UUID getWorkoutId();

        long getExerciseCount();

        long getSetCount();

        BigDecimal getTotalVolumeKg();

        long getPrCount();
    }
}
