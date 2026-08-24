package com.avenfit.exercise.controller;

import com.avenfit.auth.entity.User;
import com.avenfit.common.dto.ApiResponse;
import com.avenfit.common.dto.PagedResponse;
import com.avenfit.exercise.dto.CreateExerciseRequest;
import com.avenfit.exercise.dto.ExerciseDto;
import com.avenfit.exercise.service.ExerciseService;
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

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/exercises")
public class ExerciseController {

    private final ExerciseService exerciseService;

    public ExerciseController(ExerciseService exerciseService) {
        this.exerciseService = exerciseService;
    }

    @GetMapping
    public PagedResponse<ExerciseDto> list(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String muscleGroup,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return exerciseService.list(
                currentUser.getId(), search, category, muscleGroup, page, size);
    }

    @GetMapping("/{id}")
    public ApiResponse<ExerciseDto> get(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID id
    ) {
        return ApiResponse.ok(exerciseService.getVisibleExercise(currentUser.getId(), id));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ExerciseDto>> create(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreateExerciseRequest request
    ) {
        ExerciseDto created = exerciseService.create(currentUser, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(created));
    }

    @PutMapping("/{id}")
    public ApiResponse<ExerciseDto> update(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID id,
            @Valid @RequestBody CreateExerciseRequest request
    ) {
        return ApiResponse.ok(exerciseService.update(currentUser.getId(), id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID id
    ) {
        exerciseService.delete(currentUser.getId(), id);
        return ResponseEntity.noContent().build();
    }
}
