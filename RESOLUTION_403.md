# Résolution de l'Erreur 403 - NFC4Care

## Problème Identifié

L'erreur 403 (Forbidden) sur l'endpoint `/auth/login` indique un problème de configuration ou d'endpoint manquant.

## Solutions Implémentées

### 1. Endpoints Manquants Ajoutés

**Problème :** Les endpoints `/auth/verify-2fa` et `/auth/validate` n'existaient pas.

**Solution :** Ajoutés dans `AuthController.java` et `AuthService.java`.

### 2. Configuration CORS Complète

**Problème :** Configuration CORS incomplète causant des erreurs 403.

**Solution :** Configuration CORS complète avec tous les en-têtes nécessaires.

## Étapes de Résolution

### Étape 1: Redémarrage Forcé du Backend

```powershell
# Forcer le redémarrage complet avec reconstruction
.\force-restart-backend.ps1
```

### Étape 2: Test de l'Authentification

```powershell
# Tester l'authentification
.\test-auth.ps1
```

### Étape 3: Vérification des Logs

```powershell
# Voir les logs du backend
docker-compose logs backend
```

## Endpoints Ajoutés

### 1. `/auth/verify-2fa`

```java
@PostMapping("/verify-2fa")
public ResponseEntity<AuthResponse> verify2FA(@RequestBody Map<String, String> request, @RequestHeader("Authorization") String token) {
    String code = request.get("code");
    // Logique de vérification 2FA
}
```

### 2. `/auth/validate`

```java
@GetMapping("/validate")
public ResponseEntity<AuthResponse> validateToken(@RequestHeader("Authorization") String token) {
    // Validation du token JWT
}
```

## Méthodes de Service Ajoutées

### 1. `verify2FA()`

```java
public AuthResponse verify2FA(String code, String token) {
    // Simulation 2FA avec code "123456"
    if (!"123456".equals(code)) {
        throw new RuntimeException("Code 2FA invalide");
    }
    // Retourne les informations du professionnel
}
```

### 2. `validateToken()`

```java
public AuthResponse validateToken(String token) {
    // Validation du token JWT
    String email = jwtService.extractUsername(token);
    // Vérification de la validité
}
```

## Configuration CORS Complète

```java
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

## Test de Fonctionnement

### 1. Test d'Authentification

```powershell
# Données de test
Email: doctor@example.com
Password: password
```

### 2. Test 2FA

```powershell
# Code 2FA de test
Code: 123456
```

### 3. Test de Validation

```powershell
# Le token JWT est automatiquement validé
```

## Vérification Finale

Après avoir appliqué les corrections :

1. ✅ **Backend redémarré** avec nouvelle configuration
2. ✅ **Endpoints d'authentification** fonctionnels
3. ✅ **Configuration CORS** active
4. ✅ **Plus d'erreurs 403** sur `/auth/login`
5. ✅ **Authentification complète** fonctionnelle

## Dépannage

### Si l'erreur 403 persiste :

1. **Vérifier les logs** :
   ```powershell
   docker-compose logs backend
   ```

2. **Redémarrer complètement** :
   ```powershell
   docker-compose down
   docker-compose up -d
   ```

3. **Vérifier la configuration** :
   - Fichiers CORS créés
   - Endpoints ajoutés
   - Service mis à jour

### Logs à Surveiller

```
✅ Connexion réussie pour l'utilisateur: doctor@example.com
✅ Token validé avec succès
✅ Vérification 2FA réussie
```

## Support

Si le problème persiste après ces corrections :

1. Vérifier que Docker est démarré
2. Vérifier que les ports sont disponibles
3. Consulter les logs détaillés
4. Redémarrer complètement l'environnement 