package com.avenfit.sync.dto;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record SyncPushRequest(
        @NotEmpty(message = "operations is required")
        @Valid
        List<SyncOperation> operations
) {

    public record SyncOperation(
            @NotBlank(message = "entityType is required")
            String entityType,

            @NotNull(message = "entityId is required")
            UUID entityId,

            /** CREATE, UPDATE or DELETE. */
            @NotBlank(message = "operation is required")
            String operation,

            /** Full entity JSON — required for CREATE/UPDATE, ignored for DELETE. */
            JsonNode data,

            Instant clientTimestamp
    ) {
    }
}
