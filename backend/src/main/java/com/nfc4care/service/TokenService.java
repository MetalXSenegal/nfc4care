package com.nfc4care.service;

import com.nfc4care.entity.Token;
import com.nfc4care.repository.TokenRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class TokenService {
    
    private final TokenRepository tokenRepository;
    
    /**
     * Sauvegarde un token en base de données
     * Assure qu'il n'y a qu'un seul token actif par utilisateur
     */
    @Transactional
    public Token saveToken(String tokenValue, String userEmail, LocalDateTime expiresAt, String userAgent, String ipAddress) {
        log.info("Sauvegarde du token pour l'utilisateur: {}", userEmail);
        
        // Désactiver tous les tokens actifs existants pour cet utilisateur
        List<Token> activeTokens = tokenRepository.findValidTokensByUser(userEmail, LocalDateTime.now());
        if (!activeTokens.isEmpty()) {
            log.info("Désactivation de {} tokens actifs existants pour l'utilisateur: {}", activeTokens.size(), userEmail);
            for (Token activeToken : activeTokens) {
                activeToken.setRevoked(true);
                tokenRepository.save(activeToken);
                log.debug("Token désactivé: {}", activeToken.getTokenValue().substring(0, Math.min(20, activeToken.getTokenValue().length())));
            }
        }
        
        // Créer le nouveau token
        Token token = Token.builder()
                .tokenValue(tokenValue)
                .userEmail(userEmail)
                .expiresAt(expiresAt)
                .userAgent(userAgent)
                .ipAddress(ipAddress)
                .revoked(false)
                .expired(false)
                .build();
        
        Token savedToken = tokenRepository.save(token);
        log.info("Nouveau token actif créé avec l'ID: {} pour l'utilisateur: {}", savedToken.getId(), userEmail);
        
        // Vérifier qu'il n'y a qu'un seul token actif
        long activeTokenCount = tokenRepository.countValidTokensByUser(userEmail);
        log.info("Nombre de tokens actifs pour {}: {}", userEmail, activeTokenCount);
        
        return savedToken;
    }
    
    /**
     * Vérifie si un token est valide en base de données
     */
    public boolean isTokenValid(String tokenValue) {
        log.debug("Vérification de la validité du token: {}", tokenValue.substring(0, Math.min(20, tokenValue.length())));
        
        Optional<Token> tokenOpt = tokenRepository.findByTokenValue(tokenValue);
        
        if (tokenOpt.isEmpty()) {
            log.warn("Token non trouvé en base de données");
            return false;
        }
        
        Token token = tokenOpt.get();
        
        // Vérifier si le token est révoqué
        if (token.isRevoked()) {
            log.warn("Token révoqué pour l'utilisateur: {}", token.getUserEmail());
            return false;
        }
        
        // Vérifier si le token est expiré
        if (token.isExpired() || token.getExpiresAt().isBefore(LocalDateTime.now())) {
            log.warn("Token expiré pour l'utilisateur: {}", token.getUserEmail());
            // Marquer comme expiré en base
            token.setExpired(true);
            tokenRepository.save(token);
            return false;
        }
        
        log.debug("Token valide pour l'utilisateur: {}", token.getUserEmail());
        return true;
    }
    
    /**
     * Récupère l'email de l'utilisateur associé au token
     */
    public Optional<String> getUserEmailFromToken(String tokenValue) {
        return tokenRepository.findByTokenValue(tokenValue)
                .map(Token::getUserEmail);
    }
    
    /**
     * Révoque un token spécifique
     */
    public void revokeToken(String tokenValue) {
        log.info("Révocation du token: {}", tokenValue.substring(0, Math.min(20, tokenValue.length())));
        
        tokenRepository.findByTokenValue(tokenValue)
                .ifPresent(token -> {
                    token.setRevoked(true);
                    tokenRepository.save(token);
                    log.info("Token révoqué pour l'utilisateur: {}", token.getUserEmail());
                });
    }
    
    /**
     * Révoque tous les tokens d'un utilisateur
     */
    public void revokeAllUserTokens(String userEmail) {
        log.info("Révocation de tous les tokens pour l'utilisateur: {}", userEmail);
        tokenRepository.revokeAllUserTokens(userEmail);
    }
    
    /**
     * Récupère tous les tokens valides d'un utilisateur
     */
    public List<Token> getValidTokensByUser(String userEmail) {
        return tokenRepository.findValidTokensByUser(userEmail, LocalDateTime.now());
    }
    
    /**
     * Nettoie les tokens expirés (tâche planifiée)
     */
    @Scheduled(fixedRate = 3600000) // Toutes les heures
    @Transactional
    public void cleanExpiredTokens() {
        log.info("Nettoyage des tokens expirés...");
        
        try {
            // Marquer les tokens expirés
            int expiredCount = tokenRepository.expireTokens(LocalDateTime.now());
            log.info("{} tokens marqués comme expirés", expiredCount);
            
            // Supprimer les tokens expirés depuis plus de 24h
            LocalDateTime cutoffDate = LocalDateTime.now().minusHours(24);
            tokenRepository.deleteByExpiresAtBefore(cutoffDate);
            
            log.info("Nettoyage des tokens expirés terminé avec succès");
        } catch (Exception e) {
            log.error("Erreur lors du nettoyage des tokens expirés: {}", e.getMessage(), e);
        }
    }
    
    /**
     * Nettoie les tokens multiples pour tous les utilisateurs (tâche planifiée)
     */
    @Scheduled(fixedRate = 1800000) // Toutes les 30 minutes
    @Transactional
    public void cleanMultipleTokensForAllUsers() {
        log.info("Vérification des tokens multiples pour tous les utilisateurs...");
        
        try {
            // Récupérer tous les utilisateurs avec des tokens actifs
            List<String> usersWithTokens = tokenRepository.findUsersWithActiveTokens(LocalDateTime.now());
            
            int cleanedUsers = 0;
            for (String userEmail : usersWithTokens) {
                long activeTokenCount = tokenRepository.countValidTokensByUser(userEmail);
                if (activeTokenCount > 1) {
                    log.info("Nettoyage des tokens multiples pour l'utilisateur: {} ({} tokens)", userEmail, activeTokenCount);
                    cleanMultipleTokensForUser(userEmail);
                    cleanedUsers++;
                }
            }
            
            if (cleanedUsers > 0) {
                log.info("Nettoyage terminé pour {} utilisateurs", cleanedUsers);
            } else {
                log.debug("Aucun utilisateur avec des tokens multiples trouvé");
            }
        } catch (Exception e) {
            log.error("Erreur lors du nettoyage des tokens multiples: {}", e.getMessage(), e);
        }
    }
    
    /**
     * Compte le nombre de tokens valides pour un utilisateur
     */
    public long countValidTokensByUser(String userEmail) {
        return tokenRepository.countValidTokensByUser(userEmail);
    }
    
    /**
     * Nettoie les tokens multiples pour un utilisateur
     * Garde seulement le token le plus récent
     */
    @Transactional
    public void cleanMultipleTokensForUser(String userEmail) {
        log.info("Nettoyage des tokens multiples pour l'utilisateur: {}", userEmail);
        
        List<Token> activeTokens = tokenRepository.findValidTokensByUser(userEmail, LocalDateTime.now());
        
        if (activeTokens.size() > 1) {
            log.warn("{} tokens actifs trouvés pour l'utilisateur: {}", activeTokens.size(), userEmail);
            
            // Trier par date de création (le plus récent en premier)
            activeTokens.sort((t1, t2) -> t2.getCreatedAt().compareTo(t1.getCreatedAt()));
            
            // Garder seulement le premier (le plus récent) et désactiver les autres
            for (int i = 1; i < activeTokens.size(); i++) {
                Token tokenToRevoke = activeTokens.get(i);
                tokenToRevoke.setRevoked(true);
                tokenRepository.save(tokenToRevoke);
                log.info("Token désactivé (multiple): {}", tokenToRevoke.getTokenValue().substring(0, Math.min(20, tokenToRevoke.getTokenValue().length())));
            }
            
            log.info("Nettoyage terminé. 1 token actif conservé pour l'utilisateur: {}", userEmail);
        } else {
            log.debug("Aucun nettoyage nécessaire pour l'utilisateur: {} ({} tokens actifs)", userEmail, activeTokens.size());
        }
    }
    
    /**
     * Vérifie et corrige l'état des tokens pour un utilisateur
     * Assure qu'il n'y a qu'un seul token actif
     */
    @Transactional
    public void ensureSingleActiveToken(String userEmail) {
        log.info("Vérification de l'état des tokens pour l'utilisateur: {}", userEmail);
        
        long activeTokenCount = tokenRepository.countValidTokensByUser(userEmail);
        
        if (activeTokenCount > 1) {
            log.warn("{} tokens actifs détectés pour l'utilisateur: {}. Nettoyage en cours...", activeTokenCount, userEmail);
            cleanMultipleTokensForUser(userEmail);
        } else if (activeTokenCount == 1) {
            log.debug("État correct: 1 token actif pour l'utilisateur: {}", userEmail);
        } else {
            log.debug("Aucun token actif pour l'utilisateur: {}", userEmail);
        }
    }
} 