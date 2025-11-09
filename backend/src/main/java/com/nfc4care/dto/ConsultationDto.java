package com.nfc4care.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ConsultationDto {
    private Long id;
    
    @NotNull(message = "L'ID du dossier médical est obligatoire")
    private Long dossierMedicalId;
    
    private Long professionnelId;
    
    @NotBlank(message = "Le motif de consultation est obligatoire")
    private String motifConsultation;
    
    private String examenClinique;
    
    private String diagnostic;
    
    private String traitementPrescrit;
    
    private String ordonnance;
    
    private String observations;
    
    private LocalDateTime prochainRdv;
    
    private LocalDateTime dateConsultation;
    
    private String hashContenu;
    
    private String blockchainTxnHash;
    
    private LocalDateTime dateCreation;
    
    private LocalDateTime dateModification;
    
    // Données complètes pour l'affichage
    private PatientDto patient;
    
    private ProfessionnelDto professionnel;
} 