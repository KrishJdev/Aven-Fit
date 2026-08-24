package com.avenfit.workout.entity;

import com.avenfit.exercise.entity.Exercise;
import com.avenfit.common.entity.BaseEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(
        name = "workout_exercises",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_workout_exercise_position",
                columnNames = {"workout_id", "position"}
        )
)
@Getter
@Setter
@NoArgsConstructor
public class WorkoutExercise extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "workout_id", nullable = false)
    private Workout workout;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "exercise_id", nullable = false)
    private Exercise exercise;

    @Column(name = "position", nullable = false)
    private Integer position;

    @Column(name = "rest_seconds")
    private Integer restSeconds = 90;

    @Column(name = "notes", columnDefinition = "text")
    private String notes;

    @OneToMany(
            mappedBy = "workoutExercise",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    @OrderBy("position ASC")
    private List<WorkoutSet> sets = new ArrayList<>();
}
