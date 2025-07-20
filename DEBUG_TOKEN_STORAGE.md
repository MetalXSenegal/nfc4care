# Guide de Debugging - Problème de Stockage des Tokens

## Problème Identifié

L'utilisateur se connecte mais est déconnecté immédiatement. Le message "Aucune session trouvée" apparaît dans les logs.

## Causes Possibles

### 1. **Erreur de Décodage JWT**
- Token malformé
- Erreur dans le décodage base64
- Payload JSON invalide

### 2. **Problème de Stockage localStorage**
- localStorage non disponible
- Erreur lors de l'écriture/lecture
- Données corrompues

### 3. **Configuration Backend Incorrecte**
- Durée d'expiration trop courte
- Secret JWT incorrect
- Problème de génération du token

### 4. **Problème de Validation Locale**
- Logique de validation incorrecte
- Marge de sécurité trop importante
- Problème de timezone

## Solution Implémentée

### 1. **Validation Locale Améliorée**

```typescript
const validateTokenLocally = (token: string): boolean => {
  try {
    console.log('🔍 Validation locale du token...');
    
    // Vérifier que le token a le bon format JWT
    if (!token || !token.includes('.')) {
      console.log('❌ Token invalide: format incorrect');
      return false;
    }
    
    // Décoder le token JWT pour vérifier l'expiration
    const parts = token.split('.');
    if (parts.length !== 3) {
      console.log('❌ Token invalide: structure JWT incorrecte');
      return false;
    }
    
    // Décoder le payload (partie 2)
    const payload = JSON.parse(atob(parts[1]));
    console.log('📋 Payload du token:', payload);
    
    // Vérifier que le token a une expiration
    if (!payload.exp) {
      console.log('❌ Token invalide: pas d\'expiration');
      return false;
    }
    
    const expirationTime = payload.exp * 1000; // Convertir en millisecondes
    const currentTime = Date.now();
    const timeUntilExpiration = expirationTime - currentTime;
    
    console.log(`⏰ Expiration: ${new Date(expirationTime).toLocaleString()}`);
    console.log(`⏰ Temps restant: ${Math.floor(timeUntilExpiration / (1000 * 60))} minutes`);
    
    // Ajouter une marge de sécurité de 5 minutes
    const safetyMargin = 5 * 60 * 1000;
    
    const isValid = currentTime < (expirationTime - safetyMargin);
    console.log(`✅ Token ${isValid ? 'valide' : 'expiré'} (validation locale)`);
    
    return isValid;
  } catch (error) {
    console.error('❌ Erreur lors de la validation locale du token:', error);
    console.log('🔍 Token reçu:', token ? `${token.substring(0, 50)}...` : 'Aucun token');
    return false;
  }
};
```

### 2. **Initialisation Optimisée**

```typescript
// Si la validation locale réussit, restaurer immédiatement la session
try {
  const doctor = JSON.parse(doctorData);
  setCurrentDoctor(doctor);
  console.log('✅ Session restaurée avec succès pour:', doctor.prenom, doctor.nom);
  
  // Démarrer la validation périodique
  startTokenValidation();
  
  // Validation avec le backend en arrière-plan (optionnelle)
  setTimeout(async () => {
    console.log('🔄 Validation backend en arrière-plan...');
    const isValid = await validateToken(token);
    if (!isValid) {
      console.log('❌ Token invalide (validation backend), nettoyage de la session');
      clearAuth();
      window.location.href = '/login';
    } else {
      console.log('✅ Token validé avec le backend');
    }
  }, 1000); // Attendre 1 seconde avant la validation backend
  
} catch (error) {
  console.error('❌ Erreur lors du parsing des données utilisateur:', error);
  clearAuth();
}
```

## Étapes de Debugging

### 1. **Vérifier les Logs de Connexion**

Ouvrez la console du navigateur (F12) et connectez-vous. Vous devriez voir :

```
🔐 Tentative de connexion pour: email@example.com
✅ Connexion réussie, token reçu: eyJhbGciOiJIUzI1NiJ9...
💾 Stockage du token et des données utilisateur
✅ Connexion réussie pour: Prénom Nom
```

### 2. **Vérifier le Stockage localStorage**

Dans la console du navigateur, tapez :

```javascript
// Vérifier le token
console.log('Token:', localStorage.getItem('authToken'));

// Vérifier les données utilisateur
console.log('Données:', localStorage.getItem('doctorData'));

// Vérifier le pending login
console.log('Pending:', localStorage.getItem('pendingLogin'));
```

### 3. **Vérifier la Validation Locale**

Après connexion, vous devriez voir :

```
🔍 Validation locale du token...
📋 Payload du token: {sub: "email@example.com", exp: 1234567890, ...}
⏰ Expiration: 12/31/2024, 11:59:59 PM
⏰ Temps restant: 1439 minutes
✅ Token valide (validation locale)
```

### 4. **Vérifier l'Initialisation**

Au rechargement de la page :

```
🔍 Initialisation de l'authentification...
🔍 Token trouvé: Oui
🔍 Données utilisateur trouvées: Oui
🔄 Tentative de restauration de session...
🔍 Validation locale du token...
✅ Session restaurée avec succès pour: Prénom Nom
🔄 Validation backend en arrière-plan...
✅ Token validé avec le backend
```

## Problèmes Courants et Solutions

### Problème 1: "Token invalide: format incorrect"
**Cause :** Le token n'est pas au format JWT standard
**Solution :** Vérifier que le backend génère bien des tokens JWT

### Problème 2: "Token invalide: structure JWT incorrecte"
**Cause :** Le token n'a pas 3 parties séparées par des points
**Solution :** Vérifier la génération du token côté backend

### Problème 3: "Token invalide: pas d'expiration"
**Cause :** Le payload JWT ne contient pas le champ `exp`
**Solution :** Vérifier la configuration JWT dans le backend

### Problème 4: "Token expiré (validation locale)"
**Cause :** Le token a expiré ou la marge de sécurité est trop importante
**Solution :** Vérifier la durée d'expiration dans `application.yml`

### Problème 5: "Erreur lors du parsing des données utilisateur"
**Cause :** Les données utilisateur stockées sont corrompues
**Solution :** Nettoyer le localStorage et se reconnecter

## Configuration Backend Vérifiée

```yaml
spring:
  security:
    jwt:
      secret: nfc4care-super-secret-jwt-key-2024-very-long-and-secure
      expiration: 86400000 # 24 hours in milliseconds
```

## Script de Test

Utilisez le script `fix-token-storage.ps1` :

```powershell
.\fix-token-storage.ps1
```

Ce script :
1. Arrête le frontend en cours
2. Vérifie les corrections appliquées
3. Vérifie la configuration backend
4. Redémarre avec les améliorations
5. Affiche les instructions de test

## Commandes de Debugging

### Vérifier le localStorage
```javascript
// Nettoyer le localStorage
localStorage.clear();

// Vérifier le contenu
Object.keys(localStorage).forEach(key => {
  console.log(`${key}:`, localStorage.getItem(key));
});
```

### Tester la Validation Locale
```javascript
// Récupérer le token
const token = localStorage.getItem('authToken');

// Tester le décodage
try {
  const parts = token.split('.');
  const payload = JSON.parse(atob(parts[1]));
  console.log('Payload:', payload);
  console.log('Expiration:', new Date(payload.exp * 1000));
} catch (error) {
  console.error('Erreur:', error);
}
```

### Vérifier la Configuration
```javascript
// Vérifier la configuration backend
fetch('/api/auth/validate', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('authToken')}`
  }
}).then(response => {
  console.log('Status:', response.status);
  return response.json();
}).then(data => {
  console.log('Response:', data);
});
```

## Résolution du Problème

1. **Exécutez le script de correction**
2. **Connectez-vous et vérifiez les logs**
3. **Identifiez le problème spécifique**
4. **Appliquez la solution correspondante**
5. **Testez la persistance de session**

Le système est maintenant optimisé pour :
- ✅ **Validation locale robuste** avec logs détaillés
- ✅ **Initialisation optimisée** pour éviter la déconnexion immédiate
- ✅ **Validation backend en arrière-plan** pour la sécurité
- ✅ **Gestion d'erreurs améliorée** pour le debugging 