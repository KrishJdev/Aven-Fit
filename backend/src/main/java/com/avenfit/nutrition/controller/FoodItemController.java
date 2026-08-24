package com.avenfit.nutrition.controller;

import com.avenfit.auth.entity.User;
import com.avenfit.common.dto.ApiResponse;
import com.avenfit.common.dto.PagedResponse;
import com.avenfit.nutrition.dto.CreateFoodItemRequest;
import com.avenfit.nutrition.dto.FoodItemDto;
import com.avenfit.nutrition.service.FoodItemService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/food-items")
public class FoodItemController {

    private final FoodItemService foodItemService;

    public FoodItemController(FoodItemService foodItemService) {
        this.foodItemService = foodItemService;
    }

    @GetMapping("/search")
    public PagedResponse<FoodItemDto> search(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) Boolean vegetarian,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return foodItemService.search(currentUser.getId(), q, vegetarian, page, size);
    }

    @GetMapping("/{id}")
    public ApiResponse<FoodItemDto> get(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID id
    ) {
        return ApiResponse.ok(foodItemService.getVisible(currentUser.getId(), id));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<FoodItemDto>> create(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreateFoodItemRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(foodItemService.create(currentUser, request)));
    }
}
