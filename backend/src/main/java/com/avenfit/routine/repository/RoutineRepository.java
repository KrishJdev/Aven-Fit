package com.avenfit.routine.repository;

import com.avenfit.routine.entity.Routine;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface RoutineRepository extends JpaRepository<Routine, UUID> {

    @EntityGraph(attributePaths = {"exercises", "exercises.sets"})
    List<Routine> findByUserIdOrderByUpdatedAtDesc(UUID userId);

    Optional<Routine> findByIdAndUserId(UUID id, UUID userId);
}
