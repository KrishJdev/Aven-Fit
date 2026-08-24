package com.avenfit.nutrition.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Daily summary per Task 8.2: totals for the calendar day (IST) with meals
 * grouped as logged.
 */
public record DailyNutritionDto(
        LocalDate date,
        String timezone,
        BigDecimal totalCalories,
        BigDecimal totalProteinG,
        BigDecimal totalCarbsG,
        BigDecimal totalFatG,
        List<MealGroupDto> meals
) {

    public record MealGroupDto(
            UUID id,
            String mealType,
            Instant loggedAt,
            List<ItemDto> items,
            BigDecimal totalCalories
    ) {
    }

    public record ItemDto(
            UUID id,
            UUID foodItemId,
            String foodItemName,
            BigDecimal quantity,
            String servingUnit,
            BigDecimal calories,
            BigDecimal proteinG,
            BigDecimal carbsG,
            BigDecimal fatG
    ) {
    }
}
