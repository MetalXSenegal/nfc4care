@echo off
echo ========================================
echo Redémarrage du Backend avec Filtres Auth
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
echo Démarrage du backend avec les nouveaux filtres d'authentification...
echo Nouvelles fonctionnalités :
echo - ConsultationController créé avec @PreAuthorize
echo - PatientController avec filtres d'authentification
echo - ConsultationService avec gestion des erreurs
echo - Validation du token sur tous les endpoints protégés
echo.
mvn spring-boot:run

echo.
echo ========================================
echo Backend démarré avec succès !
echo ========================================
echo.
echo Les endpoints sont maintenant protégés :
echo - GET /api/patients - Requiert token DOCTOR
echo - GET /api/patients/search - Requiert token DOCTOR
echo - GET /api/consultations - Requiert token DOCTOR
echo - POST /api/consultations - Requiert token DOCTOR
echo.
echo Test des endpoints :
echo 1. Connectez-vous via le frontend
echo 2. Testez la recherche de patients
echo 3. Testez l'historique des consultations
echo.
echo Accédez à : http://localhost:8080
echo.
pause 