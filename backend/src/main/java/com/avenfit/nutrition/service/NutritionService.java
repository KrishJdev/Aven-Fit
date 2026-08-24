package com.avenfit.nutrition.service;

import com.avenfit.auth.entity.User;
import com.avenfit.common.exception.ResourceNotFoundException;
import com.avenfit.nutrition.dto.DailyNutritionDto;
import com.avenfit.nutrition.dto.LogMealRequest;
import com.avenfit.nutrition.entity.FoodItem;
import com.avenfit.nutrition.entity.MealType;
import com.avenfit.nutrition.entity.NutritionEntry;
import com.avenfit.nutrition.entity.NutritionEntryItem;
import com.avenfit.nutrition.repository.FoodItemRepository;
import com.avenfit.nutrition.repository.NutritionEntryRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class NutritionService {

    /**
     * Day boundaries are computed in this zone — India-first product, so the
     * default is IST regardless of server locale.
     */
    private final ZoneId dayZone;

    private final NutritionEntryRepository nutritionEntryRepository;
    private final FoodItemRepository foodItemRepository;

    public NutritionService(NutritionEntryRepository nutritionEntryRepository,
                            FoodItemRepository foodItemRepository,
                            @Value("${avenfit.nutrition.day-zone:Asia/Kolkata}") String dayZone) {
        this.nutritionEntryRepository = nutritionEntryRepository;
        this.foodItemRepository = foodItemRepository;
        this.dayZone = ZoneId.of(dayZone);
    }

    /**
     * Logs a meal and computes macros server-side as food macros x quantity
     * (each food row defines one serving). The client-supplied unit label is
     * stored as-is when provided.
     */
    @Transactional
    public DailyNutritionDto.MealGroupDto logMeal(User currentUser, LogMealRequest request) {
        NutritionEntry entry = new NutritionEntry();
        entry.setUser(currentUser);
        entry.setMealType(request.mealType());
        entry.setLoggedAt(request.loggedAt() != null ? request.loggedAt() : Instant.now());

        for (LogMealRequest.ItemRequest itemRequest : request.items()) {
            FoodItem food = foodItemRepository.findById(itemRequest.foodItemId())
                    .orElseThrow(() -> ResourceNotFoundException.of("Food item", itemRequest.foodItemId()));

            NutritionEntryItem item = new NutritionEntryItem();
            item.setNutritionEntry(entry);
            item.setFoodItem(food);
            item.setQuantity(itemRequest.quantity());
            item.setServingUnit(org.springframework.util.StringUtils.hasText(itemRequest.servingUnit())
                    ? itemRequest.servingUnit().trim()
                    : food.getServingUnit());
            item.setCalories(scale(food.getCalories().multiply(itemRequest.quantity())));
            item.setProteinG(scale(multiplyOrZero(food.getProteinG(), itemRequest.quantity())));
            item.setCarbsG(scale(multiplyOrZero(food.getCarbsG(), itemRequest.quantity())));
            item.setFatG(scale(multiplyOrZero(food.getFatG(), itemRequest.quantity())));
            entry.getItems().add(item);
        }

        NutritionEntry saved = nutritionEntryRepository.saveAndFlush(entry);
        return toMealGroup(saved);
    }

    @Transactional(readOnly = true)
    public DailyNutritionDto dailySummary(UUID userId, LocalDate date) {
        LocalDate effectiveDate = date != null ? date : LocalDate.now(dayZone);
        Instant start = effectiveDate.atStartOfDay(dayZone).toInstant();
        Instant end = effectiveDate.plusDays(1).atStartOfDay(dayZone).toInstant();

        List<NutritionEntry> entries =
                nutritionEntryRepository.findByUserIdAndLoggedAtBetween(userId, start, end);

        BigDecimal calories = BigDecimal.ZERO;
        BigDecimal protein = BigDecimal.ZERO;
        BigDecimal carbs = BigDecimal.ZERO;
        BigDecimal fat = BigDecimal.ZERO;
        List<DailyNutritionDto.MealGroupDto> meals = new ArrayList<>();

        for (NutritionEntry entry : entries) {
            DailyNutritionDto.MealGroupDto meal = toMealGroup(entry);
            meals.add(meal);
            calories = calories.add(meal.totalCalories());
            protein = protein.add(sum(entry, "protein"));
            carbs = carbs.add(sum(entry, "carbs"));
            fat = fat.add(sum(entry, "fat"));
        }

        return new DailyNutritionDto(
                effectiveDate,
                dayZone.getId(),
                scale(calories),
                scale(protein),
                scale(carbs),
                scale(fat),
                meals);
    }

    @Transactional
    public void delete(UUID userId, UUID entryId) {
        NutritionEntry entry = nutritionEntryRepository.findByIdAndUserId(entryId, userId)
                .orElseThrow(() -> ResourceNotFoundException.of("Nutrition entry", entryId));
        nutritionEntryRepository.delete(entry);
    }

    // ------------------------------------------------------------------

    private DailyNutritionDto.MealGroupDto toMealGroup(NutritionEntry entry) {
        List<DailyNutritionDto.ItemDto> items = entry.getItems().stream()
                .map(item -> new DailyNutritionDto.ItemDto(
                        item.getId(),
                        item.getFoodItem().getId(),
                        item.getFoodItem().getName(),
                        item.getQuantity(),
                        item.getServingUnit(),
                        item.getCalories(),
                        item.getProteinG(),
                        item.getCarbsG(),
                        item.getFatG()))
                .toList();

        BigDecimal mealCalories = entry.getItems().stream()
                .map(NutritionEntryItem::getCalories)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return new DailyNutritionDto.MealGroupDto(
                entry.getId(),
                entry.getMealType().name(),
                entry.getLoggedAt(),
                items,
                scale(mealCalories));
    }

    private BigDecimal sum(NutritionEntry entry, String macro) {
        return entry.getItems().stream()
                .map(item -> switch (macro) {
                    case "protein" -> item.getProteinG();
                    case "carbs" -> item.getCarbsG();
                    default -> item.getFatG();
                })
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private static BigDecimal multiplyOrZero(BigDecimal macro, BigDecimal quantity) {
        return macro == null ? BigDecimal.ZERO : macro.multiply(quantity);
    }

    private static BigDecimal scale(BigDecimal value) {
        return value.setScale(2, RoundingMode.HALF_UP);
    }
}
