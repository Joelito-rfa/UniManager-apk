# Planning de Développement - UniManager APP

## 1. Découpage en phases

```
═══════════════════════════════════════════════════════════════════════════════
                   PLANNING DE DÉVELOPPEMENT UniManager APP
═══════════════════════════════════════════════════════════════════════════════

PHASE 0 : INITIALISATION DU PROJET
───────────────────────────────────
  Étapes :
    □ 0.1 - Création dépôt GitHub
    □ 0.2 - Configuration Git (branches, .gitignore)
    □ 0.3 - Création projet Laravel
    □ 0.4 - Création projet Flutter
    □ 0.5 - Configuration PostgreSQL
    □ 0.6 - Installation dépendances
  ⏱  Estimation : 1 jour

PHASE 1 : BACKEND - AUTHENTIFICATION
─────────────────────────────────────
  Étapes :
    □ 1.1 - Configuration JWT (tymon-jwt)
    □ 1.2 - Modèle User + Migration
    □ 1.3 - Modèle Role + Permission (Spatie)
    □ 1.4 - Seeders (rôles, admin par défaut)
    □ 1.5 - API Login/Register/Logout
    □ 1.6 - API Refresh Token
    □ 1.7 - Middleware vérification rôle
    □ 1.8 - Tests authentification
  ⏱  Estimation : 2 jours

PHASE 2 : BACKEND - GESTION ACADÉMIQUE
────────────────────────────────────────
  Étapes :
    □ 2.1 - CRUD Départements (API + Tests)
    □ 2.2 - CRUD Programmes/Filières (API + Tests)
    □ 2.3 - CRUD Niveaux (API + Tests)
    □ 2.4 - CRUD Matières (API + Tests)
    □ 2.5 - CRUD Salles (API + Tests)
    □ 2.6 - CRUD Étudiants (API + Tests)
    □ 2.7 - CRUD Enseignants (API + Tests)
    □ 2.8 - CRUD Cours (API + Tests)
    □ 2.9 - CRUD Emplois du temps (API + Tests)
  ⏱  Estimation : 4 jours

PHASE 3 : BACKEND - GESTION PÉDAGOGIQUE
─────────────────────────────────────────
  Étapes :
    □ 3.1 - CRUD Inscriptions (API + Tests)
    □ 3.2 - CRUD Notes (API + Tests)
    □ 3.3 - Calcul des résultats (Service)
    □ 3.4 - Génération bulletins (PDF)
    □ 3.5 - Export Excel
    □ 3.6 - Notifications
  ⏱  Estimation : 3 jours

PHASE 4 : BACKEND - DASHBOARD & STATISTIQUES
─────────────────────────────────────────────
  Étapes :
    □ 4.1 - Endpoints statistiques étudiants
    □ 4.2 - Endpoints statistiques enseignants
    □ 4.3 - Endpoints statistiques résultats
    □ 4.4 - Endpoints graphiques
  ⏱  Estimation : 1 jour

PHASE 5 : FRONTEND - ARCHITECTURE
───────────────────────────────────
  Étapes :
    □ 5.1 - Structure des dossiers
    □ 5.2 - Configuration Router (Go Router)
    □ 5.3 - Configuration Thème (Material 3)
    □ 5.4 - Configuration Riverpod
    □ 5.5 - Services HTTP (Dio)
    □ 5.6 - Gestion du token JWT
    □ 5.7 - Responsive Design Setup
  ⏱  Estimation : 2 jours

PHASE 6 : FRONTEND - AUTHENTIFICATION
───────────────────────────────────────
  Étapes :
    □ 6.1 - Écran Connexion
    □ 6.2 - Écran Mot de passe oublié
    □ 6.3 - Provider Auth
    □ 6.4 - Garde de navigation (rôles)
    □ 6.5 - Gestion des sessions
  ⏱  Estimation : 1 jour

PHASE 7 : FRONTEND - GESTION ACADÉMIQUE
─────────────────────────────────────────
  Étapes :
    □ 7.1 - Écrans Liste/Création/Modification Étudiants
    □ 7.2 - Écrans Liste/Création/Modification Enseignants
    □ 7.3 - Écrans Liste/Création/Modification Départements
    □ 7.4 - Écrans Liste/Création/Modification Filières
    □ 7.5 - Écrans Liste/Création/Modification Matières
    □ 7.6 - Écrans Liste/Création/Modification Cours
    □ 7.7 - Écrans Liste/Création/Modification Salles
    □ 7.8 - Écrans Liste/Création/Modification Emplois du temps
  ⏱  Estimation : 5 jours

PHASE 8 : FRONTEND - GESTION PÉDAGOGIQUE
──────────────────────────────────────────
  Étapes :
    □ 8.1 - Écran Inscriptions
    □ 8.2 - Écran Saisie notes (enseignant)
    □ 8.3 - Écrans Consultation notes (étudiant)
    □ 8.4 - Écran Résultats
    □ 8.5 - Écran Bulletins
    □ 8.6 - Téléchargement PDF
  ⏱  Estimation : 3 jours

PHASE 9 : FRONTEND - DASHBOARD
────────────────────────────────
  Étapes :
    □ 9.1 - Dashboard Administrateur
    □ 9.2 - Dashboard Enseignant
    □ 9.3 - Dashboard Étudiant
    □ 9.4 - Graphiques (fl_chart)
    □ 9.5 - Notifications
  ⏱  Estimation : 2 jours

PHASE 10 : TESTS & FINALISATION
─────────────────────────────────
  Étapes :
    □ 10.1 - Tests unitaires Laravel
    □ 10.2 - Tests d'intégration Laravel
    □ 10.3 - Tests widgets Flutter
    □ 10.4 - Documentation API (Postman)
    □ 10.5 - Guide déploiement
    □ 10.6 - Pull Request finale
  ⏱  Estimation : 2 jours

═══════════════════════════════════════════════════════════════════════════════
  DURÉE TOTALE ESTIMÉE : 26 jours
═══════════════════════════════════════════════════════════════════════════════

## 2. Diagramme de Gantt (textuel)

Semaine 1 : [PHASE 0][PHASE 1████████]
Semaine 2 : [PHASE 2████████████████]
Semaine 3 : [PHASE 3████████████][PHASE 4████]
Semaine 4 : [PHASE 5████████][PHASE 6████]
Semaine 5 : [PHASE 7████████████████]
Semaine 6 : [PHASE 7████][PHASE 8████████████]
Semaine 7 : [PHASE 9████████][PHASE 10████████]

## 3. Jalons clés

│ Jalon                            │ Date     │ Livrable                          │
│──────────────────────────────────┼──────────┼───────────────────────────────────│
│ M0 - Lancement projet            │ J1       │ Dépôt GitHub configuré            │
│ M1 - Auth opérationnelle         │ J3       │ API Login + Middleware             │
│ M2 - CRUD académique complet     │ J10      │ API Départements..EDT             │
│ M3 - Gestion pédagogique         │ J15      │ API Notes + Résultats             │
│ M4 - Application Flutter V1      │ J23      │ Tous les écrans fonctionnels      │
│ M5 - Livraison finale            │ J26      │ Tests + Documentation             │

## 4. Règles de gestion

1. Chaque fonctionnalité est développée sur une branche feature séparée
2. Une Pull Request est créée pour chaque feature vers develop
3. Le code est revu avant merge
4. Les tests doivent passer avant merge
5. Les commits doivent suivre la convention : type(scope): message
   - feat(auth): add login endpoint
   - fix(students): handle duplicate email
   - refactor(api): simplify response format
   - docs(readme): update installation guide
