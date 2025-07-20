# Script pour redémarrer le backend et tester les nouveaux endpoints dashboard
Write-Host "🔄 Redémarrage du backend avec les nouveaux endpoints dashboard..." -ForegroundColor Cyan

# Arrêter le processus backend existant
Write-Host "`n🛑 Arrêt du processus backend existant..." -ForegroundColor Yellow
try {
    Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "java" } | Stop-Process -Force
    Write-Host "✅ Processus backend arrêté" -ForegroundColor Green
} catch {
    Write-Host "ℹ️  Aucun processus backend à arrêter" -ForegroundColor Blue
}

# Attendre que le processus soit complètement arrêté
Write-Host "`n⏳ Attente de l'arrêt complet..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Démarrer le backend
Write-Host "`n🚀 Démarrage du backend..." -ForegroundColor Green
Set-Location "backend"
Start-Process -FilePath "mvn" -ArgumentList "spring-boot:run" -NoNewWindow

Write-Host "`n⏳ Attente du démarrage du backend..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Tester les nouveaux endpoints
Write-Host "`n🔍 Test des nouveaux endpoints dashboard..." -ForegroundColor Blue

# Test de l'endpoint /api/dashboard/stats
Write-Host "`n📊 Test de /api/dashboard/stats..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/dashboard/stats" -Method GET -TimeoutSec 10
    Write-Host "✅ Endpoint /api/dashboard/stats accessible" -ForegroundColor Green
    Write-Host "📋 Réponse: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erreur sur /api/dashboard/stats: $($_.Exception.Message)" -ForegroundColor Red
}

# Test de l'endpoint /api/dashboard/recent-patients
Write-Host "`n👥 Test de /api/dashboard/recent-patients..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/dashboard/recent-patients" -Method GET -TimeoutSec 10
    Write-Host "✅ Endpoint /api/dashboard/recent-patients accessible" -ForegroundColor Green
    Write-Host "📋 Réponse: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erreur sur /api/dashboard/recent-patients: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📝 Instructions pour tester le frontend:" -ForegroundColor Magenta
Write-Host "  1. Ouvrir http://localhost:5173 dans le navigateur"
Write-Host "  2. Se connecter avec doctor@example.com / password"
Write-Host "  3. Vérifier que le dashboard se charge correctement"
Write-Host "  4. Vérifier que les statistiques et patients récents s'affichent"

Write-Host "`n🔧 Nouveaux endpoints créés:" -ForegroundColor Yellow
Write-Host "  - GET /api/dashboard/stats"
Write-Host "  - GET /api/dashboard/recent-patients"

Write-Host "`n✅ Redémarrage terminé!" -ForegroundColor Green 