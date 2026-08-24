package com.avenfit.workout.service;

import com.avenfit.analytics.service.PersonalRecordService;
import com.avenfit.auth.entity.User;
import com.avenfit.common.dto.PagedResponse;
import com.avenfit.common.exception.ConflictException;
import com.avenfit.common.exception.ResourceNotFoundException;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.exercise.repository.ExerciseRepository;
import com.avenfit.routine.entity.Routine;
import com.avenfit.routine.repository.RoutineRepository;
import com.avenfit.workout.dto.CreateWorkoutRequest;
import com.avenfit.workout.dto.LogSetRequest;
import com.avenfit.workout.dto.SetLogResponse;
import com.avenfit.workout.dto.WorkoutDto;
import com.avenfit.workout.dto.WorkoutExerciseDto;
import com.avenfit.workout.dto.WorkoutSetDto;
import com.avenfit.workout.dto.WorkoutSummaryDto;
import com.avenfit.workout.entity.SetType;
import com.avenfit.workout.entity.Workout;
import com.avenfit.workout.entity.WorkoutExercise;
import com.avenfit.workout.entity.WorkoutSet;
import com.avenfit.workout.entity.WorkoutStatus;
import com.avenfit.workout.repository.WorkoutExerciseRepository;
import com.avenfit.workout.repository.WorkoutRepository;
import com.avenfit.workout.repository.WorkoutRepository.WorkoutSummaryRow;
import com.avenfit.workout.repository.WorkoutSetRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class WorkoutService {

    private static final int MAX_PAGE_SIZE = 100;
    private static final int DEFAULT_REST_SECONDS = 90;

    private final WorkoutRepository workoutRepository;
    private final WorkoutExerciseRepository workoutExerciseRepository;
    private final WorkoutSetRepository workoutSetRepository;
    private final ExerciseRepository exerciseRepository;
    private final RoutineRepository routineRepository;
    private final PersonalRecordService personalRecordService;

    public WorkoutService(WorkoutRepository workoutRepository,
                          WorkoutExerciseRepository workoutExerciseRepository,
                          WorkoutSetRepository workoutSetRepository,
                          ExerciseRepository exerciseRepository,
                          RoutineRepository routineRepository,
                          PersonalRecordService personalRecordService) {
        this.workoutRepository = workoutRepository;
        this.workoutExerciseRepository = workoutExerciseRepository;
        this.workoutSetRepository = workoutSetRepository;
        this.exerciseRepository = exerciseRepository;
        this.routineRepository = routineRepository;
        this.personalRecordService = personalRecordService;
    }

    // ------------------------------------------------------------------
    // Start / detail / history
    // ------------------------------------------------------------------

    @Transactional
    public WorkoutDto start(User currentUser, CreateWorkoutRequest request) {
        Workout workout = new Workout();
        workout.setUser(currentUser);
        workout.setName(request.name().trim());
        workout.setStatus(WorkoutStatus.IN_PROGRESS);
        workout.setStartedAt(request.startedAt());

        if (request.routineId() != null) {
            Routine routine = routineRepository.findByIdAndUserId(request.routineId(), currentUser.getId())
                    .orElseThrow(() -> ResourceNotFoundException.of("Routine", request.routineId()));
            applyRoutineTemplate(workout, routine);
        }

        return WorkoutDto.from(workoutRepository.save(workout));
    }

    @Transactional(readOnly = true)
    public WorkoutDto getDetail(UUID userId, UUID workoutId) {
        Workout workout = ownedWorkout(userId, workoutId);
        // Two purposeful fetches instead of one cartesian EntityGraph
        var exercises = workoutExerciseRepository.findWithSetsByWorkoutId(workout.getId());
        return WorkoutDto.from(workout, exercises);
    }

    @Transactional(readOnly = true)
    public PagedResponse<WorkoutSummaryDto> history(UUID userId, Integer page, Integer size, String status) {
        Pageable pageable = PageRequest.of(
                page == null ? 0 : requireValidPage(page),
                size == null ? 20 : requireValidSize(size));
        Page<Workout> result = status == null
                ? workoutRepository.findByUserIdOrderByStartedAtDesc(userId, pageable)
                : workoutRepository.findByUserIdAndStatusOrderByStartedAtDesc(
                        userId, parseStatus(status), pageable);

        Map<UUID, WorkoutSummaryRow> aggregates =
                aggregateFor(result.getContent().stream().map(Workout::getId).toList());

        List<WorkoutSummaryDto> items = result.getContent().stream()
                .map(w -> {
                    WorkoutSummaryRow row = aggregates.get(w.getId());
                    return WorkoutSummaryDto.of(
                            w,
                            row == null ? 0 : row.getExerciseCount(),
                            row == null ? 0 : row.getSetCount(),
                            row == null ? BigDecimal.ZERO : row.getTotalVolumeKg(),
                            row == null ? 0 : row.getPrCount());
                })
                .toList();

        return new PagedResponse<>(items, result.getNumber(), result.getSize(),
                result.getTotalElements(), result.getTotalPages());
    }

    // ------------------------------------------------------------------
    // Exercises within a workout
    // ------------------------------------------------------------------

    @Transactional
    public WorkoutExerciseDto addExercise(UUID userId, UUID workoutId, UUID exerciseId, Integer restSeconds) {
        Workout workout = ownedInProgress(userId, workoutId);
        Exercise exercise = visibleExercise(userId, exerciseId);

        WorkoutExercise we = new WorkoutExercise();
        we.setWorkout(workout);
        we.setExercise(exercise);
        we.setPosition(workoutExerciseRepository.findNextPosition(workoutId) + 1);
        we.setRestSeconds(restSeconds != null ? restSeconds : DEFAULT_REST_SECONDS);
        we = workoutExerciseRepository.save(we);
        return WorkoutExerciseDto.emptySets(we);
    }

    @Transactional
    public void removeExercise(UUID userId, UUID workoutId, UUID workoutExerciseId) {
        ownedInProgress(userId, workoutId);
        WorkoutExercise removed = workoutExerciseRepository.findByIdAndWorkoutId(workoutExerciseId, workoutId)
                .orElseThrow(() -> ResourceNotFoundException.of("Workout exercise", workoutExerciseId));

        int removedPosition = removed.getPosition();
        workoutExerciseRepository.delete(removed);

        List<WorkoutExercise> remaining =
                workoutExerciseRepository.findByWorkoutIdOrderByPositionAsc(workoutId);
        for (WorkoutExercise we : remaining) {
            if (we.getPosition() > removedPosition) {
                we.setPosition(we.getPosition() - 1);
            }
        }
        workoutExerciseRepository.saveAll(remaining);
    }

    // ------------------------------------------------------------------
    // Sets
    // ------------------------------------------------------------------

    @Transactional
    public SetLogResponse logSet(UUID userId, UUID workoutId, UUID workoutExerciseId, LogSetRequest request) {
        Workout workout = ownedInProgress(userId, workoutId);
        WorkoutExercise we = workoutExerciseRepository
                .findByIdAndWorkoutId(workoutExerciseId, workoutId)
                .orElseThrow(() -> ResourceNotFoundException.of("Workout exercise", workoutExerciseId));

        WorkoutSet set = new WorkoutSet();
        set.setWorkoutExercise(we);
        set.setPosition(workoutSetRepository.findNextPosition(we.getId()) + 1);
        set.setSetType(request.setType() == null ? SetType.NORMAL : request.setType());
        set.setWeightKg(request.weightKg());
        set.setReps(request.reps());
        set.setRpe(request.rpe());
        set.setIsCompleted(true);
        set.setCompletedAt(Instant.now());
        set = workoutSetRepository.saveAndFlush(set);

        var improvements = personalRecordService.synchronize(userId, we.getExercise().getId());
        return SetLogResponse.from(set, personalRecordService.toPrDetails(set.getId(), improvements));
    }

    @Transactional
    public SetLogResponse updateSet(UUID userId, UUID workoutId, UUID setId, LogSetRequest request) {
        Workout workout = ownedInProgress(userId, workoutId);
        WorkoutSet set = ownedSet(workout, setId);

        if (request.setType() != null) {
            set.setSetType(request.setType());
        }
        if (request.weightKg() != null) {
            set.setWeightKg(request.weightKg());
        }
        if (request.reps() != null) {
            set.setReps(request.reps());
        }
        if (request.rpe() != null) {
            set.setRpe(request.rpe());
        }
        set = workoutSetRepository.saveAndFlush(set);

        var improvements = personalRecordService.synchronize(userId, exerciseIdOf(set));
        return SetLogResponse.from(set, personalRecordService.toPrDetails(set.getId(), improvements));
    }

    @Transactional
    public void deleteSet(UUID userId, UUID workoutId, UUID setId) {
        Workout workout = ownedInProgress(userId, workoutId);
        WorkoutSet set = ownedSet(workout, setId);
        UUID exerciseId = exerciseIdOf(set);
        workoutSetRepository.delete(set);
        workoutSetRepository.flush();
        personalRecordService.synchronize(userId, exerciseId);
    }

    // ------------------------------------------------------------------
    // Lifecycle
    // ------------------------------------------------------------------

    @Transactional
    public WorkoutDto complete(UUID userId, UUID workoutId, String notes) {
        Workout workout = ownedInProgress(userId, workoutId);
        Instant completedAt = Instant.now();
        workout.setStatus(WorkoutStatus.COMPLETED);
        workout.setCompletedAt(completedAt);
        workout.setDurationSeconds((int) Duration.between(workout.getStartedAt(), completedAt).getSeconds());
        if (notes != null && !notes.isBlank()) {
            workout.setNotes(notes.trim());
        }
        return WorkoutDto.from(workoutRepository.save(workout));
    }

    @Transactional
    public WorkoutDto cancel(UUID userId, UUID workoutId) {
        Workout workout = ownedInProgress(userId, workoutId);
        workout.setStatus(WorkoutStatus.CANCELLED);
        return WorkoutDto.from(workoutRepository.save(workout));
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    private void applyRoutineTemplate(Workout workout, Routine routine) {
        for (var routineExercise : routine.getExercises()) {
            WorkoutExercise we = new WorkoutExercise();
            we.setWorkout(workout);
            we.setExercise(routineExercise.getExercise());
            we.setPosition(routineExercise.getPosition());
            we.setRestSeconds(routineExercise.getRestSeconds() != null
                    ? routineExercise.getRestSeconds() : DEFAULT_REST_SECONDS);
            we.setNotes(routineExercise.getNotes());
            workout.getExercises().add(we);

            for (var routineSet : routineExercise.getSets()) {
                WorkoutSet templateSet = new WorkoutSet();
                templateSet.setWorkoutExercise(we);
                templateSet.setPosition(routineSet.getPosition());
                templateSet.setSetType(routineSet.getSetType());
                templateSet.setIsCompleted(false);
                we.getSets().add(templateSet);
            }
        }
    }

    private Workout ownedWorkout(UUID userId, UUID workoutId) {
        return workoutRepository.findByIdAndUserId(workoutId, userId)
                .orElseThrow(() -> ResourceNotFoundException.of("Workout", workoutId));
    }

    private Workout ownedInProgress(UUID userId, UUID workoutId) {
        Workout workout = ownedWorkout(userId, workoutId);
        if (workout.getStatus() != WorkoutStatus.IN_PROGRESS) {
            throw new ConflictException("Workout is " + workout.getStatus() + " and can no longer be modified");
        }
        return workout;
    }

    private WorkoutSet ownedSet(Workout workout, UUID setId) {
        WorkoutSet set = workoutSetRepository.findById(setId)
                .orElseThrow(() -> ResourceNotFoundException.of("Set", setId));
        UUID actualWorkoutId = set.getWorkoutExercise().getWorkout().getId();
        if (!actualWorkoutId.equals(workout.getId())) {
            throw ResourceNotFoundException.of("Set", setId);
        }
        return set;
    }

    private Exercise visibleExercise(UUID userId, UUID exerciseId) {
        Exercise exercise = exerciseRepository.findById(exerciseId)
                .orElseThrow(() -> ResourceNotFoundException.of("Exercise", exerciseId));
        boolean system = !Boolean.TRUE.equals(exercise.getIsCustom());
        boolean ownCustom = Boolean.TRUE.equals(exercise.getIsCustom())
                && exercise.getCreatedBy() != null
                && userId.equals(exercise.getCreatedBy().getId());
        if (!system && !ownCustom) {
            throw ResourceNotFoundException.of("Exercise", exerciseId);
        }
        return exercise;
    }

    private UUID exerciseIdOf(WorkoutSet set) {
        return set.getWorkoutExercise().getExercise().getId();
    }

    private Map<UUID, WorkoutSummaryRow> aggregateFor(List<UUID> workoutIds) {
        Map<UUID, WorkoutSummaryRow> map = new HashMap<>();
        if (workoutIds.isEmpty()) {
            return map;
        }
        for (WorkoutSummaryRow row : workoutRepository.summarize(workoutIds)) {
            map.put(row.getWorkoutId(), row);
        }
        return map;
    }

    private static WorkoutStatus parseStatus(String status) {
        try {
            return WorkoutStatus.valueOf(status.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Unknown status: " + status);
        }
    }

    private static int requireValidPage(int page) {
        if (page < 0) {
            throw new IllegalArgumentException("page must not be negative");
        }
        return page;
    }

    private static int requireValidSize(int size) {
        if (size < 1 || size > MAX_PAGE_SIZE) {
            throw new IllegalArgumentException("size must be between 1 and " + MAX_PAGE_SIZE);
        }
        return size;
    }
}
