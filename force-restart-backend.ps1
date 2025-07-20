# Script pour forcer le redémarrage complet du backend NFC4Care
Write-Host "🔄 Redémarrage forcé du backend NFC4Care..." -ForegroundColor Green
Write-Host ""

# Arrêter complètement le backend
Write-Host "⏹️  Arrêt complet du backend..." -ForegroundColor Yellow
docker-compose stop backend
docker-compose rm -f backend

# Attendre un peu
Start-Sleep -Seconds 5

# Reconstruire et redémarrer le backend
Write-Host "🔨 Reconstruction et redémarrage du backend..." -ForegroundColor Yellow
docker-compose up -d --build backend

# Attendre que le backend soit prêt
Write-Host "⏳ Attente que le backend soit prêt..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Vérifier que le backend répond
Write-Host "🔍 Vérification du backend..." -ForegroundColor Yellow
$maxAttempts = 10
$attempt = 0

do {
    $attempt++
    Write-Host "Tentative $attempt/$maxAttempts..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body '{"email":"test","password":"test"}' -ContentType "application/json" -TimeoutSec 5
        Write-Host "✅ Backend répond correctement" -ForegroundColor Green
        break
    } catch {
        if ($_.Exception.Message -like "*400*") {
            Write-Host "✅ Backend répond (400 attendu pour données invalides)" -ForegroundColor Green
            break
        } elseif ($_.Exception.Message -like "*403*") {
            Write-Host "⚠️  Backend répond mais erreur 403 - problème de configuration" -ForegroundColor Yellow
            break
        } else {
            Write-Host "⏳ Backend pas encore prêt, nouvelle tentative dans 5 secondes..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        }
    }
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "❌ Backend ne répond pas après $maxAttempts tentatives" -ForegroundColor Red
    Write-Host "Vérifiez les logs avec: docker-compose logs backend" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "🎉 Backend redémarré avec succès!" -ForegroundColor Green
    Write-Host "Configuration CORS appliquée." -ForegroundColor Cyan
}

# Afficher les logs récents
Write-Host ""
Write-Host "📋 Logs récents du backend:" -ForegroundColor Yellow
try {
    $logs = docker-compose logs --tail=10 backend
    $logs | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} catch {
    Write-Host "Impossible de récupérer les logs" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Redémarrage terminé!" -ForegroundColor Green 