package com.avenfit.workout.entity;

import com.avenfit.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(
        name = "workout_sets",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_workout_set_position",
                columnNames = {"workout_exercise_id", "position"}
        )
)
@Getter
@Setter
@NoArgsConstructor
public class WorkoutSet extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "workout_exercise_id", nullable = false)
    private WorkoutExercise workoutExercise;

    @Column(name = "position", nullable = false)
    private Integer position;

    @Enumerated(EnumType.STRING)
    @Column(name = "set_type", nullable = false, length = 20)
    private SetType setType = SetType.NORMAL;

    @Column(name = "weight_kg", precision = 7, scale = 2)
    private BigDecimal weightKg;

    @Column(name = "reps")
    private Integer reps;

    @Column(name = "rpe", precision = 3, scale = 1)
    private BigDecimal rpe;

    @Column(name = "is_completed", nullable = false)
    private Boolean isCompleted = false;

    @Column(name = "completed_at")
    private Instant completedAt;

    @Column(name = "is_pr", nullable = false)
    private Boolean isPr = false;

    @Column(name = "notes", columnDefinition = "text")
    private String notes;
}
