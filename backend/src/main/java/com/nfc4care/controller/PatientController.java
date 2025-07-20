package com.nfc4care.controller;

import com.nfc4care.dto.PatientDto;
import com.nfc4care.entity.Patient;
import com.nfc4care.service.PatientService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/patients")
@RequiredArgsConstructor
@Slf4j
public class PatientController {
    
    private final PatientService patientService;
    
    @GetMapping
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<List<Patient>> getAllPatients() {
        log.info("Récupération de tous les patients");
        try {
            List<Patient> patients = patientService.getAllPatients();
            log.info("✅ {} patients récupérés", patients.size());
            return ResponseEntity.ok(patients);
        } catch (Exception e) {
            log.error("❌ Erreur lors de la récupération des patients", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<Patient> getPatientById(@PathVariable Long id) {
        log.info("Récupération du patient avec l'ID: {}", id);
        try {
            Optional<Patient> patient = patientService.getPatientById(id);
            if (patient.isPresent()) {
                log.info("✅ Patient trouvé");
                return ResponseEntity.ok(patient.get());
            } else {
                log.info("❌ Patient non trouvé");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("❌ Erreur lors de la récupération du patient", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    @GetMapping("/nfc/{numeroNFC}")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<Patient> getPatientByNFC(@PathVariable String numeroNFC) {
        log.info("Récupération du patient par NFC: {}", numeroNFC);
        try {
            Optional<Patient> patient = patientService.getPatientByNFC(numeroNFC);
            if (patient.isPresent()) {
                log.info("✅ Patient trouvé par NFC");
                return ResponseEntity.ok(patient.get());
            } else {
                log.info("❌ Patient non trouvé par NFC");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("❌ Erreur lors de la récupération du patient par NFC", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    @GetMapping("/search")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<List<Patient>> searchPatients(@RequestParam String q) {
        log.info("Recherche de patients avec le terme: {}", q);
        try {
            List<Patient> patients = patientService.searchPatients(q);
            log.info("✅ {} patients trouvés pour la recherche: {}", patients.size(), q);
            return ResponseEntity.ok(patients);
        } catch (Exception e) {
            log.error("❌ Erreur lors de la recherche de patients", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    @PostMapping
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<Patient> createPatient(@Valid @RequestBody PatientDto patientDto) {
        log.info("Création d'un nouveau patient: {}", patientDto.getNom());
        try {
            Patient createdPatient = patientService.createPatient(patientDto);
            log.info("✅ Patient créé avec l'ID: {}", createdPatient.getId());
            return ResponseEntity.ok(createdPatient);
        } catch (Exception e) {
            log.error("❌ Erreur lors de la création du patient", e);
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<Patient> updatePatient(@PathVariable Long id, @Valid @RequestBody PatientDto patientDto) {
        log.info("Mise à jour du patient avec l'ID: {}", id);
        try {
            Patient updatedPatient = patientService.updatePatient(id, patientDto);
            log.info("✅ Patient mis à jour");
            return ResponseEntity.ok(updatedPatient);
        } catch (Exception e) {
            log.error("❌ Erreur lors de la mise à jour du patient", e);
            return ResponseEntity.badRequest().build();
        }
    }
    
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<Void> deletePatient(@PathVariable Long id) {
        log.info("Suppression du patient avec l'ID: {}", id);
        try {
            patientService.deletePatient(id);
            log.info("✅ Patient supprimé");
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("❌ Erreur lors de la suppression du patient", e);
            return ResponseEntity.badRequest().build();
        }
    }
} 