package com.avenfit.analytics.repository;

import com.avenfit.analytics.entity.PersonalRecord;
import com.avenfit.analytics.entity.RecordType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PersonalRecordRepository extends JpaRepository<PersonalRecord, UUID> {

    List<PersonalRecord> findByUserIdAndExerciseIdOrderByAchievedAtDesc(UUID userId, UUID exerciseId);

    List<PersonalRecord> findByUserIdOrderByAchievedAtDesc(UUID userId);

    List<PersonalRecord> findByUserIdAndExerciseIdAndRecordType(UUID userId, UUID exerciseId, RecordType recordType);

    Optional<PersonalRecord> findTopByUserIdAndExerciseIdAndRecordTypeOrderByValueDesc(
            UUID userId, UUID exerciseId, RecordType recordType);

    long countByUserIdAndAchievedAtGreaterThanEqual(UUID userId, Instant achievedAt);

    void deleteByWorkoutSetId(UUID workoutSetId);
}
