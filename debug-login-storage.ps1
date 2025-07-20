# Script PowerShell pour diagnostiquer le problème de stockage du token
Write-Host "🔧 Diagnostic du problème de stockage du token..." -ForegroundColor Green

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

# Vérifier que les logs de debug sont présents
Write-Host "🔍 Vérification des logs de debug..." -ForegroundColor Yellow

$authContextFile = "src/context/AuthContext.tsx"
$loginFile = "src/pages/Login.tsx"

if (Test-Path $authContextFile) {
    $content = Get-Content $authContextFile -Raw
    if ($content -match "CONTENU COMPLET DU LOCALSTORAGE") {
        Write-Host "✅ Logs de debug détaillés présents dans AuthContext" -ForegroundColor Green
    } else {
        Write-Host "❌ Logs de debug détaillés manquants dans AuthContext" -ForegroundColor Red
    }
} else {
    Write-Host "❌ AuthContext.tsx non trouvé" -ForegroundColor Red
}

if (Test-Path $loginFile) {
    $content = Get-Content $loginFile -Raw
    if ($content -match "Vérification du stockage avant redirection") {
        Write-Host "✅ Logs de debug présents dans Login" -ForegroundColor Green
    } else {
        Write-Host "❌ Logs de debug manquants dans Login" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Login.tsx non trouvé" -ForegroundColor Red
}

# Démarrer le serveur de développement
Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 Problème identifié:" -ForegroundColor Cyan
Write-Host "   - Token non stocké dans localStorage" -ForegroundColor Cyan
Write-Host "   - Page qui se rafraîchit après connexion" -ForegroundColor Cyan
Write-Host "   - Seulement lastTokenValidation et recentSearches dans localStorage" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Instructions de test:" -ForegroundColor Green
Write-Host "   1. Ouvrez http://localhost:5173 dans votre navigateur" -ForegroundColor White
Write-Host "   2. Ouvrez la console du navigateur (F12)" -ForegroundColor White
Write-Host "   3. Connectez-vous avec vos identifiants" -ForegroundColor White
Write-Host "   4. Surveillez attentivement les logs de connexion" -ForegroundColor White
Write-Host "   5. Vérifiez si la page se rafraîchit" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Logs à surveiller:" -ForegroundColor Yellow
Write-Host "   - '🔐 Début de la tentative de connexion...'" -ForegroundColor Gray
Write-Host "   - '📡 Réponse API reçue: ...'" -ForegroundColor Gray
Write-Host "   - '🔑 TOKEN COMPLET RÉCUPÉRÉ: ...'" -ForegroundColor Gray
Write-Host "   - '✅ Token stocké dans localStorage'" -ForegroundColor Gray
Write-Host "   - '🔍 CONTENU COMPLET DU LOCALSTORAGE:'" -ForegroundColor Gray
Write-Host "   - '🎯 REDIRECTION VERS: /dashboard'" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 Commandes de debugging dans la console:" -ForegroundColor Cyan
Write-Host "   // Vérifier le localStorage avant connexion" -ForegroundColor Gray
Write-Host "   console.log('localStorage avant:', Object.keys(localStorage));" -ForegroundColor Gray
Write-Host ""
Write-Host "   // Vérifier le localStorage après connexion" -ForegroundColor Gray
Write-Host "   console.log('localStorage après:', Object.keys(localStorage));" -ForegroundColor Gray
Write-Host "   console.log('authToken:', localStorage.getItem('authToken'));" -ForegroundColor Gray
Write-Host "   console.log('doctorData:', localStorage.getItem('doctorData'));" -ForegroundColor Gray
Write-Host ""
Write-Host "   // Nettoyer le localStorage si nécessaire" -ForegroundColor Gray
Write-Host "   localStorage.clear();" -ForegroundColor Gray
Write-Host ""
Write-Host "   // Tester le stockage manuellement" -ForegroundColor Gray
Write-Host "   localStorage.setItem('test', 'value');" -ForegroundColor Gray
Write-Host "   console.log('Test storage:', localStorage.getItem('test'));" -ForegroundColor Gray
Write-Host ""
Write-Host "📱 Frontend accessible sur: http://localhost:5173" -ForegroundColor Green
Write-Host "🔄 Appuyez sur Ctrl+C pour arrêter le serveur" -ForegroundColor Gray

try {
    npm run dev
} catch {
    Write-Host "❌ Erreur lors du démarrage du serveur de développement" -ForegroundColor Red
    exit 1
} 