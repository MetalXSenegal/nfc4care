# NFC4Care - Système de Gestion Médicale avec NFC et Blockchain

## 🏥 Vue d'ensemble

NFC4Care est une application médicale complète et moderne qui révolutionne la gestion des dossiers patients grâce à l'intégration de technologies NFC et blockchain. L'application permet aux professionnels de santé d'accéder rapidement aux informations patients via des cartes NFC, tout en garantissant l'intégrité et la sécurité des données médicales.

### 🎯 Objectifs principaux

- **Accès rapide aux dossiers patients** via cartes NFC
- **Sécurisation des données médicales** avec blockchain Cardano
- **Interface moderne et intuitive** pour les professionnels de santé
- **Gestion complète des consultations** et dossiers médicaux
- **Authentification sécurisée** avec 2FA
- **Conformité RGPD** et standards médicaux

## 🏗️ Architecture

### Frontend (React + TypeScript)
- **Framework**: React 18 avec TypeScript
- **Styling**: Tailwind CSS
- **État**: Context API pour l'authentification
- **NFC**: Web NFC API pour la lecture/écriture de cartes
- **Routing**: React Router v6
- **UI Components**: Composants personnalisés avec Lucide React

### Backend (Spring Boot + Java)
- **Framework**: Spring Boot 3.x
- **Base de données**: PostgreSQL 15
- **Authentification**: JWT avec 2FA
- **API**: RESTful avec documentation Swagger
- **Blockchain**: Intégration Cardano via Blockfrost API
- **Sécurité**: Spring Security avec CORS configuré

### Base de données (PostgreSQL)
- **Tables principales**: Patients, Professionnels, Dossiers médicaux, Consultations
- **Indexation**: Optimisée pour les recherches rapides
- **Intégrité**: Contraintes et relations bien définies
- **Données**: 10 patients réels avec dossiers complets

## 🚀 Démarrage rapide

### Prérequis
- **Node.js** 18+ et npm
- **Java** 17+ et Maven
- **Docker** Desktop
- **Git**

### Installation et démarrage

#### Option 1: Script automatique (Recommandé)

**Windows (PowerShell) :**
```powershell
# Cloner le projet
git clone <repository-url>
cd nfc4care

# Démarrer toute l'application
.\start-nfc4care.ps1
```

**Windows (Command Prompt) :**
```cmd
# Cloner le projet
git clone <repository-url>
cd nfc4care

# Démarrer toute l'application
start-nfc4care.bat
```

#### Option 2: Démarrage manuel

**Windows (PowerShell) :**
```powershell
# 1. Démarrer la base de données
.\start-database.bat

# 2. Démarrer le backend
.\start-backend.bat

# 3. Démarrer le frontend
.\start-frontend.ps1
```

**Windows (Command Prompt) :**
```cmd
# 1. Démarrer la base de données
start-database.bat

# 2. Démarrer le backend
start-backend.bat

# 3. Démarrer le frontend
start-frontend.bat
```

### Accès à l'application
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8080
- **Documentation API**: http://localhost:8080/swagger-ui.html
- **Base de données**: localhost:5432

### Identifiants de connexion
```
Email: doctor@example.com
Mot de passe: password
```

## 📊 Données de démonstration

L'application inclut des données réelles et complètes :

### Professionnels de santé (4)
- Dr. Martin Dubois (Médecine générale)
- Dr. Marie Bernard (Cardiologie)
- Dr. Jean Petit (Dermatologie)
- Sophie Dupont (Infirmier)

### Patients (10) avec dossiers complets
- Sophie Laurent (42 ans, Lombalgie chronique)
- Marc Dupont (67 ans, Hypertension)
- Émilie Moreau (29 ans, Anxiété)
- Thomas Petit (54 ans, Diabète type 2)
- Claire Martin (35 ans, Asthme)
- Pierre Rousseau (48 ans, Arthrose)
- Anne Leroy (32 ans, Dépression)
- Michel Simon (61 ans, BPCO)
- Isabelle Garcia (38 ans, Hypothyroïdie)
- François Lefevre (45 ans, Ulcère gastrique)

### Consultations (12)
- Consultations récentes avec diagnostics, traitements et ordonnances
- Données temporelles réalistes (dernières heures à semaines)
- Multiples spécialités médicales

## 🔧 Fonctionnalités principales

### 🔐 Authentification sécurisée
- Connexion avec email/mot de passe
- Authentification à deux facteurs (2FA)
- Gestion des sessions avec JWT
- Déconnexion automatique après inactivité

### 📱 Interface utilisateur moderne
- **Dashboard** avec statistiques en temps réel
- **Recherche patients** avec filtres avancés
- **Historique des consultations** détaillé
- **Profil médecin** avec informations complètes
- **Gestion des dossiers patients** complète

### 🏷️ Technologie NFC
- **Lecture de cartes NFC** pour accès rapide aux dossiers
- **Écriture de cartes NFC** pour nouveaux patients
- **Support Web NFC API** natif
- **Gestion des erreurs** et fallbacks

### ⛓️ Intégration Blockchain
- **Vérification d'intégrité** des dossiers médicaux
- **Historique blockchain** des modifications
- **Hachage sécurisé** des données sensibles
- **API Cardano** via Blockfrost

### 🔍 Recherche et filtres
- **Recherche en temps réel** par nom, prénom, dossier, téléphone, email
- **Filtres avancés** : groupe sanguin, âge, présence NFC
- **Historique des recherches** récentes
- **Interface responsive** et intuitive

## 🛡️ Sécurité

### Authentification
- JWT avec expiration automatique
- Authentification à deux facteurs
- Gestion sécurisée des sessions
- Protection contre les attaques par force brute

### Données
- Chiffrement des mots de passe (BCrypt)
- Hachage des dossiers médicaux
- Validation des entrées utilisateur
- Protection CORS configurée

### Blockchain
- Vérification d'intégrité des données
- Traçabilité des modifications
- Immutabilité des enregistrements
- Conformité RGPD

## 📁 Structure du projet

```
nfc4care/
├── frontend/                 # Application React
│   ├── src/
│   │   ├── components/      # Composants UI
│   │   ├── pages/          # Pages principales
│   │   ├── services/       # Services API
│   │   ├── context/        # Context React
│   │   └── types/          # Types TypeScript
│   ├── package.json
│   └── vite.config.ts
├── backend/                 # Application Spring Boot
│   ├── src/main/java/
│   │   ├── controllers/    # Contrôleurs REST
│   │   ├── services/       # Services métier
│   │   ├── repositories/   # Accès données
│   │   ├── entities/       # Entités JPA
│   │   └── config/         # Configuration
│   ├── database/           # Scripts SQL
│   └── pom.xml
├── docker-compose.yml      # Configuration Docker
├── start-nfc4care.ps1      # Script PowerShell principal
├── start-nfc4care.bat      # Script batch principal
├── start-frontend.ps1      # Script PowerShell frontend
├── start-frontend.bat      # Script batch frontend
├── start-backend.bat       # Script backend
├── start-database.bat      # Script base de données
└── README.md
```

## 🚀 Déploiement

### Développement
```powershell
# Démarrer en mode développement (PowerShell)
.\start-nfc4care.ps1

# Ou avec Command Prompt
start-nfc4care.bat
```

### Production
```bash
# Construire les images Docker
docker-compose -f docker-compose.prod.yml build

# Démarrer en production
docker-compose -f docker-compose.prod.yml up -d
```

## 🔧 Configuration

### Variables d'environnement

#### Frontend (.env)
```env
VITE_API_URL=http://localhost:8080/api
VITE_APP_NAME=NFC4Care
```

#### Backend (application.properties)
```properties
# Base de données
spring.datasource.url=jdbc:postgresql://localhost:5432/nfc4care
spring.datasource.username=nfc4care
spring.datasource.password=nfc4care

# JWT
jwt.secret=your-secret-key
jwt.expiration=86400000

# Blockchain
blockfrost.api.key=your-blockfrost-api-key
blockfrost.network=testnet
```

## 📈 Statistiques du projet

- **10 patients** avec dossiers médicaux complets
- **12 consultations** récentes avec données détaillées
- **4 professionnels** de santé de différentes spécialités
- **100% des données simulées** remplacées par des données réelles
- **Interface complètement nettoyée** sans boutons inutiles
- **Recherche en temps réel** optimisée
- **Prêt pour le déploiement** en production

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Contacter l'équipe de développement
- Consulter la documentation API

---

**NFC4Care** - Révolutionner la gestion médicale avec la technologie NFC et blockchain 🏥✨
