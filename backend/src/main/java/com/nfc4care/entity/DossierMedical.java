package com.nfc4care.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "dossiers_medicaux")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DossierMedical {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false, unique = true)
    private Patient patient;
    
    @Column(name = "antecedents_medicaux", columnDefinition = "TEXT")
    private String antecedentsMedicaux;
    
    @Column(name = "antecedents_chirurgicaux", columnDefinition = "TEXT")
    private String antecedentsChirurgicaux;
    
    @Column(name = "antecedents_familiaux", columnDefinition = "TEXT")
    private String antecedentsFamiliaux;
    
    @Column(name = "traitements_en_cours", columnDefinition = "TEXT")
    private String traitementsEnCours;
    
    @Column(name = "allergies", columnDefinition = "TEXT")
    private String allergies;
    
    @Column(name = "observations_generales", columnDefinition = "TEXT")
    private String observationsGenerales;
    
    @Column(name = "hash_contenu", nullable = false)
    private String hashContenu;
    
    @Column(name = "blockchain_txn_hash")
    private String blockchainTxnHash;
    
    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation;
    
    @Column(name = "date_modification", nullable = false)
    private LocalDateTime dateModification;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "professionnel_creation_id", nullable = false)
    private Professionnel professionnelCreation;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "professionnel_modification_id")
    private Professionnel professionnelModification;
    
    @OneToMany(mappedBy = "dossierMedical", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Consultation> consultations = new ArrayList<>();
    
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