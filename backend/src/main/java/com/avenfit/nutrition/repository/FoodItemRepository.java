package com.avenfit.nutrition.repository;

import com.avenfit.nutrition.entity.FoodItem;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.lang.Nullable;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FoodItemRepository
        extends JpaRepository<FoodItem, UUID>, JpaSpecificationExecutor<FoodItem> {

    Optional<FoodItem> findByIdAndCreatedBy_Id(UUID id, UUID userId);

    Page<FoodItem> findByNameContainingIgnoreCase(String query, Pageable pageable);

    Optional<FoodItem> findByBarcode(String barcode);

    List<FoodItem> findByFoodCategory(String category);

    List<FoodItem> findByIsVegetarian(boolean isVegetarian);

    @Nullable
    Page<FoodItem> findAll(@Nullable Specification<FoodItem> spec, Pageable pageable);

    @Nullable
    List<FoodItem> findAll(@Nullable Specification<FoodItem> spec);
}
