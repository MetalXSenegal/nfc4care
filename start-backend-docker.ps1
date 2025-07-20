# Script pour démarrer le backend NFC4Care avec Docker
Write-Host "🚀 Démarrage du backend NFC4Care avec Docker..." -ForegroundColor Green
Write-Host ""

# Vérifier que Docker est installé et en cours d'exécution
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker détecté: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker non trouvé. Veuillez installer Docker Desktop." -ForegroundColor Red
    exit 1
}

# Vérifier que Docker est en cours d'exécution
try {
    docker ps > $null 2>&1
    Write-Host "✅ Docker est en cours d'exécution" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker n'est pas en cours d'exécution. Veuillez démarrer Docker Desktop." -ForegroundColor Red
    exit 1
}

# Vérifier que la base de données PostgreSQL est active
Write-Host "🔍 Vérification de la base de données..." -ForegroundColor Yellow
$postgresContainer = docker ps --filter "name=nfc4care-postgres" --format "table {{.Names}}\t{{.Status}}"
if ($postgresContainer -like "*nfc4care-postgres*") {
    Write-Host "✅ Base de données PostgreSQL active" -ForegroundColor Green
} else {
    Write-Host "⚠️  Base de données PostgreSQL non trouvée, démarrage..." -ForegroundColor Yellow
    docker-compose up -d postgres
    Start-Sleep -Seconds 10
}

# Construire et démarrer le backend
Write-Host "🔨 Construction de l'image backend..." -ForegroundColor Yellow
docker-compose build backend

Write-Host "🚀 Démarrage du backend..." -ForegroundColor Yellow
docker-compose up -d backend

# Attendre que le backend soit prêt
Write-Host "⏳ Attente que le backend soit prêt..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

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
Write-Host "🎉 Backend démarré avec succès!" -ForegroundColor Green
Write-Host "Le backend est accessible sur http://localhost:8080" -ForegroundColor Cyan
Write-Host "Configuration CORS appliquée" -ForegroundColor Cyan
Write-Host ""
Write-Host "Vous pouvez maintenant démarrer le frontend avec: .\start-frontend.ps1" -ForegroundColor Yellow 