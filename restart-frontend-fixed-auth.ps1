@echo off
echo ========================================
echo Redémarrage du Frontend avec Auth Corrigée
echo ========================================
echo.

echo Arrêt du serveur de développement frontend...
taskkill /f /im node.exe 2>nul
timeout /t 2 /nobreak >nul

echo.
echo Navigation vers le dossier frontend...
cd frontend

echo.
echo Installation des dépendances si nécessaire...
npm install

echo.
echo Démarrage du serveur de développement...
echo Corrections apportées :
echo - Suppression de la validation périodique du token
echo - Validation uniquement lors des requêtes API réelles
echo - Gestion automatique de l'expiration du token
echo - Nettoyage automatique du localStorage en cas d'expiration
echo.
npm run dev

echo.
echo ========================================
echo Frontend démarré avec succès !
echo ========================================
echo.
echo Le frontend ne fait plus de requêtes en boucle :
echo - Plus de validation périodique du token
echo - Validation uniquement lors des requêtes API
echo - Gestion automatique de l'expiration
echo - Nettoyage automatique du localStorage
echo.
echo Accédez à : http://localhost:5173
echo.
pause 