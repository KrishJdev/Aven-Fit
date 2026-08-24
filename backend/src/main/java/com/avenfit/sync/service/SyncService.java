package com.avenfit.sync.service;

import com.avenfit.auth.entity.User;
import com.avenfit.exercise.dto.ExerciseDto;
import com.avenfit.exercise.repository.ExerciseRepository;
import com.avenfit.nutrition.dto.FoodItemDto;
import com.avenfit.nutrition.entity.FoodItem;
import com.avenfit.nutrition.repository.FoodItemRepository;
import com.avenfit.routine.dto.RoutineDetailDto;
import com.avenfit.routine.repository.RoutineRepository;
import com.avenfit.sync.dto.SyncPullResponse;
import com.avenfit.sync.dto.SyncPushRequest;
import com.avenfit.sync.dto.SyncPushResponse;
import com.avenfit.workout.dto.WorkoutDto;
import com.avenfit.workout.entity.Workout;
import com.avenfit.workout.repository.WorkoutExerciseRepository;
import com.avenfit.workout.repository.WorkoutRepository;
import jakarta.persistence.criteria.Predicate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class SyncService {

    private static final Logger log = LoggerFactory.getLogger(SyncService.class);

    private final SyncOperationProcessor processor;
    private final ExerciseRepository exerciseRepository;
    private final WorkoutRepository workoutRepository;
    private final WorkoutExerciseRepository workoutExerciseRepository;
    private final RoutineRepository routineRepository;
    private final FoodItemRepository foodItemRepository;

    public SyncService(SyncOperationProcessor processor,
                       ExerciseRepository exerciseRepository,
                       WorkoutRepository workoutRepository,
                       WorkoutExerciseRepository workoutExerciseRepository,
                       RoutineRepository routineRepository,
                       FoodItemRepository foodItemRepository) {
        this.processor = processor;
        this.exerciseRepository = exerciseRepository;
        this.workoutRepository = workoutRepository;
        this.workoutExerciseRepository = workoutExerciseRepository;
        this.routineRepository = routineRepository;
        this.foodItemRepository = foodItemRepository;
    }

    /**
     * Applies operations one at a time with per-operation error isolation:
     * a failed operation is reported in the results without aborting the rest.
     */
    public SyncPushResponse push(User currentUser, SyncPushRequest request) {
        List<SyncPushResponse.OperationResult> results = new ArrayList<>();
        int processed = 0;
        int conflicts = 0;

        for (SyncPushRequest.SyncOperation op : request.operations()) {
            SyncPushResponse.OperationResult result = apply(currentUser, op);
            results.add(result);
            if (!isFailure(result.status())) {
                processed++;
            }
            if (SyncOperationProcessor.CONFLICT.equals(result.status())) {
                conflicts++;
            }
        }
        return new SyncPushResponse(processed, conflicts, results);
    }

    @Transactional(readOnly = true)
    public SyncPullResponse pull(UUID userId, Instant since) {
        Instant windowStart = since != null ? since : Instant.EPOCH;

        List<ExerciseDto> exercises =
                exerciseRepository.findAll(visibleAndUpdated(userId, windowStart))
                        .stream().map(ExerciseDto::from).toList();

        List<WorkoutDto> workouts = new ArrayList<>();
        for (Workout w : workoutRepository
                .findByUserIdAndUpdatedAtAfterOrderByUpdatedAtAsc(userId, windowStart)) {
            var graph = workoutExerciseRepository.findWithSetsByWorkoutId(w.getId());
            workouts.add(WorkoutDto.from(w, graph));
        }

        List<RoutineDetailDto> routines = routineRepository
                .findByUserIdAndUpdatedAtAfterOrderByUpdatedAtAsc(userId, windowStart)
                .stream()
                .map(r -> routineDetailFor(userId, r.getId()))
                .toList();

        List<FoodItemDto> foodItems =
                foodItemRepository.findAll(visibleAndUpdatedFood(userId, windowStart))
                        .stream().map(FoodItemDto::from).toList();

        return new SyncPullResponse(exercises, workouts, routines, foodItems, Instant.now());
    }

    // ------------------------------------------------------------------

    private SyncPushResponse.OperationResult apply(User user, SyncPushRequest.SyncOperation op) {
        if (!processor.supports(op.entityType())) {
            return new SyncPushResponse.OperationResult(
                    op.entityId(), null, SyncOperationProcessor.UNSUPPORTED_TYPE);
        }
        try {
            SyncOperationProcessor.Result result = switch (op.entityType()) {
                case "exercise" -> processor.exercise(
                        user.getId(), op.entityId(), op.operation(), op.data(), op.clientTimestamp());
                case "workout" -> processor.workout(
                        user, op.entityId(), op.operation(), op.data(), op.clientTimestamp());
                case "workout_exercise" -> processor.workoutExercise(
                        user.getId(), op.entityId(), op.operation(), op.data(), op.clientTimestamp());
                case "workout_set" -> processor.workoutSet(
                        user.getId(), op.entityId(), op.operation(), op.data(), op.clientTimestamp());
                case "routine" -> processor.routine(
                        user, op.entityId(), op.operation(), op.data(), op.clientTimestamp());
                case "food_item" -> processor.foodItem(
                        user.getId(), op.entityId(), op.operation(), op.data(), op.clientTimestamp());
                default -> new SyncOperationProcessor.Result(
                        op.entityId(), null, SyncOperationProcessor.UNSUPPORTED_TYPE);
            };
            return new SyncPushResponse.OperationResult(result.clientId(), result.serverId(), result.status());
        } catch (Exception e) {
            log.warn("Sync operation {} {} failed: {}", op.entityType(), op.operation(),
                    e.getClass().getSimpleName() + ": " + e.getMessage());
            String status = e instanceof IllegalArgumentException
                    ? "VALIDATION_ERROR"
                    : (e.getMessage() != null && e.getMessage().toLowerCase().contains("not found")
                            ? SyncOperationProcessor.NOT_FOUND
                            : "FAILED");
            return new SyncPushResponse.OperationResult(op.entityId(), op.entityId(), status);
        }
    }

    private static boolean isFailure(String status) {
        return SyncOperationProcessor.CONFLICT.equals(status)
                || SyncOperationProcessor.UNSUPPORTED_TYPE.equals(status)
                || SyncOperationProcessor.NOT_FOUND.equals(status)
                || "FAILED".equals(status)
                || "VALIDATION_ERROR".equals(status);
    }

    private RoutineDetailDto routineDetailFor(UUID userId, UUID routineId) {
        // Owned already guaranteed by the pull query; reuse the detail builder
        var routine = routineRepository.findById(routineId).orElseThrow();
        var exercises = routineRepository.findWithSetsByRoutineId(routineId);
        return toDetail(routine, exercises);
    }

    /** Mirrors RoutineService.toDetail — kept local to avoid widening its API. */
    private RoutineDetailDto toDetail(com.avenfit.routine.entity.Routine routine,
                                      List<com.avenfit.routine.entity.RoutineExercise> exercises) {
        List<RoutineDetailDto.RoutineExerciseDto> exerciseDtos = new ArrayList<>();
        for (var re : exercises) {
            List<RoutineDetailDto.RoutineSetDto> setDtos = re.getSets().stream()
                    .map(rs -> new RoutineDetailDto.RoutineSetDto(
                            rs.getPosition(),
                            rs.getSetType().name(),
                            rs.getTargetReps(),
                            rs.getTargetWeightKg()))
                    .toList();
            exerciseDtos.add(new RoutineDetailDto.RoutineExerciseDto(
                    re.getId(),
                    re.getExercise().getId(),
                    re.getExercise().getName(),
                    re.getPosition(),
                    re.getRestSeconds(),
                    setDtos));
        }
        return new RoutineDetailDto(
                routine.getId(),
                routine.getName(),
                routine.getDescription(),
                routine.getCreatedAt(),
                routine.getUpdatedAt(),
                exerciseDtos);
    }

    private Specification<com.avenfit.exercise.entity.Exercise> visibleAndUpdated(UUID userId, Instant since) {
        return (root, query, cb) -> {
            Predicate visible = cb.or(
                    cb.isFalse(root.<Boolean>get("isCustom")),
                    cb.equal(root.get("createdBy").get("id"), userId));
            Predicate updated = cb.greaterThan(root.<Instant>get("updatedAt"), since);
            return cb.and(visible, updated);
        };
    }

    private Specification<FoodItem> visibleAndUpdatedFood(UUID userId, Instant since) {
        return (root, query, cb) -> {
            Predicate visible = cb.or(
                    cb.isFalse(root.<Boolean>get("isCustom")),
                    cb.equal(root.get("createdBy").get("id"), userId));
            Predicate updated = cb.greaterThan(root.<Instant>get("updatedAt"), since);
            return cb.and(visible, updated);
        };
    }
}
