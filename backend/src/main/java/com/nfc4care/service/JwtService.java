package com.nfc4care.service;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import io.jsonwebtoken.SignatureAlgorithm;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
@Slf4j
public class JwtService {
    
    @Value("${spring.security.jwt.secret}")
    private String secretKey;
    
    @Value("${spring.security.jwt.expiration}")
    private long jwtExpiration;
    
    private final TokenService tokenService;
    
    public JwtService(TokenService tokenService) {
        this.tokenService = tokenService;
    }
    
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }
    
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }
    
    public String generateToken(UserDetails userDetails) {
        return generateToken(new HashMap<>(), userDetails);
    }
    
    public String generateToken(Map<String, Object> extraClaims, UserDetails userDetails) {
        return buildToken(extraClaims, userDetails, jwtExpiration);
    }
    
    public String generateAndSaveToken(UserDetails userDetails, String userAgent, String ipAddress) {
        String token = generateToken(userDetails);
        
        // Calculer la date d'expiration
        LocalDateTime expiresAt = LocalDateTime.now().plusSeconds(jwtExpiration / 1000);
        
        // Vérifier et nettoyer les tokens multiples avant de sauvegarder le nouveau
        tokenService.ensureSingleActiveToken(userDetails.getUsername());
        
        // Sauvegarder le nouveau token (les anciens seront automatiquement désactivés)
        tokenService.saveToken(token, userDetails.getUsername(), expiresAt, userAgent, ipAddress);
        
        log.info("Token unique généré et sauvegardé pour l'utilisateur: {}", userDetails.getUsername());
        return token;
    }
    
    private String buildToken(Map<String, Object> extraClaims, UserDetails userDetails, long expiration) {
        return Jwts.builder()
                .setClaims(extraClaims)
                .setSubject(userDetails.getUsername())
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getSignInKey(), SignatureAlgorithm.HS256)
                .compact();
    }
    
    public boolean isTokenValid(String token, UserDetails userDetails) {
        try {
            // Vérifier d'abord la validité JWT
            final String username = extractUsername(token);
            boolean jwtValid = (username.equals(userDetails.getUsername())) && !isTokenExpired(token);
            
            if (!jwtValid) {
                log.warn("Token JWT invalide pour l'utilisateur: {}", userDetails.getUsername());
                return false;
            }
            
            // Vérifier ensuite la validité en base de données
            boolean dbValid = tokenService.isTokenValid(token);
            
            if (!dbValid) {
                log.warn("Token invalide en base de données pour l'utilisateur: {}", userDetails.getUsername());
                return false;
            }
            
            log.debug("Token valide pour l'utilisateur: {}", userDetails.getUsername());
            return true;
            
        } catch (Exception e) {
            log.error("Erreur lors de la validation du token: {}", e.getMessage());
            return false;
        }
    }
    
    public boolean isTokenValid(String token) {
        try {
            // Vérifier d'abord la validité JWT
            if (isTokenExpired(token)) {
                log.warn("Token JWT expiré");
                return false;
            }
            
            // Vérifier ensuite la validité en base de données
            return tokenService.isTokenValid(token);
            
        } catch (Exception e) {
            log.error("Erreur lors de la validation du token: {}", e.getMessage());
            return false;
        }
    }
    
    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }
    
    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }
    
    private Claims extractAllClaims(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(getSignInKey())
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (JwtException e) {
            log.error("Erreur lors du parsing du token JWT: {}", e.getMessage());
            throw e;
        }
    }
    
    private SecretKey getSignInKey() {
        byte[] keyBytes = secretKey.getBytes();
        return Keys.hmacShaKeyFor(keyBytes);
    }
    
    /**
     * Révoque un token
     */
    public void revokeToken(String token) {
        tokenService.revokeToken(token);
    }
    
    /**
     * Révoque tous les tokens d'un utilisateur
     */
    public void revokeAllUserTokens(String userEmail) {
        tokenService.revokeAllUserTokens(userEmail);
    }
} 