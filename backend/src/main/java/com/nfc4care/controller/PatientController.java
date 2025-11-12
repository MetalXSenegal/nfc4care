package com.nfc4care.controller;

import com.nfc4care.dto.ApiResponse;
import com.nfc4care.dto.PagedResponse;
import com.nfc4care.dto.PatientDto;
import com.nfc4care.entity.Patient;
import com.nfc4care.service.DossierMedicalService;
import com.nfc4care.service.ExportService;
import com.nfc4care.service.PatientService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.Optional;

import com.itextpdf.text.DocumentException;

@RestController
@RequestMapping("/patients")
@RequiredArgsConstructor
@Slf4j
public class PatientController {

    private final PatientService patientService;
    private final ExportService exportService;
    private final DossierMedicalService dossierMedicalService;
    
    @GetMapping
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<ApiResponse<PagedResponse<Patient>>> getAllPatients(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        log.info("Récupération des patients - page: {}, size: {}", page, size);
        try {
            Pageable pageable = PageRequest.of(page, size);
            Page<Patient> patients = patientService.getAllPatientsPaginated(pageable);
            log.info("✅ {} patients récupérés (page {}/{})",
                patients.getContent().size(), patients.getNumber() + 1, patients.getTotalPages());
            return ResponseEntity.ok(ApiResponse.success(PagedResponse.of(patients)));
        } catch (Exception e) {
            log.error("❌ Erreur lors de la récupération des patients", e);
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("ERROR", e.getMessage()));
        }
    }
    
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('MEDECIN')")
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
    @PreAuthorize("hasRole('MEDECIN')")
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
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<ApiResponse<PagedResponse<Patient>>> searchPatients(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        log.info("Recherche de patients avec le terme: {}, page: {}, size: {}", q, page, size);
        try {
            Pageable pageable = PageRequest.of(page, size);
            Page<Patient> patients = patientService.searchPatients(q, pageable);
            log.info("✅ {} patients trouvés pour la recherche: {}", patients.getContent().size(), q);
            return ResponseEntity.ok(ApiResponse.success(PagedResponse.of(patients)));
        } catch (Exception e) {
            log.error("❌ Erreur lors de la recherche de patients", e);
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("SEARCH_ERROR", e.getMessage()));
        }
    }
    
    @PostMapping
    @PreAuthorize("hasRole('MEDECIN')")
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
    @PreAuthorize("hasRole('MEDECIN')")
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
    @PreAuthorize("hasRole('MEDECIN')")
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

    @GetMapping("/{id}/export/pdf")
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<byte[]> exportPatientToPDF(@PathVariable Long id) {
        log.info("Export PDF du patient avec l'ID: {}", id);
        try {
            Patient patient = patientService.getPatientById(id)
                    .orElseThrow(() -> new com.nfc4care.exception.ResourceNotFoundException("Patient non trouvé"));

            var dossier = dossierMedicalService.getByPatientId(id).orElse(null);
            ByteArrayOutputStream pdfStream = exportService.exportToPDF(patient, dossier);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.setContentDispositionFormData("attachment",
                    "dossier_" + patient.getNumeroDossier() + ".pdf");

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(pdfStream.toByteArray());
        } catch (DocumentException | IOException e) {
            log.error("Erreur lors de la génération du PDF", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/{id}/export/excel")
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<byte[]> exportPatientToExcel(@PathVariable Long id) {
        log.info("Export Excel du patient avec l'ID: {}", id);
        try {
            Patient patient = patientService.getPatientById(id)
                    .orElseThrow(() -> new com.nfc4care.exception.ResourceNotFoundException("Patient non trouvé"));

            var dossier = dossierMedicalService.getByPatientId(id).orElse(null);
            ByteArrayOutputStream excelStream = exportService.exportToExcel(patient, dossier);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
            headers.setContentDispositionFormData("attachment",
                    "dossier_" + patient.getNumeroDossier() + ".xlsx");

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(excelStream.toByteArray());
        } catch (IOException e) {
            log.error("Erreur lors de la génération d'Excel", e);
            return ResponseEntity.internalServerError().build();
        }
    }
} 