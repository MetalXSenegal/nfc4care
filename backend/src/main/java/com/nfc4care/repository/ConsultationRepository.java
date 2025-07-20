package com.nfc4care.repository;

import com.nfc4care.entity.Consultation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ConsultationRepository extends JpaRepository<Consultation, Long> {
    
    List<Consultation> findByDossierMedicalIdOrderByDateConsultationDesc(Long dossierMedicalId);
    
    @Query("SELECT c FROM Consultation c WHERE c.dossierMedical.patient.id = :patientId ORDER BY c.dateConsultation DESC")
    List<Consultation> findByPatientIdOrderByDateConsultationDesc(@Param("patientId") Long patientId);
    
    @Query("SELECT c FROM Consultation c WHERE c.professionnel.id = :professionnelId AND c.dateConsultation >= :startDate ORDER BY c.dateConsultation DESC")
    List<Consultation> findByProfessionnelIdAndDateConsultationAfter(@Param("professionnelId") Long professionnelId, @Param("startDate") LocalDateTime startDate);
    
    Optional<Consultation> findByBlockchainTxnHash(String blockchainTxnHash);
    
    // Dashboard methods
    long countByDateConsultationBetween(LocalDateTime startDate, LocalDateTime endDate);
    
    Consultation findTopByDossierMedicalPatientOrderByDateConsultationDesc(com.nfc4care.entity.Patient patient);
} 