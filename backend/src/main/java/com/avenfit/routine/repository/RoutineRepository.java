package com.avenfit.routine.repository;

import com.avenfit.routine.entity.Routine;
import com.avenfit.routine.entity.RoutineExercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface RoutineRepository extends JpaRepository<Routine, UUID> {

    List<Routine> findByUserIdOrderByUpdatedAtDesc(UUID userId);

    /** Sync pull: user's routines modified since the given instant. */
    List<Routine> findByUserIdAndUpdatedAtAfterOrderByUpdatedAtAsc(UUID userId, java.time.Instant since);

    Optional<Routine> findByIdAndUserId(UUID id, UUID userId);

    /**
     * Detail fetch: exercise + default sets in one query (single bag per
     * query — fetching Routine.exercises and sets together triggers a
     * MultipleBagFetchException).
     */
    @Query("""
            select distinct re from RoutineExercise re
            join fetch re.exercise
            left join fetch re.sets
            where re.routine.id = :routineId
            order by re.position asc
            """)
    List<RoutineExercise> findWithSetsByRoutineId(@Param("routineId") UUID routineId);

    /**
     * exerciseCount for list rows in one grouped query (no N+1).
     */
    @Query("""
            select r.id as routineId,
                   count(re.id) as exerciseCount
            from Routine r
            left join r.exercises re
            where r.id in :routineIds
            group by r.id
            """)
    List<RoutineSummaryRow> summarize(@Param("routineIds") List<UUID> routineIds);

    interface RoutineSummaryRow {
        UUID getRoutineId();

        long getExerciseCount();
    }

    /**
     * Ordered bulk deletes for full-replace updates: children must be gone
     * before replacements insert, or uq_routine_exercise_position breaks
     * mid-flush (same failure mode as Step 3's muscle links).
     */
    @Modifying
    @Query("delete from RoutineSet rs where rs.routineExercise.routine.id = :routineId")
    void deleteSetsForRoutine(@Param("routineId") UUID routineId);

    @Modifying
    @Query("delete from RoutineExercise re where re.routine.id = :routineId")
    void deleteExercisesForRoutine(@Param("routineId") UUID routineId);
}
