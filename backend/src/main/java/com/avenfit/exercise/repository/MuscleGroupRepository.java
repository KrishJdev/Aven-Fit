package com.avenfit.exercise.repository;

import com.avenfit.exercise.entity.MuscleGroup;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface MuscleGroupRepository extends JpaRepository<MuscleGroup, UUID> {

    List<MuscleGroup> findAllByOrderByDisplayOrderAsc();
}
