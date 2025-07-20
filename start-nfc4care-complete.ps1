# Script principal pour démarrer NFC4Care complet
Write-Host "🏥 Démarrage de NFC4Care - Système de Gestion Médicale" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
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

# Vérifier que Node.js est installé
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js détecté: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js non trouvé. Veuillez installer Node.js 18 ou supérieur." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🚀 Étape 1: Démarrage de la base de données PostgreSQL..." -ForegroundColor Yellow
docker-compose up -d postgres

Write-Host "⏳ Attente que la base de données soit prête..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host ""
Write-Host "🚀 Étape 2: Démarrage du backend Spring Boot..." -ForegroundColor Yellow
docker-compose build backend
docker-compose up -d backend

Write-Host "⏳ Attente que le backend soit prêt..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "🚀 Étape 3: Démarrage du frontend React..." -ForegroundColor Yellow

# Aller dans le dossier frontend
Set-Location frontend

# Installer les dépendances si nécessaire
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installation des dépendances frontend..." -ForegroundColor Yellow
    npm install
}

# Démarrer le frontend en arrière-plan
Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "npm run dev"

# Retourner au répertoire racine
Set-Location ..

Write-Host ""
Write-Host "🎉 NFC4Care démarré avec succès!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host "📊 Base de données: PostgreSQL (Docker) - Port 5432" -ForegroundColor Cyan
Write-Host "🔧 Backend: Spring Boot (Docker) - Port 8080" -ForegroundColor Cyan
Write-Host "🌐 Frontend: React (Local) - Port 5173" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔗 Accès à l'application:" -ForegroundColor Yellow
Write-Host "   Frontend: http://localhost:5173" -ForegroundColor White
Write-Host "   Backend API: http://localhost:8080/api" -ForegroundColor White
Write-Host ""
Write-Host "👤 Identifiants de test:" -ForegroundColor Yellow
Write-Host "   Email: doctor@example.com" -ForegroundColor White
Write-Host "   Mot de passe: password" -ForegroundColor White
Write-Host "   Code 2FA: 123456" -ForegroundColor White
Write-Host ""
Write-Host "🛑 Pour arrêter l'application:" -ForegroundColor Yellow
Write-Host "   docker-compose down" -ForegroundColor White
Write-Host "   (Puis fermer la fenêtre PowerShell du frontend)" -ForegroundColor White 