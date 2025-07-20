package com.nfc4care.repository;

import com.nfc4care.entity.Patient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PatientRepository extends JpaRepository<Patient, Long> {
    
    Optional<Patient> findByNumeroDossier(String numeroDossier);
    
    Optional<Patient> findByNumeroSecuriteSociale(String numeroSecuriteSociale);
    
    Optional<Patient> findByNumeroNFC(String numeroNFC);
    
    @Query("SELECT p FROM Patient p WHERE p.actif = true AND " +
           "(LOWER(p.nom) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(p.prenom) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "p.numeroDossier LIKE CONCAT('%', :searchTerm, '%') OR " +
           "p.telephone LIKE CONCAT('%', :searchTerm, '%') OR " +
           "LOWER(p.email) LIKE LOWER(CONCAT('%', :searchTerm, '%')))")
    List<Patient> searchPatients(@Param("searchTerm") String searchTerm);
    
    boolean existsByNumeroDossier(String numeroDossier);
    
    boolean existsByNumeroSecuriteSociale(String numeroSecuriteSociale);
    
    boolean existsByNumeroNFC(String numeroNFC);
    
    // Dashboard methods
    long countByNumeroNFCIsNotNull();
    
    List<Patient> findTop5ByOrderByDateCreationDesc();
} 