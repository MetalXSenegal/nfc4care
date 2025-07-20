export interface Doctor {
  id: number;
  email: string;
  nom: string;
  prenom: string;
  specialite: string;
  numeroRpps: string;
  role: string;
  dateCreation: string;
  derniereConnexion?: string;
  actif: boolean;
}

export interface Patient {
  id: number;
  numeroDossier: string;
  nom: string;
  prenom: string;
  dateNaissance: string;
  sexe: string;
  adresse: string;
  telephone: string;
  email?: string;
  numeroSecuriteSociale: string;
  groupeSanguin?: string;
  numeroNfc?: string;
  dateCreation: string;
  derniereConsultation?: string;
  actif: boolean;
}

export interface MedicalRecord {
  id: number;
  patientId: number;
  antecedentsMedicaux?: string;
  antecedentsChirurgicaux?: string;
  antecedentsFamiliaux?: string;
  traitementsEnCours?: string;
  allergies?: string;
  observationsGenerales?: string;
  hashContenu: string;
  blockchainTxnHash?: string;
  dateCreation: string;
  dateModification: string;
  professionnelCreationId: number;
  professionnelModificationId?: number;
}

export interface Consultation {
  id: number;
  dossierMedicalId: number;
  professionnelId: number;
  dateConsultation: string;
  motifConsultation: string;
  examenClinique?: string;
  diagnostic?: string;
  traitementPrescrit?: string;
  ordonnance?: string;
  observations?: string;
  prochainRdv?: string;
  hashContenu: string;
  blockchainTxnHash?: string;
  dateCreation: string;
  dateModification: string;
}

export interface MedicalHistoryItem {
  id: string;
  date: string;
  description: string;
  doctorName: string;
}

export interface Prescription {
  id: string;
  date: string;
  medication: string;
  dosage: string;
  instructions: string;
  doctorName: string;
}

export interface Allergy {
  id: string;
  allergen: string;
  severity: 'Mild' | 'Moderate' | 'Severe';
  notes?: string;
}

export interface TestResult {
  id: string;
  date: string;
  testName: string;
  result: string;
  normalRange?: string;
  notes?: string;
}