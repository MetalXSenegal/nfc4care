# Script PowerShell pour tester le stockage des tokens
Write-Host "🔧 Test du stockage des tokens..." -ForegroundColor Green

# Arrêter le frontend s'il tourne
Write-Host "🛑 Arrêt du frontend en cours..." -ForegroundColor Yellow
try {
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
    exit 1
}

# Vérifier si Node.js est installé
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js détecté: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js n'est pas installé" -ForegroundColor Red
    exit 1
}

# Vérifier si npm est installé
try {
    $npmVersion = npm --version
    Write-Host "✅ npm détecté: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ npm n'est pas installé" -ForegroundColor Red
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

# Vérifier que les logs de debugging sont présents
Write-Host "🔍 Vérification des logs de debugging..." -ForegroundColor Yellow

$authContextFile = "src/context/AuthContext.tsx"
if (Test-Path $authContextFile) {
    $content = Get-Content $authContextFile -Raw
    if ($content -match "console\.log.*Stockage du token") {
        Write-Host "✅ Logs de stockage présents dans AuthContext" -ForegroundColor Green
    } else {
        Write-Host "❌ Logs de stockage manquants dans AuthContext" -ForegroundColor Red
    }
} else {
    Write-Host "❌ AuthContext.tsx non trouvé" -ForegroundColor Red
}

# Démarrer le serveur de développement
Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 Instructions de test:" -ForegroundColor Cyan
Write-Host "   1. Ouvrez http://localhost:5173 dans votre navigateur" -ForegroundColor White
Write-Host "   2. Ouvrez la console du navigateur (F12)" -ForegroundColor White
Write-Host "   3. Connectez-vous avec vos identifiants" -ForegroundColor White
Write-Host "   4. Surveillez les logs dans la console" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Logs à surveiller:" -ForegroundColor Yellow
Write-Host "   - '🔐 Tentative de connexion pour: ...'" -ForegroundColor Gray
Write-Host "   - '📡 Appel API login...'" -ForegroundColor Gray
Write-Host "   - '📡 Réponse API reçue: ...'" -ForegroundColor Gray
Write-Host "   - '✅ Connexion réussie, token reçu: ...'" -ForegroundColor Gray
Write-Host "   - '💾 Stockage du token et des données utilisateur'" -ForegroundColor Gray
Write-Host "   - '✅ Token stocké dans localStorage'" -ForegroundColor Gray
Write-Host "   - '✅ Données utilisateur stockées dans localStorage'" -ForegroundColor Gray
Write-Host "   - '🔍 Vérification du stockage:'" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 Commandes de debugging dans la console:" -ForegroundColor Cyan
Write-Host "   // Vérifier le localStorage" -ForegroundColor Gray
Write-Host "   console.log('Token:', localStorage.getItem('authToken'));" -ForegroundColor Gray
Write-Host "   console.log('Données:', localStorage.getItem('doctorData'));" -ForegroundColor Gray
Write-Host ""
Write-Host "   // Nettoyer le localStorage si nécessaire" -ForegroundColor Gray
Write-Host "   localStorage.clear();" -ForegroundColor Gray
Write-Host ""
Write-Host "📱 Frontend accessible sur: http://localhost:5173" -ForegroundColor Green
Write-Host "🔄 Appuyez sur Ctrl+C pour arrêter le serveur" -ForegroundColor Gray

try {
    npm run dev
} catch {
    Write-Host "❌ Erreur lors du démarrage du serveur de développement" -ForegroundColor Red
    exit 1
} 