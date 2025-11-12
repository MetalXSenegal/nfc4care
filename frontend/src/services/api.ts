const API_BASE_URL = 'http://localhost:8080/api';

export interface ApiResponse<T> {
  data?: T;
  error?: string;
  success: boolean;
}

class ApiService {
  private getAuthHeaders(): HeadersInit {
    const token = localStorage.getItem('authToken');

    const headers: HeadersInit = {
      'Content-Type': 'application/json',
    };

    if (token) {
      headers.Authorization = `Bearer ${token}`;
    }

    return headers;
  }

  private async handleResponse<T>(response: Response, url?: string): Promise<ApiResponse<T>> {
    // Vérifier si c'est une requête de recherche pour éviter la déconnexion automatique
    const isSearchRequest = url && url.includes('/patients/search');

    if (response.ok) {
      try {
        const data = await response.json();
        return { data, success: true };
      } catch {
        return { success: true };
      }
    } else if (response.status === 401) {
      // Token expiré ou invalide
      // Pour les recherches, ne pas déclencher de déconnexion automatique
      if (isSearchRequest) {
        return { error: 'Session expirée. Veuillez vous reconnecter.', success: false };
      }

      // Déclencher un événement global pour la modal d'expiration
      window.dispatchEvent(new CustomEvent('api-error', {
        detail: { status: 401, message: 'Token expiré' }
      }));

      this.handleUnauthorized();
      return { error: 'Session expirée. Veuillez vous reconnecter.', success: false };
    } else if (response.status === 403) {
      // Pour les recherches, ne pas déclencher de déconnexion automatique
      if (isSearchRequest) {
        return { error: 'Accès refusé. Vous n\'avez pas les permissions nécessaires.', success: false };
      }

      // Vérifier d'abord localement si le token existe
      const token = localStorage.getItem('authToken');
      if (!token) {
        this.handleUnauthorized();
      } else {
        // Validation silencieuse seulement si pas faite récemment
        const lastValidation = localStorage.getItem('lastTokenValidation');
        const now = Date.now();
        const timeSinceLastValidation = lastValidation ? now - parseInt(lastValidation) : Infinity;
        const oneHour = 60 * 60 * 1000;

        if (timeSinceLastValidation > oneHour) {
          const isValid = await this.validateTokenSilently();
          if (!isValid) {
            // Déclencher un événement global pour la modal d'expiration
            window.dispatchEvent(new CustomEvent('api-error', {
              detail: { status: 403, message: 'Token invalide' }
            }));

            this.handleUnauthorized();
          } else {
            // Marquer la validation comme récente
            localStorage.setItem('lastTokenValidation', now.toString());
          }
        } else {
          this.handleUnauthorized();
        }
      }
      return { error: 'Accès refusé. Vous n\'avez pas les permissions nécessaires.', success: false };
    } else if (response.status === 404) {
      return { error: 'Ressource introuvable.', success: false };
    } else if (response.status === 422) {
      try {
        const errorData = await response.json();
        return { error: errorData.message || 'Données invalides.', success: false };
      } catch {
        return { error: 'Données invalides.', success: false };
      }
    } else if (response.status >= 500) {
      return { error: 'Erreur serveur. Veuillez réessayer plus tard.', success: false };
    } else {
      try {
        const errorText = await response.text();
        return { error: errorText || `Erreur ${response.status}: ${response.statusText}`, success: false };
      } catch {
        return { error: `Erreur ${response.status}: ${response.statusText}`, success: false };
      }
    }
  }

  private handleUnauthorized() {
    // Nettoyer l'authentification locale
    localStorage.removeItem('authToken');
    localStorage.removeItem('doctorData');
    localStorage.removeItem('pendingLogin');

    // Rediriger vers la page de connexion si on est sur une page protégée
    if (window.location.pathname !== '/login') {
      window.location.href = '/login';
    }
  }

  private async validateTokenSilently(): Promise<boolean> {
    try {
      const token = localStorage.getItem('authToken');
      if (!token) return false;

      const response = await fetch(`${API_BASE_URL}/auth/validate`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });

      return response.ok;
    } catch (error) {
      console.error('Erreur lors de la validation silencieuse:', error);
      return false;
    }
  }

  private async makeRequest<T>(
    url: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    try {
      const authHeaders = this.getAuthHeaders();
      const headers = {
        ...authHeaders,
        ...options.headers,
      };

      const response = await fetch(url, {
        ...options,
        headers,
      });

      return this.handleResponse<T>(response, url);
    } catch (error) {
      // Gérer les erreurs de réseau
      if (error instanceof TypeError && error.message.includes('fetch')) {
        return { error: 'Erreur de connexion au serveur. Vérifiez votre connexion internet.', success: false };
      }

      return { error: 'Erreur de connexion au serveur', success: false };
    }
  }

  // Authentification
  async login(email: string, password: string): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
  }

  async verify2FA(code: string, token: string): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/auth/verify-2fa`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify({ code }),
    });
  }

  async validateToken(): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/auth/validate`);
  }

  async logout(): Promise<ApiResponse<void>> {
    const result = await this.makeRequest<void>(`${API_BASE_URL}/auth/logout`, {
      method: 'POST',
    });
    
    // Toujours nettoyer localement, même si la requête échoue
    localStorage.removeItem('authToken');
    localStorage.removeItem('doctorData');
    localStorage.removeItem('pendingLogin');
    
    return result;
  }

  async logoutAllSessions(): Promise<ApiResponse<void>> {
    const result = await this.makeRequest<void>(`${API_BASE_URL}/auth/logout-all`, {
      method: 'POST',
    });
    
    // Toujours nettoyer localement
    localStorage.removeItem('authToken');
    localStorage.removeItem('doctorData');
    localStorage.removeItem('pendingLogin');
    
    return result;
  }

  // Patients
  async getPatients(): Promise<ApiResponse<any[]>> {
    return this.makeRequest(`${API_BASE_URL}/patients`);
  }

  async getPatientById(id: string): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/patients/${id}`);
  }

  async getPatientByNFC(nfcId: string): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/patients/nfc/${nfcId}`);
  }

  async searchPatients(query: string): Promise<ApiResponse<any[]>> {
    if (!query.trim()) {
      return { data: [], success: true };
    }
    return this.makeRequest(`${API_BASE_URL}/patients/search?q=${encodeURIComponent(query)}`);
  }

  async createPatient(patientData: any): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/patients`, {
      method: 'POST',
      body: JSON.stringify(patientData),
    });
  }

  async updatePatient(id: string, patientData: any): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/patients/${id}`, {
      method: 'PUT',
      body: JSON.stringify(patientData),
    });
  }

  async deletePatient(id: string): Promise<ApiResponse<void>> {
    return this.makeRequest(`${API_BASE_URL}/patients/${id}`, {
      method: 'DELETE',
    });
  }

  // Consultations
  async getConsultations(patientId?: string): Promise<ApiResponse<any[]>> {
    const url = patientId 
      ? `${API_BASE_URL}/consultations?patientId=${patientId}`
      : `${API_BASE_URL}/consultations`;
    return this.makeRequest(url);
  }

  async createConsultation(consultationData: any): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/consultations`, {
      method: 'POST',
      body: JSON.stringify(consultationData),
    });
  }

  async updateConsultation(id: string, consultationData: any): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/consultations/${id}`, {
      method: 'PUT',
      body: JSON.stringify(consultationData),
    });
  }

  // Dossiers médicaux
  async getMedicalRecord(patientId: string): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/medical-records/${patientId}`);
  }

  async updateMedicalRecord(patientId: string, recordData: any): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/medical-records/${patientId}`, {
      method: 'PUT',
      body: JSON.stringify(recordData),
    });
  }

  // Blockchain
  async verifyIntegrity(id: string): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/blockchain/verify/${id}`);
  }

  async getBlockchainHistory(patientId: string): Promise<ApiResponse<any[]>> {
    return this.makeRequest(`${API_BASE_URL}/blockchain/history/${patientId}`);
  }

  // Profil utilisateur
  async getProfile(): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/profile`);
  }

  async updateProfile(profileData: any): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/profile`, {
      method: 'PUT',
      body: JSON.stringify(profileData),
    });
  }

  async changePassword(passwordData: any): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/profile/change-password`, {
      method: 'POST',
      body: JSON.stringify(passwordData),
    });
  }

  async enable2FA(): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/profile/enable-2fa`, {
      method: 'POST',
    });
  }

  async disable2FA(code: string): Promise<ApiResponse<any>> {
    return this.makeRequest(`${API_BASE_URL}/profile/disable-2fa`, {
      method: 'POST',
      body: JSON.stringify({ code }),
    });
  }
}

export const apiService = new ApiService(); 