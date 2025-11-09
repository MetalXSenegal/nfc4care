package com.nfc4care.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "consultations")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Consultation {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dossier_medical_id", nullable = false)
    private DossierMedical dossierMedical;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "professionnel_id", nullable = false)
    private Professionnel professionnel;
    
    @Column(name = "date_consultation", nullable = false)
    private LocalDateTime dateConsultation;
    
    @Column(name = "motif_consultation", nullable = false, columnDefinition = "TEXT")
    private String motifConsultation;
    
    @Column(name = "examen_clinique", columnDefinition = "TEXT")
    private String examenClinique;
    
    @Column(name = "diagnostic", columnDefinition = "TEXT")
    private String diagnostic;
    
    @Column(name = "traitement_prescrit", columnDefinition = "TEXT")
    private String traitementPrescrit;
    
    @Column(name = "ordonnance", columnDefinition = "TEXT")
    private String ordonnance;
    
    @Column(name = "observations", columnDefinition = "TEXT")
    private String observations;
    
    @Column(name = "prochain_rdv")
    private LocalDateTime prochainRdv;
    
    @Column(name = "hash_contenu", nullable = false)
    private String hashContenu;
    
    @Column(name = "blockchain_txn_hash")
    private String blockchainTxnHash;
    
    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation;
    
    @Column(name = "date_modification", nullable = false)
    private LocalDateTime dateModification;
    
    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
        dateModification = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        dateModification = LocalDateTime.now();
    }
    
    // Ignorer cette propriété lors de la sérialisation JSON pour éviter les problèmes avec les proxies Hibernate
    @JsonIgnore
    public Object getHibernateLazyInitializer() {
        return null;
    }
} 