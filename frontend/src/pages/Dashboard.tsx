import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, History, CreditCard, User, Clock } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

const Dashboard: React.FC = () => {
  const navigate = useNavigate();
  const { currentDoctor } = useAuth();

  const getDoctorName = () => {
    if (currentDoctor) {
      return `${currentDoctor.prenom} ${currentDoctor.nom}`;
    }
    return 'Médecin';
  };

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  };

  const quickActions = [
    {
      name: 'Rechercher un patient',
      description: 'Trouver rapidement un dossier',
      icon: Search,
      href: '/search',
      color: 'bg-blue-500',
      textColor: 'text-blue-500',
      primary: true
    },
    {
      name: 'Scanner NFC',
      description: 'Identifier par carte NFC',
      icon: CreditCard,
      href: '/nfc-scan',
      color: 'bg-green-500',
      textColor: 'text-green-500'
    },
    {
      name: 'Historique',
      description: 'Voir les consultations récentes',
      icon: History,
      href: '/history',
      color: 'bg-purple-500',
      textColor: 'text-purple-500'
    }
  ];

  return (
    <div className="py-4 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        {/* En-tête */}
        <div className="mb-6">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">
                {getGreeting()}, {getDoctorName()} 👋
              </h1>
              <p className="text-gray-600 mt-1">
                Bienvenue dans votre espace médical
              </p>
            </div>
            <div className="flex items-center text-sm text-gray-500 mt-2 sm:mt-0">
              <Clock className="h-4 w-4 mr-1" />
              {new Date().toLocaleDateString('fr-FR', { 
                weekday: 'long', 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric' 
              })}
            </div>
          </div>
        </div>

        {/* Actions rapides */}
        <div className="mb-8">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Actions rapides</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {quickActions.map((action) => {
              const Icon = action.icon;
              return (
                <button
                  key={action.name}
                  onClick={() => navigate(action.href)}
                  className={`
                    bg-white rounded-lg shadow-sm border border-gray-200 p-4 hover:shadow-md transition-shadow text-left
                    ${action.primary ? 'border-blue-200 bg-blue-50' : ''}
                  `}
                >
                  <div className="flex items-center">
                    <div className={`p-2 rounded-lg ${action.color} ${action.primary ? 'bg-opacity-20' : 'bg-opacity-10'}`}>
                      <Icon className={`h-6 w-6 ${action.textColor}`} />
                    </div>
                    <div className="ml-3">
                      <h3 className={`font-medium text-gray-900 ${action.primary ? 'font-semibold' : ''}`}>
                        {action.name}
                        {action.primary && <span className="ml-2 text-blue-600">⭐</span>}
                      </h3>
                      <p className="text-sm text-gray-500">{action.description}</p>
                    </div>
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Section récente */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200">
          <div className="px-4 py-4 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Activité récente</h2>
          </div>
          <div className="p-4">
            <div className="space-y-4">
              <div className="flex items-center">
                <div className="h-8 w-8 bg-blue-100 rounded-full flex items-center justify-center">
                  <User className="h-4 w-4 text-blue-600" />
                </div>
                <div className="ml-3 flex-1">
                  <p className="text-sm font-medium text-gray-900">Consultation - Sophie Laurent</p>
                  <p className="text-sm text-gray-500">Il y a 2 heures</p>
                </div>
                <span className="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-800">
                  Terminée
                </span>
              </div>

              <div className="flex items-center">
                <div className="h-8 w-8 bg-green-100 rounded-full flex items-center justify-center">
                  <CreditCard className="h-4 w-4 text-green-600" />
                </div>
                <div className="ml-3 flex-1">
                  <p className="text-sm font-medium text-gray-900">Scan NFC - Marc Dupont</p>
                  <p className="text-sm text-gray-500">Il y a 4 heures</p>
                </div>
                <span className="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full bg-blue-100 text-blue-800">
                  Identifié
                </span>
              </div>

              <div className="flex items-center">
                <div className="h-8 w-8 bg-purple-100 rounded-full flex items-center justify-center">
                  <Search className="h-4 w-4 text-purple-600" />
                </div>
                <div className="ml-3 flex-1">
                  <p className="text-sm font-medium text-gray-900">Recherche patient</p>
                  <p className="text-sm text-gray-500">Il y a 6 heures</p>
                </div>
                <span className="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full bg-gray-100 text-gray-800">
                  Recherche
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;