package com.nfc4care.service;

import com.nfc4care.dto.DossierMedicalDto;
import com.nfc4care.entity.DossierMedical;
import com.nfc4care.entity.Patient;
import com.nfc4care.entity.Professionnel;
import com.nfc4care.repository.DossierMedicalRepository;
import com.nfc4care.repository.PatientRepository;
import com.nfc4care.repository.ProfessionnelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class DossierMedicalService {
    private final DossierMedicalRepository dossierMedicalRepository;
    private final PatientRepository patientRepository;
    private final ProfessionnelRepository professionnelRepository;

    public Optional<DossierMedical> getById(Long id) {
        return dossierMedicalRepository.findById(id);
    }

    public Optional<DossierMedical> getByPatientId(Long patientId) {
        return dossierMedicalRepository.findByPatientId(patientId);
    }

    @Transactional
    public DossierMedical create(DossierMedicalDto dto) {
        DossierMedical dossier = new DossierMedical();
        mapDtoToEntity(dto, dossier);
        return dossierMedicalRepository.save(dossier);
    }

    @Transactional
    public DossierMedical update(Long id, DossierMedicalDto dto) {
        DossierMedical dossier = dossierMedicalRepository.findById(id).orElseThrow();
        mapDtoToEntity(dto, dossier);
        return dossierMedicalRepository.save(dossier);
    }

    @Transactional
    public void delete(Long id) {
        dossierMedicalRepository.deleteById(id);
    }

    private void mapDtoToEntity(DossierMedicalDto dto, DossierMedical dossier) {
        if (dto.getPatientId() != null) {
            Patient patient = patientRepository.findById(dto.getPatientId()).orElseThrow();
            dossier.setPatient(patient);
        }
        dossier.setAntecedentsMedicaux(dto.getAntecedentsMedicaux());
        dossier.setAntecedentsChirurgicaux(dto.getAntecedentsChirurgicaux());
        dossier.setAntecedentsFamiliaux(dto.getAntecedentsFamiliaux());
        dossier.setTraitementsEnCours(dto.getTraitementsEnCours());
        dossier.setAllergies(dto.getAllergies());
        dossier.setObservationsGenerales(dto.getObservationsGenerales());
        dossier.setHashContenu(dto.getHashContenu());
        dossier.setBlockchainTxnHash(dto.getBlockchainTxnHash());
        if (dto.getProfessionnelCreationId() != null) {
            Professionnel p = professionnelRepository.findById(dto.getProfessionnelCreationId()).orElseThrow();
            dossier.setProfessionnelCreation(p);
        }
        if (dto.getProfessionnelModificationId() != null) {
            Professionnel p = professionnelRepository.findById(dto.getProfessionnelModificationId()).orElse(null);
            dossier.setProfessionnelModification(p);
        }
    }

    public DossierMedicalDto toDto(DossierMedical dossier) {
        DossierMedicalDto dto = new DossierMedicalDto();
        dto.setId(dossier.getId());
        dto.setPatientId(dossier.getPatient().getId());
        dto.setAntecedentsMedicaux(dossier.getAntecedentsMedicaux());
        dto.setAntecedentsChirurgicaux(dossier.getAntecedentsChirurgicaux());
        dto.setAntecedentsFamiliaux(dossier.getAntecedentsFamiliaux());
        dto.setTraitementsEnCours(dossier.getTraitementsEnCours());
        dto.setAllergies(dossier.getAllergies());
        dto.setObservationsGenerales(dossier.getObservationsGenerales());
        dto.setHashContenu(dossier.getHashContenu());
        dto.setBlockchainTxnHash(dossier.getBlockchainTxnHash());
        dto.setDateCreation(dossier.getDateCreation());
        dto.setDateModification(dossier.getDateModification());
        dto.setProfessionnelCreationId(dossier.getProfessionnelCreation() != null ? dossier.getProfessionnelCreation().getId() : null);
        dto.setProfessionnelModificationId(dossier.getProfessionnelModification() != null ? dossier.getProfessionnelModification().getId() : null);
        return dto;
    }
} 