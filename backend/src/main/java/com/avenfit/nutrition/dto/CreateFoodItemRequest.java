package com.avenfit.nutrition.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record CreateFoodItemRequest(
        @NotBlank(message = "name is required")
        @Size(max = 300, message = "name must be at most 300 characters")
        String name,

        @Size(max = 200, message = "brand must be at most 200 characters")
        String brand,

        @NotNull(message = "servingSize is required")
        @DecimalMin(value = "0.01", message = "servingSize must be positive")
        BigDecimal servingSize,

        @NotBlank(message = "servingUnit is required")
        @Size(max = 30, message = "servingUnit must be at most 30 characters")
        String servingUnit,

        @NotNull(message = "calories is required")
        @DecimalMin(value = "0", message = "calories must not be negative")
        BigDecimal calories,

        @DecimalMin(value = "0", message = "proteinG must not be negative")
        BigDecimal proteinG,

        @DecimalMin(value = "0", message = "carbsG must not be negative")
        BigDecimal carbsG,

        @DecimalMin(value = "0", message = "fatG must not be negative")
        BigDecimal fatG,

        @DecimalMin(value = "0", message = "fiberG must not be negative")
        BigDecimal fiberG,

        Boolean isVegetarian,

        @Size(max = 50, message = "foodCategory must be at most 50 characters")
        String foodCategory
) {
}
