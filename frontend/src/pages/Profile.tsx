import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useErrorHandler } from '../hooks/useErrorHandler';
import { LogOut, Shield, User, Settings, AlertTriangle } from 'lucide-react';

const Profile: React.FC = () => {
  const { currentDoctor, logout, logoutAllSessions } = useAuth();
  const { handleApiError } = useErrorHandler();
  const [isLoggingOut, setIsLoggingOut] = useState(false);
  const [showLogoutAllConfirm, setShowLogoutAllConfirm] = useState(false);

  const handleLogout = async () => {
    setIsLoggingOut(true);
    try {
      await logout();
    } catch (error) {
      handleApiError('Erreur lors de la déconnexion', error instanceof Error ? error.message : String(error));
    } finally {
      setIsLoggingOut(false);
    }
  };

  const handleLogoutAllSessions = async () => {
    setIsLoggingOut(true);
    try {
      await logoutAllSessions();
      setShowLogoutAllConfirm(false);
    } catch (error) {
      handleApiError('Erreur lors de la déconnexion de toutes les sessions', error instanceof Error ? error.message : String(error));
    } finally {
      setIsLoggingOut(false);
    }
  };

  if (!currentDoctor) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-2 text-gray-600">Chargement du profil...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto p-6">
      <div className="bg-white rounded-lg shadow-md">
        {/* En-tête du profil */}
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 text-white p-6 rounded-t-lg">
          <div className="flex items-center">
            <div className="bg-white bg-opacity-20 rounded-full p-3 mr-4">
              <User className="h-8 w-8" />
            </div>
            <div>
              <h1 className="text-2xl font-bold">
                Dr. {currentDoctor.prenom} {currentDoctor.nom}
              </h1>
              <p className="text-blue-100">{currentDoctor.specialite}</p>
            </div>
          </div>
        </div>

        <div className="p-6">
          {/* Informations personnelles */}
          <div className="mb-8">
            <h2 className="text-xl font-semibold text-gray-800 mb-4 flex items-center">
              <User className="h-5 w-5 mr-2" />
              Informations personnelles
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="bg-gray-50 p-4 rounded-lg">
                <label className="text-sm font-medium text-gray-600">Nom complet</label>
                <p className="text-gray-900 font-medium">
                  Dr. {currentDoctor.prenom} {currentDoctor.nom}
                </p>
              </div>
              <div className="bg-gray-50 p-4 rounded-lg">
                <label className="text-sm font-medium text-gray-600">Email</label>
                <p className="text-gray-900">{currentDoctor.email}</p>
              </div>
              <div className="bg-gray-50 p-4 rounded-lg">
                <label className="text-sm font-medium text-gray-600">Spécialité</label>
                <p className="text-gray-900">{currentDoctor.specialite}</p>
              </div>
              <div className="bg-gray-50 p-4 rounded-lg">
                <label className="text-sm font-medium text-gray-600">Numéro RPPS</label>
                <p className="text-gray-900">{currentDoctor.numeroRpps}</p>
              </div>
              <div className="bg-gray-50 p-4 rounded-lg">
                <label className="text-sm font-medium text-gray-600">Rôle</label>
                <p className="text-gray-900 capitalize">{currentDoctor.role}</p>
              </div>
              <div className="bg-gray-50 p-4 rounded-lg">
                <label className="text-sm font-medium text-gray-600">Statut</label>
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                  currentDoctor.actif 
                    ? 'bg-green-100 text-green-800' 
                    : 'bg-red-100 text-red-800'
                }`}>
                  {currentDoctor.actif ? 'Actif' : 'Inactif'}
                </span>
              </div>
            </div>
          </div>

          {/* Sécurité et sessions */}
          <div className="mb-8">
            <h2 className="text-xl font-semibold text-gray-800 mb-4 flex items-center">
              <Shield className="h-5 w-5 mr-2" />
              Sécurité et sessions
            </h2>
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-4">
              <div className="flex items-start">
                <AlertTriangle className="h-5 w-5 text-yellow-600 mr-2 mt-0.5" />
                <div>
                  <h3 className="text-sm font-medium text-yellow-800">
                    Gestion des sessions
                  </h3>
                  <p className="text-sm text-yellow-700 mt-1">
                    Vous pouvez vous déconnecter de cette session ou de toutes vos sessions actives.
                  </p>
                </div>
              </div>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <button
                onClick={handleLogout}
                disabled={isLoggingOut}
                className="flex items-center justify-center px-4 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <LogOut className="h-4 w-4 mr-2" />
                {isLoggingOut ? 'Déconnexion...' : 'Se déconnecter'}
              </button>
              
              <button
                onClick={() => setShowLogoutAllConfirm(true)}
                disabled={isLoggingOut}
                className="flex items-center justify-center px-4 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <Shield className="h-4 w-4 mr-2" />
                Déconnecter toutes les sessions
              </button>
            </div>
          </div>

          {/* Paramètres */}
          <div>
            <h2 className="text-xl font-semibold text-gray-800 mb-4 flex items-center">
              <Settings className="h-5 w-5 mr-2" />
              Paramètres
            </h2>
            <div className="bg-gray-50 rounded-lg p-4">
              <p className="text-gray-600 text-sm">
                Les paramètres avancés seront disponibles dans une prochaine version.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Modal de confirmation pour déconnexion de toutes les sessions */}
      {showLogoutAllConfirm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
            <div className="flex items-center mb-4">
              <AlertTriangle className="h-6 w-6 text-red-500 mr-2" />
              <h3 className="text-lg font-semibold text-gray-900">
                Déconnexion de toutes les sessions
              </h3>
            </div>
            
            <p className="text-gray-600 mb-6">
              Êtes-vous sûr de vouloir vous déconnecter de toutes vos sessions actives ? 
              Cette action fermera toutes vos connexions sur tous vos appareils.
            </p>
            
            <div className="flex space-x-3">
              <button
                onClick={() => setShowLogoutAllConfirm(false)}
                className="flex-1 px-4 py-2 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400"
              >
                Annuler
              </button>
              <button
                onClick={handleLogoutAllSessions}
                disabled={isLoggingOut}
                className="flex-1 px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 disabled:opacity-50"
              >
                {isLoggingOut ? 'Déconnexion...' : 'Confirmer'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Profile;