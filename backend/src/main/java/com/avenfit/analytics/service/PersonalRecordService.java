package com.avenfit.analytics.service;

import com.avenfit.analytics.entity.PersonalRecord;
import com.avenfit.analytics.entity.RecordType;
import com.avenfit.analytics.repository.PersonalRecordRepository;
import com.avenfit.auth.repository.UserRepository;
import com.avenfit.exercise.repository.ExerciseRepository;
import com.avenfit.workout.dto.SetLogResponse;
import com.avenfit.workout.entity.SetType;
import com.avenfit.workout.entity.WorkoutSet;
import com.avenfit.workout.repository.WorkoutSetRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * Personal-record engine per Tasks 4.1 / 7.1:
 * - four record types (MAX_WEIGHT, MAX_REPS, MAX_VOLUME, EST_1RM)
 * - Brzycki estimated 1RM, valid for reps <= 10
 * - warmup sets never count toward records
 * - full recompute after any set create/update/delete keeps personal_records
 *   rows and workout_sets.is_pr flags truthful
 */
@Service
public class PersonalRecordService {

    /**
     * Which improvement to surface in prDetails when several types improve at
     * once — MAX_WEIGHT is the headline celebration.
     */
    private static final List<RecordType> REPORT_PRIORITY =
            List.of(RecordType.MAX_WEIGHT, RecordType.EST_1RM, RecordType.MAX_VOLUME, RecordType.MAX_REPS);

    public record Improvement(RecordType recordType, BigDecimal previousValue, BigDecimal newValue,
                              Set<UUID> holderSetIds) {
    }

    private record Best(BigDecimal value, Set<UUID> holderIds, Instant achievedAt) {
        UUID primaryHolderId() {
            return holderIds.iterator().next();
        }
    }

    private final WorkoutSetRepository workoutSetRepository;
    private final PersonalRecordRepository personalRecordRepository;
    private final UserRepository userRepository;
    private final ExerciseRepository exerciseRepository;

    public PersonalRecordService(WorkoutSetRepository workoutSetRepository,
                                 PersonalRecordRepository personalRecordRepository,
                                 UserRepository userRepository,
                                 ExerciseRepository exerciseRepository) {
        this.workoutSetRepository = workoutSetRepository;
        this.personalRecordRepository = personalRecordRepository;
        this.userRepository = userRepository;
        this.exerciseRepository = exerciseRepository;
    }

    /**
     * Recomputes all record types for a user+exercise from completed sets,
     * upserts/deletes personal_records rows, syncs is_pr flags on sets, and
     * returns the improvements produced by the most recent change.
     */
    @Transactional
    public Map<RecordType, Improvement> synchronize(UUID userId, UUID exerciseId) {
        List<WorkoutSet> completedSets =
                workoutSetRepository.findCompletedSetsForExercise(userId, exerciseId);
        List<WorkoutSet> eligible = completedSets.stream()
                .filter(s -> s.getSetType() != SetType.WARMUP)
                .toList();

        Map<RecordType, Best> bests = computeBests(eligible);
        Map<RecordType, List<PersonalRecord>> existing = loadExisting(userId, exerciseId);

        Map<RecordType, Improvement> improvements = new LinkedHashMap<>();
        for (RecordType type : RecordType.values()) {
            Best best = bests.get(type);
            PersonalRecord current = first(existing.get(type));

            if (best == null) {
                if (current != null) {
                    personalRecordRepository.delete(current);
                }
                continue;
            }

            boolean improved = current == null || best.value().compareTo(current.getValue()) > 0;
            BigDecimal previous = current == null ? null : current.getValue();
            PersonalRecord saved = upsert(current, userId, exerciseId, type, best);

            if (improved) {
                improvements.put(type,
                        new Improvement(type, previous, best.value(), best.holderIds()));
            }
        }

        syncPrFlags(completedSets, bests);
        return improvements;
    }

    /**
     * Chooses the headline PR detail for a set from an improvements map.
     */
    public SetLogResponse.PrDetails toPrDetails(UUID setId, Map<RecordType, Improvement> improvements) {
        for (RecordType type : REPORT_PRIORITY) {
            Improvement improvement = improvements.get(type);
            if (improvement != null && improvement.holderSetIds().contains(setId)) {
                return new SetLogResponse.PrDetails(
                        improvement.recordType(), improvement.previousValue(), improvement.newValue());
            }
        }
        return null;
    }

    /**
     * Brzycki formula: 1RM = weight × 36 / (37 − reps), valid for reps ≤ 10.
     */
    public static BigDecimal estimateOneRepMax(BigDecimal weightKg, int reps) {
        if (reps < 1 || reps > 10) {
            throw new IllegalArgumentException("Brzycki formula requires reps between 1 and 10");
        }
        return weightKg.multiply(BigDecimal.valueOf(36))
                .divide(BigDecimal.valueOf(37L - reps), 2, RoundingMode.HALF_UP);
    }

    private PersonalRecord upsert(PersonalRecord current, UUID userId, UUID exerciseId,
                                  RecordType type, Best best) {
        PersonalRecord record = current == null ? new PersonalRecord() : current;
        if (current == null) {
            record.setUser(userRepository.getReferenceById(userId));
            record.setExercise(exerciseRepository.getReferenceById(exerciseId));
            record.setRecordType(type);
        }
        record.setValue(best.value());
        record.setWorkoutSetId(best.primaryHolderId());
        record.setAchievedAt(best.achievedAt());
        return personalRecordRepository.save(record);
    }

    private Map<RecordType, Best> computeBests(List<WorkoutSet> sets) {
        Map<RecordType, Best> bests = new EnumMap<>(RecordType.class);
        putBest(bests, RecordType.MAX_WEIGHT, sets,
                s -> s.getWeightKg() == null ? null : s.getWeightKg());
        putBest(bests, RecordType.MAX_REPS, sets,
                s -> s.getReps() == null ? null : BigDecimal.valueOf(s.getReps()));
        putBest(bests, RecordType.MAX_VOLUME, sets,
                s -> s.getWeightKg() != null && s.getReps() != null
                        ? s.getWeightKg().multiply(BigDecimal.valueOf(s.getReps())).setScale(2, RoundingMode.HALF_UP)
                        : null);
        putBest(bests, RecordType.EST_1RM, sets,
                s -> {
                    if (s.getWeightKg() == null || s.getReps() == null
                            || s.getReps() < 1 || s.getReps() > 10) {
                        return null;
                    }
                    return estimateOneRepMax(s.getWeightKg(), s.getReps());
                });
        return bests;
    }

    private interface MetricExtractor {
        BigDecimal extract(WorkoutSet set);
    }

    private void putBest(Map<RecordType, Best> bests, RecordType type, List<WorkoutSet> sets,
                         MetricExtractor extractor) {
        BigDecimal bestValue = null;
        Set<UUID> holders = new HashSet<>();
        Instant achievedAt = null;
        for (WorkoutSet set : sets) {
            BigDecimal value = extractor.extract(set);
            if (value == null) {
                continue;
            }
            int cmp = bestValue == null ? 1 : value.compareTo(bestValue);
            if (cmp > 0) {
                bestValue = value;
                holders = new HashSet<>();
                holders.add(set.getId());
                achievedAt = completedAtOf(set);
            } else if (cmp == 0) {
                holders.add(set.getId());
            }
        }
        if (bestValue != null) {
            bests.put(type, new Best(bestValue, holders, achievedAt));
        }
    }

    private void syncPrFlags(List<WorkoutSet> completedSets, Map<RecordType, Best> bests) {
        // Badge-worthy metrics only: MAX_WEIGHT / MAX_VOLUME / EST_1RM.
        // MAX_REPS is tracked in personal_records but never badges a set on
        // its own — otherwise every new rep count at any weight would show
        // as a PR celebration.
        Set<UUID> winners = new HashSet<>();
        for (Map.Entry<RecordType, Best> entry : bests.entrySet()) {
            if (entry.getKey() != RecordType.MAX_REPS) {
                winners.addAll(entry.getValue().holderIds());
            }
        }
        for (WorkoutSet set : completedSets) {
            set.setIsPr(winners.contains(set.getId()));
        }
    }

    private Map<RecordType, List<PersonalRecord>> loadExisting(UUID userId, UUID exerciseId) {
        Map<RecordType, List<PersonalRecord>> map = new EnumMap<>(RecordType.class);
        for (PersonalRecord record :
                personalRecordRepository.findByUserIdAndExerciseIdOrderByAchievedAtDesc(userId, exerciseId)) {
            map.computeIfAbsent(record.getRecordType(), t -> new ArrayList<>()).add(record);
        }
        return map;
    }

    private static PersonalRecord first(List<PersonalRecord> records) {
        return records == null || records.isEmpty() ? null : records.get(0);
    }

    private static Instant completedAtOf(WorkoutSet set) {
        return set.getCompletedAt() != null ? set.getCompletedAt() : Instant.now();
    }
}
