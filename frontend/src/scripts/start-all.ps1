# Script PowerShell pour démarrer toute l'application NFC4Care
Write-Host "🚀 Démarrage complet de NFC4Care..." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan

# Fonction pour vérifier si un port est utilisé
function Test-Port {
    param([int]$Port)
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $Port -InformationLevel Quiet
        return $connection
    } catch {
        return $false
    }
}

# Vérifier les ports requis
Write-Host "🔍 Vérification des ports..." -ForegroundColor Yellow

$ports = @{
    "Frontend" = 5173
    "Backend" = 8080
    "Database" = 5432
}

foreach ($service in $ports.Keys) {
    $port = $ports[$service]
    if (Test-Port -Port $port) {
        Write-Host "⚠️  Port $port ($service) est déjà utilisé" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Port $port ($service) disponible" -ForegroundColor Green
    }
}

Write-Host ""

# Démarrer la base de données PostgreSQL
Write-Host "🗄️  Démarrage de la base de données PostgreSQL..." -ForegroundColor Yellow
try {
    docker-compose up -d postgres
    Write-Host "✅ Base de données démarrée" -ForegroundColor Green
    
    # Attendre que la base de données soit prête
    Write-Host "⏳ Attente que la base de données soit prête..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
} catch {
    Write-Host "❌ Erreur lors du démarrage de la base de données" -ForegroundColor Red
    Write-Host "Assurez-vous que Docker est installé et en cours d'exécution" -ForegroundColor Yellow
    exit 1
}

# Appliquer les migrations de base de données
Write-Host "📊 Application des migrations de base de données..." -ForegroundColor Yellow
try {
    docker-compose exec -T postgres psql -U nfc4care -d nfc4care -f /docker-entrypoint-initdb.d/01-init.sql
    docker-compose exec -T postgres psql -U nfc4care -d nfc4care -f /docker-entrypoint-initdb.d/02-tokens.sql
    Write-Host "✅ Migrations appliquées" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Erreur lors de l'application des migrations (peut être normal si déjà appliquées)" -ForegroundColor Yellow
}

# Démarrer le backend Spring Boot
Write-Host "🔧 Démarrage du backend Spring Boot..." -ForegroundColor Yellow
try {
    if (Test-Path "backend") {
        Set-Location "backend"
        Write-Host "📁 Répertoire backend trouvé" -ForegroundColor Green
        
        # Vérifier si Maven est installé
        try {
            $mvnVersion = mvn --version
            Write-Host "✅ Maven détecté" -ForegroundColor Green
        } catch {
            Write-Host "❌ Maven n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
            Write-Host "Veuillez installer Maven" -ForegroundColor Yellow
            exit 1
        }
        
        # Démarrer le backend en arrière-plan
        Start-Process -FilePath "mvn" -ArgumentList "spring-boot:run" -WindowStyle Hidden
        Write-Host "✅ Backend démarré en arrière-plan" -ForegroundColor Green
        
        # Attendre que le backend soit prêt
        Write-Host "⏳ Attente que le backend soit prêt..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15
        
        Set-Location ".."
    } else {
        Write-Host "❌ Répertoire backend non trouvé" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Erreur lors du démarrage du backend" -ForegroundColor Red
    exit 1
}

# Démarrer le frontend React
Write-Host "🌐 Démarrage du frontend React..." -ForegroundColor Yellow
try {
    if (Test-Path "frontend") {
        Set-Location "frontend"
        Write-Host "📁 Répertoire frontend trouvé" -ForegroundColor Green
        
        # Vérifier si les dépendances sont installées
        if (-not (Test-Path "node_modules")) {
            Write-Host "📦 Installation des dépendances frontend..." -ForegroundColor Yellow
            npm install
        }
        
        # Démarrer le frontend
        Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Green
        Write-Host "📱 Frontend accessible sur: http://localhost:5173" -ForegroundColor Cyan
        Write-Host "🔧 Backend accessible sur: http://localhost:8080" -ForegroundColor Cyan
        Write-Host "🗄️  Base de données accessible sur: localhost:5432" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "🔄 Appuyez sur Ctrl+C pour arrêter tous les services" -ForegroundColor Gray
        
        npm run dev
    } else {
        Write-Host "❌ Répertoire frontend non trouvé" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Erreur lors du démarrage du frontend" -ForegroundColor Red
    exit 1
} 