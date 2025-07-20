import { useState, useCallback } from 'react';
import { Notification, NotificationType } from '../components/ui/ErrorNotification';

interface ErrorState {
  hasError: boolean;
  message: string;
}

export const useErrorHandler = () => {
  const [error, setError] = useState<ErrorState>({ hasError: false, message: '' });
  const [notifications, setNotifications] = useState<Notification[]>([]);

  const showError = useCallback((title: string, message: string, type: NotificationType = 'error') => {
    const id = Date.now().toString();
    const notification: Notification = {
      id,
      type,
      title,
      message,
      duration: type === 'error' ? 8000 : 5000 // Erreurs plus longues, succès plus courts
    };

    setNotifications(prev => [...prev, notification]);

    // Auto-remove notification after duration
    if (notification.duration) {
      setTimeout(() => {
        removeNotification(id);
      }, notification.duration);
    }
  }, []);

  const hideError = useCallback(() => {
    setError({ hasError: false, message: '' });
  }, []);

  const handleApiError = useCallback((error: any, defaultMessage: string = 'Une erreur est survenue') => {
    console.error('API Error:', error);
    
    let message = defaultMessage;
    
    if (error?.response?.data?.message) {
      message = error.response.data.message;
    } else if (error?.message) {
      message = error.message;
    } else if (typeof error === 'string') {
      message = error;
    }

    showError('Erreur', message, 'error');
  }, [showError]);

  const showSuccess = useCallback((title: string, message: string) => {
    showError(title, message, 'success');
  }, [showError]);

  const showWarning = useCallback((title: string, message: string) => {
    showError(title, message, 'warning');
  }, [showError]);

  const showInfo = useCallback((title: string, message: string) => {
    showError(title, message, 'info');
  }, [showError]);

  const removeNotification = useCallback((id: string) => {
    setNotifications(prev => prev.filter(notification => notification.id !== id));
  }, []);

  const clearAllNotifications = useCallback(() => {
    setNotifications([]);
  }, []);

  return {
    error,
    showError,
    hideError,
    handleApiError,
    showSuccess,
    showWarning,
    showInfo,
    notifications,
    removeNotification,
    clearAllNotifications
  };
}; 