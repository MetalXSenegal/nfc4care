import { Doctor } from '../types';

// Données mockées pour le dashboard
export const mockDashboardStats = {
  totalPatients: 156,
  totalConsultations: 342,
  consultationsThisMonth: 28,
  patientsWithNFC: 89
};

export const mockRecentPatients = [
  {
    id: 1,
    nom: "Dupont",
    prenom: "Marie",
    dateNaissance: "1985-03-15",
    numeroDossier: "P2024001",
    derniereConsultation: "2024-01-15T10:30:00",
    email: "marie.dupont@email.com",
    telephone: "0123456789",
    adresse: "123 Rue de la Paix, Paris",
    nfcId: "NFC001"
  },
  {
    id: 2,
    nom: "Martin",
    prenom: "Jean",
    dateNaissance: "1978-07-22",
    numeroDossier: "P2024002",
    derniereConsultation: "2024-01-14T14:15:00",
    email: "jean.martin@email.com",
    telephone: "0123456790",
    adresse: "456 Avenue des Champs, Lyon",
    nfcId: "NFC002"
  },
  {
    id: 3,
    nom: "Bernard",
    prenom: "Sophie",
    dateNaissance: "1992-11-08",
    numeroDossier: "P2024003",
    derniereConsultation: "2024-01-13T09:45:00",
    email: "sophie.bernard@email.com",
    telephone: "0123456791",
    adresse: "789 Boulevard Central, Marseille",
    nfcId: "NFC003"
  },
  {
    id: 4,
    nom: "Petit",
    prenom: "Pierre",
    dateNaissance: "1980-05-12",
    numeroDossier: "P2024004",
    derniereConsultation: "2024-01-12T16:20:00",
    email: "pierre.petit@email.com",
    telephone: "0123456792",
    adresse: "321 Rue du Commerce, Toulouse",
    nfcId: "NFC004"
  },
  {
    id: 5,
    nom: "Robert",
    prenom: "Claire",
    dateNaissance: "1987-09-30",
    numeroDossier: "P2024005",
    derniereConsultation: "2024-01-11T11:10:00",
    email: "claire.robert@email.com",
    telephone: "0123456793",
    adresse: "654 Place de la République, Nantes",
    nfcId: "NFC005"
  }
];

// Données mockées pour les consultations récentes
export const mockRecentConsultations = [
  {
    id: 1,
    patientName: "Marie Dupont",
    date: "2024-01-15T10:30:00",
    motif: "Contrôle annuel",
    status: "Terminée"
  },
  {
    id: 2,
    patientName: "Jean Martin",
    date: "2024-01-14T14:15:00",
    motif: "Suivi traitement",
    status: "Terminée"
  },
  {
    id: 3,
    patientName: "Sophie Bernard",
    date: "2024-01-13T09:45:00",
    motif: "Consultation urgente",
    status: "Terminée"
  }
];

// Données mockées pour l'activité récente
export const mockRecentActivity = [
  {
    id: 1,
    type: "login",
    description: "Connexion réussie",
    timestamp: "2024-01-15T08:00:00",
    user: "Dr. Smith"
  },
  {
    id: 2,
    type: "consultation",
    description: "Nouvelle consultation créée",
    timestamp: "2024-01-15T10:30:00",
    user: "Dr. Smith"
  },
  {
    id: 3,
    type: "patient",
    description: "Patient ajouté au système",
    timestamp: "2024-01-14T16:45:00",
    user: "Dr. Smith"
  }
]; 