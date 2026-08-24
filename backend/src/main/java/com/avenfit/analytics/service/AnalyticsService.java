package com.avenfit.analytics.service;

import com.avenfit.analytics.dto.ExerciseHistoryDto;
import com.avenfit.analytics.dto.PersonalRecordGroupDto;
import com.avenfit.analytics.dto.SummaryDto;
import com.avenfit.analytics.repository.PersonalRecordRepository;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.exercise.service.ExerciseService;
import com.avenfit.workout.entity.SetType;
import com.avenfit.workout.entity.Workout;
import com.avenfit.workout.entity.WorkoutStatus;
import com.avenfit.workout.entity.WorkoutSet;
import com.avenfit.workout.repository.WorkoutRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class AnalyticsService {

    private static final int DEFAULT_DAYS = 30;
    private static final int MIN_DAYS = 1;
    private static final int MAX_DAYS = 365;

    private final WorkoutRepository workoutRepository;
    private final com.avenfit.workout.repository.WorkoutSetRepository workoutSetRepository;
    private final PersonalRecordRepository personalRecordRepository;
    private final ExerciseService exerciseService;

    public AnalyticsService(WorkoutRepository workoutRepository,
                            com.avenfit.workout.repository.WorkoutSetRepository workoutSetRepository,
                            PersonalRecordRepository personalRecordRepository,
                            ExerciseService exerciseService) {
        this.workoutRepository = workoutRepository;
        this.workoutSetRepository = workoutSetRepository;
        this.personalRecordRepository = personalRecordRepository;
        this.exerciseService = exerciseService;
    }

    /**
     * PRs grouped per exercise; only record types that exist appear.
     * With exerciseId filter, returns at most that exercise's group
     * (foreign/unknown ids → 404, consistent with the visibility rule).
     */
    @Transactional(readOnly = true)
    public List<PersonalRecordGroupDto> personalRecords(UUID userId, UUID exerciseId) {
        if (exerciseId != null) {
            Exercise exercise = exerciseService.getVisibleExerciseEntity(userId, exerciseId);
            return List.of(PersonalRecordGroupDto.from(exercise,
                    personalRecordRepository.findByUserIdAndExerciseIdOrderByAchievedAtDesc(userId, exerciseId)));
        }

        Map<Exercise, List<com.avenfit.analytics.entity.PersonalRecord>> grouped = new LinkedHashMap<>();
        for (var record : personalRecordRepository.findByUserIdOrderByAchievedAtDesc(userId)) {
            Exercise exercise = record.getExercise();
            grouped.computeIfAbsent(exercise, e -> new ArrayList<>()).add(record);
        }
        return grouped.entrySet().stream()
                .map(e -> PersonalRecordGroupDto.from(e.getKey(), e.getValue()))
                .toList();
    }

    /**
     * Completed sets for an exercise grouped by workout day (UTC). All
     * completed sets are listed; bestSet and daily volume ignore warmups,
     * matching the PR engine.
     */
    @Transactional(readOnly = true)
    public ExerciseHistoryDto exerciseHistory(UUID userId, UUID exerciseId) {
        Exercise exercise = exerciseService.getVisibleExerciseEntity(userId, exerciseId);
        List<WorkoutSet> sets = workoutSetRepository.findCompletedSetsForExercise(userId, exerciseId);

        Map<LocalDate, List<WorkoutSet>> byDay = new LinkedHashMap<>();
        for (WorkoutSet set : sets) {
            LocalDate day = workoutDayOf(set);
            byDay.computeIfAbsent(day, d -> new ArrayList<>()).add(set);
        }

        List<ExerciseHistoryDto.DayHistory> history = byDay.entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .map(entry -> buildDay(entry.getValue()))
                .toList();

        return new ExerciseHistoryDto(exercise.getId(), exercise.getName(), history);
    }

    @Transactional(readOnly = true)
    public SummaryDto summary(UUID userId, Integer days) {
        int windowDays = normalizeDays(days);
        Instant since = Instant.now().minus(java.time.Duration.ofDays(windowDays));

        var totals = workoutRepository.totalsSince(userId, since);
        var setTotals = workoutRepository.setTotalsSince(userId, since);

        long totalDurationSeconds = totals.getTotalDurationSeconds();
        long totalWorkouts = totals.getTotalWorkouts();
        long totalMinutes = totalDurationSeconds / 60;
        long avgMinutes = totalWorkouts == 0 ? 0 : totalMinutes / totalWorkouts;

        List<SummaryDto.MuscleGroupVolume> muscleGroups =
                workoutRepository.muscleGroupVolumeSince(userId, since).stream()
                        .map(row -> new SummaryDto.MuscleGroupVolume(
                                row.getMuscleGroup(), row.getVolumeKg(), row.getSets()))
                        .toList();

        long newPrs = personalRecordRepository.countByUserIdAndAchievedAtGreaterThanEqual(userId, since);

        return new SummaryDto(
                windowDays + " days",
                totalWorkouts,
                setTotals.getTotalSets(),
                setTotals.getTotalVolumeKg(),
                totalMinutes,
                avgMinutes,
                muscleGroups,
                newPrs);
    }

    // ------------------------------------------------------------------

    private ExerciseHistoryDto.DayHistory buildDay(List<WorkoutSet> daySets) {
        List<WorkoutSet> scored = daySets.stream()
                .filter(s -> s.getSetType() != SetType.WARMUP)
                .toList();

        WorkoutSet best = scored.stream()
                .max(Comparator
                        .comparing((WorkoutSet s) -> s.getWeightKg() == null ? BigDecimal.ZERO : s.getWeightKg())
                        .thenComparing(s -> s.getReps() == null ? 0 : s.getReps()))
                .orElse(null);

        BigDecimal volume = scored.stream()
                .map(s -> {
                    if (s.getWeightKg() == null || s.getReps() == null) {
                        return BigDecimal.ZERO;
                    }
                    return s.getWeightKg().multiply(BigDecimal.valueOf(s.getReps()));
                })
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .setScale(2, RoundingMode.HALF_UP);

        List<ExerciseHistoryDto.HistorySetDto> setDtos = daySets.stream()
                .map(s -> new ExerciseHistoryDto.HistorySetDto(
                        s.getWeightKg(), s.getReps(), s.getSetType().name()))
                .toList();

        ExerciseHistoryDto.HistorySetDto bestDto = best == null ? null
                : new ExerciseHistoryDto.HistorySetDto(
                        best.getWeightKg(), best.getReps(), best.getSetType().name());

        return new ExerciseHistoryDto.DayHistory(workoutDayOf(daySets.get(0)), setDtos, bestDto, volume);
    }

    private LocalDate workoutDayOf(WorkoutSet set) {
        // Group by the owning workout's start date in UTC — a session belongs
        // to the day it began, even if it crosses midnight.
        return set.getWorkoutExercise().getWorkout().getStartedAt().atZone(ZoneOffset.UTC).toLocalDate();
    }

    private static int normalizeDays(Integer days) {
        int value = days == null ? DEFAULT_DAYS : days;
        if (value < MIN_DAYS || value > MAX_DAYS) {
            throw new IllegalArgumentException("days must be between " + MIN_DAYS + " and " + MAX_DAYS);
        }
        return value;
    }
}
