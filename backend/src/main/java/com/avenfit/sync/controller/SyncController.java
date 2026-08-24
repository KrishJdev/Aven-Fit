package com.avenfit.sync.controller;

import com.avenfit.auth.entity.User;
import com.avenfit.common.dto.ApiResponse;
import com.avenfit.sync.dto.SyncPullResponse;
import com.avenfit.sync.dto.SyncPushRequest;
import com.avenfit.sync.dto.SyncPushResponse;
import com.avenfit.sync.service.SyncService;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;

@RestController
@RequestMapping("/api/sync")
public class SyncController {

    private final SyncService syncService;

    public SyncController(SyncService syncService) {
        this.syncService = syncService;
    }

    @PostMapping("/push")
    public ApiResponse<SyncPushResponse> push(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody SyncPushRequest request
    ) {
        return ApiResponse.ok(syncService.push(currentUser, request));
    }

    @GetMapping("/pull")
    public ResponseEntity<ApiResponse<SyncPullResponse>> pull(
            @AuthenticationPrincipal User currentUser,
            @RequestParam("since")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant since
    ) {
        return ResponseEntity.ok(ApiResponse.ok(syncService.pull(currentUser.getId(), since)));
    }
}
