# PARTIE I — PRÉSENTATION GÉNÉRALE ET ARCHITECTURE

## 1. Introduction

### 1.1 Contexte
UniManager est une application de gestion universitaire développée dans le cadre d'un projet de Licence 3 en Développement Mobile. L'objectif est de fournir une plateforme complète de gestion des étudiants, enseignants, cours, notes, emplois du temps, et ressources pédagogiques.

### 1.2 Objectifs
- Centraliser la gestion administrative d'une université
- Permettre aux étudiants de consulter notes, emploi du temps, ressources
- Permettre aux enseignants de saisir notes, gérer cours, communiquer
- Offrir aux administrateurs un tableau de bord complet avec KPIs
- Générer rapports PDF et exports Excel
- Fonctionner en mode déconnecté avec cache local

### 1.3 Périmètre Fonctionnel
- Gestion des départements, programmes, niveaux, matières
- Gestion des étudiants, enseignants, salles
- Inscription aux cours et programmes
- Saisie et calcul des notes
- Génération des résultats (Admis/Rattrapage/Ajourné)
- Emploi du temps avec détection de conflits
- Messagerie interne avec pièces jointes et réactions
- Ressources pédagogiques (PDF, vidéo, liens)
- Notifications push et internes
- Rapports PDF (bulletins, listes) et exports Excel
- Tableaux de bord avec graphiques interactifs
- Recherche unifiée multi-entités
- Mode hors-ligne avec cache

## 2. Architecture Globale

### 2.1 Stack Technique

#### Backend
- **Framework** : Laravel 12 (PHP 8.2+)
- **Base de données** : PostgreSQL 16
- **Authentification** : tymon/jwt-auth (JSON Web Tokens)
- **RBAC** : Spatie Laravel Permission v6
- **API Docs** : L5-Swagger (OpenAPI 3.0)
- **PDF** : barryvdh/laravel-dompdf
- **Excel** : maatwebsite/laravel-excel
- **Validation** : Form Requests (classes de validation dédiées)
- **Tests** : PHPUnit

#### Frontend
- **Framework** : Flutter 3.29+ (Dart 3.x)
- **État** : Riverpod 2.x (StateNotifierProvider + StreamProvider)
- **Routing** : go_router (ShellRoute pour navigation persistante)
- **HTTP** : Dio 5.x avec intercepteurs (auth, retry, cache)
- **Cache** : Hive 4.x (stockage local NoSQL)
- **UI** : Material 3 (thème dynamique, dark/light)
- **Animations** : flutter_animate, lottie
- **Graphiques** : fl_chart
- **Connectivité** : connectivity_plus + internet_connection_checker
- **Notifications** : flutter_local_notifications

### 2.2 Architecture Backend (Clean Architecture / Service Layer)
```
Controller (HTTP)
    ↕ Request/Response
Service Layer (Logique métier)
    ↕ Model Query
Repository/Model (ORM Eloquent)
    ↕ SQL
PostgreSQL
```

Chaque contrôleur est mince (thin controller) : il valide la requête, délègue au service, retourne la ressource.

Chaque service encapsule une unité métier cohérente (ex: NoteService, CourseService, ScheduleService).

### 2.3 Architecture Frontend (MVVM avec Riverpod)
```
Écran (Widget)
    ↕ ConsumerWidget
Provider (StateNotifierProvider)
    ↕ Logique métier + état
Service (Dio + API)
    ↕ HTTP JSON
Backend Laravel
```

## 3. Structure du Projet

### 3.1 Backend (Laravel)
```
backend/
├── app/
│   ├── Console/Kernel.php
│   ├── Enums/               # 10 énumérations PHP 8.2
│   │   ├── CourseType.php
│   │   ├── DecisionType.php
│   │   ├── ExamType.php
│   │   ├── GradeType.php
│   │   ├── MentionQuality.php
│   │   ├── NotificationType.php
│   │   ├── ReactionType.php
│   │   ├── ResourceType.php
│   │   ├── SessionStatus.php
│   │   └── WeekDay.php
│   ├── Exceptions/
│   │   └── Handler.php
│   ├── Http/
│   │   ├── Controllers/Api/   # 25 contrôleurs
│   │   ├── Middleware/         # JWT, CORS
│   │   ├── Requests/           # 30+ Form Requests
│   │   └── Resources/          # 20 API Resources
│   ├── Models/                 # 22 modèles Eloquent
│   ├── Observers/              # Observers Eloquent
│   ├── Policies/               # 8 policies
│   ├── Providers/
│   ├── Services/               # 22 services
│   └── Traits/                 # Traits réutilisables
├── config/                     # 20+ fichiers de configuration
├── database/
│   ├── factories/              # 4 factories
│   ├── migrations/             # Schéma complet BDD
│   └── seeders/                # 15 seeders
├── routes/
│   ├── api.php                 # Routes API
│   └── console.php
├── storage/
│   ├── app/public/             # Uploads (cours, messages, resources)
│   └── api-docs/               # Documentation Swagger
├── tests/
│   ├── Feature/
│   └── Unit/
└── composer.json
```

### 3.2 Frontend (Flutter)
```
frontend/
├── lib/
│   ├── config/
│   │   ├── theme_config.dart
│   │   └── theme.dart
│   ├── models/                 # 19 modèles Dart
│   ├── providers/              # 25 providers Riverpod
│   ├── routes/
│   │   └── router.dart         # Configuration go_router
│   ├── screens/                # 59 écrans organisés par rôle
│   │   ├── admin/
│   │   ├── teacher/
│   │   ├── student/
│   │   └── shared/
│   ├── services/               # Services Flutter (auth, storage, notification)
│   ├── widgets/                # 34 widgets partagés
│   └── helpers/                # Responsive, extensions
├── pubspec.yaml
├── build.gradle.kts
└── android/app/build.gradle.kts
```
