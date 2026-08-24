package com.avenfit.nutrition.entity;

import com.avenfit.auth.entity.User;
import com.avenfit.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "food_items")
@Getter
@Setter
@NoArgsConstructor
public class FoodItem extends BaseEntity {

    @Column(name = "name", nullable = false, length = 300)
    private String name;

    @Column(name = "brand", length = 200)
    private String brand;

    @Column(name = "serving_size", nullable = false, precision = 8, scale = 2)
    private BigDecimal servingSize;

    @Column(name = "serving_unit", nullable = false, length = 30)
    private String servingUnit;

    @Column(name = "calories", nullable = false, precision = 8, scale = 2)
    private BigDecimal calories;

    @Column(name = "protein_g", nullable = false, precision = 7, scale = 2)
    private BigDecimal proteinG;

    @Column(name = "carbs_g", nullable = false, precision = 7, scale = 2)
    private BigDecimal carbsG;

    @Column(name = "fat_g", nullable = false, precision = 7, scale = 2)
    private BigDecimal fatG;

    @Column(name = "fiber_g", precision = 7, scale = 2)
    private BigDecimal fiberG;

    @Column(name = "is_vegetarian", nullable = false)
    private Boolean isVegetarian = false;

    @Column(name = "food_category", length = 50)
    private String foodCategory;

    @Column(name = "is_verified", nullable = false)
    private Boolean isVerified = false;

    @Column(name = "barcode", length = 50)
    private String barcode;

    @Column(name = "is_custom", nullable = false)
    private Boolean isCustom = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;
}
