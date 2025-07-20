# Script PowerShell pour redémarrer le frontend avec toutes les corrections
Write-Host "🔧 Redémarrage complet du frontend avec toutes les corrections..." -ForegroundColor Green

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

# Vérifier que tous les composants ont été créés
Write-Host "🔍 Vérification des composants..." -ForegroundColor Yellow

$requiredFiles = @(
    "src/components/ui/ErrorBoundary.tsx",
    "src/components/ui/ErrorNotification.tsx",
    "src/components/ui/TokenExpirationModal.tsx",
    "src/hooks/useErrorHandler.ts",
    "src/hooks/useTokenExpiration.ts"
)

$allFilesExist = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file trouvé" -ForegroundColor Green
    } else {
        Write-Host "❌ $file manquant" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Host "❌ Certains composants sont manquants. Veuillez les créer d'abord." -ForegroundColor Red
    exit 1
}

# Vérifier les pages corrigées
Write-Host "🔍 Vérification des pages corrigées..." -ForegroundColor Yellow

$correctedPages = @(
    "src/pages/Dashboard.tsx",
    "src/pages/SearchPatient.tsx",
    "src/pages/History.tsx",
    "src/App.tsx"
)

foreach ($file in $correctedPages) {
    if (Test-Path $file) {
        Write-Host "✅ $file trouvé" -ForegroundColor Green
    } else {
        Write-Host "❌ $file manquant" -ForegroundColor Red
    }
}

# Démarrer le serveur de développement
Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Yellow
Write-Host "🔧 Corrections appliquées:" -ForegroundColor Cyan
Write-Host "   - ErrorBoundary créé pour gérer les erreurs globales" -ForegroundColor Cyan
Write-Host "   - ErrorNotification créé pour les notifications" -ForegroundColor Cyan
Write-Host "   - TokenExpirationModal créé pour l'expiration des tokens" -ForegroundColor Cyan
Write-Host "   - useErrorHandler hook créé" -ForegroundColor Cyan
Write-Host "   - useTokenExpiration hook créé" -ForegroundColor Cyan
Write-Host "   - Imports corrigés dans App.tsx" -ForegroundColor Cyan
Write-Host "   - Pages Dashboard, SearchPatient, History corrigées" -ForegroundColor Cyan
Write-Host "   - Ancienne gestion d'erreur supprimée" -ForegroundColor Cyan
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