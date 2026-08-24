package com.avenfit.auth.repository;

import com.avenfit.auth.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByPhoneNumber(String phoneNumber);

    Optional<User> findByGoogleId(String googleId);

    Optional<User> findByEmail(String email);
}
