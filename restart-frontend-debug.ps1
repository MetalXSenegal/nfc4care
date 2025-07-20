# Script pour redémarrer le frontend en mode debug
Write-Host "🔄 Redémarrage du frontend en mode debug..." -ForegroundColor Cyan

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

# Vérifier que StrictMode est désactivé
Write-Host "`n🔍 Vérification de StrictMode..." -ForegroundColor Blue
$mainContent = Get-Content "frontend/src/main.tsx" -Raw
if ($mainContent -match "// Temporarily disabled StrictMode") {
    Write-Host "✅ StrictMode désactivé pour le débogage" -ForegroundColor Green
} else {
    Write-Host "⚠️  StrictMode pourrait être actif" -ForegroundColor Yellow
}

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

Write-Host "`n📝 Instructions de débogage:" -ForegroundColor Magenta
Write-Host "  1. Ouvrir http://localhost:5173 dans le navigateur"
Write-Host "  2. Ouvrir les outils de développement (F12)"
Write-Host "  3. Aller dans l'onglet Console"
Write-Host "  4. Tenter de se connecter avec doctor@example.com / password"
Write-Host "  5. Observer les logs d'authentification"

Write-Host "`n🔧 Vérifications à faire:" -ForegroundColor Yellow
Write-Host "  - Les logs d'initialisation ne doivent plus apparaître en double"
Write-Host "  - Le token doit être stocké dans localStorage après login"
Write-Host "  - La redirection vers le dashboard doit fonctionner"

Write-Host "`n✅ Redémarrage terminé!" -ForegroundColor Green 