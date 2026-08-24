package com.avenfit.nutrition.repository;

import com.avenfit.nutrition.entity.FoodItem;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FoodItemRepository extends JpaRepository<FoodItem, UUID> {

    Page<FoodItem> findByNameContainingIgnoreCase(String query, Pageable pageable);

    Page<FoodItem> findByNameContainingIgnoreCaseAndIsVegetarian(String query, boolean isVegetarian, Pageable pageable);

    Optional<FoodItem> findByBarcode(String barcode);

    List<FoodItem> findByFoodCategory(String category);

    List<FoodItem> findByIsVegetarian(boolean isVegetarian);

    @Query("select f from FoodItem f where lower(f.name) like lower(concat('%', :q, '%')) order by f.name")
    Page<FoodItem> searchByName(@Param("q") String q, Pageable pageable);
}
