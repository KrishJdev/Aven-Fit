package com.avenfit.common.dto;

import org.springframework.data.domain.Page;

import java.util.List;

/**
 * Standard paginated list envelope per DEVELOPMENT_PLAN.md §1.
 */
public record PagedResponse<T>(
        List<T> data,
        int page,
        int size,
        long totalElements,
        int totalPages
) {
    public static <T> PagedResponse<T> from(Page<T> page) {
        return new PagedResponse<>(
                page.getContent(),
                page.getNumber(),
                page.getSize(),
                page.getTotalElements(),
                page.getTotalPages()
        );
    }
}
