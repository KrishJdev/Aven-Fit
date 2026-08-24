package com.avenfit.common.dto;

/**
 * Standard success envelope per DEVELOPMENT_PLAN.md §1:
 * { "data": ..., "message": "OK" }
 */
public record ApiResponse<T>(T data, String message) {

    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(data, "OK");
    }

    public static <T> ApiResponse<T> of(T data, String message) {
        return new ApiResponse<>(data, message);
    }
}
