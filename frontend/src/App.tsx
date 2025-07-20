import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import ErrorBoundary from './components/ui/ErrorBoundary';
import ErrorNotification from './components/ui/ErrorNotification';
import TokenExpirationModal from './components/ui/TokenExpirationModal';
import { useTokenExpiration } from './hooks/useTokenExpiration';
import { useErrorHandler } from './hooks/useErrorHandler';
import Layout from './components/layout/Layout';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import SearchPatient from './pages/SearchPatient';
import PatientRecord from './pages/PatientRecord';
import History from './pages/History';
import Profile from './pages/Profile';
import NFCScan from './pages/NFCScan';
import './index.css';

// Composant pour les routes protégées
const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Chargement...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return <>{children}</>;
};

// Composant principal avec gestion des tokens
const AppContent: React.FC = () => {
  const {
    showExpirationModal,
    closeExpirationModal,
    handleTokenRefresh,
    handleForceLogout
  } = useTokenExpiration();

  const { notifications, removeNotification } = useErrorHandler();

  return (
    <>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route path="dashboard" element={<Dashboard />} />
            <Route path="search" element={<SearchPatient />} />
            <Route path="patient/:id" element={<PatientRecord />} />
            <Route path="history" element={<History />} />
            <Route path="profile" element={<Profile />} />
            <Route path="nfc-scan" element={<NFCScan />} />
          </Route>
        </Routes>
      </Router>

      {/* Modal d'expiration de token */}
      <TokenExpirationModal
        isOpen={showExpirationModal}
        onClose={closeExpirationModal}
        onRefresh={handleTokenRefresh}
        onLogout={handleForceLogout}
      />

      {/* Notification d'erreurs globales */}
      <ErrorNotification 
        notifications={notifications}
        onRemove={removeNotification}
      />
    </>
  );
};

const App: React.FC = () => {
  return (
    <ErrorBoundary>
      <AuthProvider>
        <AppContent />
      </AuthProvider>
    </ErrorBoundary>
  );
};

export default App;