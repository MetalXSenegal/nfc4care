# Debugging Rapide - Problème de Stockage des Tokens

## Problème
Le token n'est pas stocké dans le localStorage après connexion.

## Solution Rapide

### 1. **Exécuter le Script de Test**
```powershell
.\test-token-storage.ps1
```

### 2. **Tester la Connexion**
1. Ouvrez http://localhost:5173
2. Ouvrez la console (F12)
3. Connectez-vous avec vos identifiants
4. Surveillez les logs

### 3. **Logs Attendus**
```
🔐 Tentative de connexion pour: email@example.com
📡 Appel API login...
📡 Réponse API reçue: {success: true, data: {...}}
✅ Connexion réussie, token reçu: eyJhbGciOiJIUzI1NiJ9...
💾 Stockage du token et des données utilisateur
✅ Token stocké dans localStorage
✅ Données utilisateur stockées dans localStorage
🔍 Vérification du stockage:
  - Token stocké: Oui
  - Données stockées: Oui
```

### 4. **Vérifier le localStorage**
Dans la console du navigateur :
```javascript
// Vérifier le token
console.log('Token:', localStorage.getItem('authToken'));

// Vérifier les données utilisateur
console.log('Données:', localStorage.getItem('doctorData'));

// Vérifier tous les éléments
Object.keys(localStorage).forEach(key => {
  console.log(`${key}:`, localStorage.getItem(key));
});
```

## Problèmes Courants

### Problème 1: "Aucun token reçu"
**Cause :** Le backend ne renvoie pas de token
**Solution :** Vérifier que le backend fonctionne sur http://localhost:8080

### Problème 2: "Erreur de connexion au serveur"
**Cause :** Le backend n'est pas démarré ou CORS
**Solution :** Démarrer le backend avec `cd backend && mvn spring-boot:run`

### Problème 3: "Token stocké: Non"
**Cause :** Erreur lors du stockage localStorage
**Solution :** Vérifier les permissions du navigateur

### Problème 4: "Réponse API reçue: {success: false}"
**Cause :** Identifiants incorrects ou erreur backend
**Solution :** Vérifier les identifiants et les logs backend

## Commandes de Debugging

### Nettoyer le localStorage
```javascript
localStorage.clear();
location.reload();
```

### Tester l'API directement
```javascript
fetch('http://localhost:8080/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: 'test@example.com', password: 'password' })
})
.then(r => r.json())
.then(data => console.log('API Response:', data));
```

### Vérifier la configuration
```javascript
// Vérifier l'URL de l'API
console.log('API URL:', 'http://localhost:8080/api');

// Vérifier le localStorage
console.log('localStorage disponible:', typeof localStorage !== 'undefined');
```

## Étapes de Résolution

1. **Démarrer le backend** : `cd backend && mvn spring-boot:run`
2. **Démarrer le frontend** : `.\test-token-storage.ps1`
3. **Tester la connexion** avec les logs détaillés
4. **Identifier le problème** dans les logs
5. **Appliquer la solution** correspondante

## Logs d'Erreur Courants

### Erreur CORS
```
Access to fetch at 'http://localhost:8080/api/auth/login' from origin 'http://localhost:5173' has been blocked by CORS policy
```
**Solution :** Vérifier la configuration CORS dans le backend

### Erreur de Réseau
```
Failed to fetch
```
**Solution :** Vérifier que le backend fonctionne sur le port 8080

### Erreur d'Authentification
```
401 Unauthorized
```
**Solution :** Vérifier les identifiants de connexion

### Erreur de Stockage
```
QuotaExceededError
```
**Solution :** Nettoyer le localStorage et réessayer 