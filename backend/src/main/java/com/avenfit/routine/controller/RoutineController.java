package com.avenfit.routine.controller;

import com.avenfit.auth.entity.User;
import com.avenfit.common.dto.ApiResponse;
import com.avenfit.routine.dto.CreateRoutineRequest;
import com.avenfit.routine.dto.RoutineDetailDto;
import com.avenfit.routine.dto.RoutineDto;
import com.avenfit.routine.service.RoutineService;
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
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/routines")
public class RoutineController {

    private final RoutineService routineService;

    public RoutineController(RoutineService routineService) {
        this.routineService = routineService;
    }

    @GetMapping
    public ApiResponse<List<RoutineDto>> list(@AuthenticationPrincipal User currentUser) {
        return ApiResponse.ok(routineService.list(currentUser.getId()));
    }

    @GetMapping("/{id}")
    public ApiResponse<RoutineDetailDto> detail(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID id
    ) {
        return ApiResponse.ok(routineService.get(currentUser.getId(), id));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<RoutineDetailDto>> create(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreateRoutineRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(routineService.create(currentUser, request)));
    }

    @PutMapping("/{id}")
    public ApiResponse<RoutineDetailDto> replace(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID id,
            @Valid @RequestBody CreateRoutineRequest request
    ) {
        return ApiResponse.ok(routineService.replace(currentUser.getId(), id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID id
    ) {
        routineService.delete(currentUser.getId(), id);
        return ResponseEntity.noContent().build();
    }
}
