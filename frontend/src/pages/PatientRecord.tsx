import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import PatientHeader from '../components/patient/PatientHeader';
import MedicalTabs from '../components/patient/MedicalTabs';
import NFCWriter from '../components/nfc/NFCWriter';
import Button from '../components/ui/Button';
import { ArrowLeft, Loader2, CreditCard } from 'lucide-react';
import { apiService } from '../services/api';

interface Patient {
  id: string;
  nom: string;
  prenom: string;
  dateNaissance: string;
  sexe: string;
  numeroDossier: string;
  adresse: string;
  telephone: string;
  email?: string;
  groupeSanguin?: string;
  numeroNfc?: string;
}

interface MedicalRecord {
  id: string;
  patientId: string;
  antecedentsMedicaux?: string;
  antecedentsChirurgicaux?: string;
  antecedentsFamiliaux?: string;
  traitementsEnCours?: string;
  allergies?: string;
  observationsGenerales?: string;
  hashContenu: string;
  blockchainTxnHash?: string;
}

const PatientRecord: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [patient, setPatient] = useState<Patient | null>(null);
  const [medicalRecord, setMedicalRecord] = useState<MedicalRecord | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showNFCWriter, setShowNFCWriter] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      if (!id) return;
      
      setLoading(true);
      try {
        // Récupérer les données du patient
        const patientResponse = await apiService.getPatientById(id);
        
        if (!patientResponse.success || !patientResponse.data) {
          setError('Patient non trouvé');
          setLoading(false);
          return;
        }
        
        setPatient(patientResponse.data);
        
        // Pour l'instant, on simule un dossier médical
        // En production, vous auriez un endpoint pour récupérer le dossier médical
        const mockMedicalRecord: MedicalRecord = {
          id: '1',
          patientId: id,
          antecedentsMedicaux: 'Aucun antécédent médical notable',
          allergies: 'Aucune allergie connue',
          hashContenu: 'abc123...',
          blockchainTxnHash: 'txn_hash_123'
        };
        
        setMedicalRecord(mockMedicalRecord);
      } catch (err) {
        console.error('Erreur lors du chargement des données:', err);
        setError('Erreur lors du chargement des données');
      } finally {
        setLoading(false);
      }
    };
    
    fetchData();
  }, [id]);

  const handleNFCSuccess = () => {
    // Optionnel: mettre à jour l'interface ou afficher une notification
    console.log('Carte NFC écrite avec succès');
  };

  const handleNFCError = (error: string) => {
    console.error('Erreur NFC:', error);
    // Optionnel: afficher une notification d'erreur
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="w-10 h-10 text-blue-600 animate-spin" />
      </div>
    );
  }

  if (error || !patient || !medicalRecord) {
    return (
      <div className="py-6 px-4 sm:px-6 lg:px-8 max-w-4xl mx-auto">
        <div className="bg-red-50 p-4 rounded-md border border-red-200 mb-4">
          <p className="text-red-700">{error || 'Une erreur est survenue'}</p>
        </div>
        <Button
          variant="outline"
          icon={<ArrowLeft size={16} />}
          onClick={() => navigate('/dashboard')}
        >
          Retour au tableau de bord
        </Button>
      </div>
    );
  }

  return (
    <div className="min-h-full bg-gray-50">
      <PatientHeader patient={patient} />
      
      <div className="py-6 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
        <div className="mb-6 flex justify-between items-center">
          <Button
            variant="outline"
            size="sm"
            icon={<ArrowLeft size={16} />}
            onClick={() => navigate('/dashboard')}
          >
            Retour au tableau de bord
          </Button>
          
          <Button
            variant="outline"
            size="sm"
            icon={<CreditCard size={16} />}
            onClick={() => setShowNFCWriter(!showNFCWriter)}
          >
            {showNFCWriter ? 'Masquer' : 'Écrire'} Carte NFC
          </Button>
        </div>
        
        <div className="space-y-6">
          {showNFCWriter && (
            <div className="bg-white rounded-lg shadow-sm border p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">
                Configuration Carte NFC
              </h2>
              <NFCWriter
                patientId={patient.id}
                patientName={`${patient.prenom} ${patient.nom}`}
                nfcId={patient.numeroNfc || `nfc-${patient.id}`}
                onSuccess={handleNFCSuccess}
                onError={handleNFCError}
              />
            </div>
          )}
          
          <MedicalTabs medicalRecord={medicalRecord} />
        </div>
      </div>
    </div>
  );
};

export default PatientRecord;