# Script de test pour l'authentification NFC4Care
Write-Host "🔐 Test d'authentification NFC4Care..." -ForegroundColor Green
Write-Host ""

# Test 1: Vérifier si le backend répond
Write-Host "Test 1: Vérification du backend..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body '{"email":"test","password":"test"}' -ContentType "application/json" -TimeoutSec 10
    Write-Host "❌ Erreur: Le backend répond mais l'authentification ne devrait pas fonctionner avec des données de test" -ForegroundColor Red
} catch {
    if ($_.Exception.Message -like "*400*") {
        Write-Host "✅ Backend répond correctement (400 attendu pour données invalides)" -ForegroundColor Green
    } elseif ($_.Exception.Message -like "*403*") {
        Write-Host "⚠️  Backend répond mais erreur 403 - problème de configuration" -ForegroundColor Yellow
    } elseif ($_.Exception.Message -like "*Failed to fetch*") {
        Write-Host "❌ Backend non accessible - vérifiez qu'il est démarré" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "❌ Erreur inattendue: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Test 2: Test avec les vraies données de test
Write-Host ""
Write-Host "Test 2: Authentification avec les données de test..." -ForegroundColor Yellow
try {
    $loginBody = @{
        email = "doctor@example.com"
        password = "password"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json" -TimeoutSec 10
    
    if ($response.token) {
        Write-Host "✅ Authentification réussie!" -ForegroundColor Green
        Write-Host "Token obtenu: $($response.token.Substring(0, 20))..." -ForegroundColor Cyan
        
        # Test 3: Vérifier l'accès aux endpoints protégés
        Write-Host ""
        Write-Host "Test 3: Accès aux endpoints protégés..." -ForegroundColor Yellow
        
        $headers = @{
            "Authorization" = "Bearer $($response.token)"
            "Content-Type" = "application/json"
        }
        
        try {
            $patientsResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/patients" -Method GET -Headers $headers -TimeoutSec 10
            Write-Host "✅ Accès aux patients réussi" -ForegroundColor Green
        } catch {
            Write-Host "❌ Erreur accès patients: $($_.Exception.Message)" -ForegroundColor Red
        }
        
    } else {
        Write-Host "❌ Pas de token dans la réponse" -ForegroundColor Red
    }
} catch {
    if ($_.Exception.Message -like "*401*") {
        Write-Host "❌ Identifiants incorrects" -ForegroundColor Red
        Write-Host "Vérifiez que les données de test sont présentes dans la base de données" -ForegroundColor Yellow
    } elseif ($_.Exception.Message -like "*403*") {
        Write-Host "❌ Erreur 403 - Problème de configuration CORS ou sécurité" -ForegroundColor Red
        Write-Host "Redémarrez le backend avec: .\restart-backend.ps1" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Erreur d'authentification: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 4: Vérifier les logs du backend
Write-Host ""
Write-Host "Test 4: Vérification des logs du backend..." -ForegroundColor Yellow
try {
    $logs = docker-compose logs --tail=20 backend
    Write-Host "Derniers logs du backend:" -ForegroundColor Cyan
    $logs | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} catch {
    Write-Host "Impossible de récupérer les logs du backend" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Tests terminés!" -ForegroundColor Green
Read-Host "Press Enter to exit" 