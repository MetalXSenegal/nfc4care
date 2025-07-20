package com.nfc4care.repository;

import com.nfc4care.entity.Token;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface TokenRepository extends JpaRepository<Token, Long> {
    
    Optional<Token> findByTokenValue(String tokenValue);
    
    List<Token> findByUserEmailAndRevokedFalseAndExpiredFalse(String userEmail);
    
    @Query("SELECT t FROM Token t WHERE t.userEmail = :userEmail AND t.revoked = false AND t.expired = false AND t.expiresAt > :now")
    List<Token> findValidTokensByUser(@Param("userEmail") String userEmail, @Param("now") LocalDateTime now);
    
    @Modifying
    @Transactional
    @Query("UPDATE Token t SET t.revoked = true WHERE t.userEmail = :userEmail")
    void revokeAllUserTokens(@Param("userEmail") String userEmail);
    
    @Modifying
    @Transactional
    @Query("UPDATE Token t SET t.expired = true WHERE t.expiresAt < :now")
    int expireTokens(@Param("now") LocalDateTime now);
    
    @Query("SELECT COUNT(t) FROM Token t WHERE t.userEmail = :userEmail AND t.revoked = false AND t.expired = false")
    long countValidTokensByUser(@Param("userEmail") String userEmail);
    
    @Transactional
    void deleteByExpiresAtBefore(LocalDateTime date);
    
    @Query("SELECT DISTINCT t.userEmail FROM Token t WHERE t.revoked = false AND t.expired = false AND t.expiresAt > :now")
    List<String> findUsersWithActiveTokens(@Param("now") LocalDateTime now);
} 