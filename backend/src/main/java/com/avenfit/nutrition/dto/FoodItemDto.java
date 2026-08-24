package com.avenfit.nutrition.dto;

import com.avenfit.nutrition.entity.FoodItem;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Shape per Task 8.1 response example (isCustom/createdBy intentionally not
 * echoed; barcode reserved for the P1 scanner feature).
 */
public record FoodItemDto(
        UUID id,
        String name,
        String brand,
        BigDecimal servingSize,
        String servingUnit,
        BigDecimal calories,
        BigDecimal proteinG,
        BigDecimal carbsG,
        BigDecimal fatG,
        BigDecimal fiberG,
        boolean isVegetarian,
        String foodCategory,
        boolean isVerified
) {
    public static FoodItemDto from(FoodItem f) {
        return new FoodItemDto(
                f.getId(),
                f.getName(),
                f.getBrand(),
                f.getServingSize(),
                f.getServingUnit(),
                f.getCalories(),
                f.getProteinG(),
                f.getCarbsG(),
                f.getFatG(),
                f.getFiberG(),
                Boolean.TRUE.equals(f.getIsVegetarian()),
                f.getFoodCategory(),
                Boolean.TRUE.equals(f.getIsVerified())
        );
    }
}
