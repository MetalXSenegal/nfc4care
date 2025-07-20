# Script pour démarrer le frontend NFC4Care
Write-Host "🚀 Démarrage du frontend NFC4Care..." -ForegroundColor Green
Write-Host ""

# Aller dans le dossier frontend
Write-Host "📁 Changement vers le dossier frontend..." -ForegroundColor Yellow
Set-Location frontend

# Vérifier que Node.js est installé
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js détecté: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js non trouvé. Veuillez installer Node.js 18 ou supérieur." -ForegroundColor Red
    exit 1
}

# Vérifier que npm est installé
try {
    $npmVersion = npm --version
    Write-Host "✅ npm détecté: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ npm non trouvé. Veuillez installer npm." -ForegroundColor Red
    exit 1
}

# Installer les dépendances si nécessaire
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installation des dépendances..." -ForegroundColor Yellow
    npm install
}

# Démarrer le serveur de développement
Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Yellow
Write-Host "Le frontend sera accessible sur http://localhost:5173" -ForegroundColor Cyan
Write-Host "Appuyez sur Ctrl+C pour arrêter" -ForegroundColor Yellow
Write-Host ""

npm run dev 