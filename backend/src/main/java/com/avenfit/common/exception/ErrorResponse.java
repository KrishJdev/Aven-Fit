package com.avenfit.common.exception;

import java.util.Map;

/**
 * Standard error envelope per DEVELOPMENT_PLAN.md §1:
 * { "error": "...", "message": "...", "details": {...} }
 */
public record ErrorResponse(String error, String message, Map<String, Object> details) {

    public static ErrorResponse of(String error, String message) {
        return new ErrorResponse(error, message, null);
    }

    public static ErrorResponse of(String error, String message, Map<String, Object> details) {
        return new ErrorResponse(error, message, details);
    }
}
