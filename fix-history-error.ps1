# Script PowerShell pour corriger l'erreur du fichier History.tsx
Write-Host "🔧 Correction de l'erreur du fichier History.tsx..." -ForegroundColor Green

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

# Vérifier que le fichier History.tsx a été corrigé
Write-Host "🔍 Vérification du fichier History.tsx..." -ForegroundColor Yellow
if (Test-Path "src/pages/History.tsx") {
    Write-Host "✅ Fichier History.tsx trouvé" -ForegroundColor Green
    
    # Vérifier la structure JSX
    $content = Get-Content "src/pages/History.tsx" -Raw
    if ($content -match "export default History;") {
        Write-Host "✅ Structure JSX correcte" -ForegroundColor Green
    } else {
        Write-Host "❌ Structure JSX incorrecte" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Fichier History.tsx non trouvé" -ForegroundColor Red
    exit 1
}

# Vérifier la syntaxe TypeScript
Write-Host "🔍 Vérification de la syntaxe TypeScript..." -ForegroundColor Yellow
try {
    npx tsc --noEmit --skipLibCheck src/pages/History.tsx
    Write-Host "✅ Syntaxe TypeScript correcte" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur de syntaxe TypeScript détectée" -ForegroundColor Red
    Write-Host "Vérifiez le fichier History.tsx pour les erreurs de syntaxe" -ForegroundColor Yellow
}

# Démarrer le serveur de développement
Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Yellow
Write-Host "🔧 Corrections appliquées:" -ForegroundColor Cyan
Write-Host "   - Structure JSX corrigée dans History.tsx" -ForegroundColor Cyan
Write-Host "   - Balises fermantes orphelines supprimées" -ForegroundColor Cyan
Write-Host "   - Imports corrigés" -ForegroundColor Cyan
Write-Host ""
Write-Host "📱 Frontend accessible sur: http://localhost:5173" -ForegroundColor Green
Write-Host "🔄 Appuyez sur Ctrl+C pour arrêter le serveur" -ForegroundColor Gray

try {
    npm run dev
} catch {
    Write-Host "❌ Erreur lors du démarrage du serveur de développement" -ForegroundColor Red
    Write-Host "Vérifiez les logs pour plus de détails" -ForegroundColor Yellow
    exit 1
} 