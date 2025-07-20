# Script pour démarrer seulement le frontend NFC4Care
Write-Host "🎨 Démarrage du frontend NFC4Care..." -ForegroundColor Green
Write-Host ""

# Vérifier si on est dans le bon répertoire
if (-not (Test-Path "package.json")) {
    Write-Host "❌ Erreur: package.json non trouvé" -ForegroundColor Red
    Write-Host "Assurez-vous d'être dans le répertoire racine du projet" -ForegroundColor Yellow
    exit 1
}

# Vérifier si node_modules existe
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installation des dépendances..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur lors de l'installation des dépendances" -ForegroundColor Red
        exit 1
    }
}

# Vérifier que le backend est démarré
Write-Host "🔍 Vérification du backend..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body '{"email":"test","password":"test"}' -ContentType "application/json" -TimeoutSec 5
} catch {
    if ($_.Exception.Message -like "*401*") {
        Write-Host "✅ Backend détecté (401 attendu)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Backend non détecté. Assurez-vous qu'il est démarré sur http://localhost:8080" -ForegroundColor Yellow
        Write-Host "Vous pouvez le démarrer avec: .\restart-backend.ps1" -ForegroundColor Cyan
    }
}

# Démarrer le serveur de développement
Write-Host ""
Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Green
Write-Host "Le frontend sera accessible sur: http://localhost:5173" -ForegroundColor Cyan
Write-Host "Appuyez sur Ctrl+C pour arrêter le serveur" -ForegroundColor Yellow
Write-Host ""

npm run dev 