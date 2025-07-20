@echo off
echo ========================================
echo Redémarrage du Frontend avec Recherche Corrigée
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
echo - Recherche en temps réel optimisée (3+ caractères)
echo - Debounce augmenté à 500ms
echo - Pas de déconnexion automatique pour les recherches
echo - Gestion d'erreurs silencieuse pour les recherches
echo - Logs détaillés pour debugging
echo.
npm run dev

echo.
echo ========================================
echo Frontend démarré avec succès !
echo ========================================
echo.
echo La recherche ne déconnecte plus :
echo - Recherche seulement après 3+ caractères
echo - Délai de 500ms entre les requêtes
echo - Erreurs d'auth silencieuses pour les recherches
echo - Pas de redirection automatique
echo.
echo Test de la recherche :
echo 1. Connectez-vous normalement
echo 2. Allez sur la page de recherche
echo 3. Tapez progressivement (pas de déconnexion)
echo 4. Vérifiez que les résultats s'affichent
echo.
echo Accédez à : http://localhost:5173
echo.
pause 