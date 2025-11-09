package com.nfc4care.service;

import com.nfc4care.dto.ProfileDto;
import com.nfc4care.entity.Professionnel;
import com.nfc4care.repository.ProfessionnelRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProfileService {

    private final ProfessionnelRepository professionnelRepository;
    private final PasswordEncoder passwordEncoder;
    private final TotpService totpService;

    public ProfileDto getProfileByEmail(String email) {
        Professionnel professionnel = professionnelRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Professionnel non trouvé"));
        return toDto(professionnel);
    }

    public ProfileDto updateProfile(String email, ProfileDto profileDto) {
        Professionnel professionnel = professionnelRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Professionnel non trouvé"));

        // Mettre à jour seulement les champs modifiables
        if (profileDto.getNom() != null) {
            professionnel.setNom(profileDto.getNom());
        }
        if (profileDto.getPrenom() != null) {
            professionnel.setPrenom(profileDto.getPrenom());
        }
        if (profileDto.getSpecialite() != null) {
            professionnel.setSpecialite(profileDto.getSpecialite());
        }

        Professionnel updated = professionnelRepository.save(professionnel);
        log.info("✅ Profil mis à jour pour: {}", email);
        return toDto(updated);
    }

    public void changePassword(String email, String currentPassword, String newPassword) {
        Professionnel professionnel = professionnelRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Professionnel non trouvé"));

        // Vérifier le password actuel
        if (!passwordEncoder.matches(currentPassword, professionnel.getPassword())) {
            log.warn("❌ Tentative de changement de password avec ancien password invalide: {}", email);
            throw new RuntimeException("Password actuel incorrect");
        }

        // Vérifier que le nouveau password est différent
        if (currentPassword.equals(newPassword)) {
            throw new RuntimeException("Le nouveau password doit être différent de l'actuel");
        }

        // Encoder et sauvegarder
        professionnel.setPassword(passwordEncoder.encode(newPassword));
        professionnelRepository.save(professionnel);
        log.info("✅ Password changé pour: {}", email);
    }

    public boolean verifyPassword(String email, String password) {
        Professionnel professionnel = professionnelRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Professionnel non trouvé"));
        return passwordEncoder.matches(password, professionnel.getPassword());
    }

    public ProfileDto setup2FA(String email) {
        Professionnel professionnel = professionnelRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Professionnel non trouvé"));

        // Générer une nouvelle clé secrète (elle ne sera pas sauvegardée tant que l'utilisateur ne confirme pas)
        String secret = totpService.generateSecretKey();
        String qrCodeUri = totpService.generateQrCodeUri(secret, email, "NFC4Care");

        ProfileDto dto = toDto(professionnel);
        dto.setSecret(secret);
        dto.setQrCodeUri(qrCodeUri);

        log.info("✅ Setup 2FA initié pour: {}", email);
        return dto;
    }

    public void enable2FA(String email, String totpCode) {
        Professionnel professionnel = professionnelRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Professionnel non trouvé"));

        // La clé secrète doit être générée en premier (dans le setup)
        if (professionnel.getTwoFaSecret() == null) {
            throw new RuntimeException("Veuillez d'abord initialiser la 2FA avec /2fa/setup");
        }

        // Valider le code TOTP avec la clé secrète
        if (!totpService.validateTotp(professionnel.getTwoFaSecret(), totpCode)) {
            log.warn("❌ Tentative d'activation 2FA avec code invalide: {}", email);
            throw new RuntimeException("Code 2FA invalide");
        }

        // Activer la 2FA
        professionnel.setTwoFaEnabled(true);
        professionnelRepository.save(professionnel);
        log.info("✅ 2FA activée pour: {}", email);
    }

    public void disable2FA(String email, String password) {
        Professionnel professionnel = professionnelRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Professionnel non trouvé"));

        // Vérifier le password
        if (!passwordEncoder.matches(password, professionnel.getPassword())) {
            log.warn("❌ Tentative de désactivation 2FA avec password invalide: {}", email);
            throw new RuntimeException("Password incorrect");
        }

        // Désactiver la 2FA
        professionnel.setTwoFaEnabled(false);
        professionnel.setTwoFaSecret(null);
        professionnelRepository.save(professionnel);
        log.info("✅ 2FA désactivée pour: {}", email);
    }

    private ProfileDto toDto(Professionnel professionnel) {
        return ProfileDto.builder()
                .id(professionnel.getId())
                .email(professionnel.getEmail())
                .nom(professionnel.getNom())
                .prenom(professionnel.getPrenom())
                .specialite(professionnel.getSpecialite())
                .numeroRpps(professionnel.getNumeroRPPS())
                .role(professionnel.getRole().name())
                .actif(professionnel.isActif())
                .twoFaEnabled(professionnel.isTwoFaEnabled())
                .dateCreation(professionnel.getDateCreation().toString())
                .build();
    }
}
