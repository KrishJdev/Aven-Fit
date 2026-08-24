package com.avenfit.routine.service;

import com.avenfit.auth.entity.User;
import com.avenfit.common.exception.ResourceNotFoundException;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.exercise.repository.ExerciseRepository;
import com.avenfit.routine.dto.CreateRoutineRequest;
import com.avenfit.routine.dto.RoutineDetailDto;
import com.avenfit.routine.dto.RoutineDto;
import com.avenfit.routine.entity.Routine;
import com.avenfit.routine.entity.RoutineExercise;
import com.avenfit.routine.entity.RoutineSet;
import com.avenfit.routine.repository.RoutineRepository;
import com.avenfit.workout.entity.SetType;
import jakarta.persistence.EntityManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class RoutineService {

    private static final int DEFAULT_REST_SECONDS = 90;

    private final RoutineRepository routineRepository;
    private final ExerciseRepository exerciseRepository;
    private final EntityManager entityManager;

    public RoutineService(RoutineRepository routineRepository, ExerciseRepository exerciseRepository,
                          EntityManager entityManager) {
        this.routineRepository = routineRepository;
        this.exerciseRepository = exerciseRepository;
        this.entityManager = entityManager;
    }

    @Transactional(readOnly = true)
    public List<RoutineDto> list(UUID userId) {
        List<Routine> routines = routineRepository.findByUserIdOrderByUpdatedAtDesc(userId);
        Map<UUID, Long> counts = new HashMap<>();
        if (!routines.isEmpty()) {
            for (RoutineRepository.RoutineSummaryRow row :
                    routineRepository.summarize(routines.stream().map(Routine::getId).toList())) {
                counts.put(row.getRoutineId(), row.getExerciseCount());
            }
        }
        return routines.stream()
                .map(r -> new RoutineDto(
                        r.getId(),
                        r.getName(),
                        r.getDescription(),
                        counts.getOrDefault(r.getId(), 0L),
                        r.getCreatedAt()))
                .toList();
    }

    @Transactional(readOnly = true)
    public RoutineDetailDto get(UUID userId, UUID routineId) {
        Routine routine = owned(userId, routineId);
        return toDetail(routine, routineRepository.findWithSetsByRoutineId(routineId));
    }

    @Transactional
    public RoutineDetailDto create(User currentUser, CreateRoutineRequest request) {
        Routine routine = new Routine();
        routine.setUser(currentUser);
        applyFields(routine, request);
        rebuildChildren(routine, currentUser.getId(), request);
        routine = routineRepository.save(routine);
        return toDetail(routine, routine.getExercises());
    }

    /**
     * Full replace per Task 5.1. Children are bulk-deleted in FK order, then
     * the persistence context is cleared and the routine re-fetched — stale
     * managed children would otherwise emit orphan-removal DELETEs against
     * already-deleted rows (Hibernate 6 checks row counts and throws).
     */
    @Transactional
    public RoutineDetailDto replace(UUID userId, UUID routineId, CreateRoutineRequest request) {
        owned(userId, routineId);

        routineRepository.deleteSetsForRoutine(routineId);
        routineRepository.deleteExercisesForRoutine(routineId);
        entityManager.flush();
        entityManager.clear();

        Routine routine = routineRepository.findById(routineId)
                .orElseThrow(() -> ResourceNotFoundException.of("Routine", routineId));

        applyFields(routine, request);
        rebuildChildren(routine, userId, request);
        routine = routineRepository.saveAndFlush(routine);
        return toDetail(routine, routineRepository.findWithSetsByRoutineId(routineId));
    }

    @Transactional
    public void delete(UUID userId, UUID routineId) {
        Routine routine = owned(userId, routineId);
        // workouts.routine_id is ON DELETE SET NULL (V4), so deletion is safe
        routineRepository.delete(routine);
    }

    // ------------------------------------------------------------------

    private Routine owned(UUID userId, UUID routineId) {
        return routineRepository.findByIdAndUserId(routineId, userId)
                .orElseThrow(() -> ResourceNotFoundException.of("Routine", routineId));
    }

    private void applyFields(Routine routine, CreateRoutineRequest request) {
        routine.setName(request.name().trim());
        routine.setDescription(request.description() == null || request.description().isBlank()
                ? null : request.description().trim());
    }

    private void rebuildChildren(Routine routine, UUID userId, CreateRoutineRequest request) {
        List<CreateRoutineRequest.RoutineExerciseRequest> requested =
                request.exercises() == null ? List.of() : request.exercises();

        Set<Integer> seenPositions = new HashSet<>();
        for (CreateRoutineRequest.RoutineExerciseRequest re : requested) {
            if (!seenPositions.add(re.position())) {
                throw new IllegalArgumentException("Duplicate exercise position: " + re.position());
            }
            Exercise exercise = visibleExercise(userId, re.exerciseId());

            RoutineExercise routineExercise = new RoutineExercise();
            routineExercise.setRoutine(routine);
            routineExercise.setExercise(exercise);
            routineExercise.setPosition(re.position());
            routineExercise.setRestSeconds(re.restSeconds() != null ? re.restSeconds() : DEFAULT_REST_SECONDS);
            routineExercise.setNotes(re.notes() == null || re.notes().isBlank() ? null : re.notes().trim());
            routine.getExercises().add(routineExercise);

            List<CreateRoutineRequest.RoutineSetRequest> requestedSets =
                    re.sets() == null ? List.of() : re.sets();
            Set<Integer> seenSetPositions = new HashSet<>();
            int autoPosition = 1;
            for (CreateRoutineRequest.RoutineSetRequest rs : requestedSets) {
                Integer position = rs.position();
                if (!seenSetPositions.add(position)) {
                    throw new IllegalArgumentException(
                            "Duplicate set position " + position + " for exercise at position " + re.position());
                }
                RoutineSet routineSet = new RoutineSet();
                routineSet.setRoutineExercise(routineExercise);
                routineSet.setPosition(position != null ? position : autoPosition);
                routineSet.setSetType(rs.setType() == null ? SetType.NORMAL : rs.setType());
                routineSet.setTargetReps(rs.targetReps());
                routineSet.setTargetWeightKg(rs.targetWeightKg());
                routineSet.setTargetRpe(rs.targetRpe());
                routineExercise.getSets().add(routineSet);
                autoPosition++;
            }
        }
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

    private RoutineDetailDto toDetail(Routine routine, List<RoutineExercise> exercises) {
        List<RoutineDetailDto.RoutineExerciseDto> exerciseDtos = new ArrayList<>();
        for (RoutineExercise re : exercises) {
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
}
