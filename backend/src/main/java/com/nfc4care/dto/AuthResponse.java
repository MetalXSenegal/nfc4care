package com.nfc4care.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Builder;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthResponse {
    private String token;
    private String type = "Bearer";
    private Long professionnelId;
    private String nom;
    private String prenom;
    private String email;
    private String role;
    private String specialite;
    private String numeroRpps;
    private String dateCreation;
    private boolean actif;
} 