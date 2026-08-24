package com.avenfit.routine.entity;

import com.avenfit.workout.entity.SetType;
import com.avenfit.common.entity.BaseEntity;
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

import java.math.BigDecimal;

@Entity
@Table(name = "routine_sets")
@Getter
@Setter
@NoArgsConstructor
public class RoutineSet extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "routine_exercise_id", nullable = false)
    private RoutineExercise routineExercise;

    @Column(name = "position", nullable = false)
    private Integer position;

    @Enumerated(EnumType.STRING)
    @Column(name = "set_type", nullable = false, length = 20)
    private SetType setType = SetType.NORMAL;

    @Column(name = "target_reps")
    private Integer targetReps;

    @Column(name = "target_weight_kg", precision = 7, scale = 2)
    private BigDecimal targetWeightKg;

    @Column(name = "target_rpe", precision = 3, scale = 1)
    private BigDecimal targetRpe;
}
