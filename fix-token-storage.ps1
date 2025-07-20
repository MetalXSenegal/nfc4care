# Script PowerShell pour corriger le problème de stockage des tokens
Write-Host "🔧 Correction du problème de stockage des tokens..." -ForegroundColor Green

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

# Vérifier que les corrections ont été appliquées
Write-Host "🔍 Vérification des corrections..." -ForegroundColor Yellow

$correctedFiles = @(
    "src/context/AuthContext.tsx",
    "src/services/api.ts"
)

foreach ($file in $correctedFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file trouvé" -ForegroundColor Green
    } else {
        Write-Host "❌ $file manquant" -ForegroundColor Red
    }
}

# Vérifier la configuration backend
Write-Host "🔍 Vérification de la configuration backend..." -ForegroundColor Yellow
$backendConfig = "backend/src/main/resources/application.yml"
if (Test-Path $backendConfig) {
    $configContent = Get-Content $backendConfig -Raw
    if ($configContent -match "expiration: 86400000") {
        Write-Host "✅ Configuration backend correcte: expiration 24h" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Configuration backend à vérifier" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Configuration backend non trouvée" -ForegroundColor Yellow
}

# Démarrer le serveur de développement
Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Yellow
Write-Host "🔧 Corrections appliquées:" -ForegroundColor Cyan
Write-Host "   - Validation locale améliorée avec logs détaillés" -ForegroundColor Cyan
Write-Host "   - Initialisation optimisée pour éviter la déconnexion immédiate" -ForegroundColor Cyan
Write-Host "   - Validation backend en arrière-plan (1s de délai)" -ForegroundColor Cyan
Write-Host "   - Gestion d'erreurs améliorée pour le décodage JWT" -ForegroundColor Cyan
Write-Host "   - Logs détaillés pour le debugging" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Instructions de test:" -ForegroundColor Green
Write-Host "   1. Connectez-vous avec vos identifiants" -ForegroundColor White
Write-Host "   2. Vérifiez les logs dans la console du navigateur" -ForegroundColor White
Write-Host "   3. Le token doit être stocké et validé localement" -ForegroundColor White
Write-Host "   4. La session doit persister après rafraîchissement" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Logs à surveiller:" -ForegroundColor Yellow
Write-Host "   - '🔍 Validation locale du token...'" -ForegroundColor Gray
Write-Host "   - '📋 Payload du token:'" -ForegroundColor Gray
Write-Host "   - '⏰ Expiration: ...'" -ForegroundColor Gray
Write-Host "   - '✅ Session restaurée avec succès'" -ForegroundColor Gray
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