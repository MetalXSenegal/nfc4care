import React, { useState } from 'react';
import { AlertTriangle, RefreshCw, LogOut, X } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

interface TokenExpirationModalProps {
  isOpen: boolean;
  onClose: () => void;
  onRefresh: () => void;
  onLogout: () => void;
}

const TokenExpirationModal: React.FC<TokenExpirationModalProps> = ({
  isOpen,
  onClose,
  onRefresh,
  onLogout
}) => {
  const [isRefreshing, setIsRefreshing] = useState(false);
  const { validateToken } = useAuth();

  const handleRefresh = async () => {
    setIsRefreshing(true);
    try {
      const isValid = await validateToken();
      if (isValid) {
        onRefresh();
        onClose();
      } else {
        // Token toujours invalide, forcer la déconnexion
        onLogout();
      }
    } catch (error) {
      console.error('Erreur lors du refresh:', error);
      onLogout();
    } finally {
      setIsRefreshing(false);
    }
  };

  const handleLogout = () => {
    onLogout();
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4 shadow-xl">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center">
            <AlertTriangle className="h-6 w-6 text-yellow-500 mr-2" />
            <h3 className="text-lg font-semibold text-gray-900">
              Session Expirée
            </h3>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="mb-6">
          <p className="text-gray-600 mb-4">
            Votre session a expiré. Vous pouvez essayer de la renouveler ou vous reconnecter.
          </p>
          
          <div className="bg-yellow-50 border border-yellow-200 rounded-md p-3">
            <p className="text-sm text-yellow-800">
              <strong>Note :</strong> Si le renouvellement échoue, vous devrez vous reconnecter.
            </p>
          </div>
        </div>

        <div className="flex space-x-3">
          <button
            onClick={handleRefresh}
            disabled={isRefreshing}
            className="flex-1 flex items-center justify-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isRefreshing ? (
              <RefreshCw className="h-4 w-4 animate-spin mr-2" />
            ) : (
              <RefreshCw className="h-4 w-4 mr-2" />
            )}
            {isRefreshing ? 'Renouvellement...' : 'Renouveler'}
          </button>

          <button
            onClick={handleLogout}
            className="flex-1 flex items-center justify-center px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700"
          >
            <LogOut className="h-4 w-4 mr-2" />
            Se reconnecter
          </button>
        </div>
      </div>
    </div>
  );
};

export default TokenExpirationModal; 