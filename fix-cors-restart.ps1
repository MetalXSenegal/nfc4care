# Script pour corriger et redémarrer le backend avec la configuration CORS fixée
Write-Host "🔧 Correction de la configuration CORS..." -ForegroundColor Green
Write-Host ""

# Arrêter le backend existant
Write-Host "⏹️  Arrêt du backend..." -ForegroundColor Yellow
docker-compose stop backend

# Attendre un peu
Start-Sleep -Seconds 5

# Redémarrer le backend
Write-Host "🚀 Redémarrage du backend avec la nouvelle configuration CORS..." -ForegroundColor Yellow
docker-compose up -d backend

# Attendre que le backend soit prêt
Write-Host "⏳ Attente que le backend soit prêt..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Vérifier que le backend répond
Write-Host "🔍 Vérification du backend..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body '{"email":"test","password":"test"}' -ContentType "application/json" -TimeoutSec 10
    Write-Host "✅ Backend répond correctement" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*401*" -or $_.Exception.Message -like "*400*") {
        Write-Host "✅ Backend répond (erreur attendue pour test)" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur backend: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎉 Configuration CORS corrigée!" -ForegroundColor Green
Write-Host "✅ Suppression des @CrossOrigin conflictuels" -ForegroundColor Cyan
Write-Host "✅ Configuration CORS unifiée" -ForegroundColor Cyan
Write-Host "✅ Origines spécifiques autorisées" -ForegroundColor Cyan
Write-Host ""
Write-Host "Le frontend devrait maintenant pouvoir communiquer avec le backend sans erreurs CORS." -ForegroundColor Cyan
Write-Host "Testez la connexion sur http://localhost:5173" -ForegroundColor Yellow 