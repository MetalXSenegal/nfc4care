import React from 'react';
import { Calendar, FileText, Phone, Mail } from 'lucide-react';

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
}

interface PatientHeaderProps {
  patient: Patient;
}

const PatientHeader: React.FC<PatientHeaderProps> = ({ patient }) => {
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

  const formatPhone = (phone: string) => {
    // Formatage du téléphone pour l'affichage
    const cleaned = phone.replace(/\D/g, '');
    if (cleaned.length === 10) {
      return cleaned.replace(/(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/, '$1 $2 $3 $4 $5');
    }
    return phone;
  };

  return (
    <div className="bg-white border-b border-gray-200 shadow-sm">
      <div className="px-4 py-4 sm:px-6 lg:px-8">
        <div className="md:flex md:items-center md:justify-between">
          <div className="flex-1 min-w-0">
            <h1 className="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
              {patient.prenom} {patient.nom}
            </h1>
            <div className="mt-1 flex flex-col sm:flex-row sm:flex-wrap sm:mt-0 sm:space-x-6">
              <div className="mt-2 flex items-center text-sm text-gray-500">
                <Calendar className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
                {calculateAge(patient.dateNaissance)} ans
              </div>
              <div className="mt-2 flex items-center text-sm text-gray-500">
                <FileText className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
                Dossier: {patient.numeroDossier}
              </div>
              {patient.telephone && (
                <div className="mt-2 flex items-center text-sm text-gray-500">
                  <Phone className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
                  <a 
                    href={`tel:${patient.telephone}`}
                    className="hover:text-blue-600 transition-colors"
                  >
                    {formatPhone(patient.telephone)}
                  </a>
                </div>
              )}
              {patient.email && (
                <div className="mt-2 flex items-center text-sm text-gray-500">
                  <Mail className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
                  <a 
                    href={`mailto:${patient.email}`}
                    className="hover:text-blue-600 transition-colors truncate"
                  >
                    {patient.email}
                  </a>
                </div>
              )}
            </div>
          </div>
          <div className="mt-4 flex flex-col sm:flex-row gap-2 md:mt-0 md:ml-4">
            <button
              type="button"
              className="inline-flex items-center justify-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Éditer informations
            </button>
            <button
              type="button"
              className="inline-flex items-center justify-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Ajouter commentaire
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PatientHeader;