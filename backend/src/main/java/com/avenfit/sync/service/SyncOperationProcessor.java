package com.avenfit.sync.service;

import com.avenfit.analytics.service.PersonalRecordService;
import com.avenfit.auth.entity.User;
import com.avenfit.auth.repository.UserRepository;
import com.avenfit.exercise.entity.Equipment;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.exercise.entity.ExerciseCategory;
import com.avenfit.exercise.repository.ExerciseRepository;
import com.avenfit.nutrition.entity.FoodItem;
import com.avenfit.nutrition.repository.FoodItemRepository;
import com.avenfit.routine.dto.CreateRoutineRequest;
import com.avenfit.routine.repository.RoutineRepository;
import com.avenfit.routine.service.RoutineService;
import com.avenfit.workout.entity.SetType;
import com.avenfit.workout.entity.Workout;
import com.avenfit.workout.entity.WorkoutExercise;
import com.avenfit.workout.entity.WorkoutSet;
import com.avenfit.workout.entity.WorkoutStatus;
import com.avenfit.workout.repository.WorkoutExerciseRepository;
import com.avenfit.workout.repository.WorkoutRepository;
import com.avenfit.workout.repository.WorkoutSetRepository;
import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Applies one sync operation per transaction so a bad operation never poisons
 * the batch. Idempotency comes from shared client-generated UUIDs: a replayed
 * CREATE hits an existing row and is acknowledged as IGNORED_DUPLICATE.
 *
 * Conflict rule: when the server row's updated_at is newer than the client's
 * snapshot timestamp, the operation is rejected as CONFLICT.
 */
@Component
public class SyncOperationProcessor {

    public record Result(UUID clientId, UUID serverId, String status) {
    }

    public static final String CREATED = "CREATED";
    public static final String UPDATED = "UPDATED";
    public static final String DELETED = "DELETED";
    public static final String IGNORED_DUPLICATE = "IGNORED_DUPLICATE";
    public static final String CONFLICT = "CONFLICT";
    public static final String UNSUPPORTED_TYPE = "UNSUPPORTED_TYPE";
    public static final String NOT_FOUND = "NOT_FOUND";

    private final UserRepository userRepository;
    private final ExerciseRepository exerciseRepository;
    private final WorkoutRepository workoutRepository;
    private final WorkoutExerciseRepository workoutExerciseRepository;
    private final WorkoutSetRepository workoutSetRepository;
    private final RoutineRepository routineRepository;
    private final FoodItemRepository foodItemRepository;
    private final RoutineService routineService;
    private final PersonalRecordService personalRecordService;

    public SyncOperationProcessor(UserRepository userRepository,
                                  ExerciseRepository exerciseRepository,
                                  WorkoutRepository workoutRepository,
                                  WorkoutExerciseRepository workoutExerciseRepository,
                                  WorkoutSetRepository workoutSetRepository,
                                  RoutineRepository routineRepository,
                                  FoodItemRepository foodItemRepository,
                                  RoutineService routineService,
                                  PersonalRecordService personalRecordService) {
        this.userRepository = userRepository;
        this.exerciseRepository = exerciseRepository;
        this.workoutRepository = workoutRepository;
        this.workoutExerciseRepository = workoutExerciseRepository;
        this.workoutSetRepository = workoutSetRepository;
        this.routineRepository = routineRepository;
        this.foodItemRepository = foodItemRepository;
        this.routineService = routineService;
        this.personalRecordService = personalRecordService;
    }

    public boolean supports(String entityType) {
        return switch (entityType) {
            case "exercise", "workout", "workout_exercise", "workout_set", "routine", "food_item" -> true;
            default -> false;
        };
    }

    // ------------------------------------------------------------------
    // Exercise (scalars only; muscle links are managed online)
    // ------------------------------------------------------------------

    @Transactional
    public Result exercise(UUID userId, UUID id, String operation, JsonNode data, Instant clientTs) {
        return switch (operation) {
            case "CREATE", "UPDATE" -> {
                if ("CREATE".equals(operation) && exerciseRepository.existsById(id)) {
                    yield new Result(id, id, IGNORED_DUPLICATE);
                }
                yield upsertExercise(id, data, clientTs);
            }
            case "DELETE" -> deleteIfExists(exerciseRepository.existsById(id),
                    () -> exerciseRepository.deleteById(id), id);
            default -> unsupported(id);
        };
    }

    private Result upsertExercise(UUID id, JsonNode data, Instant clientTs) {
        Exercise existing = exerciseRepository.findById(id).orElse(null);
        if (existing != null && isConflicting(existing.getUpdatedAt(), clientTs)) {
            return new Result(id, id, CONFLICT);
        }
        boolean created = existing == null;
        Exercise e = existing != null ? existing : new Exercise();
        if (created) {
            e.setId(id);
            e.setIsCustom(true);
        }
        e.setName(textOrDefault(data, "name", orDefault(e.getName(), "Synced Exercise")));
        if (data.hasNonNull("description")) {
            e.setDescription(data.get("description").asText());
        }
        try {
            if (data.hasNonNull("category")) {
                e.setCategory(ExerciseCategory.valueOf(data.get("category").asText()));
            } else if (created) {
                e.setCategory(ExerciseCategory.OTHER);
            }
            if (data.hasNonNull("equipment")) {
                e.setEquipment(Equipment.valueOf(data.get("equipment").asText()));
            } else if (created) {
                e.setEquipment(Equipment.NONE);
            }
            exerciseRepository.saveAndFlush(e);
            return new Result(id, e.getId(), created ? CREATED : UPDATED);
        } catch (IllegalArgumentException enumError) {
            throw new IllegalArgumentException("Unknown category/equipment value");
        }
    }

    // ------------------------------------------------------------------
    // Workout (own rows only; children sync separately)
    // ------------------------------------------------------------------

    @Transactional
    public Result workout(User user, UUID id, String operation, JsonNode data, Instant clientTs) {
        switch (operation) {
            case "CREATE", "UPDATE" -> {
                Workout existing = workoutRepository.findById(id).orElse(null);
                if ("CREATE".equals(operation) && existing != null) {
                    return new Result(id, id, IGNORED_DUPLICATE);
                }
                boolean foreign = existing != null && !existing.getUser().getId().equals(user.getId());
                if (foreign) {
                    return new Result(id, id, NOT_FOUND);
                }
                if (existing != null && isConflicting(existing.getUpdatedAt(), clientTs)) {
                    return new Result(id, id, CONFLICT);
                }
                boolean created = existing == null;
                Workout w = existing != null ? existing : new Workout();
                if (created) {
                    w.setId(id);
                    w.setUser(user);
                    w.setStatus(WorkoutStatus.IN_PROGRESS);
                }
                w.setName(textOrDefault(data, "name", orDefault(w.getName(), "Synced Workout")));
                if (data.hasNonNull("startedAt")) {
                    w.setStartedAt(Instant.parse(data.get("startedAt").asText()));
                } else if (created) {
                    w.setStartedAt(Instant.now());
                }
                if (data.hasNonNull("completedAt")) {
                    w.setCompletedAt(Instant.parse(data.get("completedAt").asText()));
                }
                if (data.hasNonNull("durationSeconds")) {
                    w.setDurationSeconds(data.get("durationSeconds").intValue());
                }
                if (data.hasNonNull("notes")) {
                    w.setNotes(data.get("notes").asText());
                }
                if (data.hasNonNull("status")) {
                    w.setStatus(WorkoutStatus.valueOf(data.get("status").asText()));
                }
                workoutRepository.saveAndFlush(w);
                return new Result(id, w.getId(), created ? CREATED : UPDATED);
            }
            case "DELETE" -> {
                Workout existing = workoutRepository.findById(id).orElse(null);
                if (existing == null || !existing.getUser().getId().equals(user.getId())) {
                    return new Result(id, id, IGNORED_DUPLICATE);
                }
                workoutRepository.delete(existing);
                workoutRepository.flush();
                return new Result(id, id, DELETED);
            }
            default -> {
                return unsupported(id);
            }
        }
    }

    // ------------------------------------------------------------------
    // Workout exercise (parent must exist and belong to the user)
    // ------------------------------------------------------------------

    @Transactional
    public Result workoutExercise(UUID userId, UUID id, String operation, JsonNode data, Instant clientTs) {
        switch (operation) {
            case "CREATE", "UPDATE" -> {
                WorkoutExercise existing = workoutExerciseRepository.findById(id).orElse(null);
                if ("CREATE".equals(operation) && existing != null) {
                    return new Result(id, id, IGNORED_DUPLICATE);
                }
                if (existing != null) {
                    if (!existing.getWorkout().getUser().getId().equals(userId)) {
                        return new Result(id, id, NOT_FOUND);
                    }
                    if (isConflicting(existing.getUpdatedAt(), clientTs)) {
                        return new Result(id, id, CONFLICT);
                    }
                } else {
                    UUID workoutId = uuidOrNull(data, "workoutId");
                    if (workoutId == null || !ownedWorkout(userId, workoutId)) {
                        return new Result(id, id, NOT_FOUND);
                    }
                    existing = new WorkoutExercise();
                    existing.setId(id);
                    existing.setWorkout(workoutRepository.getReferenceById(workoutId));
                    existing.setPosition(workoutExerciseRepository.findNextPosition(workoutId) + 1);
                }
                if (data.hasNonNull("exerciseId")) {
                    UUID exerciseId = UUID.fromString(data.get("exerciseId").asText());
                    existing.setExercise(exerciseRepository.findById(exerciseId)
                            .orElseThrow(() -> new IllegalArgumentException("exerciseId does not exist")));
                }
                if (data.hasNonNull("position")) {
                    existing.setPosition(data.get("position").intValue());
                }
                if (data.hasNonNull("restSeconds")) {
                    existing.setRestSeconds(data.get("restSeconds").intValue());
                }
                if (data.hasNonNull("notes")) {
                    existing.setNotes(data.get("notes").asText());
                }
                try {
                    workoutExerciseRepository.saveAndFlush(existing);
                } catch (DataIntegrityViolationException e) {
                    return new Result(id, id, CONFLICT); // position already occupied
                }
                return new Result(id, existing.getId(),
                        existing.getCreatedAt() == null ? CREATED : UPDATED);
            }
            case "DELETE" -> {
                WorkoutExercise existing = workoutExerciseRepository.findById(id).orElse(null);
                if (existing == null || !existing.getWorkout().getUser().getId().equals(userId)) {
                    return new Result(id, id, IGNORED_DUPLICATE);
                }
                workoutExerciseRepository.delete(existing);
                workoutExerciseRepository.flush();
                return new Result(id, id, DELETED);
            }
            default -> {
                return unsupported(id);
            }
        }
    }

    // ------------------------------------------------------------------
    // Workout set (+ PR re-synchronization)
    // ------------------------------------------------------------------

    @Transactional
    public Result workoutSet(UUID userId, UUID id, String operation, JsonNode data, Instant clientTs) {
        switch (operation) {
            case "CREATE", "UPDATE" -> {
                WorkoutSet existing = workoutSetRepository.findById(id).orElse(null);
                if ("CREATE".equals(operation) && existing != null) {
                    return new Result(id, id, IGNORED_DUPLICATE);
                }
                UUID weId = existing != null
                        ? existing.getWorkoutExercise().getId()
                        : uuidOrNull(data, "workoutExerciseId");
                if (weId == null) {
                    return new Result(id, id, NOT_FOUND);
                }
                WorkoutExercise we = workoutExerciseRepository.findById(weId).orElse(null);
                if (we == null || !we.getWorkout().getUser().getId().equals(userId)) {
                    return new Result(id, id, NOT_FOUND);
                }
                if (existing != null && isConflicting(existing.getUpdatedAt(), clientTs)) {
                    return new Result(id, id, CONFLICT);
                }

                boolean created = existing == null;
                WorkoutSet s = existing != null ? existing : new WorkoutSet();
                if (created) {
                    s.setId(id);
                    s.setWorkoutExercise(we);
                    s.setIsCompleted(true);
                    s.setPosition(workoutSetRepository.findNextPosition(we.getId()) + 1);
                    s.setSetType(SetType.NORMAL);
                }
                if (data.hasNonNull("position")) {
                    s.setPosition(data.get("position").intValue());
                }
                if (data.hasNonNull("setType")) {
                    s.setSetType(SetType.valueOf(data.get("setType").asText()));
                }
                if (data.hasNonNull("weightKg")) {
                    s.setWeightKg(safeDecimal(data, "weightKg"));
                }
                if (data.hasNonNull("reps")) {
                    s.setReps(data.get("reps").intValue());
                }
                if (data.hasNonNull("rpe")) {
                    s.setRpe(safeDecimal(data, "rpe"));
                }
                if (data.hasNonNull("isCompleted")) {
                    s.setIsCompleted(data.get("isCompleted").booleanValue());
                }
                if (data.hasNonNull("completedAt")) {
                    s.setCompletedAt(Instant.parse(data.get("completedAt").asText()));
                }
                workoutSetRepository.saveAndFlush(s);

                if (Boolean.TRUE.equals(s.getIsCompleted())) {
                    personalRecordService.synchronize(userId, we.getExercise().getId());
                }
                return new Result(id, s.getId(), created ? CREATED : UPDATED);
            }
            case "DELETE" -> {
                WorkoutSet existing = workoutSetRepository.findById(id).orElse(null);
                if (existing == null || !existing.getWorkoutExercise().getWorkout().getUser().getId()
                        .equals(userId)) {
                    return new Result(id, id, IGNORED_DUPLICATE);
                }
                UUID exerciseId = existing.getWorkoutExercise().getExercise().getId();
                workoutSetRepository.delete(existing);
                workoutSetRepository.flush();
                personalRecordService.synchronize(userId, exerciseId);
                return new Result(id, id, DELETED);
            }
            default -> {
                return unsupported(id);
            }
        }
    }

    // ------------------------------------------------------------------
    // Routine (full template payload mirrors CreateRoutineRequest)
    // ------------------------------------------------------------------

    @Transactional
    public Result routine(User user, UUID id, String operation, JsonNode data, Instant clientTs) {
        switch (operation) {
            case "CREATE", "UPDATE" -> {
                var existing = routineRepository.findById(id).orElse(null);
                if ("CREATE".equals(operation) && existing != null) {
                    return new Result(id, id, IGNORED_DUPLICATE);
                }
                if (existing != null && !existing.getUser().getId().equals(user.getId())) {
                    return new Result(id, id, NOT_FOUND);
                }
                if (existing != null && isConflicting(existing.getUpdatedAt(), clientTs)) {
                    return new Result(id, id, CONFLICT);
                }
                CreateRoutineRequest request = parseRoutineRequest(data);
                routineService.syncUpsert(user, id, request);
                return new Result(id, id, existing == null ? CREATED : UPDATED);
            }
            case "DELETE" -> {
                var existing = routineRepository.findById(id).orElse(null);
                if (existing == null || !existing.getUser().getId().equals(user.getId())) {
                    return new Result(id, id, IGNORED_DUPLICATE);
                }
                routineRepository.delete(existing);
                routineRepository.flush();
                return new Result(id, id, DELETED);
            }
            default -> {
                return unsupported(id);
            }
        }
    }

    private CreateRoutineRequest parseRoutineRequest(JsonNode data) {
        var mapper = new com.fasterxml.jackson.databind.ObjectMapper();
        CreateRoutineRequest parsed = mapper.convertValue(data, CreateRoutineRequest.class);
        if (parsed.name() == null || parsed.name().isBlank()) {
            throw new IllegalArgumentException("name is required for routine sync");
        }
        return parsed;
    }

    // ------------------------------------------------------------------
    // Food item (custom foods owned by the syncing user)
    // ------------------------------------------------------------------

    @Transactional
    public Result foodItem(UUID userId, UUID id, String operation, JsonNode data, Instant clientTs) {
        switch (operation) {
            case "CREATE", "UPDATE" -> {
                FoodItem existing = foodItemRepository.findById(id).orElse(null);
                if ("CREATE".equals(operation) && existing != null) {
                    return new Result(id, id, IGNORED_DUPLICATE);
                }
                boolean foreign = existing != null && (
                        !Boolean.TRUE.equals(existing.getIsCustom())
                                || existing.getCreatedBy() == null
                                || !userId.equals(existing.getCreatedBy().getId()));
                if (foreign) {
                    return new Result(id, id, CONFLICT); // system rows are immutable via sync
                }
                if (existing != null && isConflicting(existing.getUpdatedAt(), clientTs)) {
                    return new Result(id, id, CONFLICT);
                }
                boolean created = existing == null;
                FoodItem f = existing != null ? existing : new FoodItem();
                if (created) {
                    f.setId(id);
                    f.setIsCustom(true);
                    f.setCreatedBy(userRepository.getReferenceById(userId));
                    f.setProteinG(BigDecimal.ZERO);
                    f.setCarbsG(BigDecimal.ZERO);
                    f.setFatG(BigDecimal.ZERO);
                    f.setServingSize(BigDecimal.ONE);
                    f.setServingUnit("serving");
                    f.setCalories(BigDecimal.ZERO);
                }
                f.setName(textOrDefault(data, "name", orDefault(f.getName(), "Synced Food")));
                if (data.hasNonNull("brand")) {
                    f.setBrand(data.get("brand").asText());
                }
                if (data.hasNonNull("servingSize")) {
                    f.setServingSize(safeDecimal(data, "servingSize"));
                }
                if (data.hasNonNull("servingUnit")) {
                    f.setServingUnit(data.get("servingUnit").asText());
                }
                if (data.hasNonNull("calories")) {
                    f.setCalories(safeDecimal(data, "calories"));
                }
                if (data.hasNonNull("proteinG")) {
                    f.setProteinG(safeDecimal(data, "proteinG"));
                }
                if (data.hasNonNull("carbsG")) {
                    f.setCarbsG(safeDecimal(data, "carbsG"));
                }
                if (data.hasNonNull("fatG")) {
                    f.setFatG(safeDecimal(data, "fatG"));
                }
                if (data.hasNonNull("fiberG")) {
                    f.setFiberG(safeDecimal(data, "fiberG"));
                }
                if (data.hasNonNull("isVegetarian")) {
                    f.setIsVegetarian(data.get("isVegetarian").booleanValue());
                }
                if (data.hasNonNull("foodCategory")) {
                    f.setFoodCategory(data.get("foodCategory").asText());
                }
                foodItemRepository.saveAndFlush(f);
                return new Result(id, f.getId(), created ? CREATED : UPDATED);
            }
            case "DELETE" -> {
                FoodItem existing = foodItemRepository.findById(id).orElse(null);
                if (existing == null || !Boolean.TRUE.equals(existing.getIsCustom())
                        || existing.getCreatedBy() == null
                        || !userId.equals(existing.getCreatedBy().getId())) {
                    return new Result(id, id, IGNORED_DUPLICATE);
                }
                foodItemRepository.delete(existing);
                foodItemRepository.flush();
                return new Result(id, id, DELETED);
            }
            default -> {
                return unsupported(id);
            }
        }
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    /**
     * True when the server row changed meaningfully after the client's
     * snapshot. A one-second grace window absorbs sub-second write latency:
     * without it, an immediate idempotent replay would see server updated_at
     * marginally newer than a second-precision client timestamp and
     * incorrectly report CONFLICT.
     */
    private static boolean isConflicting(Instant serverUpdatedAt, Instant clientTimestamp) {
        return clientTimestamp != null && serverUpdatedAt != null
                && serverUpdatedAt.isAfter(clientTimestamp.plusSeconds(1));
    }

    private boolean ownedWorkout(UUID userId, UUID workoutId) {
        return workoutRepository.findByIdAndUserId(workoutId, userId).isPresent();
    }

    private Result deleteIfExists(boolean exists, Runnable deleter, UUID id) {
        if (!exists) {
            return new Result(id, id, IGNORED_DUPLICATE);
        }
        deleter.run();
        return new Result(id, id, DELETED);
    }

    private Result unsupported(UUID id) {
        return new Result(id, id, UNSUPPORTED_TYPE);
    }

    private static String textOrDefault(JsonNode data, String field, String fallback) {
        return data != null && data.hasNonNull(field) && !data.get(field).asText().isBlank()
                ? data.get(field).asText()
                : fallback;
    }

    private static String orDefault(String value, String fallback) {
        return value != null && !value.isBlank() ? value : fallback;
    }

    private static UUID uuidOrNull(JsonNode data, String field) {
        if (data == null || !data.hasNonNull(field)) {
            return null;
        }
        return UUID.fromString(data.get(field).asText());
    }

    private static BigDecimal safeDecimal(JsonNode data, String field) {
        return data.get(field).decimalValue();
    }
}
