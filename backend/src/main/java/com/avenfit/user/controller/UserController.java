package com.avenfit.user.controller;

import com.avenfit.auth.entity.User;
import com.avenfit.common.dto.ApiResponse;
import com.avenfit.user.dto.UpdateProfileRequest;
import com.avenfit.user.dto.UserProfileDto;
import com.avenfit.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/me")
    public ApiResponse<UserProfileDto> getMe(@AuthenticationPrincipal User currentUser) {
        return ApiResponse.ok(userService.getProfile(currentUser));
    }

    @PutMapping("/me")
    public ApiResponse<UserProfileDto> updateMe(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody UpdateProfileRequest request
    ) {
        return ApiResponse.ok(userService.updateProfile(currentUser, request));
    }
}
