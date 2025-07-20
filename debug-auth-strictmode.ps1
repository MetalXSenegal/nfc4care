# Script de débogage pour l'authentification avec StrictMode
Write-Host "🔍 Débogage de l'authentification avec StrictMode..." -ForegroundColor Cyan

Write-Host "`n📋 Problème identifié:" -ForegroundColor Yellow
Write-Host "  - React StrictMode en mode développement double les effets"
Write-Host "  - Cela cause l'initialisation de l'auth à s'exécuter deux fois"
Write-Host "  - C'est normal en développement, mais peut masquer d'autres problèmes"

Write-Host "`n🔧 Solutions possibles:" -ForegroundColor Green
Write-Host "  1. Désactiver StrictMode temporairement pour le débogage"
Write-Host "  2. Améliorer la gestion des effets pour éviter les doublons"
Write-Host "  3. Vérifier que le login fonctionne réellement"

Write-Host "`n🚀 Actions recommandées:" -ForegroundColor Blue
Write-Host "  1. Vérifier les logs du backend lors du login"
Write-Host "  2. Tester le login avec les identifiants de test"
Write-Host "  3. Vérifier que localStorage fonctionne"
Write-Host "  4. Désactiver StrictMode si nécessaire"

Write-Host "`n📝 Pour désactiver StrictMode temporairement:" -ForegroundColor Magenta
Write-Host "  - Modifier main.tsx pour retirer StrictMode"
Write-Host "  - Ou utiliser un flag pour le désactiver en développement"

Write-Host "`n✅ Script terminé!" -ForegroundColor Green 