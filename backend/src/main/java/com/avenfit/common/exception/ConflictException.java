package com.avenfit.common.exception;

/**
 * Thrown when an operation conflicts with current resource state — mapped
 * to 409 per DEVELOPMENT_PLAN.md §1.
 */
public class ConflictException extends RuntimeException {

    public ConflictException(String message) {
        super(message);
    }
}
