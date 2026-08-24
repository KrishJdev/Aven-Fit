package com.avenfit.nutrition.controller;

import com.avenfit.auth.entity.User;
import com.avenfit.common.dto.ApiResponse;
import com.avenfit.nutrition.dto.DailyNutritionDto;
import com.avenfit.nutrition.dto.LogMealRequest;
import com.avenfit.nutrition.service.NutritionService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/nutrition")
public class NutritionController {

    private final NutritionService nutritionService;

    public NutritionController(NutritionService nutritionService) {
        this.nutritionService = nutritionService;
    }

    @GetMapping("/entries")
    public ApiResponse<DailyNutritionDto> dailySummary(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return ApiResponse.ok(nutritionService.dailySummary(currentUser.getId(), date));
    }

    @PostMapping("/entries")
    public ResponseEntity<ApiResponse<DailyNutritionDto.MealGroupDto>> logMeal(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody LogMealRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(nutritionService.logMeal(currentUser, request)));
    }

    @DeleteMapping("/entries/{id}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID id
    ) {
        nutritionService.delete(currentUser.getId(), id);
        return ResponseEntity.noContent().build();
    }
}
