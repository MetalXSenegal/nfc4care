import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { useErrorHandler } from '../../hooks/useErrorHandler';
import { 
  Home, 
  Search, 
  Users, 
  History, 
  User, 
  LogOut, 
  Shield,
  AlertTriangle
} from 'lucide-react';

const Sidebar: React.FC = () => {
  const { currentDoctor, logout, logoutAllSessions } = useAuth();
  const { handleApiError } = useErrorHandler();
  const location = useLocation();
  const [showLogoutAllConfirm, setShowLogoutAllConfirm] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  const navigation = [
    { name: 'Tableau de bord', href: '/dashboard', icon: Home },
    { name: 'Rechercher un patient', href: '/search', icon: Search },
    { name: 'Historique', href: '/history', icon: History },
    { name: 'Scanner NFC', href: '/nfc-scan', icon: Users },
    { name: 'Profil', href: '/profile', icon: User },
  ];

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

  const isActive = (path: string) => {
    return location.pathname === path;
  };

  return (
    <>
      {/* Desktop Sidebar */}
      <div className="fixed inset-y-0 left-0 z-40 w-64 bg-white shadow-lg">
        <div className="flex flex-col h-full">
          {/* Header */}
          <div className="flex items-center justify-center h-16 px-4 bg-blue-600 text-white">
            <h1 className="text-xl font-bold">NFC4Care</h1>
          </div>

          {/* User info */}
          {currentDoctor && (
            <div className="px-4 py-3 border-b border-gray-200">
              <div className="flex items-center">
                <div className="h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center">
                  <User className="h-5 w-5 text-blue-600" />
                </div>
                <div className="ml-3">
                  <p className="text-sm font-medium text-gray-900">
                    Dr. {currentDoctor.prenom} {currentDoctor.nom}
                  </p>
                  <p className="text-xs text-gray-500">{currentDoctor.specialite}</p>
                </div>
              </div>
            </div>
          )}

          {/* Navigation */}
          <nav className="flex-1 px-4 py-6 space-y-2">
            {navigation.map((item) => {
              const Icon = item.icon;
              return (
                <Link
                  key={item.name}
                  to={item.href}
                  className={`
                    flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors
                    ${isActive(item.href)
                      ? 'bg-blue-100 text-blue-700'
                      : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'
                    }
                  `}
                >
                  <Icon className="mr-3 h-5 w-5" />
                  {item.name}
                </Link>
              );
            })}
          </nav>

          {/* Logout section */}
          <div className="px-4 py-4 border-t border-gray-200">
            <div className="space-y-2">
              <button
                onClick={handleLogout}
                disabled={isLoggingOut}
                className="w-full flex items-center px-3 py-2 text-sm font-medium text-gray-600 hover:bg-gray-100 hover:text-gray-900 rounded-md transition-colors disabled:opacity-50"
              >
                <LogOut className="mr-3 h-5 w-5" />
                {isLoggingOut ? 'Déconnexion...' : 'Se déconnecter'}
              </button>
              
              <button
                onClick={() => setShowLogoutAllConfirm(true)}
                disabled={isLoggingOut}
                className="w-full flex items-center px-3 py-2 text-sm font-medium text-red-600 hover:bg-red-50 hover:text-red-700 rounded-md transition-colors disabled:opacity-50"
              >
                <Shield className="mr-3 h-5 w-5" />
                Déconnecter toutes les sessions
              </button>
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
    </>
  );
};

export default Sidebar;