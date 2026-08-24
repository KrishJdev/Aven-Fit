package com.avenfit.nutrition.repository;

import com.avenfit.nutrition.entity.NutritionEntry;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface NutritionEntryRepository extends JpaRepository<NutritionEntry, UUID> {

    @EntityGraph(attributePaths = {"items", "items.foodItem"})
    List<NutritionEntry> findByUserIdAndLoggedAtBetween(UUID userId, Instant start, Instant end);
}
