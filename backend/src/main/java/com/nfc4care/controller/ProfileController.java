package com.nfc4care.controller;

import com.nfc4care.dto.ProfileDto;
import com.nfc4care.dto.PasswordChangeRequest;
import com.nfc4care.dto.TwoFaSetupRequest;
import com.nfc4care.service.ProfileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/profile")
@RequiredArgsConstructor
@Slf4j
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping
    public ResponseEntity<ProfileDto> getProfile() {
        String email = getCurrentUserEmail();
        log.info("Récupération du profil pour: {}", email);
        ProfileDto profile = profileService.getProfileByEmail(email);
        return ResponseEntity.ok(profile);
    }

    @PutMapping
    public ResponseEntity<ProfileDto> updateProfile(@RequestBody ProfileDto profileDto) {
        String email = getCurrentUserEmail();
        log.info("Mise à jour du profil pour: {}", email);
        ProfileDto updated = profileService.updateProfile(email, profileDto);
        return ResponseEntity.ok(updated);
    }

    @PostMapping("/change-password")
    public ResponseEntity<String> changePassword(@RequestBody PasswordChangeRequest request) {
        String email = getCurrentUserEmail();
        log.info("Changement de password pour: {}", email);
        profileService.changePassword(email, request.getCurrentPassword(), request.getNewPassword());
        return ResponseEntity.ok("Password changé avec succès");
    }

    @PostMapping("/verify-password")
    public ResponseEntity<Boolean> verifyPassword(@RequestBody PasswordChangeRequest request) {
        String email = getCurrentUserEmail();
        log.info("Vérification du password pour: {}", email);
        boolean isValid = profileService.verifyPassword(email, request.getCurrentPassword());
        return ResponseEntity.ok(isValid);
    }

    @PostMapping("/2fa/setup")
    public ResponseEntity<ProfileDto> setup2FA() {
        String email = getCurrentUserEmail();
        log.info("Initialisation du setup 2FA pour: {}", email);
        ProfileDto setup = profileService.setup2FA(email);
        return ResponseEntity.ok(setup);
    }

    @PostMapping("/2fa/enable")
    public ResponseEntity<String> enable2FA(@RequestBody TwoFaSetupRequest request) {
        String email = getCurrentUserEmail();
        log.info("Activation de la 2FA pour: {}", email);
        profileService.enable2FA(email, request.getTotpCode());
        return ResponseEntity.ok("2FA activée avec succès");
    }

    @PostMapping("/2fa/disable")
    public ResponseEntity<String> disable2FA(@RequestBody PasswordChangeRequest request) {
        String email = getCurrentUserEmail();
        log.info("Désactivation de la 2FA pour: {}", email);
        profileService.disable2FA(email, request.getCurrentPassword());
        return ResponseEntity.ok("2FA désactivée");
    }

    private String getCurrentUserEmail() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication.getName();
    }
}
