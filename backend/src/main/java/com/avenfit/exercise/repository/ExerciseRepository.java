package com.avenfit.exercise.repository;

import com.avenfit.auth.entity.User;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.exercise.entity.ExerciseCategory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.lang.Nullable;

import java.util.List;
import java.util.UUID;

public interface ExerciseRepository
        extends JpaRepository<Exercise, UUID>, JpaSpecificationExecutor<Exercise> {

    List<Exercise> findByIsCustomFalse();

    List<Exercise> findByCreatedBy(User user);

    List<Exercise> findByNameContainingIgnoreCase(String query);

    List<Exercise> findByCategory(ExerciseCategory category);

    /**
     * Specification-driven paged search with eager muscle-group fetching so
     * DTO mapping never triggers lazy loads (no N+1).
     */
    @Override
    @EntityGraph(attributePaths = {"muscleGroups", "muscleGroups.muscleGroup"})
    Page<Exercise> findAll(@Nullable Specification<Exercise> spec, Pageable pageable);

    @Override
    @EntityGraph(attributePaths = {"muscleGroups", "muscleGroups.muscleGroup"})
    List<Exercise> findAll(@Nullable Specification<Exercise> spec);
}
