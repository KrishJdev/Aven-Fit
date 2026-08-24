package com.avenfit.workout.controller;

import com.avenfit.auth.entity.User;
import com.avenfit.common.dto.ApiResponse;
import com.avenfit.common.dto.PagedResponse;
import com.avenfit.workout.dto.CreateWorkoutRequest;
import com.avenfit.workout.dto.LogSetRequest;
import com.avenfit.workout.dto.SetLogResponse;
import com.avenfit.workout.dto.WorkoutDto;
import com.avenfit.workout.dto.WorkoutExerciseDto;
import com.avenfit.workout.dto.WorkoutSummaryDto;
import com.avenfit.workout.service.WorkoutService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/workouts")
public class WorkoutController {

    private final WorkoutService workoutService;

    public WorkoutController(WorkoutService workoutService) {
        this.workoutService = workoutService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<WorkoutDto>> start(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreateWorkoutRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(workoutService.start(currentUser, request)));
    }

    @GetMapping
    public PagedResponse<WorkoutSummaryDto> history(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(defaultValue = "0") Integer page,
            @RequestParam(defaultValue = "20") Integer size,
            @RequestParam(required = false) String status
    ) {
        return workoutService.history(currentUser.getId(), page, size, status);
    }

    @GetMapping("/{id}")
    public ApiResponse<WorkoutDto> detail(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID id
    ) {
        return ApiResponse.ok(workoutService.getDetail(currentUser.getId(), id));
    }

    @PostMapping("/{workoutId}/exercises")
    public ResponseEntity<ApiResponse<WorkoutExerciseDto>> addExercise(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID workoutId,
            @Valid @RequestBody AddExerciseRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(workoutService.addExercise(
                        currentUser.getId(), workoutId, request.exerciseId(), request.restSeconds())));
    }

    public record AddExerciseRequest(
            java.util.UUID exerciseId,
            Integer restSeconds
    ) {
    }

    @DeleteMapping("/{workoutId}/exercises/{workoutExerciseId}")
    public ResponseEntity<Void> removeExercise(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID workoutId,
            @PathVariable UUID workoutExerciseId
    ) {
        workoutService.removeExercise(currentUser.getId(), workoutId, workoutExerciseId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{workoutId}/exercises/{workoutExerciseId}/sets")
    public ApiResponse<SetLogResponse> logSet(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID workoutId,
            @PathVariable UUID workoutExerciseId,
            @Valid @RequestBody LogSetRequest request
    ) {
        return ApiResponse.ok(workoutService.logSet(currentUser.getId(), workoutId, workoutExerciseId, request));
    }

    @PutMapping("/{workoutId}/sets/{setId}")
    public ApiResponse<SetLogResponse> updateSet(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID workoutId,
            @PathVariable UUID setId,
            @Valid @RequestBody LogSetRequest request
    ) {
        return ApiResponse.ok(workoutService.updateSet(currentUser.getId(), workoutId, setId, request));
    }

    @DeleteMapping("/{workoutId}/sets/{setId}")
    public ResponseEntity<Void> deleteSet(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID workoutId,
            @PathVariable UUID setId
    ) {
        workoutService.deleteSet(currentUser.getId(), workoutId, setId);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{workoutId}/complete")
    public ApiResponse<WorkoutDto> complete(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID workoutId,
            @Valid @RequestBody CompleteRequest request
    ) {
        return ApiResponse.ok(workoutService.complete(currentUser.getId(), workoutId, request.notes()));
    }

    public record CompleteRequest(String notes) {
    }

    @PutMapping("/{workoutId}/cancel")
    public ApiResponse<WorkoutDto> cancel(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID workoutId
    ) {
        return ApiResponse.ok(workoutService.cancel(currentUser.getId(), workoutId));
    }
}
