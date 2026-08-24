package com.avenfit.sync.dto;

import java.util.List;
import java.util.UUID;

/**
 * Push result per Task 9.1. Statuses:
 * CREATED, UPDATED, DELETED, IGNORED_DUPLICATE (idempotent replay),
 * CONFLICT (server row is newer), UNSUPPORTED_TYPE, NOT_FOUND, FAILED.
 */
public record SyncPushResponse(
        int processed,
        int conflicts,
        List<OperationResult> results
) {

    public record OperationResult(UUID clientId, UUID serverId, String status) {
    }
}
