import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { useErrorHandler } from '../../hooks/useErrorHandler';
import { 
  User, 
  LogOut, 
  Shield,
  AlertTriangle,
  Bell,
  Settings,
  ChevronDown
} from 'lucide-react';

const MobileHeader: React.FC = () => {
  const { currentDoctor, logout, logoutAllSessions } = useAuth();
  const { handleApiError } = useErrorHandler();
  const [showUserMenu, setShowUserMenu] = useState(false);
  const [showLogoutAllConfirm, setShowLogoutAllConfirm] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);

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
      setShowUserMenu(false);
    } catch (error) {
      handleApiError('Erreur lors de la déconnexion de toutes les sessions', error instanceof Error ? error.message : String(error));
    } finally {
      setIsLoggingOut(false);
    }
  };

  return (
    <>
      {/* Header fixe */}
      <header className="fixed top-0 left-0 right-0 z-40 bg-gradient-to-r from-blue-500 to-blue-600 border-b border-blue-300 shadow-lg">
        <div className="px-4 py-3">
          <div className="flex items-center justify-between">
            {/* Logo et titre */}
            <div className="flex items-center">
              <div className="bg-white rounded-full p-1.5 mr-3 shadow-sm flex items-center justify-center">
                <img
                  src="/assets/logo.png"
                  alt="NFC4Care Logo"
                  className="h-6 w-6 object-contain"
                  loading="eager"
                />
              </div>
              <div>
                <h1 className="text-lg font-bold text-white">NFC4Care</h1>
                <p className="text-xs text-blue-100">Médecine sécurisée</p>
              </div>
            </div>

            {/* Actions rapides */}
            <div className="flex items-center space-x-2">
              <button 
                className="p-2 text-white hover:text-blue-100 hover:bg-white/20 rounded-lg transition-colors"
                aria-label="Notifications"
                title="Notifications"
              >
                <Bell size={20} />
              </button>
              
              {/* Menu utilisateur */}
              <div className="relative">
                <button 
                  onClick={() => setShowUserMenu(!showUserMenu)}
                  className="flex items-center p-2 text-white hover:text-blue-100 hover:bg-white/20 rounded-lg transition-colors"
                  aria-label="Menu utilisateur"
                  title="Menu utilisateur"
                >
                  <User size={20} />
                  <ChevronDown size={16} className="ml-1" />
                </button>
                
                {/* Dropdown menu */}
                {showUserMenu && (
                  <div className="absolute right-0 mt-2 w-56 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-50">
                    {currentDoctor && (
                      <div className="px-4 py-3 border-b border-gray-100 bg-gray-50">
                        <p className="text-sm font-medium text-gray-900">
                          Dr. {currentDoctor.prenom} {currentDoctor.nom}
                        </p>
                        <p className="text-xs text-gray-500">{currentDoctor.specialite}</p>
                      </div>
                    )}
                    
                    <button
                      onClick={() => setShowUserMenu(false)}
                      className="w-full flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                    >
                      <Settings size={16} className="mr-3" />
                      Paramètres
                    </button>
                    
                    <div className="border-t border-gray-100 my-1"></div>
                    
                    <button
                      onClick={handleLogout}
                      disabled={isLoggingOut}
                      className="w-full flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 disabled:opacity-50"
                    >
                      <LogOut size={16} className="mr-3" />
                      {isLoggingOut ? 'Déconnexion...' : 'Se déconnecter'}
                    </button>
                    
                    <button
                      onClick={() => {
                        setShowLogoutAllConfirm(true);
                        setShowUserMenu(false);
                      }}
                      disabled={isLoggingOut}
                      className="w-full flex items-center px-4 py-2 text-sm text-red-600 hover:bg-red-50 disabled:opacity-50"
                    >
                      <Shield size={16} className="mr-3" />
                      Déconnecter toutes les sessions
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Espace pour le header fixe */}
      <div className="h-16"></div>

      {/* Overlay pour fermer le menu */}
      {showUserMenu && (
        <div 
          className="fixed inset-0 z-30"
          onClick={() => setShowUserMenu(false)}
        />
      )}

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
    </>
  );
};

export default MobileHeader; 