# Gestion des Tokens - Frontend NFC4Care

## Vue d'ensemble

Le frontend NFC4Care a été adapté pour gérer efficacement l'expiration des tokens JWT et offrir une expérience utilisateur fluide avec la nouvelle gestion des tokens côté backend.

## Fonctionnalités implémentées

### 1. Validation périodique des tokens
- **Validation automatique** : Toutes les 5 minutes
- **Détection d'expiration** : Validation silencieuse avant chaque requête
- **Nettoyage automatique** : Suppression des données locales si token expiré

### 2. Gestion des erreurs d'authentification
- **Erreurs 401/403** : Détection automatique des tokens expirés
- **Modal d'expiration** : Interface utilisateur pour gérer l'expiration
- **Redirection intelligente** : Retour au login si nécessaire

### 3. Déconnexion multi-sessions
- **Déconnexion simple** : Ferme la session actuelle
- **Déconnexion globale** : Ferme toutes les sessions actives
- **Confirmation utilisateur** : Modal de confirmation pour les actions critiques

## Composants principaux

### AuthContext (`src/context/AuthContext.tsx`)
```typescript
// Validation périodique des tokens
const startTokenValidation = useCallback(() => {
  const interval = setInterval(async () => {
    const token = localStorage.getItem('authToken');
    if (token && currentDoctor) {
      const isValid = await validateToken(token);
      if (!isValid) {
        clearAuth();
        window.location.href = '/login';
      }
    }
  }, 5 * 60 * 1000); // 5 minutes
}, [currentDoctor]);
```

### API Service (`src/services/api.ts`)
```typescript
// Gestion des erreurs d'authentification
private async handleResponse<T>(response: Response): Promise<ApiResponse<T>> {
  if (response.status === 401) {
    // Déclencher un événement global pour la modal d'expiration
    window.dispatchEvent(new CustomEvent('api-error', {
      detail: { status: 401, message: 'Token expiré' }
    }));
    this.handleUnauthorized();
    return { error: 'Session expirée. Veuillez vous reconnecter.', success: false };
  }
  // ... autres cas
}
```

### TokenExpirationModal (`src/components/ui/TokenExpirationModal.tsx`)
- Modal pour gérer l'expiration des tokens
- Options de renouvellement ou déconnexion
- Interface utilisateur intuitive

### useTokenExpiration Hook (`src/hooks/useTokenExpiration.ts`)
- Hook personnalisé pour la gestion de l'expiration
- Écoute des événements d'erreur API
- Gestion centralisée des actions d'expiration

## Flux d'authentification

### 1. Connexion initiale
```
Utilisateur saisit credentials → Login API → Token reçu → Stockage localStorage → Validation périodique démarrée
```

### 2. Validation continue
```
Toutes les 5 minutes → Validation silencieuse → Token valide ? Continuer : Déconnexion
```

### 3. Détection d'expiration
```
Requête API → Erreur 401/403 → Événement global → Modal d'expiration → Action utilisateur
```

### 4. Gestion de l'expiration
```
Modal affichée → Renouvellement ou déconnexion → Nettoyage localStorage → Redirection si nécessaire
```

## Fonctionnalités de sécurité

### Validation silencieuse
```typescript
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
    return false;
  }
}
```

### Nettoyage automatique
```typescript
const clearAuth = () => {
  localStorage.removeItem('authToken');
  localStorage.removeItem('doctorData');
  localStorage.removeItem('pendingLogin');
  setCurrentDoctor(null);
  setPendingLoginData(null);
  stopTokenValidation();
};
```

## Interface utilisateur

### Modal d'expiration
- **Design moderne** : Interface claire et intuitive
- **Options claires** : Renouvellement ou déconnexion
- **Feedback visuel** : Indicateurs de chargement et d'état

### Sidebar améliorée
- **Informations utilisateur** : Affichage du nom et spécialité
- **Menu responsive** : Adaptation mobile avec overlay
- **Options de déconnexion** : Déconnexion simple et globale

### Page de profil
- **Informations complètes** : Toutes les données du professionnel
- **Gestion des sessions** : Options de déconnexion avancées
- **Interface moderne** : Design cohérent avec l'application

## Scripts de démarrage

### start-frontend.ps1
```powershell
# Vérifications automatiques
- Node.js et npm installés
- Dépendances à jour
- Démarrage du serveur de développement
```

### start-all.ps1
```powershell
# Démarrage complet
- Base de données PostgreSQL
- Backend Spring Boot
- Frontend React
- Vérifications de ports
- Application des migrations
```

## Gestion des erreurs

### Types d'erreurs gérées
1. **Erreurs réseau** : Connexion perdue, timeout
2. **Erreurs d'authentification** : Token expiré, invalide
3. **Erreurs serveur** : 500+, maintenance
4. **Erreurs de validation** : Données invalides

### Stratégies de récupération
1. **Tentative de renouvellement** : Validation silencieuse
2. **Redirection intelligente** : Retour au login si nécessaire
3. **Nettoyage automatique** : Suppression des données corrompues
4. **Feedback utilisateur** : Messages d'erreur clairs

## Tests recommandés

### Test de session
1. Se connecter normalement
2. Attendre l'expiration du token (ou modifier la date)
3. Vérifier que la modal d'expiration s'affiche
4. Tester le renouvellement et la déconnexion

### Test de déconnexion
1. Se connecter sur plusieurs onglets/appareils
2. Utiliser "Déconnecter toutes les sessions"
3. Vérifier que toutes les sessions sont fermées

### Test de persistance
1. Se connecter et fermer le navigateur
2. Rouvrir et naviguer vers l'application
3. Vérifier que la session est restaurée

## Dépannage

### Problèmes courants

#### Token expiré mais pas détecté
```bash
# Vérifier les logs du navigateur
# Contrôler que la validation périodique fonctionne
# Vérifier la configuration CORS
```

#### Déconnexion automatique
```bash
# Vérifier la validité du token côté backend
# Contrôler les logs d'authentification
# Vérifier la configuration de sécurité
```

#### Erreurs CORS
```bash
# Vérifier la configuration CORS du backend
# Contrôler les headers de requête
# Vérifier les URLs d'API
```

### Logs utiles
```javascript
// Logs de validation de token
console.log('🔄 Validation périodique du token...');
console.log('❌ Token expiré lors de la validation périodique');

// Logs d'API
console.log('📡 Réponse API: 401 Unauthorized');
console.log('🔑 Token récupéré: eyJhbGciOiJIUzI1NiIs...');
```

## Évolutions futures

### Fonctionnalités prévues
1. **Refresh tokens** : Renouvellement automatique des tokens
2. **Sessions multiples** : Gestion avancée des sessions
3. **Notifications push** : Alertes d'expiration
4. **Audit trail** : Historique des connexions

### Améliorations techniques
1. **Service Worker** : Gestion hors ligne
2. **WebSocket** : Notifications en temps réel
3. **Chiffrement local** : Sécurisation des données sensibles
4. **Biométrie** : Authentification biométrique

## Conclusion

La gestion des tokens côté frontend est maintenant complète et robuste. Elle offre une expérience utilisateur fluide tout en maintenant un niveau de sécurité élevé. L'architecture modulaire permet des évolutions futures et une maintenance facile. 