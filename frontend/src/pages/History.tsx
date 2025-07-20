import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Calendar, Clock, User, FileText, UserCheck } from 'lucide-react';
import { apiService } from '../services/api';
import { useErrorHandler } from '../hooks/useErrorHandler';
import LoadingSpinner from '../components/ui/LoadingSpinner';
import { Consultation, Patient } from '../types';

interface ConsultationWithPatient extends Consultation {
  patient?: Patient;
  professionnel?: {
    id: number;
    nom: string;
    prenom: string;
    specialite: string;
  };
}

const History: React.FC = () => {
  const [consultations, setConsultations] = useState<ConsultationWithPatient[]>([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const { handleApiError } = useErrorHandler();

  useEffect(() => {
    const fetchConsultations = async () => {
      try {
        setLoading(true);
        const response = await apiService.getConsultations();
        
        if (response.success && response.data) {
          setConsultations(response.data);
        } else {
          handleApiError(response.error || 'Erreur lors du chargement des consultations');
        }
      } catch (error) {
        handleApiError(error, 'Erreur lors du chargement des consultations');
      } finally {
        setLoading(false);
      }
    };

    fetchConsultations();
  }, [handleApiError]);

  // Grouper les consultations par date
  const groupByDate = (entries: ConsultationWithPatient[]) => {
    const grouped: { [key: string]: ConsultationWithPatient[] } = {};
    entries.forEach(entry => {
      const date = entry.dateConsultation.split('T')[0];
      if (!grouped[date]) {
        grouped[date] = [];
      }
      grouped[date].push(entry);
    });
    return grouped;
  };

  const groupedConsultations = groupByDate(consultations);
  const sortedDates = Object.keys(groupedConsultations).sort((a, b) => 
    new Date(b).getTime() - new Date(a).getTime()
  );

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('fr-FR', { 
      weekday: 'long', 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
  };

  const formatTime = (dateString: string) => {
    return new Date(dateString).toLocaleTimeString('fr-FR', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  };

  const getDoctorName = (consultation: ConsultationWithPatient) => {
    if (consultation.professionnel) {
      return `${consultation.professionnel.prenom} ${consultation.professionnel.nom}`;
    }
    return 'Médecin non spécifié';
  };

  const getDoctorSpecialty = (consultation: ConsultationWithPatient) => {
    return consultation.professionnel?.specialite || 'Spécialité non spécifiée';
  };

  if (loading) {
    return (
      <div className="py-6 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto">
          <LoadingSpinner fullScreen text="Chargement de l'historique..." />
        </div>
      </div>
    );
  }

  return (
    <div className="py-6 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-2xl font-bold text-gray-900 mb-6">Historique des consultations</h1>
          
        {consultations.length === 0 ? (
          <div className="bg-white shadow rounded-lg p-8 text-center">
            <FileText className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">Aucune consultation</h3>
            <p className="text-gray-500">Aucune consultation n'a encore été enregistrée.</p>
          </div>
        ) : (
          <div className="bg-white shadow overflow-hidden rounded-lg">
            <div className="px-4 py-5 sm:px-6 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <h2 className="text-lg font-medium text-gray-900">
                  Consultations récentes ({consultations.length})
                </h2>
              </div>
            </div>
            
            <div className="divide-y divide-gray-200">
              {sortedDates.map(date => (
                <div key={date} className="px-4 py-5 sm:p-6">
                  <div className="flex items-center mb-4">
                    <Calendar className="h-5 w-5 text-gray-400 mr-2" />
                    <h3 className="text-base font-medium text-gray-900">
                      {formatDate(date)}
                    </h3>
                  </div>
                  
                  <ul className="space-y-4">
                    {groupedConsultations[date].map(consultation => (
                      <li key={consultation.id} className="bg-gray-50 rounded-lg p-4 hover:bg-gray-100 transition-colors">
                        <div className="flex items-start">
                          <div className="flex-shrink-0">
                            <div className="h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center">
                              <User className="h-5 w-5 text-blue-600" />
                            </div>
                          </div>
                          <div className="ml-3 flex-1">
                            <div className="flex items-center justify-between">
                              <div>
                                <p className="text-sm font-medium text-gray-900">
                                  {consultation.patient ? 
                                    `${consultation.patient.prenom} ${consultation.patient.nom}` : 
                                    'Patient inconnu'
                                  }
                                </p>
                                <p className="text-xs text-gray-500 mt-1">
                                  Dossier: {consultation.patient?.numeroDossier || 'N/A'}
                                </p>
                              </div>
                              <p className="text-sm text-gray-500 flex items-center">
                                <Clock className="h-4 w-4 mr-1" />
                                {formatTime(consultation.dateConsultation)}
                              </p>
                            </div>
                            
                            {/* Informations sur le médecin */}
                            <div className="mt-2 flex items-center text-sm text-gray-600">
                              <UserCheck className="h-4 w-4 mr-1 text-green-500" />
                              <span className="font-medium">{getDoctorName(consultation)}</span>
                              <span className="mx-2">•</span>
                              <span className="text-gray-500">{getDoctorSpecialty(consultation)}</span>
                            </div>
                            
                            {/* Motif et diagnostic */}
                            <div className="mt-2 flex items-center gap-2">
                              <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                                {consultation.motifConsultation}
                              </span>
                              {consultation.diagnostic && (
                                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                  Diagnostic posé
                                </span>
                              )}
                            </div>
                            
                            {consultation.diagnostic && (
                              <div className="mt-2">
                                <p className="text-sm text-gray-600">
                                  <strong>Diagnostic:</strong> {consultation.diagnostic}
                                </p>
                              </div>
                            )}
                            
                            {consultation.traitementPrescrit && (
                              <div className="mt-2">
                                <p className="text-sm text-gray-600">
                                  <strong>Traitement:</strong> {consultation.traitementPrescrit}
                                </p>
                              </div>
                            )}
                            
                            <div className="mt-3 flex items-center justify-between">
                              <button 
                                onClick={() => navigate(`/patient/${consultation.patient?.id}`)}
                                className="text-sm font-medium text-blue-600 hover:text-blue-500"
                              >
                                Voir dossier complet
                              </button>
                              
                              {consultation.blockchainTxnHash && (
                                <span className="text-xs text-green-600 bg-green-50 px-2 py-1 rounded">
                                  ✓ Sécurisé par blockchain
                                </span>
                              )}
                            </div>
                          </div>
                        </div>
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default History;