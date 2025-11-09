package com.nfc4care.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProfileDto {
    private Long id;
    private String email;
    private String nom;
    private String prenom;
    private String specialite;
    private String numeroRpps;
    private String role;
    private boolean actif;
    private boolean twoFaEnabled;
    private String dateCreation;

    // For 2FA setup
    private String qrCodeUri;
    private String secret;
}
