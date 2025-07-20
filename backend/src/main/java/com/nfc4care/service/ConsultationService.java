package com.nfc4care.service;

import com.nfc4care.dto.ConsultationDto;
import com.nfc4care.entity.Consultation;
import com.nfc4care.entity.DossierMedical;
import com.nfc4care.entity.Professionnel;
import com.nfc4care.repository.ConsultationRepository;
import com.nfc4care.repository.DossierMedicalRepository;
import com.nfc4care.repository.ProfessionnelRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class ConsultationService {
    
    private final ConsultationRepository consultationRepository;
    private final DossierMedicalRepository dossierMedicalRepository;
    private final ProfessionnelRepository professionnelRepository;
    
    public List<Consultation> getAllConsultations() {
        log.info("Récupération de toutes les consultations");
        return consultationRepository.findAll();
    }
    
    public List<Consultation> getConsultationsByPatientId(Long patientId) {
        log.info("Récupération des consultations pour le patient: {}", patientId);
        return consultationRepository.findByPatientIdOrderByDateConsultationDesc(patientId);
    }
    
    public Optional<Consultation> getConsultationById(Long id) {
        log.info("Récupération de la consultation: {}", id);
        return consultationRepository.findById(id);
    }
    
    public Consultation createConsultation(ConsultationDto consultationDto) {
        log.info("Création d'une nouvelle consultation");
        
        // Récupérer le dossier médical
        DossierMedical dossierMedical = dossierMedicalRepository.findById(consultationDto.getDossierMedicalId())
            .orElseThrow(() -> new RuntimeException("Dossier médical non trouvé"));
        
        // Récupérer le professionnel (pour l'instant, on utilise le premier disponible)
        List<Professionnel> professionnels = professionnelRepository.findAll();
        if (professionnels.isEmpty()) {
            throw new RuntimeException("Aucun professionnel disponible");
        }
        Professionnel professionnel = professionnels.get(0);
        
        // Créer la consultation
        Consultation consultation = new Consultation();
        consultation.setDossierMedical(dossierMedical);
        consultation.setProfessionnel(professionnel);
        consultation.setDateConsultation(consultationDto.getDateConsultation() != null ? 
            consultationDto.getDateConsultation() : LocalDateTime.now());
        consultation.setMotifConsultation(consultationDto.getMotifConsultation());
        consultation.setExamenClinique(consultationDto.getExamenClinique());
        consultation.setDiagnostic(consultationDto.getDiagnostic());
        consultation.setTraitementPrescrit(consultationDto.getTraitementPrescrit());
        consultation.setOrdonnance(consultationDto.getOrdonnance());
        consultation.setObservations(consultationDto.getObservations());
        consultation.setProchainRdv(consultationDto.getProchainRdv());
        
        // Générer le hash du contenu (simplifié)
        String content = consultationDto.getMotifConsultation() + 
                        (consultationDto.getDiagnostic() != null ? consultationDto.getDiagnostic() : "") + 
                        (consultationDto.getTraitementPrescrit() != null ? consultationDto.getTraitementPrescrit() : "");
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(content.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            consultation.setHashContenu(hexString.toString());
        } catch (Exception e) {
            log.error("Erreur lors de la génération du hash", e);
            consultation.setHashContenu("error");
        }
        
        Consultation savedConsultation = consultationRepository.save(consultation);
        log.info("✅ Consultation créée avec l'ID: {}", savedConsultation.getId());
        
        return savedConsultation;
    }
    
    public Consultation updateConsultation(Long id, ConsultationDto consultationDto) {
        log.info("Mise à jour de la consultation: {}", id);
        
        Consultation consultation = consultationRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Consultation non trouvée"));
        
        // Mettre à jour les champs
        if (consultationDto.getDateConsultation() != null) {
            consultation.setDateConsultation(consultationDto.getDateConsultation());
        }
        if (consultationDto.getMotifConsultation() != null) {
            consultation.setMotifConsultation(consultationDto.getMotifConsultation());
        }
        if (consultationDto.getExamenClinique() != null) {
            consultation.setExamenClinique(consultationDto.getExamenClinique());
        }
        if (consultationDto.getDiagnostic() != null) {
            consultation.setDiagnostic(consultationDto.getDiagnostic());
        }
        if (consultationDto.getTraitementPrescrit() != null) {
            consultation.setTraitementPrescrit(consultationDto.getTraitementPrescrit());
        }
        if (consultationDto.getOrdonnance() != null) {
            consultation.setOrdonnance(consultationDto.getOrdonnance());
        }
        if (consultationDto.getObservations() != null) {
            consultation.setObservations(consultationDto.getObservations());
        }
        if (consultationDto.getProchainRdv() != null) {
            consultation.setProchainRdv(consultationDto.getProchainRdv());
        }
        
        // Mettre à jour le hash du contenu
        String content = consultation.getMotifConsultation() + 
                        consultation.getDiagnostic() + 
                        consultation.getTraitementPrescrit();
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(content.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            consultation.setHashContenu(hexString.toString());
        } catch (Exception e) {
            log.error("Erreur lors de la génération du hash", e);
            consultation.setHashContenu("error");
        }
        
        Consultation updatedConsultation = consultationRepository.save(consultation);
        log.info("✅ Consultation mise à jour");
        
        return updatedConsultation;
    }
    
    public void deleteConsultation(Long id) {
        log.info("Suppression de la consultation: {}", id);
        
        if (!consultationRepository.existsById(id)) {
            throw new RuntimeException("Consultation non trouvée");
        }
        
        consultationRepository.deleteById(id);
        log.info("✅ Consultation supprimée");
    }
} 