@echo off
echo ========================================
echo Redémarrage du Frontend avec Dashboard Vide
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
echo Le dashboard est maintenant complètement vide - aucune donnée simulée
echo.
npm run dev

echo.
echo ========================================
echo Frontend démarré avec succès !
echo ========================================
echo.
echo Le dashboard affiche maintenant :
echo - En-tête avec salutation
echo - Actions rapides (Search, NFC Scan, History)
echo - Section d'accueil vide
echo - Aucune donnée simulée ou mockée
echo.
echo Accédez à : http://localhost:5173
echo.
pause 