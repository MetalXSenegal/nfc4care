package com.nfc4care.controller;

import com.nfc4care.dto.AuthRequest;
import com.nfc4care.dto.AuthResponse;
import com.nfc4care.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {
    
    private final AuthService authService;
    
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody AuthRequest request, HttpServletRequest httpRequest) {
        log.info("Tentative de connexion pour l'utilisateur: {}", request.getEmail());
        
        try {
            AuthResponse response = authService.authenticate(request);
            log.info("Connexion réussie pour l'utilisateur: {}", request.getEmail());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Échec de connexion pour l'utilisateur: {}", request.getEmail(), e);
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PostMapping("/verify-2fa")
    public ResponseEntity<AuthResponse> verify2FA(@RequestBody Map<String, String> request, @RequestHeader("Authorization") String token) {
        String code = request.get("code");
        log.info("Vérification 2FA pour le token: {}", token.substring(0, Math.min(20, token.length())));
        
        try {
            AuthResponse response = authService.verify2FA(code, token.replace("Bearer ", ""));
            log.info("Vérification 2FA réussie");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Échec de vérification 2FA", e);
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/validate")
    public ResponseEntity<?> validateToken(@RequestHeader("Authorization") String token) {
        log.info("Validation du token: {}", token.substring(0, Math.min(20, token.length())));
        
        try {
            AuthResponse response = authService.validateToken(token.replace("Bearer ", ""));
            log.info("Token validé avec succès");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Token invalide ou expiré", e);
            return ResponseEntity.status(401)
                .body(Map.of(
                    "success", false,
                    "error", "Token expiré ou invalide",
                    "message", "Votre session a expiré. Veuillez vous reconnecter."
                ));
        }
    }
    
    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@RequestHeader("Authorization") String token) {
        try {
            String tokenValue = token.replace("Bearer ", "");
            authService.logout(tokenValue);
            log.info("Déconnexion réussie");
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Erreur lors de la déconnexion", e);
            return ResponseEntity.ok().build(); // Toujours retourner OK même en cas d'erreur
        }
    }
    
    @PostMapping("/logout-all")
    public ResponseEntity<Void> logoutAllSessions(@RequestHeader("Authorization") String token) {
        try {
            String tokenValue = token.replace("Bearer ", "");
            // Extraire l'email du token pour révoquer toutes les sessions
            String email = authService.validateToken(tokenValue).getEmail();
            authService.logoutAllSessions(email);
            log.info("Déconnexion de toutes les sessions pour l'utilisateur: {}", email);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Erreur lors de la déconnexion de toutes les sessions", e);
            return ResponseEntity.ok().build();
        }
    }
} 