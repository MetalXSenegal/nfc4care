# Guide : Dashboard avec Données Mockées

## Modifications Apportées

### 1. Dashboard.tsx
- **Supprimé** : Import de `apiService`
- **Ajouté** : Import des données mockées `mockDashboardStats` et `mockRecentPatients`
- **Remplacé** : `fetchDashboardData()` par `loadMockData()`
- **Supprimé** : Tous les appels API vers le backend
- **Ajouté** : Simulation d'un délai de chargement (500ms) pour une meilleure UX

### 2. Données Mockées Utilisées

#### Statistiques du Dashboard (`mockDashboardStats`)
```typescript
{
  totalPatients: 156,
  totalConsultations: 342,
  consultationsThisMonth: 28,
  patientsWithNFC: 89
}
```

#### Patients Récents (`mockRecentPatients`)
- 5 patients avec données complètes
- Inclut : nom, prénom, date de naissance, numéro de dossier, dernière consultation, etc.

### 3. Avantages

✅ **Plus d'erreurs 404/403** : Aucun appel API vers le backend
✅ **Chargement instantané** : Données disponibles immédiatement
✅ **Interface fonctionnelle** : Dashboard entièrement opérationnel
✅ **Navigation préservée** : Tous les liens vers les autres pages fonctionnent
✅ **UX améliorée** : Délai de chargement simulé pour une expérience naturelle

### 4. Fonctionnalités Préservées

- **Statistiques** : Affichage des 4 cartes de statistiques
- **Actions rapides** : Boutons vers Search, NFC Scan, History
- **Patients récents** : Liste des 5 derniers patients avec navigation
- **Activité récente** : Section d'activité système
- **Navigation** : Tous les liens vers les autres pages fonctionnent

### 5. Données Disponibles

Le dashboard affiche maintenant :
- **156 patients** au total
- **342 consultations** au total
- **28 consultations** ce mois-ci
- **89 patients** avec NFC
- **5 patients récents** avec données complètes

### 6. Redémarrage

Pour appliquer les changements :
```powershell
.\restart-frontend-mock-dashboard.ps1
```

### 7. Prochaines Étapes

Les patients réels seront disponibles dans :
- **Page Search** (`/search`) : Recherche de patients
- **Page Patient** (`/patient/:id`) : Détails d'un patient
- **Section Patients** : Gestion complète des patients

Le dashboard sert maintenant d'**interface d'accueil** avec des données de démonstration, tandis que les vraies données patient sont gérées dans les sections dédiées. 