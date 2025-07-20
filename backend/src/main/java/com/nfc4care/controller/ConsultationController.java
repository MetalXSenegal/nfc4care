package com.nfc4care.controller;

import com.nfc4care.dto.ConsultationDto;
import com.nfc4care.entity.Consultation;
import com.nfc4care.service.ConsultationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/consultations")
@RequiredArgsConstructor
@Slf4j
public class ConsultationController {
    
    private final ConsultationService consultationService;
    
    @GetMapping
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<List<Consultation>> getAllConsultations(@RequestParam(required = false) String patientId) {
        log.info("Récupération des consultations - patientId: {}", patientId);
        
        try {
            List<Consultation> consultations;
            if (patientId != null && !patientId.trim().isEmpty()) {
                consultations = consultationService.getConsultationsByPatientId(Long.parseLong(patientId));
            } else {
                consultations = consultationService.getAllConsultations();
            }
            
            log.info("✅ {} consultations récupérées", consultations.size());
            return ResponseEntity.ok(consultations);
        } catch (Exception e) {
            log.error("❌ Erreur lors de la récupération des consultations", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<Consultation> getConsultationById(@PathVariable Long id) {
        log.info("Récupération de la consultation avec l'ID: {}", id);
        
        try {
            Optional<Consultation> consultation = consultationService.getConsultationById(id);
            if (consultation.isPresent()) {
                log.info("✅ Consultation trouvée");
                return ResponseEntity.ok(consultation.get());
            } else {
                log.info("❌ Consultation non trouvée");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("❌ Erreur lors de la récupération de la consultation", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    @PostMapping
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<Consultation> createConsultation(@Valid @RequestBody ConsultationDto consultationDto) {
        log.info("Création d'une nouvelle consultation pour le dossier: {}", consultationDto.getDossierMedicalId());
        
        try {
            Consultation createdConsultation = consultationService.createConsultation(consultationDto);
            log.info("✅ Consultation créée avec l'ID: {}", createdConsultation.getId());
            return ResponseEntity.ok(createdConsultation);
        } catch (Exception e) {
            log.error("❌ Erreur lors de la création de la consultation", e);
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<Consultation> updateConsultation(@PathVariable Long id, @Valid @RequestBody ConsultationDto consultationDto) {
        log.info("Mise à jour de la consultation avec l'ID: {}", id);
        
        try {
            Consultation updatedConsultation = consultationService.updateConsultation(id, consultationDto);
            log.info("✅ Consultation mise à jour");
            return ResponseEntity.ok(updatedConsultation);
        } catch (Exception e) {
            log.error("❌ Erreur lors de la mise à jour de la consultation", e);
            return ResponseEntity.badRequest().build();
        }
    }
    
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<Void> deleteConsultation(@PathVariable Long id) {
        log.info("Suppression de la consultation avec l'ID: {}", id);
        
        try {
            consultationService.deleteConsultation(id);
            log.info("✅ Consultation supprimée");
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("❌ Erreur lors de la suppression de la consultation", e);
            return ResponseEntity.badRequest().build();
        }
    }
} 