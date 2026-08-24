package com.avenfit.analytics.repository;

import com.avenfit.analytics.entity.BodyMeasurement;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface BodyMeasurementRepository extends JpaRepository<BodyMeasurement, UUID> {

    List<BodyMeasurement> findByUserIdOrderByMeasuredAtDesc(UUID userId);
}
