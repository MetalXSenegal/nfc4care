import { createContext, useState, useContext, ReactNode, useEffect } from 'react';
import { apiService } from '../services/api';

interface Doctor {
  id: string;
  name: string;
  email: string;
  role: string;
}

interface AuthContextType {
  currentDoctor: Doctor | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [currentDoctor, setCurrentDoctor] = useState<Doctor | null>(null);
  const [loading, setLoading] = useState(true);

  // Vérifier si un token existe au démarrage
  useEffect(() => {
    const token = localStorage.getItem('authToken');
    if (token) {
      // Ici vous pourriez valider le token avec le backend
      // Pour l'instant, on considère qu'il est valide
      const doctorData = localStorage.getItem('doctorData');
      if (doctorData) {
        setCurrentDoctor(JSON.parse(doctorData));
      }
    }
    setLoading(false);
  }, []);

  const login = async (email: string, password: string): Promise<boolean> => {
    try {
      const response = await apiService.login(email, password);
      
      if (response.success && response.data) {
        const { token, professionnelId, nom, prenom, email: userEmail, role } = response.data;
        
        // Stocker le token et les données utilisateur
        localStorage.setItem('authToken', token);
        localStorage.setItem('doctorData', JSON.stringify({
          id: professionnelId.toString(),
          name: `Dr. ${nom} ${prenom}`,
          email: userEmail,
          role
        }));
        
        setCurrentDoctor({
          id: professionnelId.toString(),
          name: `Dr. ${nom} ${prenom}`,
          email: userEmail,
          role
        });
        
        return true;
      } else {
        console.error('Erreur de connexion:', response.error);
        return false;
      }
    } catch (error) {
      console.error('Erreur lors de la connexion:', error);
      return false;
    }
  };

  const logout = async () => {
    try {
      await apiService.logout();
    } catch (error) {
      console.error('Erreur lors de la déconnexion:', error);
    } finally {
      // Nettoyer le stockage local
      localStorage.removeItem('authToken');
      localStorage.removeItem('doctorData');
      setCurrentDoctor(null);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        currentDoctor,
        isAuthenticated: !!currentDoctor,
        login,
        logout,
        loading
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