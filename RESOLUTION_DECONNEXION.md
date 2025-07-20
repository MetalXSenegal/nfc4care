# Résolution de la Déconnexion Automatique - NFC4Care

## Problème Identifié

L'application se déconnecte automatiquement lors de l'actualisation de la page, ce qui indique un problème de persistance de session.

## Causes Possibles

1. **Token JWT non persisté** dans le localStorage
2. **Validation du token échoue** au redémarrage
3. **Configuration CORS** incorrecte
4. **Endpoints d'authentification** manquants

## Solutions Implémentées

### 1. Correction de la Validation du Token

**Problème :** La fonction `validateToken` n'utilisait pas correctement le token.

**Solution :** Correction de la logique de validation avec gestion temporaire du token.

```typescript
const validateToken = async (token: string): Promise<boolean> => {
  try {
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
    
    return response.success;
  } catch (error) {
    console.error('Erreur de validation du token:', error);
    return false;
  }
};
```

### 2. Amélioration de l'Initialisation

**Problème :** Pas de logs pour diagnostiquer les problèmes.

**Solution :** Ajout de logs détaillés pour le debugging.

```typescript
useEffect(() => {
  const initializeAuth = async () => {
    try {
      const token = localStorage.getItem('authToken');
      const doctorData = localStorage.getItem('doctorData');
      
      if (token && doctorData) {
        console.log('Tentative de restauration de session...');
        
        const isValid = await validateToken(token);
        
        if (isValid) {
          const doctor = JSON.parse(doctorData);
          setCurrentDoctor(doctor);
          console.log('Session restaurée avec succès pour:', doctor.prenom, doctor.nom);
        } else {
          console.log('Token invalide, nettoyage de la session');
          clearAuth();
        }
      } else {
        console.log('Aucune session trouvée');
      }
    } catch (error) {
      console.error('Erreur lors de l\'initialisation de l\'auth:', error);
      clearAuth();
    } finally {
      setLoading(false);
    }
  };

  initializeAuth();
}, []);
```

### 3. Logs Détaillés dans l'API

**Problème :** Pas de visibilité sur les requêtes API.

**Solution :** Ajout de logs pour toutes les requêtes et réponses.

```typescript
private async makeRequest<T>(url: string, options: RequestInit = {}): Promise<ApiResponse<T>> {
  try {
    console.log(`Requête API: ${options.method || 'GET'} ${url}`);
    
    const response = await fetch(url, {
      ...options,
      headers: {
        ...this.getAuthHeaders(),
        ...options.headers,
      },
    });
    
    console.log(`Réponse API: ${response.status} ${response.statusText}`);
    return this.handleResponse<T>(response);
  } catch (error) {
    console.error('Erreur de requête API:', error);
    return { error: 'Erreur de connexion au serveur', success: false };
  }
}
```

## Étapes de Résolution

### Étape 1: Redémarrer le Backend

```powershell
# Redémarrer avec la nouvelle configuration
.\force-restart-backend.ps1
```

### Étape 2: Tester la Session

```powershell
# Tester la persistance de session
.\test-session.ps1
```

### Étape 3: Vérifier dans le Navigateur

1. **Ouvrir** http://localhost:5173
2. **Se connecter** avec `doctor@example.com` / `password`
3. **Ouvrir les outils de développement** (F12)
4. **Aller dans l'onglet Console**
5. **Actualiser la page** (F5)
6. **Vérifier les logs** de restauration de session

## Vérification de la Persistance

### 1. Dans le Navigateur

**Ouvrir les outils de développement :**
- F12 → Application → Local Storage
- Vérifier que `authToken` et `doctorData` sont présents

**Console :**
```
✅ Tentative de restauration de session...
✅ Session restaurée avec succès pour: Martin Dubois
```

### 2. Test Manuel

1. **Connectez-vous** à l'application
2. **Actualisez la page** (F5)
3. **Vous devriez rester connecté**
4. **Vérifiez que le nom du médecin s'affiche** dans le dashboard

### 3. Test de Déconnexion

1. **Cliquez sur Déconnexion**
2. **Vérifiez** que vous êtes redirigé vers /login
3. **Actualisez la page**
4. **Vous devriez rester sur la page de connexion**

## Dépannage

### Si la déconnexion persiste :

1. **Vérifier les logs du navigateur :**
   - F12 → Console
   - Chercher les erreurs 401 ou 403

2. **Vérifier le localStorage :**
   - F12 → Application → Local Storage
   - Vérifier que `authToken` existe

3. **Tester l'API directement :**
   ```powershell
   .\test-auth.ps1
   ```

4. **Redémarrer complètement :**
   ```powershell
   docker-compose down
   docker-compose up -d
   ```

### Logs à Surveiller

**Succès :**
```
✅ Tentative de restauration de session...
✅ Session restaurée avec succès pour: [Nom] [Prénom]
✅ Validation du token JWT
```

**Erreur :**
```
❌ Token invalide, nettoyage de la session
❌ Token expiré ou invalide (401)
❌ Erreur lors de l'initialisation de l'auth
```

## Configuration de Production

Pour la production, considérez :

1. **Durée de vie du token JWT** (actuellement 24h)
2. **Refresh tokens** pour une meilleure sécurité
3. **HTTPS** obligatoire
4. **SameSite cookies** pour la sécurité

## Support

Si le problème persiste :

1. Vérifiez que le backend est démarré
2. Vérifiez les logs du backend : `docker-compose logs backend`
3. Vérifiez les logs du navigateur (F12 → Console)
4. Testez l'API directement avec les scripts fournis 