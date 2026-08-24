package com.avenfit.analytics.controller;

import com.avenfit.auth.entity.User;
import com.avenfit.common.dto.ApiResponse;
import com.avenfit.analytics.dto.ExerciseHistoryDto;
import com.avenfit.analytics.dto.PersonalRecordGroupDto;
import com.avenfit.analytics.dto.SummaryDto;
import com.avenfit.analytics.service.AnalyticsService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/analytics")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    public AnalyticsController(AnalyticsService analyticsService) {
        this.analyticsService = analyticsService;
    }

    @GetMapping("/personal-records")
    public ApiResponse<List<PersonalRecordGroupDto>> personalRecords(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) UUID exerciseId
    ) {
        return ApiResponse.ok(analyticsService.personalRecords(currentUser.getId(), exerciseId));
    }

    @GetMapping("/exercise/{exerciseId}/history")
    public ApiResponse<ExerciseHistoryDto> exerciseHistory(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID exerciseId
    ) {
        return ApiResponse.ok(analyticsService.exerciseHistory(currentUser.getId(), exerciseId));
    }

    @GetMapping("/summary")
    public ApiResponse<SummaryDto> summary(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) Integer days
    ) {
        return ApiResponse.ok(analyticsService.summary(currentUser.getId(), days));
    }
}
