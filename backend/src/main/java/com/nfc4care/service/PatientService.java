package com.nfc4care.service;

import com.nfc4care.dto.PatientDto;
import com.nfc4care.entity.Patient;
import com.nfc4care.exception.ResourceNotFoundException;
import com.nfc4care.repository.PatientRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class PatientService {

    private final PatientRepository patientRepository;

    public List<Patient> getAllPatients() {
        return patientRepository.findAll();
    }

    public Page<Patient> getAllPatientsPaginated(Pageable pageable) {
        return patientRepository.findAll(pageable);
    }
    
    public Optional<Patient> getPatientById(Long id) {
        return patientRepository.findById(id);
    }
    
    public Optional<Patient> getPatientByNFC(String numeroNFC) {
        return patientRepository.findByNumeroNFC(numeroNFC);
    }
    
    public Page<Patient> searchPatients(String searchTerm, Pageable pageable) {
        return patientRepository.searchPatients(searchTerm, pageable);
    }
    
    public Patient createPatient(PatientDto patientDto) {
        Patient patient = new Patient();
        patient.setNumeroDossier(patientDto.getNumeroDossier());
        patient.setNom(patientDto.getNom());
        patient.setPrenom(patientDto.getPrenom());
        patient.setDateNaissance(patientDto.getDateNaissance());
        patient.setSexe(patientDto.getSexe());
        patient.setAdresse(patientDto.getAdresse());
        patient.setTelephone(patientDto.getTelephone());
        patient.setEmail(patientDto.getEmail());
        patient.setNumeroSecuriteSociale(patientDto.getNumeroSecuriteSociale());
        patient.setGroupeSanguin(patientDto.getGroupeSanguin());
        patient.setNumeroNFC(patientDto.getNumeroNFC());
        patient.setActif(true);
        
        return patientRepository.save(patient);
    }
    
    public Patient updatePatient(Long id, PatientDto patientDto) {
        Patient patient = patientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Patient avec l'ID " + id + " non trouvé"));

        patient.setNom(patientDto.getNom());
        patient.setPrenom(patientDto.getPrenom());
        patient.setDateNaissance(patientDto.getDateNaissance());
        patient.setSexe(patientDto.getSexe());
        patient.setAdresse(patientDto.getAdresse());
        patient.setTelephone(patientDto.getTelephone());
        patient.setEmail(patientDto.getEmail());
        patient.setGroupeSanguin(patientDto.getGroupeSanguin());

        return patientRepository.save(patient);
    }

    public void deletePatient(Long id) {
        Patient patient = patientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Patient avec l'ID " + id + " non trouvé"));
        patient.setActif(false);
        patientRepository.save(patient);
    }
} 