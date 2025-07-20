import React, { createContext, useContext, useState, useEffect, useCallback, ReactNode } from 'react';
import { apiService } from '../services/api';

interface Doctor {
  id: number;
  email: string;
  nom: string;
  prenom: string;
  specialite?: string;
  numeroRpps?: string;
  role: string;
  dateCreation: string;
  actif: boolean;
}

interface AuthContextType {
  currentDoctor: Doctor | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<{ success: boolean; requires2FA?: boolean; error?: string }>;
  verify2FA: (code: string) => Promise<{ success: boolean; error?: string }>;
  logout: () => void;
  logoutAllSessions: () => void;
  loading: boolean;
  refreshAuth: () => Promise<void>;
  clearAuth: () => void;
  validateToken: () => Promise<boolean>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [currentDoctor, setCurrentDoctor] = useState<Doctor | null>(null);
  const [pendingLoginData, setPendingLoginData] = useState<{ email: string; token: string } | null>(null);
  const [loading, setLoading] = useState(true);

  // Validation locale du token (sans appel API)
  const validateTokenLocally = (token: string): boolean => {
    try {
      console.log('🔍 Validation locale du token...');
      
      // Décoder le token JWT
      const payload = JSON.parse(atob(token.split('.')[1]));
      console.log('📋 Payload du token:', payload);
      
      // Vérifier l'expiration
      const expirationTime = payload.exp * 1000; // Convertir en millisecondes
      const currentTime = Date.now();
      const timeRemaining = expirationTime - currentTime;
      
      console.log('⏰ Expiration:', new Date(expirationTime).toLocaleString());
      console.log('⏰ Temps restant:', Math.floor(timeRemaining / (1000 * 60)), 'minutes');
      
      if (timeRemaining <= 0) {
        console.log('❌ Token expiré (validation locale)');
        return false;
      }
      
      console.log('✅ Token valide (validation locale)');
      return true;
    } catch (error) {
      console.error('❌ Erreur lors de la validation locale du token:', error);
      return false;
    }
  };

  // Validation avec le backend (utilisée seulement lors des requêtes API)
  const validateTokenWithBackend = async (token: string): Promise<boolean> => {
    try {
      console.log('🔄 Validation du token avec le backend...');
      
      // Stocker temporairement le token pour la validation
      const originalToken = localStorage.getItem('authToken');
      localStorage.setItem('authToken', token);
      
      const response = await apiService.validateToken();
      
      // Restaurer le token original
      if (originalToken) {
        localStorage.setItem('authToken', originalToken);
      } else {
        localStorage.removeItem('authToken');
      }
      
      if (!response.success) {
        console.log('❌ Token invalide (validation backend)');
        return false;
      }
      
      console.log('✅ Token validé avec le backend');
      return true;
    } catch (error) {
      console.error('❌ Erreur de validation du token avec le backend:', error);
      return false;
    }
  };

  // Validation complète (locale + backend si nécessaire)
  const validateToken = async (token: string): Promise<boolean> => {
    // Vérifier d'abord localement
    if (!validateTokenLocally(token)) {
      return false;
    }
    
    // Validation avec le backend seulement si nécessaire
    return await validateTokenWithBackend(token);
  };

  // Initialiser l'authentification au démarrage
  useEffect(() => {
    let isInitialized = false;
    
    const initializeAuth = async () => {
      // Éviter les initialisations multiples
      if (isInitialized) {
        console.log('🔄 Initialisation déjà en cours, ignorée');
        return;
      }
      
      isInitialized = true;
      
      try {
        const token = localStorage.getItem('authToken');
        const doctorData = localStorage.getItem('doctorData');
        
        console.log('🔍 Initialisation de l\'authentification...');
        console.log('🔍 Token trouvé:', token ? 'Oui' : 'Non');
        console.log('🔍 Données utilisateur trouvées:', doctorData ? 'Oui' : 'Non');
        
        if (token && doctorData) {
          console.log('🔄 Tentative de restauration de session...');
          
          // Validation locale rapide au démarrage
          const isLocallyValid = validateTokenLocally(token);
          if (!isLocallyValid) {
            console.log('❌ Token expiré (validation locale), nettoyage de la session');
            clearAuth();
            setLoading(false);
            return;
          }
          
          // Si la validation locale réussit, restaurer immédiatement la session
          try {
            const doctor = JSON.parse(doctorData);
            setCurrentDoctor(doctor);
            console.log('✅ Session restaurée avec succès pour:', doctor.prenom, doctor.nom);
          } catch (error) {
            console.error('❌ Erreur lors du parsing des données utilisateur:', error);
            clearAuth();
          }
        } else {
          console.log('ℹ️  Aucune session trouvée');
        }
      } catch (error) {
        console.error('❌ Erreur lors de l\'initialisation de l\'auth:', error);
        clearAuth();
      } finally {
        setLoading(false);
      }
    };

    initializeAuth();
  }, []);

  const clearAuth = () => {
    localStorage.removeItem('authToken');
    localStorage.removeItem('doctorData');
    localStorage.removeItem('pendingLogin');
    setCurrentDoctor(null);
    setPendingLoginData(null);
  };

  const login = async (email: string, password: string): Promise<{ success: boolean; requires2FA?: boolean; error?: string }> => {
    try {
      console.log('🔐 Début de la tentative de connexion...');
      console.log('📧 Email:', email);
      console.log('🔑 Mot de passe fourni:', password ? 'Oui' : 'Non');
      console.log('📡 Appel API login...');
      
      const response = await apiService.login(email, password);
      
      console.log('📡 Réponse API reçue:', response);
      console.log('📡 Réponse success:', response.success);
      console.log('📡 Réponse data:', response.data);
      
      if (response.success && response.data) {
        const { token, professionnelId, nom, prenom, email: userEmail, role, specialite, numeroRpps, dateCreation, actif, requires2FA } = response.data;
        
        console.log('✅ Connexion réussie, token reçu:', token ? `${token.substring(0, 20)}...` : 'Aucun token');
        console.log('🔑 TOKEN COMPLET RÉCUPÉRÉ:', token);
        console.log('📋 Données reçues:', {
          professionnelId,
          nom,
          prenom,
          email: userEmail,
          role,
          specialite,
          requires2FA
        });
        
        if (requires2FA) {
          // Stocker temporairement les données pour la 2FA
          console.log('🔐 2FA requis, stockage temporaire des données');
          setPendingLoginData({ email, token });
          localStorage.setItem('pendingLogin', JSON.stringify({ email, token }));
          console.log('💾 Données 2FA stockées dans localStorage');
          console.log('🔍 Vérification 2FA localStorage:', localStorage.getItem('pendingLogin'));
          return { success: true, requires2FA: true };
        }
        
        // Connexion directe sans 2FA
        const doctorData: Doctor = {
          id: professionnelId,
          email: userEmail,
          nom,
          prenom,
          specialite,
          numeroRpps,
          role,
          dateCreation,
          actif
        };
        
        console.log('💾 Stockage du token et des données utilisateur');
        console.log('🔑 Token à stocker:', token ? `${token.substring(0, 50)}...` : 'Aucun token');
        console.log('👤 Données utilisateur à stocker:', doctorData);
        
        // Vérifier que localStorage est disponible
        console.log('🔍 Vérification localStorage disponible:', typeof localStorage !== 'undefined');
        console.log('🔍 localStorage accessible:', !!localStorage);
        
        try {
          // Stocker le token
          localStorage.setItem('authToken', token);
          console.log('✅ Token stocké dans localStorage');
          
          // Stocker les données utilisateur
          localStorage.setItem('doctorData', JSON.stringify(doctorData));
          console.log('✅ Données utilisateur stockées dans localStorage');
          
          // Attendre un peu pour s'assurer que le stockage est terminé
          await new Promise(resolve => setTimeout(resolve, 100));
          
          // Vérifier que le stockage a fonctionné
          const storedToken = localStorage.getItem('authToken');
          const storedData = localStorage.getItem('doctorData');
          console.log('🔍 Vérification du stockage:');
          console.log('  - Token stocké:', storedToken ? 'Oui' : 'Non');
          console.log('  - Données stockées:', storedData ? 'Oui' : 'Non');
          console.log('🔑 TOKEN STOCKÉ DANS LOCALSTORAGE:', storedToken ? `${storedToken.substring(0, 20)}...` : 'Aucun');
          console.log('📋 DONNÉES STOCKÉES DANS LOCALSTORAGE:', storedData ? 'Présentes' : 'Absentes');
          
          // Vérifier que le token stocké correspond au token reçu
          if (storedToken === token) {
            console.log('✅ CONFIRMATION: Token stocké correspond au token reçu');
          } else {
            console.log('❌ ERREUR: Token stocké ne correspond pas au token reçu');
            console.log('  - Token reçu:', token);
            console.log('  - Token stocké:', storedToken);
          }
          
          setCurrentDoctor(doctorData);
          console.log('✅ État utilisateur mis à jour');
          
          // Vérification finale que tout est bien stocké
          const finalCheck = localStorage.getItem('authToken') && localStorage.getItem('doctorData');
          if (!finalCheck) {
            console.error('❌ ÉCHEC: Token ou données non stockés après la connexion');
            clearAuth();
            return { success: false, error: 'Erreur lors du stockage de la session' };
          }
          
          console.log('✅ Vérification finale réussie - Session complètement établie');
          console.log('🎉 RÉSUMÉ FINAL:');
          console.log('  - Token récupéré du backend: ✅');
          console.log('  - Token stocké dans localStorage: ✅');
          console.log('  - Données utilisateur stockées: ✅');
          console.log('  - Session établie: ✅');
          
          // Afficher le contenu complet du localStorage
          console.log('🔍 CONTENU COMPLET DU LOCALSTORAGE:');
          Object.keys(localStorage).forEach(key => {
            console.log(`  ${key}:`, localStorage.getItem(key));
          });
          
          return { success: true };
          
        } catch (storageError) {
          console.error('❌ ERREUR LORS DU STOCKAGE:', storageError);
          console.error('📋 Détails de l\'erreur de stockage:', {
            message: storageError instanceof Error ? storageError.message : 'Erreur inconnue',
            name: storageError instanceof Error ? storageError.name : 'Erreur'
          });
          return { success: false, error: 'Erreur lors du stockage de la session' };
        }
      } else {
        console.log('❌ Échec de connexion:', response.error);
        console.log('📋 Réponse complète:', response);
        return { success: false, error: response.error || 'Erreur de connexion' };
      }
    } catch (error) {
      console.error('❌ Erreur lors de la connexion:', error);
      console.error('📋 Détails de l\'erreur:', {
        message: error instanceof Error ? error.message : 'Erreur inconnue',
        stack: error instanceof Error ? error.stack : 'Pas de stack trace',
        name: error instanceof Error ? error.name : 'Erreur'
      });
      return { success: false, error: 'Erreur de connexion au serveur' };
    }
  };

  const verify2FA = async (code: string): Promise<{ success: boolean; error?: string }> => {
    try {
      if (!pendingLoginData) {
        return { success: false, error: 'Données de connexion manquantes' };
      }

      console.log('🔐 Vérification 2FA avec code:', code);
      const response = await apiService.verify2FA(code, pendingLoginData.token);
      
      if (response.success && response.data) {
        const { professionnelId, nom, prenom, email: userEmail, role, specialite, numeroRpps, dateCreation, actif } = response.data;
        
        const doctorData: Doctor = {
          id: professionnelId,
          email: userEmail,
          nom,
          prenom,
          specialite,
          numeroRpps,
          role,
          dateCreation,
          actif
        };
        
        console.log('💾 Stockage après 2FA...');
        localStorage.setItem('authToken', pendingLoginData.token);
        localStorage.setItem('doctorData', JSON.stringify(doctorData));
        localStorage.removeItem('pendingLogin');
        
        // Attendre un peu pour s'assurer que le stockage est terminé
        await new Promise(resolve => setTimeout(resolve, 100));
        
        // Vérifier le stockage
        const storedToken = localStorage.getItem('authToken');
        const storedData = localStorage.getItem('doctorData');
        console.log('🔍 Vérification stockage 2FA:');
        console.log('  - Token stocké:', storedToken ? 'Oui' : 'Non');
        console.log('  - Données stockées:', storedData ? 'Oui' : 'Non');
        
        setCurrentDoctor(doctorData);
        setPendingLoginData(null);
        
        // Vérification finale que tout est bien stocké
        const finalCheck = localStorage.getItem('authToken') && localStorage.getItem('doctorData');
        if (!finalCheck) {
          console.error('❌ ÉCHEC: Token ou données non stockés après la connexion');
          clearAuth();
          return { success: false, error: 'Erreur lors du stockage de la session' };
        }
        
        console.log('✅ Vérification finale réussie - Session complètement établie');
        console.log('🎉 RÉSUMÉ FINAL:');
        console.log('  - Token récupéré du backend: ✅');
        console.log('  - Token stocké dans localStorage: ✅');
        console.log('  - Données utilisateur stockées: ✅');
        console.log('  - Session établie: ✅');
        
        // Afficher le contenu complet du localStorage
        console.log('🔍 CONTENU COMPLET DU LOCALSTORAGE:');
        Object.keys(localStorage).forEach(key => {
          console.log(`  ${key}:`, localStorage.getItem(key));
        });
        
        return { success: true };
      } else {
        return { success: false, error: response.error || 'Code 2FA invalide' };
      }
    } catch (error) {
      console.error('❌ Erreur lors de la vérification 2FA:', error);
      return { success: false, error: 'Erreur lors de la vérification' };
    }
  };

  const logout = async () => {
    try {
      await apiService.logout();
    } catch (error) {
      console.error('Erreur lors de la déconnexion:', error);
    } finally {
      clearAuth();
      console.log('Déconnexion effectuée');
    }
  };

  const logoutAllSessions = async () => {
    try {
      await apiService.logoutAllSessions();
    } catch (error) {
      console.error('Erreur lors de la déconnexion de toutes les sessions:', error);
    } finally {
      clearAuth();
      console.log('Déconnexion de toutes les sessions effectuée');
    }
  };

  const refreshAuth = async () => {
    try {
      const token = localStorage.getItem('authToken');
      if (token) {
        const isValid = await validateToken(token);
        if (!isValid) {
          console.log('Token expiré lors du refresh');
          clearAuth();
        }
      }
    } catch (error) {
      console.error('Erreur lors du refresh de l\'auth:', error);
      clearAuth();
    }
  };

  return (
    <AuthContext.Provider
      value={{
        currentDoctor,
        isAuthenticated: !!currentDoctor,
        login,
        verify2FA,
        logout,
        logoutAllSessions,
        loading,
        refreshAuth,
        clearAuth,
        validateToken: () => validateToken(localStorage.getItem('authToken') || '')
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};