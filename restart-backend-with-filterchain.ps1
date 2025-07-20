@echo off
echo ========================================
echo Redémarrage du Backend avec FilterChain
echo ========================================
echo.

echo Arrêt du processus backend existant...
taskkill /f /im java.exe 2>nul
timeout /t 3 /nobreak >nul

echo.
echo Navigation vers le dossier backend...
cd backend

echo.
echo Compilation du projet...
mvn clean compile

echo.
echo Démarrage du backend avec le nouveau FilterChain...
echo Nouvelles fonctionnalités :
echo - JwtAuthenticationFilter amélioré
echo - Vérification du token en base de données
echo - Validation double (JWT + base)
echo - Réponses JSON détaillées pour les erreurs
echo - Logs détaillés pour debugging
echo.
mvn spring-boot:run

echo.
echo ========================================
echo Backend démarré avec succès !
echo ========================================
echo.
echo Le FilterChain vérifie maintenant :
echo 1. Présence du header Authorization
echo 2. Extraction de l'email du token JWT
echo 3. Vérification du token en base de données
echo 4. Validation JWT du token
echo 5. Authentification Spring Security
echo.
echo Test des endpoints :
echo 1. Connectez-vous via le frontend
echo 2. Testez la recherche de patients
echo 3. Vérifiez les logs backend pour les détails
echo.
echo Accédez à : http://localhost:8080
echo.
pause 