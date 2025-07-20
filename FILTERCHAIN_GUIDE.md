# Guide : FilterChain avec Validation Token en Base

## Problème Résolu

Les requêtes de recherche retournaient "Accès refusé" car le token n'était pas correctement validé en base de données.

## Solution Implémentée

### 1. JwtAuthenticationFilter Amélioré

#### ✅ Validation Double
- **Vérification JWT** : Validation cryptographique du token
- **Vérification Base** : Contrôle de l'existence et de l'état du token en base

#### ✅ Processus de Validation
```java
1. Extraction du header Authorization
2. Extraction de l'email du token JWT
3. Vérification du token en base de données (TokenService.isTokenValid())
4. Validation JWT du token
5. Authentification Spring Security
```

#### ✅ Gestion d'Erreurs Détaillée
- **Token non trouvé** : Réponse JSON avec message explicite
- **Token révoqué** : Réponse JSON avec message explicite
- **Token expiré** : Réponse JSON avec message explicite
- **Erreur JWT** : Réponse JSON avec message explicite

### 2. TokenService.isTokenValid()

#### ✅ Vérifications Effectuées
```java
public boolean isTokenValid(String tokenValue) {
    // 1. Recherche du token en base
    Optional<Token> tokenOpt = tokenRepository.findByTokenValue(tokenValue);
    
    // 2. Vérification de l'existence
    if (tokenOpt.isEmpty()) return false;
    
    // 3. Vérification de la révocation
    if (token.isRevoked()) return false;
    
    // 4. Vérification de l'expiration
    if (token.isExpired() || token.getExpiresAt().isBefore(LocalDateTime.now())) {
        token.setExpired(true);
        tokenRepository.save(token);
        return false;
    }
    
    return true;
}
```

## Fonctionnement du FilterChain

### 1. Requête Arrive
```
GET /api/patients/search?q=Dupont
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

### 2. Filtre JWT Traite
```java
// Extraction du token
jwt = authHeader.substring(7);

// Extraction de l'email
userEmail = jwtService.extractUsername(jwt);

// Vérification en base
boolean isTokenValidInDB = tokenService.isTokenValid(jwt);

if (!isTokenValidInDB) {
    // Réponse 401 avec JSON détaillé
    response.setStatus(401);
    response.getWriter().write("{\"success\":false,\"error\":\"Token invalide ou révoqué\"}");
    return;
}

// Validation JWT
if (jwtService.isTokenValid(jwt)) {
    // Authentification Spring Security
    SecurityContextHolder.getContext().setAuthentication(authToken);
}
```

### 3. Requête Continue
- Si validation OK : Requête traitée normalement
- Si validation KO : Réponse 401 avec JSON détaillé

## Logs Détaillés

### ✅ Logs de Debug
```
🔍 Filtre JWT - URL: GET /api/patients/search
🔑 Token JWT reçu: eyJhbGciOiJIUzI1NiJ9...
📧 Email extrait du token: doctor@example.com
🔍 Vérification du token en base de données...
✅ Token validé en base de données
✅ Authentification réussie pour l'utilisateur: doctor@example.com
```

### ❌ Logs d'Erreur
```
❌ Token non trouvé en base de données ou révoqué pour l'utilisateur: doctor@example.com
❌ Token JWT invalide pour l'utilisateur: doctor@example.com
❌ Erreur lors de la validation du token JWT: Invalid token
```

## Réponses JSON Détaillées

### Token Invalide
```json
{
  "success": false,
  "error": "Token invalide ou révoqué",
  "message": "Votre session a expiré. Veuillez vous reconnecter."
}
```

### Token JWT Invalide
```json
{
  "success": false,
  "error": "Token JWT invalide",
  "message": "Votre session a expiré. Veuillez vous reconnecter."
}
```

### Erreur de Validation
```json
{
  "success": false,
  "error": "Erreur de validation du token",
  "message": "Votre session a expiré. Veuillez vous reconnecter."
}
```

## Avantages

✅ **Sécurité renforcée** - Validation double (JWT + base)
✅ **Traçabilité complète** - Logs détaillés pour debugging
✅ **Réponses claires** - Messages d'erreur explicites
✅ **Gestion d'état** - Tokens révoqués/expirés gérés
✅ **Performance optimisée** - Vérification en base rapide

## Test

### 1. Redémarrage
```powershell
.\restart-backend-with-filterchain.ps1
```

### 2. Test de Connexion
1. Connectez-vous avec doctor@example.com / password
2. Vérifiez les logs backend pour la validation

### 3. Test de Recherche
1. Allez sur la page de recherche
2. Tapez un nom de patient
3. Vérifiez que les résultats s'affichent
4. Consultez les logs pour les détails de validation

### 4. Test d'Erreur
1. Modifiez le token dans localStorage
2. Essayez une recherche
3. Vérifiez la réponse JSON d'erreur

Le FilterChain garantit maintenant que seuls les tokens valides et actifs en base de données peuvent accéder aux endpoints protégés ! 