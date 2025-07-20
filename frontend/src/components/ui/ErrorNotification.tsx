import React, { useEffect, useState } from 'react';
import { X, AlertCircle, CheckCircle, Info, AlertTriangle } from 'lucide-react';

export type NotificationType = 'error' | 'success' | 'warning' | 'info';

export interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  message: string;
  duration?: number;
}

interface ErrorNotificationProps {
  notifications: Notification[];
  onRemove: (id: string) => void;
}

const ErrorNotification: React.FC<ErrorNotificationProps> = ({ notifications, onRemove }) => {
  const [visibleNotifications, setVisibleNotifications] = useState<Notification[]>([]);

  useEffect(() => {
    setVisibleNotifications(notifications);
  }, [notifications]);

  const getIcon = (type: NotificationType) => {
    switch (type) {
      case 'error':
        return <AlertCircle className="h-5 w-5 text-red-500" />;
      case 'success':
        return <CheckCircle className="h-5 w-5 text-green-500" />;
      case 'warning':
        return <AlertTriangle className="h-5 w-5 text-yellow-500" />;
      case 'info':
        return <Info className="h-5 w-5 text-blue-500" />;
      default:
        return <AlertCircle className="h-5 w-5 text-red-500" />;
    }
  };

  const getBackgroundColor = (type: NotificationType) => {
    switch (type) {
      case 'error':
        return 'bg-red-50 border-red-200';
      case 'success':
        return 'bg-green-50 border-green-200';
      case 'warning':
        return 'bg-yellow-50 border-yellow-200';
      case 'info':
        return 'bg-blue-50 border-blue-200';
      default:
        return 'bg-red-50 border-red-200';
    }
  };

  const getTextColor = (type: NotificationType) => {
    switch (type) {
      case 'error':
        return 'text-red-800';
      case 'success':
        return 'text-green-800';
      case 'warning':
        return 'text-yellow-800';
      case 'info':
        return 'text-blue-800';
      default:
        return 'text-red-800';
    }
  };

  if (visibleNotifications.length === 0) {
    return null;
  }

  return (
    <div className="fixed top-4 right-4 z-50 space-y-2 max-w-md">
      {visibleNotifications.map((notification) => (
        <div
          key={notification.id}
          className={`
            flex items-start p-4 rounded-lg border shadow-lg transform transition-all duration-300 ease-in-out
            ${getBackgroundColor(notification.type)}
            animate-in slide-in-from-right-full
          `}
        >
          <div className="flex-shrink-0 mr-3 mt-0.5">
            {getIcon(notification.type)}
          </div>
          
          <div className="flex-1 min-w-0">
            <h4 className={`text-sm font-medium ${getTextColor(notification.type)}`}>
              {notification.title}
            </h4>
            <p className={`text-sm mt-1 ${getTextColor(notification.type)} opacity-90`}>
              {notification.message}
            </p>
          </div>
          
          <button
            onClick={() => onRemove(notification.id)}
            className="flex-shrink-0 ml-3 text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
      ))}
    </div>
  );
};

export default ErrorNotification; 