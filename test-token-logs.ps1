# Script PowerShell pour tester les logs de token détaillés
Write-Host "🔧 Test des logs de token détaillés..." -ForegroundColor Green

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

# Vérifier que les logs de token sont présents
Write-Host "🔍 Vérification des logs de token..." -ForegroundColor Yellow

$authContextFile = "src/context/AuthContext.tsx"
$loginFile = "src/pages/Login.tsx"

if (Test-Path $authContextFile) {
    $content = Get-Content $authContextFile -Raw
    if ($content -match "TOKEN COMPLET RÉCUPÉRÉ") {
        Write-Host "✅ Logs de token détaillés présents dans AuthContext" -ForegroundColor Green
    } else {
        Write-Host "❌ Logs de token détaillés manquants dans AuthContext" -ForegroundColor Red
    }
} else {
    Write-Host "❌ AuthContext.tsx non trouvé" -ForegroundColor Red
}

if (Test-Path $loginFile) {
    $content = Get-Content $loginFile -Raw
    if ($content -match "TOKEN DANS LOCALSTORAGE") {
        Write-Host "✅ Logs de token détaillés présents dans Login" -ForegroundColor Green
    } else {
        Write-Host "❌ Logs de token détaillés manquants dans Login" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Login.tsx non trouvé" -ForegroundColor Red
}

# Démarrer le serveur de développement
Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 Logs de token ajoutés:" -ForegroundColor Cyan
Write-Host "   - Affichage du token complet récupéré du backend" -ForegroundColor Cyan
Write-Host "   - Affichage du token stocké dans localStorage" -ForegroundColor Cyan
Write-Host "   - Vérification de correspondance token reçu/stocké" -ForegroundColor Cyan
Write-Host "   - Résumé final de l'état de la session" -ForegroundColor Cyan
Write-Host "   - Logs détaillés dans Login.tsx et AuthContext.tsx" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Instructions de test:" -ForegroundColor Green
Write-Host "   1. Ouvrez http://localhost:5173 dans votre navigateur" -ForegroundColor White
Write-Host "   2. Ouvrez la console du navigateur (F12)" -ForegroundColor White
Write-Host "   3. Connectez-vous avec vos identifiants" -ForegroundColor White
Write-Host "   4. Surveillez les logs de token détaillés" -ForegroundColor White
Write-Host "   5. Vérifiez que le token est affiché et stocké" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Logs à surveiller:" -ForegroundColor Yellow
Write-Host "   - '🔑 TOKEN COMPLET RÉCUPÉRÉ: ...'" -ForegroundColor Gray
Write-Host "   - '🔑 TOKEN STOCKÉ DANS LOCALSTORAGE: ...'" -ForegroundColor Gray
Write-Host "   - '✅ CONFIRMATION: Token stocké correspond au token reçu'" -ForegroundColor Gray
Write-Host "   - '🔑 TOKEN DANS LOCALSTORAGE (Login): ...'" -ForegroundColor Gray
Write-Host "   - '🎉 RÉSUMÉ FINAL: ...'" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 Commandes de debugging dans la console:" -ForegroundColor Cyan
Write-Host "   // Vérifier le token dans localStorage" -ForegroundColor Gray
Write-Host "   console.log('Token actuel:', localStorage.getItem('authToken'));" -ForegroundColor Gray
Write-Host ""
Write-Host "   // Vérifier toutes les données localStorage" -ForegroundColor Gray
Write-Host "   Object.keys(localStorage).forEach(key => {" -ForegroundColor Gray
Write-Host "     console.log(key + ':', localStorage.getItem(key));" -ForegroundColor Gray
Write-Host "   });" -ForegroundColor Gray
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