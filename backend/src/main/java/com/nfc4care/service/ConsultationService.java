package com.nfc4care.service;

import com.nfc4care.dto.ConsultationDto;
import com.nfc4care.dto.PatientDto;
import com.nfc4care.dto.ProfessionnelDto;
import com.nfc4care.entity.Consultation;
import com.nfc4care.entity.DossierMedical;
import com.nfc4care.entity.Professionnel;
import com.nfc4care.repository.ConsultationRepository;
import com.nfc4care.repository.DossierMedicalRepository;
import com.nfc4care.repository.ProfessionnelRepository;
import com.nfc4care.util.HashUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.hibernate.Hibernate;
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
        log.info("Création d'une nouvelle consultation pour le dossier: {}", consultationDto.getDossierMedicalId());

        // Récupérer le dossier médical
        DossierMedical dossierMedical = dossierMedicalRepository.findById(consultationDto.getDossierMedicalId())
            .orElseThrow(() -> new RuntimeException("Dossier médical non trouvé"));

        // Récupérer le professionnel
        Professionnel professionnel;
        if (consultationDto.getProfessionnelId() != null) {
            // Utiliser le professionnel spécifié
            professionnel = professionnelRepository.findById(consultationDto.getProfessionnelId())
                .orElseThrow(() -> new RuntimeException("Professionnel avec l'ID " + consultationDto.getProfessionnelId() + " non trouvé"));
        } else {
            // Fallback: utiliser le professionnel actif courant (depuis le contexte de sécurité en production)
            // Pour les tests: utiliser le premier disponible
            List<Professionnel> professionnels = professionnelRepository.findAll();
            if (professionnels.isEmpty()) {
                throw new RuntimeException("Aucun professionnel disponible");
            }
            professionnel = professionnels.get(0);
            log.warn("⚠️ Aucun professionnelId fourni, utilisation du premier professionnel disponible: {}", professionnel.getId());
        }

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

        // Générer le hash du contenu avec la classe utilitaire
        String content = (consultationDto.getMotifConsultation() != null ? consultationDto.getMotifConsultation() : "") +
                        (consultationDto.getDiagnostic() != null ? consultationDto.getDiagnostic() : "") +
                        (consultationDto.getTraitementPrescrit() != null ? consultationDto.getTraitementPrescrit() : "");
        consultation.setHashContenu(HashUtil.generateSHA256Hash(content));

        Consultation savedConsultation = consultationRepository.save(consultation);
        log.info("✅ Consultation créée avec l'ID: {} par le professionnel: {}",
            savedConsultation.getId(), professionnel.getEmail());

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

        // Mettre à jour le professionnel si fourni
        if (consultationDto.getProfessionnelId() != null) {
            Professionnel professionnel = professionnelRepository.findById(consultationDto.getProfessionnelId())
                .orElseThrow(() -> new RuntimeException("Professionnel non trouvé"));
            consultation.setProfessionnel(professionnel);
        }

        // Mettre à jour le hash du contenu
        String content = (consultation.getMotifConsultation() != null ? consultation.getMotifConsultation() : "") +
                        (consultation.getDiagnostic() != null ? consultation.getDiagnostic() : "") +
                        (consultation.getTraitementPrescrit() != null ? consultation.getTraitementPrescrit() : "");
        consultation.setHashContenu(HashUtil.generateSHA256Hash(content));

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
    
    public ConsultationDto toDto(Consultation consultation) {
        ConsultationDto dto = new ConsultationDto();
        dto.setId(consultation.getId());
        dto.setDossierMedicalId(consultation.getDossierMedical() != null ? consultation.getDossierMedical().getId() : null);
        dto.setProfessionnelId(consultation.getProfessionnel() != null ? consultation.getProfessionnel().getId() : null);
        dto.setDateConsultation(consultation.getDateConsultation());
        dto.setMotifConsultation(consultation.getMotifConsultation());
        dto.setExamenClinique(consultation.getExamenClinique());
        dto.setDiagnostic(consultation.getDiagnostic());
        dto.setTraitementPrescrit(consultation.getTraitementPrescrit());
        dto.setOrdonnance(consultation.getOrdonnance());
        dto.setObservations(consultation.getObservations());
        dto.setProchainRdv(consultation.getProchainRdv());
        dto.setHashContenu(consultation.getHashContenu());
        dto.setBlockchainTxnHash(consultation.getBlockchainTxnHash());
        dto.setDateCreation(consultation.getDateCreation());
        dto.setDateModification(consultation.getDateModification());
        
        // Forcer l'initialisation des proxies Hibernate et ajouter les données du patient
        if (consultation.getDossierMedical() != null) {
            Hibernate.initialize(consultation.getDossierMedical());
            if (consultation.getDossierMedical().getPatient() != null) {
                Hibernate.initialize(consultation.getDossierMedical().getPatient());
                dto.setPatient(toPatientDto(consultation.getDossierMedical().getPatient()));
            }
        }
        
        // Forcer l'initialisation des proxies Hibernate et ajouter les données du professionnel
        if (consultation.getProfessionnel() != null) {
            Hibernate.initialize(consultation.getProfessionnel());
            dto.setProfessionnel(toProfessionnelDto(consultation.getProfessionnel()));
        }
        
        return dto;
    }
    
    private PatientDto toPatientDto(com.nfc4care.entity.Patient patient) {
        PatientDto dto = new PatientDto();
        dto.setId(patient.getId());
        dto.setNumeroDossier(patient.getNumeroDossier());
        dto.setNom(patient.getNom());
        dto.setPrenom(patient.getPrenom());
        dto.setDateNaissance(patient.getDateNaissance());
        dto.setSexe(patient.getSexe());
        dto.setAdresse(patient.getAdresse());
        dto.setTelephone(patient.getTelephone());
        dto.setEmail(patient.getEmail());
        dto.setNumeroSecuriteSociale(patient.getNumeroSecuriteSociale());
        dto.setGroupeSanguin(patient.getGroupeSanguin());
        dto.setNumeroNFC(patient.getNumeroNFC());
        return dto;
    }
    
    private ProfessionnelDto toProfessionnelDto(Professionnel professionnel) {
        ProfessionnelDto dto = new ProfessionnelDto();
        dto.setId(professionnel.getId());
        dto.setEmail(professionnel.getEmail());
        dto.setNom(professionnel.getNom());
        dto.setPrenom(professionnel.getPrenom());
        dto.setSpecialite(professionnel.getSpecialite());
        dto.setNumeroRPPS(professionnel.getNumeroRPPS());
        dto.setRole(professionnel.getRole());
        dto.setDateCreation(professionnel.getDateCreation());
        dto.setDerniereConnexion(professionnel.getDerniereConnexion());
        dto.setActif(professionnel.isActif());
        return dto;
    }
} 