package com.avenfit.auth.repository;

import com.avenfit.auth.entity.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    Optional<RefreshToken> findByToken(String token);

    void deleteByToken(String token);

    /**
     * Conditional delete used by refresh rotation: returns the number of rows
     * removed so concurrent rotations of the same token have exactly one
     * winner (0 means another request already consumed it).
     */
    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.data.jpa.repository.Query(
            "delete from RefreshToken rt where rt.token = :token")
    int deleteByTokenReturningCount(@org.springframework.data.repository.query.Param("token") String token);

    /** Live-token count for a user (rotation race assertions). */
    long countByUser_Id(java.util.UUID userId);
}
