package com.nfc4care.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Builder;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Entity
@Table(name = "professionnels")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Professionnel implements UserDetails {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    @Column(nullable = false)
    private String password;
    
    @Column(nullable = false)
    private String nom;
    
    @Column(nullable = false)
    private String prenom;
    
    @Column(nullable = false)
    private String specialite;
    
    @Column(name = "numero_rpps", nullable = false)
    private String numeroRPPS; // Répertoire Partagé des Professionnels de Santé
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role = Role.MEDECIN;
    
    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation;
    
    @Column(name = "derniere_connexion")
    private LocalDateTime derniereConnexion;
    
    @Column(nullable = false)
    private boolean actif = true;

    @Column(name = "two_fa_secret")
    @JsonIgnore
    private String twoFaSecret; // Secret key for TOTP (base32 encoded)

    @Column(name = "two_fa_enabled")
    private boolean twoFaEnabled = false;

    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
    }
    
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }
    
    @Override
    public String getUsername() {
        return email;
    }
    
    @Override
    public boolean isAccountNonExpired() {
        return actif;
    }
    
    @Override
    public boolean isAccountNonLocked() {
        return actif;
    }
    
    @Override
    public boolean isCredentialsNonExpired() {
        return actif;
    }
    
    @Override
    public boolean isEnabled() {
        return actif;
    }
    
    // Ignorer cette propriété lors de la sérialisation JSON pour éviter les problèmes avec les proxies Hibernate
    @JsonIgnore
    public Object getHibernateLazyInitializer() {
        return null;
    }
    
    public enum Role {
        MEDECIN, INFIRMIER, ADMIN
    }
} 