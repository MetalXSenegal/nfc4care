# Dépannage des Erreurs CORS - NFC4Care

## Problème Identifié

L'erreur CORS empêche le frontend (http://localhost:5173) de communiquer avec le backend (http://localhost:8080).

## Solution Implémentée

### 1. Configuration CORS Ajoutée

**Fichiers créés/modifiés :**
- `backend/src/main/java/com/nfc4care/config/CorsConfig.java` - Configuration CORS principale
- `backend/src/main/java/com/nfc4care/config/WebConfig.java` - Configuration WebMvc
- `backend/src/main/java/com/nfc4care/config/SecurityConfig.java` - Intégration CORS avec Spring Security

### 2. Configuration CORS Détail

```java
// CorsConfig.java
@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    
    // Autoriser toutes les origines (développement)
    configuration.setAllowedOriginPatterns(List.of("*"));
    
    // Autoriser toutes les méthodes HTTP
    configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
    
    // Autoriser tous les en-têtes
    configuration.setAllowedHeaders(Arrays.asList("*"));
    
    // Autoriser les credentials
    configuration.setAllowCredentials(true);
    
    return source;
}
```

## Étapes de Résolution

### Étape 1: Redémarrer le Backend

```powershell
# Exécuter le script de redémarrage
.\restart-backend.ps1
```

### Étape 2: Vérifier le Backend

Le script vérifie automatiquement que le backend répond :
- ✅ Backend répond correctement
- ✅ Configuration CORS active

### Étape 3: Démarrer le Frontend

```powershell
# Démarrer le frontend
.\start-frontend-only.ps1
```

## Vérification

### Test Manuel

1. **Ouvrir le navigateur** sur http://localhost:5173
2. **Ouvrir les outils de développement** (F12)
3. **Aller dans l'onglet Network**
4. **Effectuer une action** (recherche, connexion, etc.)
5. **Vérifier** qu'il n'y a plus d'erreurs CORS

### Test API Direct

```powershell
# Tester l'API directement
.\test-api.ps1
```

## Erreurs Possibles et Solutions

### 1. "Failed to fetch"

**Cause :** Backend non démarré ou CORS mal configuré
**Solution :** Redémarrer le backend avec `.\restart-backend.ps1`

### 2. "CORS policy blocked"

**Cause :** Configuration CORS incorrecte
**Solution :** Vérifier que les fichiers de configuration CORS sont bien créés

### 3. "No 'Access-Control-Allow-Origin' header"

**Cause :** En-têtes CORS manquants
**Solution :** Redémarrer le backend pour appliquer la nouvelle configuration

## Configuration de Production

Pour la production, remplacer :
```java
configuration.setAllowedOriginPatterns(List.of("*"));
```

Par :
```java
configuration.setAllowedOrigins(Arrays.asList("https://votre-domaine.com"));
```

## Logs de Debug

### Backend
```bash
# Voir les logs du backend
docker-compose logs backend
```

### Frontend
```javascript
// Dans la console du navigateur
console.log('Test CORS');
fetch('http://localhost:8080/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({email: 'test', password: 'test'})
}).then(r => console.log('CORS OK')).catch(e => console.log('CORS Error:', e));
```

## Vérification Finale

Après avoir appliqué les corrections :

1. ✅ **Backend démarré** sur http://localhost:8080
2. ✅ **Frontend démarré** sur http://localhost:5173
3. ✅ **Pas d'erreurs CORS** dans la console
4. ✅ **API fonctionnelle** (test avec test-api.ps1)
5. ✅ **Interface utilisateur** accessible et fonctionnelle

## Support

Si le problème persiste :

1. Vérifier que Docker est démarré
2. Vérifier les ports 8080 et 5173 disponibles
3. Redémarrer complètement l'application avec `.\start-nfc4care.ps1`
4. Consulter les logs pour plus de détails 