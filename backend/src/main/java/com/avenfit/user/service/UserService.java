package com.avenfit.user.service;

import com.avenfit.auth.entity.User;
import com.avenfit.auth.repository.UserRepository;
import com.avenfit.common.exception.ResourceNotFoundException;
import com.avenfit.user.dto.UpdateProfileRequest;
import com.avenfit.user.dto.UserProfileDto;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public UserProfileDto getProfile(User user) {
        return UserProfileDto.from(user);
    }

    /**
     * Partial update — only non-null fields from the request are applied.
     */
    @Transactional
    public UserProfileDto updateProfile(User currentUser, UpdateProfileRequest request) {
        User user = userRepository.findById(currentUser.getId())
                .orElseThrow(() -> ResourceNotFoundException.of("User", currentUser.getId()));

        if (StringUtils.hasText(request.displayName())) {
            user.setDisplayName(request.displayName().trim());
        }
        if (request.heightCm() != null) {
            user.setHeightCm(request.heightCm());
        }
        if (request.weightKg() != null) {
            user.setWeightKg(request.weightKg());
        }
        if (request.dateOfBirth() != null) {
            user.setDateOfBirth(request.dateOfBirth());
        }
        if (request.gender() != null) {
            user.setGender(request.gender());
        }
        if (request.unitPreference() != null) {
            user.setUnitPreference(request.unitPreference());
        }
        return UserProfileDto.from(userRepository.save(user));
    }
}
