# Résolution de l'Erreur CORS 403 - NFC4Care

## Problème Identifié

L'erreur 403 (Forbidden) avec le message :
```
When allowCredentials is true, allowedOrigins cannot contain the special value "*"
```

Indique un conflit dans la configuration CORS entre :
1. Les annotations `@CrossOrigin(origins = "*")` dans les contrôleurs
2. La configuration globale CORS avec `allowCredentials(true)`

## Solution Implémentée

### 1. Suppression des Annotations @CrossOrigin Conflictuels

**Problème :** Les annotations `@CrossOrigin(origins = "*")` dans les contrôleurs créent des conflits avec la configuration globale.

**Solution :** Suppression de toutes les annotations `@CrossOrigin` des contrôleurs :
- `AuthController.java`
- `PatientController.java` 
- `BlockchainController.java`

### 2. Configuration CORS Unifiée

**Problème :** Configuration CORS dupliquée dans `WebConfig` et `CorsConfig`.

**Solution :** Configuration CORS centralisée dans `CorsConfig.java` uniquement.

### 3. Origines Spécifiques

**Problème :** Utilisation de wildcards `*` avec `allowCredentials(true)`.

**Solution :** Origines spécifiques autorisées :
```java
configuration.setAllowedOrigins(Arrays.asList(
    "http://localhost:5173",  // Vite dev server
    "http://localhost:3000",  // Alternative dev server
    "http://127.0.0.1:5173",  // Alternative localhost
    "http://127.0.0.1:3000"   // Alternative localhost
));
```

## Étapes de Résolution

### Étape 1: Exécuter le Script de Correction

```powershell
# Exécuter le script de correction CORS
.\fix-cors-restart.ps1
```

### Étape 2: Vérification

Le script vérifie automatiquement :
- ✅ Backend redémarré
- ✅ Configuration CORS appliquée
- ✅ API accessible

### Étape 3: Test de l'Application

1. **Ouvrir le navigateur** sur http://localhost:5173
2. **Tenter la connexion** avec :
   - Email: `doctor@example.com`
   - Password: `password`
3. **Vérifier** qu'il n'y a plus d'erreurs CORS

## Configuration CORS Finale

### CorsConfig.java
```java
@Configuration
public class CorsConfig {
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // Origines spécifiques autorisées
        configuration.setAllowedOrigins(Arrays.asList(
            "http://localhost:5173",
            "http://localhost:3000",
            "http://127.0.0.1:5173",
            "http://127.0.0.1:3000"
        ));
        
        // Méthodes HTTP autorisées
        configuration.setAllowedMethods(Arrays.asList(
            "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"
        ));
        
        // En-têtes autorisés
        configuration.setAllowedHeaders(Arrays.asList(
            "Origin", "Content-Type", "Accept", "Authorization",
            "X-Requested-With", "Access-Control-Request-Method",
            "Access-Control-Request-Headers"
        ));
        
        // Credentials autorisés
        configuration.setAllowCredentials(true);
        
        // En-têtes exposés
        configuration.setExposedHeaders(Arrays.asList(
            "Access-Control-Allow-Origin",
            "Access-Control-Allow-Credentials",
            "Authorization"
        ));
        
        configuration.setMaxAge(3600L);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        
        return source;
    }
}
```

### WebConfig.java
```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    // CORS configuration moved to CorsConfig.java to avoid conflicts
}
```

## Contrôleurs Modifiés

### AuthController.java
```java
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Slf4j
// @CrossOrigin(origins = "*") - SUPPRIMÉ
public class AuthController {
    // ...
}
```

### PatientController.java
```java
@RestController
@RequestMapping("/patients")
@RequiredArgsConstructor
@Slf4j
// @CrossOrigin(origins = "*") - SUPPRIMÉ
public class PatientController {
    // ...
}
```

### BlockchainController.java
```java
@RestController
@RequestMapping("/blockchain")
@RequiredArgsConstructor
@Slf4j
// @CrossOrigin(origins = "*") - SUPPRIMÉ
public class BlockchainController {
    // ...
}
```

## Vérification de la Résolution

### 1. Logs Backend
```
✅ Pas d'erreurs CORS dans les logs
✅ Configuration CORS appliquée
✅ Endpoints accessibles
```

### 2. Console Frontend
```
✅ Pas d'erreurs CORS
✅ Requêtes API réussies
✅ Authentification fonctionnelle
```

### 3. Test Manuel
```javascript
// Dans la console du navigateur
fetch('http://localhost:8080/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({email: 'test', password: 'test'})
}).then(r => console.log('CORS OK')).catch(e => console.log('CORS Error:', e));
```

## Dépannage

### Si l'erreur persiste :

1. **Vérifier les logs** :
   ```powershell
   docker-compose logs backend
   ```

2. **Redémarrer complètement** :
   ```powershell
   docker-compose down
   docker-compose up -d
   ```

3. **Vérifier les ports** :
   - Backend: http://localhost:8080
   - Frontend: http://localhost:5173

4. **Nettoyer le cache** :
   - Vider le cache du navigateur
   - Redémarrer le navigateur

### Erreurs Possibles

#### 1. "CORS policy blocked"
**Cause :** Origine non autorisée
**Solution :** Vérifier que l'URL du frontend est dans la liste des origines autorisées

#### 2. "No 'Access-Control-Allow-Origin' header"
**Cause :** Configuration CORS non appliquée
**Solution :** Redémarrer le backend

#### 3. "Failed to fetch"
**Cause :** Backend non démarré
**Solution :** Vérifier que le backend est en cours d'exécution

## Configuration de Production

Pour la production, remplacer les origines de développement par :
```java
configuration.setAllowedOrigins(Arrays.asList(
    "https://votre-domaine.com",
    "https://www.votre-domaine.com"
));
```

## Vérification Finale

Après avoir appliqué les corrections :

1. ✅ **Backend redémarré** avec nouvelle configuration
2. ✅ **Annotations @CrossOrigin supprimées**
3. ✅ **Configuration CORS unifiée**
4. ✅ **Origines spécifiques autorisées**
5. ✅ **Plus d'erreurs 403 CORS**
6. ✅ **Authentification fonctionnelle**

## Support

Si le problème persiste :
1. Vérifier que Docker est démarré
2. Vérifier les ports disponibles
3. Consulter les logs pour plus de détails
4. Redémarrer complètement l'application 