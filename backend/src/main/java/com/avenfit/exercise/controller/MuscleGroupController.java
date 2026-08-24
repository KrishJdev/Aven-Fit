package com.avenfit.exercise.controller;

import com.avenfit.common.dto.ApiResponse;
import com.avenfit.exercise.dto.MuscleGroupDto;
import com.avenfit.exercise.repository.MuscleGroupRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/muscle-groups")
public class MuscleGroupController {

    private final MuscleGroupRepository muscleGroupRepository;

    public MuscleGroupController(MuscleGroupRepository muscleGroupRepository) {
        this.muscleGroupRepository = muscleGroupRepository;
    }

    @GetMapping
    public ApiResponse<List<MuscleGroupDto>> list() {
        List<MuscleGroupDto> groups = muscleGroupRepository.findAllByOrderByDisplayOrderAsc().stream()
                .map(MuscleGroupDto::from)
                .toList();
        return ApiResponse.ok(groups);
    }
}
