# Script pour appliquer la migration de la table des tokens
Write-Host "🔧 Application de la migration des tokens..." -ForegroundColor Green
Write-Host ""

# Vérifier que PostgreSQL est actif
Write-Host "🔍 Vérification de PostgreSQL..." -ForegroundColor Yellow
try {
    $postgresContainer = docker ps --filter "name=nfc4care-postgres" --format "table {{.Names}}\t{{.Status}}"
    if ($postgresContainer -like "*nfc4care-postgres*") {
        Write-Host "✅ PostgreSQL actif" -ForegroundColor Green
    } else {
        Write-Host "❌ PostgreSQL non trouvé" -ForegroundColor Red
        Write-Host "💡 Démarrez PostgreSQL avec: docker-compose up -d postgres" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification de PostgreSQL" -ForegroundColor Red
    exit 1
}

# Appliquer le script SQL
Write-Host "📝 Application du script SQL..." -ForegroundColor Yellow
try {
    $sqlContent = Get-Content "backend/database/tokens.sql" -Raw
    docker exec nfc4care-postgres psql -U nfc4care -d nfc4care -c $sqlContent
    
    Write-Host "✅ Migration des tokens appliquée avec succès" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de l'application de la migration: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Migration terminée!" -ForegroundColor Green
Write-Host "La table 'tokens' a été créée avec succès." -ForegroundColor Cyan
Write-Host "Vous pouvez maintenant redémarrer le backend pour utiliser la nouvelle gestion des tokens." -ForegroundColor Yellow 