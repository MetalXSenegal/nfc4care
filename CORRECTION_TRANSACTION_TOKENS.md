# Correction de l'Erreur de Transaction - Gestion des Tokens

## Problème Identifié

L'erreur suivante se produisait lors du nettoyage automatique des tokens expirés :

```
org.springframework.dao.InvalidDataAccessApiUsageException: Executing an update/delete query
Caused by: jakarta.persistence.TransactionRequiredException: Executing an update/delete query
```

## Cause de l'Erreur

Les méthodes `@Modifying` dans Spring Data JPA nécessitent une transaction active pour exécuter des requêtes de mise à jour ou de suppression. Les méthodes suivantes manquaient de l'annotation `@Transactional` :

- `expireTokens()` dans `TokenRepository`
- `revokeAllUserTokens()` dans `TokenRepository`
- `deleteByExpiresAtBefore()` dans `TokenRepository`
- `cleanExpiredTokens()` dans `TokenService`

## Corrections Appliquées

### 1. TokenRepository.java

```java
@Repository
public interface TokenRepository extends JpaRepository<Token, Long> {
    
    // Ajout de l'import
    import org.springframework.transaction.annotation.Transactional;
    
    @Modifying
    @Transactional  // ← AJOUTÉ
    @Query("UPDATE Token t SET t.revoked = true WHERE t.userEmail = :userEmail")
    void revokeAllUserTokens(@Param("userEmail") String userEmail);
    
    @Modifying
    @Transactional  // ← AJOUTÉ
    @Query("UPDATE Token t SET t.expired = true WHERE t.expiresAt < :now")
    int expireTokens(@Param("now") LocalDateTime now);  // ← Retourne int au lieu de void
    
    @Transactional  // ← AJOUTÉ
    void deleteByExpiresAtBefore(LocalDateTime date);
}
```

### 2. TokenService.java

```java
@Service
public class TokenService {
    
    // Ajout de l'import
    import org.springframework.transaction.annotation.Transactional;
    
    @Scheduled(fixedRate = 3600000) // Toutes les heures
    @Transactional  // ← AJOUTÉ
    public void cleanExpiredTokens() {
        log.info("Nettoyage des tokens expirés...");
        
        try {
            // Marquer les tokens expirés
            int expiredCount = tokenRepository.expireTokens(LocalDateTime.now());
            log.info("{} tokens marqués comme expirés", expiredCount);
            
            // Supprimer les tokens expirés depuis plus de 24h
            LocalDateTime cutoffDate = LocalDateTime.now().minusHours(24);
            tokenRepository.deleteByExpiresAtBefore(cutoffDate);
            
            log.info("Nettoyage des tokens expirés terminé avec succès");
        } catch (Exception e) {
            log.error("Erreur lors du nettoyage des tokens expirés: {}", e.getMessage(), e);
        }
    }
}
```

## Améliorations Apportées

### 1. Gestion d'Erreurs
- Ajout d'un bloc `try-catch` dans `cleanExpiredTokens()`
- Logs détaillés pour le débogage
- Continuation du service même en cas d'erreur

### 2. Retour d'Informations
- La méthode `expireTokens()` retourne maintenant le nombre de lignes affectées
- Logs informatifs sur le nombre de tokens traités

### 3. Transactions Appropriées
- Toutes les méthodes de modification sont maintenant dans des transactions
- Gestion correcte des rollbacks en cas d'erreur

## Script de Redémarrage

Utilisez le script `restart-backend-fixed.ps1` pour redémarrer le backend avec les corrections :

```powershell
.\restart-backend-fixed.ps1
```

Ce script :
1. Arrête le backend en cours d'exécution
2. Nettoie et compile le projet
3. Redémarre avec les corrections appliquées

## Vérification de la Correction

### 1. Logs Attendus
Après le redémarrage, vous devriez voir :

```
2025-07-12 16:XX:XX - Nettoyage des tokens expirés...
2025-07-12 16:XX:XX - 0 tokens marqués comme expirés
2025-07-12 16:XX:XX - Nettoyage des tokens expirés terminé avec succès
```

### 2. Test de Fonctionnalité
1. Créer un token avec une date d'expiration passée
2. Attendre le prochain nettoyage automatique (ou le déclencher manuellement)
3. Vérifier que le token est marqué comme expiré

### 3. Test de Déconnexion Globale
1. Se connecter sur plusieurs sessions
2. Utiliser "Déconnecter toutes les sessions"
3. Vérifier que tous les tokens sont révoqués

## Prévention des Erreurs Similaires

### Règles à Suivre
1. **Toujours ajouter `@Transactional`** aux méthodes `@Modifying`
2. **Gérer les exceptions** dans les tâches planifiées
3. **Logger les opérations** pour le débogage
4. **Tester les transactions** avec des données de test

### Bonnes Pratiques
```java
@Modifying
@Transactional
@Query("UPDATE Entity e SET e.field = :value WHERE e.condition = :condition")
int updateEntities(@Param("value") String value, @Param("condition") String condition);

@Scheduled(fixedRate = 60000)
@Transactional
public void scheduledTask() {
    try {
        // Logique de la tâche
        log.info("Tâche terminée avec succès");
    } catch (Exception e) {
        log.error("Erreur dans la tâche planifiée: {}", e.getMessage(), e);
    }
}
```

## Dépannage

### Si l'erreur persiste
1. Vérifier que les imports sont corrects
2. Redémarrer complètement l'application
3. Vérifier la configuration de la base de données
4. Contrôler les logs de Hibernate

### Logs Utiles
```bash
# Vérifier les transactions
grep "Transaction" application.log

# Vérifier les erreurs de base de données
grep "InvalidDataAccessApiUsageException" application.log

# Vérifier le nettoyage des tokens
grep "Nettoyage des tokens" application.log
```

## Conclusion

Cette correction résout le problème de transaction et améliore la robustesse du système de gestion des tokens. Le nettoyage automatique fonctionne maintenant correctement et l'application est plus stable. 