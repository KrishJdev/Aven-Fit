package com.avenfit.analytics.dto;

import com.avenfit.analytics.entity.PersonalRecord;
import com.avenfit.analytics.entity.RecordType;
import com.avenfit.exercise.entity.Exercise;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * PR grouping per Task 7.1: records keyed by record type, only types that
 * exist for the exercise.
 */
public record PersonalRecordGroupDto(
        UUID exerciseId,
        String exerciseName,
        Map<RecordType, RecordValueDto> records
) {

    public record RecordValueDto(BigDecimal value, Instant achievedAt) {
    }

    public static PersonalRecordGroupDto from(Exercise exercise, List<PersonalRecord> records) {
        Map<RecordType, RecordValueDto> byType = new EnumMap<>(RecordType.class);
        for (PersonalRecord record : records) {
            // Records list is newest-first; keep the newest row per type
            byType.putIfAbsent(record.getRecordType(),
                    new RecordValueDto(record.getValue(), record.getAchievedAt()));
        }
        return new PersonalRecordGroupDto(exercise.getId(), exercise.getName(), byType);
    }
}
