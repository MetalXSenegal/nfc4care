package com.nfc4care.controller;

import com.nfc4care.dto.DossierMedicalDto;
import com.nfc4care.entity.DossierMedical;
import com.nfc4care.service.DossierMedicalService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/medical-records")
@RequiredArgsConstructor
@Slf4j
public class DossierMedicalController {
    private final DossierMedicalService dossierMedicalService;

    @GetMapping("/{patientId}")
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<DossierMedicalDto> getByPatientId(@PathVariable Long patientId) {
        Optional<DossierMedical> dossier = dossierMedicalService.getByPatientId(patientId);
        return dossier.map(value -> ResponseEntity.ok(dossierMedicalService.toDto(value)))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/id/{id}")
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<DossierMedicalDto> getById(@PathVariable Long id) {
        Optional<DossierMedical> dossier = dossierMedicalService.getById(id);
        return dossier.map(value -> ResponseEntity.ok(dossierMedicalService.toDto(value)))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<DossierMedicalDto> create(@RequestBody DossierMedicalDto dto) {
        DossierMedical dossier = dossierMedicalService.create(dto);
        return ResponseEntity.ok(dossierMedicalService.toDto(dossier));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<DossierMedicalDto> update(@PathVariable Long id, @RequestBody DossierMedicalDto dto) {
        DossierMedical dossier = dossierMedicalService.update(id, dto);
        return ResponseEntity.ok(dossierMedicalService.toDto(dossier));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        dossierMedicalService.delete(id);
        return ResponseEntity.ok().build();
    }
} 