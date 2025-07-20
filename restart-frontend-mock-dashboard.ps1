@echo off
echo ========================================
echo Redémarrage du Frontend avec Dashboard Mocké
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
echo Le dashboard utilise maintenant des données mockées au lieu du backend
echo.
npm run dev

echo.
echo ========================================
echo Frontend démarré avec succès !
echo ========================================
echo.
echo Le dashboard affiche maintenant :
echo - Statistiques mockées (156 patients, 342 consultations, etc.)
echo - Patients récents mockés
echo - Plus d'appels API vers le backend
echo.
echo Accédez à : http://localhost:5173
echo.
pause 