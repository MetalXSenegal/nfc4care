# Script PowerShell pour démarrer NFC4Care (Backend + Database + Frontend)
Write-Host "🚀 Démarrage de NFC4Care..." -ForegroundColor Green
Write-Host ""

# Vérifier si Docker est installé
try {
    $dockerVersion = docker --version
    Write-Host "Docker détecté: $dockerVersion" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Erreur: Docker n'est pas installé ou pas dans le PATH" -ForegroundColor Red
    Write-Host "Veuillez installer Docker Desktop depuis https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

# Vérifier si on est dans le bon répertoire
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "❌ Erreur: docker-compose.yml non trouvé" -ForegroundColor Red
    Write-Host "Assurez-vous d'être dans le répertoire racine du projet" -ForegroundColor Yellow
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

# Démarrer la base de données PostgreSQL
Write-Host "🗄️  Démarrage de la base de données PostgreSQL..." -ForegroundColor Yellow
docker-compose up -d postgres

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors du démarrage de la base de données" -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

Write-Host "✅ Base de données démarrée" -ForegroundColor Green

# Attendre que la base de données soit prête
Write-Host "⏳ Attente que la base de données soit prête..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Démarrer le backend Spring Boot
Write-Host "🔧 Démarrage du backend Spring Boot..." -ForegroundColor Yellow
docker-compose up -d backend

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors du démarrage du backend" -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

Write-Host "✅ Backend démarré" -ForegroundColor Green

# Attendre que le backend soit prêt
Write-Host "⏳ Attente que le backend soit prêt..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Vérifier si le frontend a les dépendances
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installation des dépendances frontend..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur lors de l'installation des dépendances" -ForegroundColor Red
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 1
    }
}

# Démarrer le frontend
Write-Host "🎨 Démarrage du frontend React..." -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 Résumé des services:" -ForegroundColor Cyan
Write-Host "  • Base de données: http://localhost:5432" -ForegroundColor White
Write-Host "  • Backend API: http://localhost:8080/api" -ForegroundColor White
Write-Host "  • Frontend: http://localhost:5173" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Pour tester l'API: .\test-api.ps1" -ForegroundColor Yellow
Write-Host "🛑 Pour arrêter: docker-compose down" -ForegroundColor Yellow
Write-Host ""

npm run dev 