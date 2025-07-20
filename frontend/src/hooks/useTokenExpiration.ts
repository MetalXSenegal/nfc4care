import { useState, useEffect, useCallback } from 'react';
import { useAuth } from '../context/AuthContext';

interface UseTokenExpirationReturn {
  showExpirationModal: boolean;
  openExpirationModal: () => void;
  closeExpirationModal: () => void;
  handleTokenRefresh: () => void;
  handleForceLogout: () => void;
}

export const useTokenExpiration = (): UseTokenExpirationReturn => {
  const [showExpirationModal, setShowExpirationModal] = useState(false);
  const { validateToken, logout } = useAuth();

  const openExpirationModal = useCallback(() => {
    setShowExpirationModal(true);
  }, []);

  const closeExpirationModal = useCallback(() => {
    setShowExpirationModal(false);
  }, []);

  const handleTokenRefresh = useCallback(async () => {
    try {
      const isValid = await validateToken();
      if (isValid) {
        closeExpirationModal();
        // Optionnel : rafraîchir les données de l'application
        window.location.reload();
      } else {
        handleForceLogout();
      }
    } catch (error) {
      console.error('Erreur lors du refresh du token:', error);
      handleForceLogout();
    }
  }, [validateToken, closeExpirationModal]);

  const handleForceLogout = useCallback(() => {
    logout();
    closeExpirationModal();
  }, [logout, closeExpirationModal]);

  // Écouter les erreurs 401/403 globalement
  useEffect(() => {
    const handleApiError = (event: CustomEvent) => {
      if (event.detail?.status === 401 || event.detail?.status === 403) {
        openExpirationModal();
      }
    };

    window.addEventListener('api-error', handleApiError as EventListener);
    
    return () => {
      window.removeEventListener('api-error', handleApiError as EventListener);
    };
  }, [openExpirationModal]);

  return {
    showExpirationModal,
    openExpirationModal,
    closeExpirationModal,
    handleTokenRefresh,
    handleForceLogout
  };
}; 