package com.avenfit.analytics.entity;

import com.avenfit.auth.entity.User;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.workout.entity.WorkoutSet;
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

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Maps to personal_records, which carries created_at only — extends
 * CreatableEntity instead of BaseEntity.
 */
@Entity
@Table(name = "personal_records")
@Getter
@Setter
@NoArgsConstructor
public class PersonalRecord extends CreatableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "exercise_id", nullable = false)
    private Exercise exercise;

    @Enumerated(EnumType.STRING)
    @Column(name = "record_type", nullable = false, length = 20)
    private RecordType recordType;

    @Column(name = "value", nullable = false, precision = 10, scale = 2)
    private BigDecimal value;

    @Column(name = "workout_set_id")
    private UUID workoutSetId;

    @Column(name = "achieved_at", nullable = false)
    private Instant achievedAt;
}
