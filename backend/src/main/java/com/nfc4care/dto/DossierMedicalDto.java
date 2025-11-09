package com.nfc4care.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class DossierMedicalDto {
    private Long id;
    private Long patientId;
    private String antecedentsMedicaux;
    private String antecedentsChirurgicaux;
    private String antecedentsFamiliaux;
    private String traitementsEnCours;
    private String allergies;
    private String observationsGenerales;
    private String hashContenu;
    private String blockchainTxnHash;
    private LocalDateTime dateCreation;
    private LocalDateTime dateModification;
    private Long professionnelCreationId;
    private Long professionnelModificationId;
} 