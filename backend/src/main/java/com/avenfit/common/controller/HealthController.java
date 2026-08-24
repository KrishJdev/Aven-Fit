package com.avenfit.common.controller;

import java.time.Instant;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/health")
public class HealthController {

    public record HealthResponse(String status, Instant timestamp) {
    }

    @GetMapping
    public HealthResponse health() {
        return new HealthResponse("UP", Instant.now());
    }
}
