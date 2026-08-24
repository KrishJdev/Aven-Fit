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

    // ------------------------------------------------------------------
    // Analytics (Step 7)
    // ------------------------------------------------------------------

    List<Workout> findByUserIdAndStatusAndStartedAtAfter(UUID userId, WorkoutStatus status, Instant since);

    /** Sync pull: user's workouts modified since the given instant. */
    List<Workout> findByUserIdAndUpdatedAtAfterOrderByUpdatedAtAsc(UUID userId, Instant since);

    /**
     * Pessimistic write lock used to serialize position assignment when
     * exercises are added to the same workout concurrently.
     */
    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query(
            "select w from Workout w where w.id = :id")
    Optional<Workout> findByIdForUpdate(@Param("id") UUID id);

    @Query("""
            select count(w.id) as totalWorkouts,
                   coalesce(sum(w.durationSeconds), 0) as totalDurationSeconds
            from Workout w
            where w.user.id = :userId
              and w.status = com.avenfit.workout.entity.WorkoutStatus.COMPLETED
              and w.startedAt >= :since
            """)
    WorkoutTotalsRow totalsSince(@Param("userId") UUID userId, @Param("since") Instant since);

    interface WorkoutTotalsRow {
        long getTotalWorkouts();

        long getTotalDurationSeconds();
    }

    /**
     * Completed-set aggregates for completed workouts inside an analytics
     * window. Warmup sets are excluded from setCount/volume for consistency
     * with the PR engine and the muscle-group breakdown.
     */
    @Query("""
            select count(distinct we.workout.id) as totalWorkouts,
                   count(case when s.isCompleted
                                and s.setType <> com.avenfit.workout.entity.SetType.WARMUP
                              then 1 end) as totalSets,
                   coalesce(sum(case when s.isCompleted
                                       and s.setType <> com.avenfit.workout.entity.SetType.WARMUP
                                     then coalesce(s.weightKg, 0) * coalesce(s.reps, 0)
                                     else 0 end), 0) as totalVolumeKg
            from WorkoutExercise we
            left join we.sets s
            where we.workout.user.id = :userId
              and we.workout.status = com.avenfit.workout.entity.WorkoutStatus.COMPLETED
              and we.workout.startedAt >= :since
            """)
    SetTotalsRow setTotalsSince(@Param("userId") UUID userId, @Param("since") Instant since);

    interface SetTotalsRow {
        long getTotalWorkouts();

        long getTotalSets();

        BigDecimal getTotalVolumeKg();
    }

    /**
     * Volume attributed to PRIMARY muscle groups only (no double counting);
     * warmup sets excluded from volume and counts for consistency with the
     * PR engine.
     */
    @Query("""
            select mg.name as muscleGroup,
                   coalesce(sum(case when s.isCompleted and s.setType <> com.avenfit.workout.entity.SetType.WARMUP
                                     then coalesce(s.weightKg, 0) * coalesce(s.reps, 0)
                                     else 0 end), 0) as volumeKg,
                   count(case when s.isCompleted and s.setType <> com.avenfit.workout.entity.SetType.WARMUP
                              then 1 end) as sets
            from WorkoutExercise we
            join we.exercise e
            join e.muscleGroups emg
            join emg.muscleGroup mg
            left join we.sets s
            where we.workout.user.id = :userId
              and we.workout.status = com.avenfit.workout.entity.WorkoutStatus.COMPLETED
              and we.workout.startedAt >= :since
              and emg.role = com.avenfit.exercise.entity.MuscleRole.PRIMARY
              and s.id is not null
            group by mg.name
            order by volumeKg desc
            """)
    List<MuscleGroupVolumeRow> muscleGroupVolumeSince(@Param("userId") UUID userId,
                                                      @Param("since") Instant since);

    interface MuscleGroupVolumeRow {
        String getMuscleGroup();

        BigDecimal getVolumeKg();

        long getSets();
    }

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
