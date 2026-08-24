package com.avenfit.nutrition.dto;

import com.avenfit.nutrition.entity.MealType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record LogMealRequest(
        MealType mealType,

        /** Optional — defaults to server time when omitted. */
        Instant loggedAt,

        @NotNull(message = "items is required")
        @NotEmpty(message = "at least one item is required")
        @Valid
        List<ItemRequest> items
) {

    public record ItemRequest(
            @NotNull(message = "foodItemId is required")
            UUID foodItemId,

            @NotNull(message = "quantity is required")
            @Positive(message = "quantity must be positive")
            BigDecimal quantity,

            /** Optional — defaults to the food item's own serving unit. */
            @Size(max = 30, message = "servingUnit must be at most 30 characters")
            String servingUnit
    ) {
    }
}
