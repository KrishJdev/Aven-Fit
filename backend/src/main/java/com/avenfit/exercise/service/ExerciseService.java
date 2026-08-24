package com.avenfit.exercise.service;

import com.avenfit.auth.entity.User;
import com.avenfit.common.dto.PagedResponse;
import com.avenfit.common.exception.ResourceNotFoundException;
import com.avenfit.exercise.dto.CreateExerciseRequest;
import com.avenfit.exercise.dto.ExerciseDto;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.exercise.entity.ExerciseCategory;
import com.avenfit.exercise.entity.ExerciseMuscleGroup;
import com.avenfit.exercise.entity.MuscleGroup;
import com.avenfit.exercise.entity.MuscleRole;
import com.avenfit.exercise.repository.ExerciseRepository;
import com.avenfit.exercise.repository.MuscleGroupRepository;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class ExerciseService {

    private static final int MAX_PAGE_SIZE = 100;

    private final ExerciseRepository exerciseRepository;
    private final MuscleGroupRepository muscleGroupRepository;

    public ExerciseService(ExerciseRepository exerciseRepository, MuscleGroupRepository muscleGroupRepository) {
        this.exerciseRepository = exerciseRepository;
        this.muscleGroupRepository = muscleGroupRepository;
    }

    @Transactional(readOnly = true)
    public PagedResponse<ExerciseDto> list(
            UUID userId, String search, String category, String muscleGroup, int page, int size) {
        Pageable pageable = PageRequest.of(page, pageSize(size), Sort.by(Sort.Direction.ASC, "name"));

        Specification<Exercise> spec = visibleTo(userId);
        String trimmedSearch = StringUtils.hasText(search) ? search.trim() : null;
        if (trimmedSearch != null) {
            spec = spec.and(nameContains(trimmedSearch));
        }
        if (StringUtils.hasText(category)) {
            spec = spec.and(hasCategory(parseCategory(category)));
        }
        if (StringUtils.hasText(muscleGroup)) {
            spec = spec.and(hasMuscleGroup(muscleGroup.trim()));
        }

        Page<Exercise> result = exerciseRepository.findAll(spec, pageable);
        return PagedResponse.from(result.map(ExerciseDto::from));
    }

    @Transactional(readOnly = true)
    public ExerciseDto getVisibleExercise(UUID userId, UUID exerciseId) {
        Exercise exercise = exerciseRepository.findById(exerciseId)
                .orElseThrow(() -> ResourceNotFoundException.of("Exercise", exerciseId));
        requireVisible(userId, exercise);
        return ExerciseDto.from(exercise);
    }

    @Transactional
    public ExerciseDto create(User currentUser, CreateExerciseRequest request) {
        List<MuscleGroup> primary = resolveMuscleGroups(request.primaryMuscleGroupIds());
        List<MuscleGroup> secondary = resolveMuscleGroups(
                request.secondaryMuscleGroupIds() == null ? List.of() : request.secondaryMuscleGroupIds());

        Exercise exercise = new Exercise();
        exercise.setName(request.name().trim());
        exercise.setDescription(emptyToNull(request.description()));
        exercise.setCategory(request.category());
        exercise.setEquipment(request.equipment());
        exercise.setIsCustom(true);
        exercise.setCreatedBy(currentUser);
        applyMuscleGroups(exercise, primary, secondary);

        return ExerciseDto.from(exerciseRepository.save(exercise));
    }

    @Transactional
    public ExerciseDto update(UUID userId, UUID exerciseId, CreateExerciseRequest request) {
        Exercise exercise = loadOwnedCustomExercise(userId, exerciseId);

        List<MuscleGroup> primary = resolveMuscleGroups(request.primaryMuscleGroupIds());
        List<MuscleGroup> secondary = resolveMuscleGroups(
                request.secondaryMuscleGroupIds() == null ? List.of() : request.secondaryMuscleGroupIds());

        exercise.setName(request.name().trim());
        exercise.setDescription(emptyToNull(request.description()));
        exercise.setCategory(request.category());
        exercise.setEquipment(request.equipment());
        // Muscle-group links are synced in place by applyMuscleGroups —
        // never clear() + re-add: unique constraint breaks mid-flush.
        applyMuscleGroups(exercise, primary, secondary);

        return ExerciseDto.from(exerciseRepository.save(exercise));
    }

    @Transactional
    public void delete(UUID userId, UUID exerciseId) {
        Exercise exercise = loadOwnedCustomExercise(userId, exerciseId);
        exerciseRepository.delete(exercise);
    }

    private Exercise loadOwnedCustomExercise(UUID userId, UUID exerciseId) {
        Exercise exercise = exerciseRepository.findById(exerciseId)
                .orElseThrow(() -> ResourceNotFoundException.of("Exercise", exerciseId));
        boolean owned = Boolean.TRUE.equals(exercise.getIsCustom())
                && exercise.getCreatedBy() != null
                && userId.equals(exercise.getCreatedBy().getId());
        if (!owned) {
            throw new AccessDeniedException("Only your own custom exercises can be modified");
        }
        return exercise;
    }

    private void requireVisible(UUID userId, Exercise exercise) {
        boolean system = !Boolean.TRUE.equals(exercise.getIsCustom());
        boolean own = exercise.getCreatedBy() != null && userId.equals(exercise.getCreatedBy().getId());
        if (!system && !own) {
            // Custom exercises of other users are treated as non-existent.
            throw ResourceNotFoundException.of("Exercise", exercise.getId());
        }
    }

    private void applyMuscleGroups(Exercise exercise, List<MuscleGroup> primary, List<MuscleGroup> secondary) {
        Map<UUID, MuscleRole> wanted = new LinkedHashMap<>();
        for (MuscleGroup g : primary) {
            wanted.put(g.getId(), MuscleRole.PRIMARY);
        }
        for (MuscleGroup g : secondary) {
            if (wanted.containsKey(g.getId())) {
                throw new IllegalArgumentException("A muscle group cannot be both primary and secondary");
            }
            wanted.put(g.getId(), MuscleRole.SECONDARY);
        }

        // Update existing links in place; remove only truly-dropped ones.
        // Never delete-and-reinsert the same key: the unique constraint
        // uq_exercise_muscle would be violated mid-flush depending on the
        // order Hibernate chooses for orphan deletes vs inserts.
        Map<UUID, ExerciseMuscleGroup> existing = new HashMap<>();
        for (ExerciseMuscleGroup emg : exercise.getMuscleGroups()) {
            existing.put(emg.getMuscleGroup().getId(), emg);
        }
        exercise.getMuscleGroups().removeIf(emg -> !wanted.containsKey(emg.getMuscleGroup().getId()));

        List<UUID> groupOrder = new ArrayList<>();
        for (var entry : wanted.entrySet()) {
            UUID groupId = entry.getKey();
            groupOrder.add(groupId);
            ExerciseMuscleGroup emg = existing.get(groupId);
            if (emg != null) {
                emg.setRole(entry.getValue());
            } else {
                ExerciseMuscleGroup created = new ExerciseMuscleGroup();
                created.setExercise(exercise);
                created.setMuscleGroup(muscleGroupRepository.getReferenceById(groupId));
                created.setRole(entry.getValue());
                exercise.getMuscleGroups().add(created);
            }
        }
    }

    private List<MuscleGroup> resolveMuscleGroups(List<UUID> ids) {
        LinkedHashSet<UUID> uniqueIds = new LinkedHashSet<>(ids);
        var groups = muscleGroupRepository.findAllById(uniqueIds);
        if (groups.size() != uniqueIds.size()) {
            Set<UUID> found = groups.stream().map(MuscleGroup::getId).collect(java.util.stream.Collectors.toSet());
            uniqueIds.stream()
                    .filter(id -> !found.contains(id))
                    .findFirst()
                    .ifPresent(id -> {
                        throw ResourceNotFoundException.of("Muscle group", id);
                    });
        }
        return new ArrayList<>(groups);
    }

    private Specification<Exercise> visibleTo(UUID userId) {
        return (root, query, cb) -> cb.or(
                cb.isFalse(root.<Boolean>get("isCustom")),
                cb.equal(root.get("createdBy").get("id"), userId)
        );
    }

    private Specification<Exercise> nameContains(String search) {
        String pattern = "%" + search.toLowerCase() + "%";
        return (root, query, cb) -> cb.like(cb.lower(root.<String>get("name")), pattern);
    }

    private Specification<Exercise> hasCategory(ExerciseCategory category) {
        return (root, query, cb) -> cb.equal(root.get("category"), category);
    }

    private Specification<Exercise> hasMuscleGroup(String muscleGroupName) {
        return (root, query, cb) -> {
            var subquery = query.subquery(Long.class);
            var emg = subquery.from(ExerciseMuscleGroup.class);
            subquery.select(cb.literal(1L));
            Predicate joinsExercise = cb.equal(emg.get("exercise"), root);
            Predicate matchesGroup = cb.equal(emg.get("muscleGroup").get("name"), muscleGroupName);
            subquery.where(joinsExercise, matchesGroup);
            return cb.exists(subquery);
        };
    }

    private static ExerciseCategory parseCategory(String category) {
        try {
            return ExerciseCategory.valueOf(category.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Unknown category: " + category);
        }
    }

    private static int pageSize(int size) {
        if (size < 1 || size > MAX_PAGE_SIZE) {
            throw new IllegalArgumentException("size must be between 1 and " + MAX_PAGE_SIZE);
        }
        return size;
    }

    private static String emptyToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }
}
