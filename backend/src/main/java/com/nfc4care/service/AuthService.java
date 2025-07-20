package com.nfc4care.service;

import com.nfc4care.dto.AuthRequest;
import com.nfc4care.dto.AuthResponse;
import com.nfc4care.entity.Professionnel;
import com.nfc4care.repository.ProfessionnelRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {
    
    private final ProfessionnelRepository professionnelRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    
    public AuthResponse authenticate(AuthRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );
        
        Professionnel professionnel = professionnelRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Professionnel non trouvé"));
        
        // Mettre à jour la dernière connexion
        professionnel.setDerniereConnexion(LocalDateTime.now());
        professionnelRepository.save(professionnel);
        
        // Générer et sauvegarder le token
        String token = jwtService.generateAndSaveToken(professionnel, "Web Client", "127.0.0.1");
        
        log.info("Token généré et sauvegardé pour l'utilisateur: {}", professionnel.getEmail());
        
        return AuthResponse.builder()
                .token(token)
                .professionnelId(professionnel.getId())
                .nom(professionnel.getNom())
                .prenom(professionnel.getPrenom())
                .email(professionnel.getEmail())
                .role(professionnel.getRole().name())
                .specialite(professionnel.getSpecialite())
                .numeroRpps(professionnel.getNumeroRPPS())
                .dateCreation(professionnel.getDateCreation().toString())
                .actif(professionnel.isActif())
                .build();
    }
    
    public AuthResponse verify2FA(String code, String token) {
        // Pour l'instant, on simule la vérification 2FA
        // En production, vous implémenteriez la vraie logique 2FA
        
        if (!"123456".equals(code)) {
            throw new RuntimeException("Code 2FA invalide");
        }
        
        // Extraire les informations du token pour récupérer le professionnel
        String email = jwtService.extractUsername(token);
        Professionnel professionnel = professionnelRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Professionnel non trouvé"));
        
        // Vérifier que le token est valide
        if (!jwtService.isTokenValid(token, professionnel)) {
            throw new RuntimeException("Token invalide ou expiré");
        }
        
        return AuthResponse.builder()
                .token(token)
                .professionnelId(professionnel.getId())
                .nom(professionnel.getNom())
                .prenom(professionnel.getPrenom())
                .email(professionnel.getEmail())
                .role(professionnel.getRole().name())
                .specialite(professionnel.getSpecialite())
                .numeroRpps(professionnel.getNumeroRPPS())
                .dateCreation(professionnel.getDateCreation().toString())
                .actif(professionnel.isActif())
                .build();
    }
    
    public AuthResponse validateToken(String token) {
        String email = jwtService.extractUsername(token);
        
        if (email == null) {
            throw new RuntimeException("Token invalide");
        }
        
        Professionnel professionnel = professionnelRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Professionnel non trouvé"));
        
        if (!jwtService.isTokenValid(token, professionnel)) {
            throw new RuntimeException("Token expiré ou invalide");
        }
        
        return AuthResponse.builder()
                .token(token)
                .professionnelId(professionnel.getId())
                .nom(professionnel.getNom())
                .prenom(professionnel.getPrenom())
                .email(professionnel.getEmail())
                .role(professionnel.getRole().name())
                .specialite(professionnel.getSpecialite())
                .numeroRpps(professionnel.getNumeroRPPS())
                .dateCreation(professionnel.getDateCreation().toString())
                .actif(professionnel.isActif())
                .build();
    }
    
    public void logout(String token) {
        log.info("Déconnexion demandée pour le token");
        jwtService.revokeToken(token);
    }
    
    public void logoutAllSessions(String userEmail) {
        log.info("Déconnexion de toutes les sessions pour l'utilisateur: {}", userEmail);
        jwtService.revokeAllUserTokens(userEmail);
    }
    
    public void initializeDefaultProfessionnel() {
        if (!professionnelRepository.existsByEmail("doctor@example.com")) {
            Professionnel defaultDoctor = Professionnel.builder()
                    .email("doctor@example.com")
                    .password(passwordEncoder.encode("password"))
                    .nom("Dubois")
                    .prenom("Martin")
                    .specialite("Médecine générale")
                    .numeroRPPS("12345678901")
                    .role(Professionnel.Role.MEDECIN)
                    .actif(true)
                    .build();
            
            professionnelRepository.save(defaultDoctor);
            log.info("Professionnel par défaut créé: {}", defaultDoctor.getEmail());
        }
    }
} 