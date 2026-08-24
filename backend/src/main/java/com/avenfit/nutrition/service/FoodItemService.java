package com.avenfit.nutrition.service;

import com.avenfit.auth.entity.User;
import com.avenfit.common.dto.PagedResponse;
import com.avenfit.common.exception.ResourceNotFoundException;
import com.avenfit.nutrition.dto.CreateFoodItemRequest;
import com.avenfit.nutrition.dto.FoodItemDto;
import com.avenfit.nutrition.entity.FoodItem;
import com.avenfit.nutrition.repository.FoodItemRepository;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.util.UUID;

@Service
public class FoodItemService {

    private static final int MAX_PAGE_SIZE = 100;

    private final FoodItemRepository foodItemRepository;

    public FoodItemService(FoodItemRepository foodItemRepository) {
        this.foodItemRepository = foodItemRepository;
    }

    /**
     * System (verified) foods plus the caller's own customs — same
     * visibility rule as exercises.
     */
    @Transactional(readOnly = true)
    public PagedResponse<FoodItemDto> search(
            UUID userId, String query, Boolean vegetarian, int page, int size) {
        Pageable pageable = PageRequest.of(
                page, pageSize(size), Sort.by(Sort.Direction.ASC, "name"));

        Specification<FoodItem> spec = visibleTo(userId);
        if (StringUtils.hasText(query)) {
            String pattern = "%" + query.trim().toLowerCase() + "%";
            spec = spec.and((root, q, cb) ->
                    cb.like(cb.lower(root.<String>get("name")), pattern));
        }
        if (vegetarian != null) {
            spec = spec.and((root, q, cb) -> cb.equal(root.<Boolean>get("isVegetarian"), vegetarian));
        }

        Page<FoodItem> result = foodItemRepository.findAll(spec, pageable);
        return PagedResponse.from(result.map(FoodItemDto::from));
    }

    @Transactional(readOnly = true)
    public FoodItemDto getVisible(UUID userId, UUID foodItemId) {
        return FoodItemDto.from(visibleFood(userId, foodItemId));
    }

    @Transactional
    public FoodItemDto create(User currentUser, CreateFoodItemRequest request) {
        FoodItem food = new FoodItem();
        food.setName(request.name().trim());
        food.setBrand(emptyToNull(request.brand()));
        food.setServingSize(request.servingSize());
        food.setServingUnit(request.servingUnit().trim());
        food.setCalories(request.calories());
        food.setProteinG(orZero(request.proteinG()));
        food.setCarbsG(orZero(request.carbsG()));
        food.setFatG(orZero(request.fatG()));
        food.setFiberG(request.fiberG());
        food.setIsVegetarian(request.isVegetarian() != null && request.isVegetarian());
        food.setFoodCategory(emptyToNull(request.foodCategory()));
        food.setIsVerified(false);
        food.setIsCustom(true);
        food.setCreatedBy(currentUser);
        return FoodItemDto.from(foodItemRepository.save(food));
    }

    public FoodItem visibleFood(UUID userId, UUID foodItemId) {
        FoodItem food = foodItemRepository.findById(foodItemId)
                .orElseThrow(() -> ResourceNotFoundException.of("Food item", foodItemId));
        boolean system = !Boolean.TRUE.equals(food.getIsCustom());
        boolean ownCustom = Boolean.TRUE.equals(food.getIsCustom())
                && food.getCreatedBy() != null
                && userId.equals(food.getCreatedBy().getId());
        if (!system && !ownCustom) {
            throw ResourceNotFoundException.of("Food item", foodItemId);
        }
        return food;
    }

    private Specification<FoodItem> visibleTo(UUID userId) {
        return (root, query, cb) -> cb.or(
                cb.isFalse(root.<Boolean>get("isCustom")),
                cb.equal(root.get("createdBy").get("id"), userId));
    }

    private static int pageSize(int size) {
        if (size < 1 || size > MAX_PAGE_SIZE) {
            throw new IllegalArgumentException("size must be between 1 and " + MAX_PAGE_SIZE);
        }
        return size;
    }

    private static BigDecimal orZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    private static String emptyToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }
}
