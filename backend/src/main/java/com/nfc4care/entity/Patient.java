package com.nfc4care.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "patients")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Patient {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true)
    private String numeroDossier;
    
    @Column(nullable = false)
    private String nom;
    
    @Column(nullable = false)
    private String prenom;
    
    @Column(nullable = false)
    private LocalDate dateNaissance;
    
    @Column(nullable = false)
    private String sexe;
    
    @Column(nullable = false)
    private String adresse;
    
    @Column(nullable = false)
    private String telephone;
    
    @Column
    private String email;
    
    @Column(name = "numero_securite_sociale", nullable = false, unique = true)
    private String numeroSecuriteSociale;
    
    @Column(name = "groupe_sanguin")
    private String groupeSanguin;
    
    @Column(name = "numero_nfc", unique = true)
    private String numeroNFC;
    
    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation;
    
    @Column(name = "derniere_consultation")
    private LocalDateTime derniereConsultation;
    
    @Column(nullable = false)
    private boolean actif = true;
    
    // Ignorer cette propriété lors de la sérialisation JSON pour éviter les problèmes avec les proxies Hibernate
    @JsonIgnore
    public Object getHibernateLazyInitializer() {
        return null;
    }
    
    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
    }
} 