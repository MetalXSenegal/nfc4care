# Script pour redémarrer le backend NFC4Care
Write-Host "🔄 Redémarrage du backend NFC4Care..." -ForegroundColor Green
Write-Host ""

# Arrêter le backend existant
Write-Host "⏹️  Arrêt du backend..." -ForegroundColor Yellow
docker-compose stop backend

# Attendre un peu
Start-Sleep -Seconds 3

# Redémarrer le backend
Write-Host "🚀 Redémarrage du backend..." -ForegroundColor Yellow
docker-compose up -d backend

# Attendre que le backend soit prêt
Write-Host "⏳ Attente que le backend soit prêt..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Vérifier que le backend répond
Write-Host "🔍 Vérification du backend..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body '{"email":"test","password":"test"}' -ContentType "application/json" -TimeoutSec 10
    Write-Host "✅ Backend répond correctement" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*401*") {
        Write-Host "✅ Backend répond (401 attendu pour test)" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur backend: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎉 Backend redémarré avec la nouvelle configuration CORS!" -ForegroundColor Green
Write-Host "Le frontend devrait maintenant pouvoir communiquer avec le backend." -ForegroundColor Cyan 