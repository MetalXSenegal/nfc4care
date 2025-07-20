# Script pour redémarrer le frontend avec les corrections du processus de login
Write-Host "🔄 Redémarrage du frontend avec corrections du processus de login..." -ForegroundColor Cyan

# Arrêter le processus frontend existant
Write-Host "`n🛑 Arrêt du processus frontend existant..." -ForegroundColor Yellow
try {
    Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "node" } | Stop-Process -Force
    Write-Host "✅ Processus frontend arrêté" -ForegroundColor Green
} catch {
    Write-Host "ℹ️  Aucun processus frontend à arrêter" -ForegroundColor Blue
}

# Nettoyer le cache
Write-Host "`n🧹 Nettoyage du cache..." -ForegroundColor Yellow
if (Test-Path "frontend/node_modules/.vite") {
    Remove-Item -Recurse -Force "frontend/node_modules/.vite"
    Write-Host "✅ Cache Vite nettoyé" -ForegroundColor Green
}

# Nettoyer le localStorage du navigateur
Write-Host "`n🧹 Nettoyage du localStorage..." -ForegroundColor Yellow
Write-Host "💡 Veuillez ouvrir les outils de développement (F12) et exécuter:" -ForegroundColor Magenta
Write-Host "   localStorage.clear()" -ForegroundColor Gray

# Démarrer le frontend
Write-Host "`n🚀 Démarrage du frontend..." -ForegroundColor Green
Set-Location "frontend"
Start-Process -FilePath "npm" -ArgumentList "run", "dev" -NoNewWindow

Write-Host "`n⏳ Attente du démarrage..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Vérifier que le frontend est accessible
Write-Host "`n🔍 Vérification de l'accessibilité du frontend..." -ForegroundColor Blue
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5173" -Method GET -TimeoutSec 10
    Write-Host "✅ Frontend accessible sur http://localhost:5173" -ForegroundColor Green
} catch {
    Write-Host "❌ Frontend non accessible: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📝 Instructions de test:" -ForegroundColor Magenta
Write-Host "  1. Ouvrir http://localhost:5173 dans le navigateur"
Write-Host "  2. Ouvrir les outils de développement (F12)"
Write-Host "  3. Aller dans l'onglet Console"
Write-Host "  4. Nettoyer le localStorage: localStorage.clear()"
Write-Host "  5. Tenter de se connecter avec doctor@example.com / password"
Write-Host "  6. Observer les logs de connexion et de stockage"

Write-Host "`n🔧 Corrections apportées:" -ForegroundColor Yellow
Write-Host "  - e.preventDefault() appelé dès le début"
Write-Host "  - Suppression des setTimeout pour la redirection"
Write-Host "  - Ajout d'attentes pour le stockage"
Write-Host "  - Amélioration des logs de débogage"
Write-Host "  - Vérification complète du localStorage"

Write-Host "`n✅ Redémarrage terminé!" -ForegroundColor Green 