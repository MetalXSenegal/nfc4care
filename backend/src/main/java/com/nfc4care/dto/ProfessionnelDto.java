package com.nfc4care.dto;

import com.nfc4care.entity.Professionnel;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProfessionnelDto {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String email;
    
    private String nom;

    private String prenom;

    private String specialite;

    private String numeroRPPS; // Répertoire Partagé des Professionnels de Santé

    private Professionnel.Role role = Professionnel.Role.MEDECIN;

    private LocalDateTime dateCreation;

    private LocalDateTime derniereConnexion;

    private boolean actif = true;

}
