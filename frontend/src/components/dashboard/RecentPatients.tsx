import React from 'react';
import { User, ArrowRight } from 'lucide-react';
import { Link } from 'react-router-dom';

interface Patient {
  id: string | number;
  nom: string;
  prenom: string;
  dateNaissance: string;
  numeroDossier: string;
  derniereConsultation?: string;
}

interface RecentPatientsProps {
  patients: Patient[];
  onPatientClick?: (id: string | number) => void;
}

const RecentPatients: React.FC<RecentPatientsProps> = ({ patients, onPatientClick }) => {
  const calculateAge = (dateNaissance: string) => {
    const birthDate = new Date(dateNaissance);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    return age;
  };

  const handlePatientClick = (patient: Patient) => {
    if (onPatientClick) {
      onPatientClick(patient.id);
    }
  };

  if (patients.length === 0) {
    return (
      <div className="bg-white rounded-lg shadow p-4">
        <h2 className="text-lg font-semibold mb-4">Derniers patients consultés</h2>
        <p className="text-gray-500 text-center py-6">Aucun patient récemment consulté</p>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow">
      <div className="px-4 py-3 border-b border-gray-200">
        <h2 className="text-lg font-semibold">Derniers patients consultés</h2>
      </div>
      <ul className="divide-y divide-gray-200">
        {patients.map(patient => (
          <li key={patient.id} className="px-4 py-3 hover:bg-gray-50 transition-colors">
            <button 
              onClick={() => handlePatientClick(patient)}
              className="w-full flex items-center justify-between text-left"
            >
              <div className="flex items-center">
                <div className="flex-shrink-0 h-10 w-10 bg-blue-100 rounded-full flex items-center justify-center">
                  <User className="h-5 w-5 text-blue-600" />
                </div>
                <div className="ml-3">
                  <p className="text-sm font-medium text-gray-900">
                    {patient.prenom} {patient.nom}
                  </p>
                  <p className="text-xs text-gray-500">
                    {patient.numeroDossier} · {calculateAge(patient.dateNaissance)} ans
                  </p>
                </div>
              </div>
              <div className="flex items-center text-sm text-gray-500">
                <span className="mr-2">
                  {patient.derniereConsultation 
                    ? new Date(patient.derniereConsultation).toLocaleDateString('fr-FR') 
                    : 'N/A'}
                </span>
                <ArrowRight size={16} className="text-gray-400" />
              </div>
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default RecentPatients;