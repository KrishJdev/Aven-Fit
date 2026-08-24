package com.avenfit.exercise.entity;

import com.avenfit.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "muscle_groups")
@Getter
@Setter
@NoArgsConstructor
public class MuscleGroup extends BaseEntity {

    @Column(name = "name", nullable = false, unique = true, length = 50)
    private String name;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder = 0;
}
