package com.avenfit.exercise.entity;

import com.avenfit.auth.entity.User;
import com.avenfit.common.entity.CreatableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Maps to exercise_muscle_groups, which carries created_at only — extends
 * CreatableEntity instead of BaseEntity.
 */
@Entity
@Table(name = "exercise_muscle_groups")
@Getter
@Setter
@NoArgsConstructor
public class ExerciseMuscleGroup extends CreatableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "exercise_id", nullable = false)
    private Exercise exercise;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "muscle_group_id", nullable = false)
    private MuscleGroup muscleGroup;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false, length = 10)
    private MuscleRole role = MuscleRole.PRIMARY;
}
