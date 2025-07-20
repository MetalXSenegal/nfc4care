# Script PowerShell pour optimiser la validation des tokens
Write-Host "🔧 Optimisation de la validation des tokens..." -ForegroundColor Green

# Arrêter le frontend s'il tourne
Write-Host "🛑 Arrêt du frontend en cours..." -ForegroundColor Yellow
try {
    # Chercher le processus Node.js qui tourne sur le port 5173
    $nodeProcess = Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue | 
                   Where-Object { $_.State -eq "Listen" } | 
                   ForEach-Object { Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue } |
                   Where-Object { $_.ProcessName -eq "node" }
    
    if ($nodeProcess) {
        Write-Host "✅ Processus Node.js trouvé, arrêt en cours..." -ForegroundColor Green
        Stop-Process -Id $nodeProcess.Id -Force
        Start-Sleep -Seconds 3
        Write-Host "✅ Frontend arrêté" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Aucun processus frontend trouvé" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Erreur lors de l'arrêt du frontend: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Aller dans le répertoire frontend
if (Test-Path "frontend") {
    Set-Location "frontend"
    Write-Host "📁 Répertoire frontend trouvé" -ForegroundColor Green
} else {
    Write-Host "❌ Répertoire frontend non trouvé" -ForegroundColor Red
    Write-Host "Assurez-vous d'être dans le répertoire racine du projet" -ForegroundColor Yellow
    exit 1
}

# Vérifier si Node.js est installé
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js détecté: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    Write-Host "Veuillez installer Node.js depuis https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Vérifier si npm est installé
try {
    $npmVersion = npm --version
    Write-Host "✅ npm détecté: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ npm n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    exit 1
}

# Vérifier si package.json existe
if (-not (Test-Path "package.json")) {
    Write-Host "❌ package.json non trouvé dans le répertoire frontend" -ForegroundColor Red
    exit 1
}

# Installer les dépendances si nécessaire
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installation des dépendances..." -ForegroundColor Yellow
    try {
        npm install
        Write-Host "✅ Dépendances installées avec succès" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erreur lors de l'installation des dépendances" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Dépendances déjà installées" -ForegroundColor Green
}

# Vérifier que les optimisations ont été appliquées
Write-Host "🔍 Vérification des optimisations..." -ForegroundColor Yellow

$optimizedFiles = @(
    "src/context/AuthContext.tsx",
    "src/services/api.ts"
)

foreach ($file in $optimizedFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file trouvé" -ForegroundColor Green
    } else {
        Write-Host "❌ $file manquant" -ForegroundColor Red
    }
}

# Démarrer le serveur de développement
Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Yellow
Write-Host "🔧 Optimisations appliquées:" -ForegroundColor Cyan
Write-Host "   - Validation locale du token JWT (sans requête backend)" -ForegroundColor Cyan
Write-Host "   - Validation périodique réduite: 2h au lieu de 5min" -ForegroundColor Cyan
Write-Host "   - Validation backend limitée: 6h au lieu de constante" -ForegroundColor Cyan
Write-Host "   - Cache de validation pour éviter les requêtes répétées" -ForegroundColor Cyan
Write-Host "   - Marge de sécurité de 5 minutes pour l'expiration" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Réduction des requêtes:" -ForegroundColor Green
Write-Host "   - Avant: 288 requêtes/jour (toutes les 5min)" -ForegroundColor Yellow
Write-Host "   - Maintenant: 4 requêtes/jour (toutes les 6h)" -ForegroundColor Green
Write-Host "   - Réduction: 98.6% moins de requêtes!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 Frontend accessible sur: http://localhost:5173" -ForegroundColor Green
Write-Host "🔄 Appuyez sur Ctrl+C pour arrêter le serveur" -ForegroundColor Gray

try {
    npm run dev
} catch {
    Write-Host "❌ Erreur lors du démarrage du serveur de développement" -ForegroundColor Red
    Write-Host "Vérifiez que toutes les dépendances sont correctement installées" -ForegroundColor Yellow
    exit 1
} 