package com.avenfit.nutrition.entity;

import com.avenfit.common.entity.CreatableEntity;
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

/**
 * Maps to nutrition_entry_items, which carries created_at only — extends
 * CreatableEntity instead of BaseEntity.
 */
@Entity
@Table(name = "nutrition_entry_items")
@Getter
@Setter
@NoArgsConstructor
public class NutritionEntryItem extends CreatableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "nutrition_entry_id", nullable = false)
    private NutritionEntry nutritionEntry;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "food_item_id", nullable = false)
    private FoodItem foodItem;

    @Column(name = "quantity", nullable = false, precision = 8, scale = 2)
    private BigDecimal quantity;

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
}
