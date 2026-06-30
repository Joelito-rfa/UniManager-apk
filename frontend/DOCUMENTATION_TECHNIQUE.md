# Documentation Technique du Projet UniManager

## 1. Choix de la Technologie

### 1.1 Comparaison des frameworks

Le projet UniManager repose sur une architecture découplée (frontend/backend) avec des technologies distinctes pour chaque couche. Le tableau ci-dessous compare les choix effectués avec les alternatives envisagées.

| Technologie | Rôle | Justification |
|---|---|---|
| **Flutter 3.44** (Dart 3.12) | Framework frontend mobile | Cross-platform natif (Android/iOS) avec un seul codebase ; hot-reload pour itération rapide ; écosystème riche (Riverpod, GoRouter, Dio) ; rendu 60 FPS natif via le moteur Skia. Alternative : React Native (performance inférieure sur animations complexes), Kotlin Multiplatform (écosystème moins mature). |
| **Laravel 12** (PHP 8.2) | Framework backend API REST | Architecture MVC mature, Eloquent ORM intégré, JWT Auth (tymon/jwt-auth), permissions (Spatie), filesystem unifié, queue, events, notifications. Alternative : Symfony (plus verbeux), Node.js/Express (moins structuré pour un projet d'envergure), Django (Python - plus lourd). |
| **PostgreSQL 16** | Base de données relationnelle | Support natif des types JSON, transactions ACID, extensions avancées (PostGIS), performance en lecture/écriture concurrente. Alternative : MySQL/MariaDB (moins de fonctionnalités avancées), SQLite (pas adapté au multi-utilisateur). |
| **Dio 5.9** | Client HTTP Flutter | Intercepteurs (auth, retry, cache), gestion des timeouts, téléchargement avec progression, support multipart. Alternative : http (trop bas niveau), chopper (nécessite code generation). |
| **Riverpod 2.6** | Gestion d'état Flutter | StateNotifierProvider pour états complexes, StreamProvider pour flux temps réel, injection de dépendances native, compile-safe (pas d'erreur runtime). Alternative : Provider (obsolète), BLoC (plus verbeux), GetX (trop magique). |
| **GoRouter 14.8** | Routage Flutter | Redirection conditionnelle (auth guard), ShellRoute pour layout partagé, paramètres d'URL typés. Alternative : Navigator 2.0 (trop verbeux), auto_route (nécessite code generation). |
| **JWT (tymon/jwt-auth)** | Authentification API | Token-based stateless, refresh token rotatif, TTL configurable. Alternative : Laravel Sanctum (cookie-based, moins adapté à Flutter), OAuth2 (trop lourd pour ce périmètre). |

### 1.2 Dépendances principales

#### Frontend (Flutter/Dart)

| Package | Version | Rôle |
|---|---|---|
| flutter_riverpod | ^2.6.1 | Gestion d'état réactive et injection de dépendances |
| go_router | ^14.8.1 | Routage déclaratif avec guards d'authentification |
| dio | ^5.7.0 | Client HTTP avec intercepteurs (auth, retry, cache) |
| flutter_secure_storage | ^9.2.4 | Stockage sécurisé des tokens JWT (Keystore Android) |
| json_annotation | ^4.9.0 | Annotations pour la sérialisation JSON |
| intl | ^0.19.0 | Internationalisation et formatage (dates, nombres) |
| fl_chart | ^0.69.2 | Graphiques et diagrammes (dashboard) |
| flutter_pdfview | ^1.3.2 | Visualisation de fichiers PDF |
| open_file | ^3.5.10 | Ouverture de fichiers dans des applications externes |
| cached_network_image | ^3.4.1 | Chargement et cache d'images réseau |
| shimmer | ^3.0.0 | Effets de chargement squelettique |
| google_fonts | ^6.2.1 | Police Inter (Material 3) |
| connectivity_plus | ^6.1.1 | Détection de l'état réseau |
| image_picker | ^1.1.2 | Sélection de photos depuis la galerie/caméra |
| file_picker | ^8.3.7 | Sélection de fichiers (documents, PDF) |
| url_launcher | ^6.3.1 | Ouverture de liens externes |
| video_player | ^2.11.1 | Lecture de vidéos (ressources pédagogiques) |
| shared_preferences | ^2.2.2 | Stockage de préférences simples (thème, langue) |
| hive / hive_flutter | ^2.2.3 / ^1.1.0 | Base de données locale NoSQL (cache API) |
| flutter_cache_manager | ^3.4.1 | Gestion de cache de fichiers |
| internet_connection_checker | ^3.0.1 | Vérification de la connectivité Internet réelle |
| permission_handler | ^11.3.1 | Gestion des permissions Android (stockage, caméra) |
| flutter_local_notifications | ^18.0.1 | Notifications locales |
| flutter_animate | ^4.5.2 | Animations fluides (splash screen) |
| lottie | ^3.3.1 | Animations vectorielles Lottie |
| skeletonizer | ^1.4.3 | Chargements squelettiques stylisés |
| logger | ^2.5.0 | Journalisation structurée (requêtes/réponses Dio) |
| equatable | ^2.0.7 | Comparaison d'objets par valeur |
| freezed_annotation | ^2.4.4 | Génération de code (classes immutables) |

#### Backend (Laravel/PHP)

| Package | Version | Rôle |
|---|---|---|
| laravel/framework | ^12.0 | Framework MVC complet |
| tymon/jwt-auth | ^2.1 | Authentification par JWT (JSON Web Token) |
| spatie/laravel-permission | ^6.0 | Gestion des rôles et permissions (Admin, Teacher, Student) |
| barryvdh/laravel-dompdf | ^3.0 | Génération de documents PDF (relevés de notes, procès-verbaux) |
| maatwebsite/excel | ^3.1 | Export/Import de fichiers Excel |
| darkaonline/l5-swagger | ^8.5 | Documentation Swagger/OpenAPI de l'API |

---

## 2. Conception Architecturale

### 2.1 Architecture globale

Le projet suit une architecture **client-serveur découplée** avec un frontend Flutter communiquant via HTTP REST avec un backend Laravel. Le frontend adopte un **pattern MVVM (Model-View-ViewModel)** adapté à Flutter, tandis que le backend suit le **pattern MVC (Modèle-Vue-Contrôleur)** de Laravel avec une couche Service supplémentaire.

La communication entre les deux parties est assurée par une API REST JSON authentifiée par JWT (JSON Web Token).

```
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND FLUTTER                          │
│                                                              │
│  Écrans (Screens) ──> Providers (Riverpod) ──> Services      │
│       │                      │                      │         │
│       │                      │                      │         │
│  Widgets / UI           StateNotifier              DioClient  │
│  (Material 3)           (gestion état)         (HTTP + Auth) │
│                                                              │
│  Routage : GoRouter (auth guard + rôle)                      │
│  Cache : Hive (API responses avec TTL)                       │
│  Stockage sécurisé : FlutterSecureStorage (JWT tokens)       │
│  Connectivité : InternetConnectionChecker (StreamProvider)   │
└──────────────────────┬───────────────────────────────────────┘
                       │ HTTPS / REST / JSON
                       │ JWT Bearer Token
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                     BACKEND LARAVEL                          │
│                                                              │
│  Routes (api.php) ──> Controllers ──> Services ──> Models   │
│       │                  │               │           │        │
│   Middleware           Requests        Logique      Eloquent  │
│   (auth:api, role)   (Form Request)   métier       ORM       │
│                                                              │
│  Base de données : PostgreSQL 16                              │
│  Authentification : JWT (tymon/jwt-auth)                      │
│  Permissions : Spatie (Admin, Teacher, Student)               │
│  API Resources : Transformation JSON                         │
└─────────────────────────────────────────────────────────────┘
```

#### Structure des dossiers frontend

| Élément | Description |
|---|---|
| `lib/config/` | Configuration globale (URL de l'API `app_config.dart`, thème Material 3 `theme_config.dart`, routage GoRouter `router_config.dart`) |
| `lib/core/network/` | Client HTTP (`dio_client.dart` avec intercepteurs JWT, retry, cache), modèle de réponse générique (`api_response.dart`) |
| `lib/core/cache/` | Service de cache Hive (`cache_service.dart`) avec TTL configurable |
| `lib/core/connectivity/` | Service de connectivité (`connectivity_service.dart`) avec StreamProvider |
| `lib/core/errors/` | Gestion centralisée des erreurs (`app_exception.dart`) avec mapping DioException → messages français |
| `lib/core/constants/` | Constantes (`api_constants.dart` endpoints, `app_constants.dart` valeurs globales) |
| `lib/core/pagination/` | Modèle générique de pagination (`pagination_model.dart`) compatible Laravel |
| `lib/core/localization/` | Fichiers de traduction (`app_strings.dart`) Français, Anglais, Malagasy |
| `lib/core/utils/` | Utilitaires (formatage dates, validation formulaires, gestion fichiers) |
| `lib/models/` | 19 modèles Dart (User, Student, Course, Schedule, Grade, etc.) avec `fromJson`/`toJson` |
| `lib/providers/` | 25 providers Riverpod (StateNotifierProvider pour chaque entité + providers transversaux) |
| `lib/services/` | 3 services métier (`auth_service.dart`, `notification_service.dart`, `storage_service.dart`) |
| `lib/screens/` | 50+ écrans organisés par rôle (auth, admin, teacher, student, shared, messaging) |
| `lib/widgets/common/` | Composants d'interface réutilisables (sidebar, topbar, data table, filter bar, skeleton loading, etc.) |
| `lib/widgets/forms/` | Champs de formulaire personnalisés (`app_text_field.dart`, `app_dropdown_field.dart`) |
| `lib/widgets/top_bar/` | Composants de la barre supérieure (horloge, notifications, messagerie, profil, thème) |

#### Structure des dossiers backend

| Élément | Description |
|---|---|
| `app/Models/` | 22 modèles Eloquent correspondant aux tables de la base de données |
| `app/Http/Controllers/` | 40 contrôleurs organisés par domaine (Auth, Admin, Teacher, Student, System) |
| `app/Http/Resources/` | 20 API Resources pour la transformation JSON des réponses |
| `app/Http/Requests/` | 41 Form Requests pour la validation des données entrantes |
| `app/Services/` | 22 services contenant la logique métier |
| `app/Repositories/` | Dépôt de recherche centralisé (`SearchRepository`) |
| `app/Enums/` | 10 énumérations (type de salle, jour de semaine, décision, statut inscription, etc.) |
| `app/Events/` | 5 événements (GradePublished, ResultPublished, StudentEnrolled, etc.) |
| `app/Listeners/` | 5 écouteurs (SendGradePublishedNotification, etc.) |
| `app/Policies/` | 8 politiques d'autorisation (Course, Grade, Subject, etc.) |
| `app/Traits/` | Trait réutilisable `HasBusinessCode` |
| `database/migrations/` | 36 migrations pour l'évolution du schéma |
| `database/seeders/` | 15 seeders pour le peuplement initial |
| `routes/` | Fichier unique `api.php` contenant toutes les routes REST |

### 2.2 Modèle de données

Le projet manipule 22 entités principales, modélisées à la fois côté backend (Eloquent ORM) et côté frontend (classes Dart avec sérialisation JSON). Les principaux modèles sont décrits ci-dessous.

#### UserModel (frontend)

| Élément | Description |
|---|---|
| `id` | Identifiant unique de l'utilisateur |
| `code` | Code interne optionnel |
| `name` | Nom complet de l'utilisateur |
| `email` | Adresse électronique (identifiant de connexion) |
| `phone` | Numéro de téléphone |
| `avatar` | URL de l'avatar |
| `status` | Statut du compte (active / inactive) |
| `role` | Rôle utilisateur (admin / teacher / student) |
| `emailVerifiedAt` | Date de vérification de l'email |
| `createdAt` / `updatedAt` | Horodatages de création et mise à jour |

**Méthodes principales :**
- `fromJson()` / `toJson()` : Sérialisation/désérialisation JSON
- `copyWith()` : Création d'une copie modifiée (pattern immuable)
- `isAdmin` / `isTeacher` / `isStudent` : Getters de vérification de rôle

#### CourseModel (frontend)

| Élément | Description |
|---|---|
| `id` | Identifiant unique du cours |
| `subjectId` / `subjectName` | Matière associée |
| `teacherId` / `teacherName` | Enseignant responsable |
| `levelId` / `levelName` | Niveau d'étude |
| `classroomId` / `classroomName` | Salle de cours |
| `semester` | Semestre (S1, S2) |
| `academicYear` | Année académique |
| `code` | Code unique du cours |
| `status` | Statut (active / inactive / completed) |

**Méthodes principales :**
- `fromJson()` : Désérialisation avec résolution des relations imbriquées (level, teacher, subject, classroom)
- `toJson()` : Sérialisation pour l'envoi à l'API
- `copyWith()` : Copie modifiée

#### StudentModel (frontend)

| Élément | Description |
|---|---|
| `id` | Identifiant unique de l'étudiant |
| `userId` | Référence vers l'utilisateur associé |
| `studentNumber` | Numéro d'étudiant (identifiant unique) |
| `dateOfBirth` | Date de naissance |
| `address` | Adresse postale |
| `phone` | Téléphone |
| `enrollmentDate` | Date d'inscription |
| `programId` / `programName` | Programme suivi |
| `levelId` / `levelName` | Niveau actuel |
| `firstName` / `lastName` | Prénom et nom extraits du nom complet |

**Méthodes principales :**
- `fromJson()` : Désérialisation avec extraction des relations (user, program, level)
- `toJson()` : Sérialisation avec `fullName` concaténé
- `fullName` : Getter combinant prénom et nom

#### ScheduleModel (frontend)

| Élément | Description |
|---|---|
| `id` | Identifiant unique de la séance |
| `levelId` / `levelName` | Niveau concerné |
| `courseId` / `courseName` | Cours associé |
| `classroomId` / `classroomName` | Salle | 
| `teacherId` / `teacherName` | Enseignant |
| `dayOfWeek` | Jour de la semaine (Lundi, Mardi...) |
| `startTime` / `endTime` | Créneau horaire (HH:mm) |
| `session` | Session (matin/après-midi/soir) |
| `group` | Groupe d'étudiants |
| `status` | Statut de la séance |
| `date` | Date spécifique pour une séance ponctuelle |

**Méthodes principales :**
- `fromJson()` / `toJson()` : Sérialisation complète
- `copyWith()` : Copie modifiée pour les formulaires

#### GradeModel (frontend)

| Élément | Description |
|---|---|
| `id` | Identifiant unique de la note |
| `enrollmentId` | Inscription associée |
| `subjectName` | Nom de la matière (résolu via relation) |
| `gradeType` | Type de note (CC / TP / Examen / Projet) |
| `grade` | Valeur de la note (sur 20) |
| `coefficient` | Coefficient appliqué |
| `comment` | Commentaire de l'enseignant |
| `gradedBy` / `gradedByName` | Enseignant ayant noté |
| `code` | Code unique de la note |

**Méthodes principales :**
- `fromJson()` : Résolution via 3 niveaux de relations (grade → enrollment → course → subject)
- `toJson()` : Sérialisation des données modifiables

### 2.3 Gestion d'état / Logique métier

Le frontend utilise **Riverpod** comme solution de gestion d'état, avec le pattern `StateNotifierProvider` pour chaque domaine fonctionnel.

| Fonction | Description |
|---|---|
| **`authProvider`** | Gère l'état d'authentification (login, register, logout, vérification de session, mise à jour profil, changement mot de passe). État : `AuthStatus` (initial/loading/authenticated/unauthenticated/error). Sauvegarde du token JWT dans `flutter_secure_storage`. |
| **`courseProvider`** | Gère la liste des cours avec pagination, recherche et filtres. Permet la création, modification et suppression. Les données sont chargées via `DioClient.get()` avec support de cache si disponible. |
| **`dashboardProvider`** | Charge les statistiques du tableau de bord via des endpoints différenciés par rôle (`dashboard`, `dashboardTeacher`, `dashboardStudent`). Les données incluent KPI, distributions, évolutions et inscriptions récentes. |
| **`scheduleProvider`** | Gère l'emploi du temps avec filtres par niveau, jour, enseignant. Supporte la création, modification et suppression de séances. |
| **`gradeProvider`** | Gère les notes avec création individuelle et par lot (batch), mise à jour, filtres par cours/étudiant. Calcul et publication des résultats. |
| **`studentProvider`** | Gère les étudiants avec pagination, recherche, création/modification. Gère l'attribution automatique des numéros d'étudiant. |
| **`teacherProvider`** | Gère les enseignants, création, modification, affectation aux cours. |
| **`enrollmentProvider`** | Gère les inscriptions aux cours avec filtres par programme, niveau, statut. |
| **`classroomProvider`** | Gère les salles de classe et leur disponibilité. |
| **`departmentProvider`** | Gère les départements académiques. |
| **`programProvider`** | Gère les programmes de formation. |
| **`subjectProvider`** | Gère les matières enseignées. |
| **`notificationProvider`** | Gère les notifications avec compteur de non-lues, marquage comme lu individuel/masse, suppression. |
| **`conversationProvider`** | Gère la messagerie instantanée (conversations, messages, réactions, non-lus). |
| **`connectionStatusProvider`** | Provider de type `StreamProvider` qui écoute en temps réel l'état de la connexion Internet via `internet_connection_checker`. |
| **`preferencesProvider`** | Gère les préférences utilisateur (thème clair/sombre, langue). |
| **`searchProvider`** | Gère la recherche globale dans l'application. |
| **`serverStatusProvider`** | Vérifie périodiquement l'état du serveur backend. |

**Cycle de vie des données :**

1. **Chargement** : Chaque provider expose une méthode de chargement (ex: `loadCourses()`) qui interroge l'API via `DioClient`. Le provider met à jour son état avec `isLoading = true`, puis passe les données ou une erreur.

2. **Sauvegarde** : Les mutations (create/update/delete) sont envoyées à l'API via `DioClient.post/put/delete`. En cas de succès, le provider recharge la liste mise à jour.

3. **Cache** : Le `DioClient` intègre un interceptor de cache qui stocke les réponses GET dans Hive avec un TTL de 15 minutes. En mode hors ligne, les données sont servies depuis le cache.

4. **Pagination** : Les listes sont chargées par page (20 éléments par défaut) avec `PaginatedResponse` qui décode la structure Laravel standard (`data`, `meta.current_page`, `meta.last_page`, `meta.total`).

5. **Offline** : Le `ConnectivityService` détecte l'état de la connexion via `InternetConnectionChecker` (3 URLs de vérification). Une `ConnectivityBanner` s'affiche en haut de l'écran en mode hors ligne avec un bouton « Réessayer ».

### 2.4 Persistance des données

Le backend utilise **PostgreSQL** comme système de gestion de base de données relationnelle.

| Élément | Description |
|---|---|
| **SGBD** | PostgreSQL 16 |
| **Connexion** | `127.0.0.1:5432`, base `unimanager`, utilisateur `postgres` |
| **ORM** | Eloquent ORM (Laravel 12) avec 22 modèles |
| **Migrations** | 36 migrations gérant l'évolution du schéma de la base de données |
| **Relations** | Relations Eloquent : `belongsTo`, `hasMany`, `belongsToMany`, `morphMany` (messagerie, notifications) |
| **Schéma principal** | 22 tables : `users`, `profiles`, `departments`, `programs`, `levels`, `students`, `teachers`, `subjects`, `classrooms`, `courses`, `schedules`, `enrollments`, `grades`, `results`, `level_results`, `notifications`, `course_resources`, `conversations`, `conversation_participants`, `messages`, `message_reactions`, `admin_invitation_codes` |

**Mécanismes de persistance côté frontend :**

| Mécanisme | Description |
|---|---|
| **Hive (cache API)** | Base NoSQL locale avec 2 boxes : `app_cache` (préférences) et `api_responses` (réponses API avec TTL). Chaque réponse est stockée avec un timestamp d'expiration. |
| **flutter_secure_storage** | Stockage chiffré via Android Keystore pour les tokens JWT (access_token, refresh_token) et les données utilisateur. |
| **shared_preferences** | Stockage simple pour les préférences non sensibles (thème, langue). |
| **flutter_cache_manager** | Cache de fichiers (images, documents) avec gestion automatique du cycle de vie. |

**Migrations principales :**

Les 36 migrations couvrent l'ensemble du schéma dans un ordre défini :
1. `users` + `cache` + `permission_tables` (tables système)
2. `profiles`, `departments`, `programs`, `levels` (structure académique)
3. `students`, `teachers`, `subjects`, `classrooms` (entités principales)
4. `courses`, `schedules`, `enrollments` (relations pédagogiques)
5. `grades`, `results`, `level_results` (évaluation)
6. `notifications`, `course_resources` (communication et ressources)
7. `messaging_tables` (conversations, participants, messages, réactions)
8. `admin_invitation_codes` (gestion des accès admin)
9. Migrations d'évolution (ajout de colonnes : `decision`, `status`, `is_public`, `attachments`, `thumbnail_path`, etc.)

---

## 3. Diagrammes UML (description textuelle)

### 3.1 Diagramme de contexte (Use Case)

| Cas d'utilisation | Priorité | Description |
|---|---|---|
| **Authentification** | Critique | Connexion avec email/mot de passe, inscription étudiant (numéro étudiant + date naissance), inscription enseignant (numéro enseignant + email), inscription admin (code d'invitation), déconnexion, rafraîchissement JWT |
| **Gestion des étudiants** | Haute | CRUD complet : liste paginée avec recherche, création, modification, suppression, attribution automatique de numéro d'étudiant |
| **Gestion des enseignants** | Haute | CRUD complet : liste paginée avec recherche, création, modification, suppression |
| **Gestion des départements** | Haute | CRUD avec code unique auto-généré, liste paginée |
| **Gestion des programmes** | Haute | CRUD avec code unique, association aux départements, liste paginée |
| **Gestion des matières** | Haute | CRUD avec code unique, association aux programmes/niveaux, heures, statut |
| **Gestion des cours** | Haute | CRUD avec association matière/enseignant/niveau/salle, statut (ouverture/fermeture) |
| **Gestion des salles** | Haute | CRUD avec code unique, type (TD/TP/CM), capacité |
| **Gestion des emplois du temps** | Haute | CRUD des séances avec association cours/salle/enseignant/groupe, filtres par niveau/jour |
| **Gestion des inscriptions** | Haute | CRUD des inscriptions aux cours, filtres par programme/niveau/statut |
| **Saisie des notes** | Haute | Saisie individuelle et par lot (batch) avec coefficients, types (CC/TP/Examen), commentaires |
| **Calcul des résultats** | Haute | Calcul automatique des moyennes, décisions (admis/ajourné), mentions, publication |
| **Consultation du dashboard** | Haute | Statistiques avec KPI, graphiques d'évolution, distribution des programmes, inscriptions récentes |
| **Gestion des ressources** | Moyenne | Upload/Download de fichiers (PDF, vidéos, images) avec miniatures, organisation par cours |
| **Messagerie instantanée** | Moyenne | Conversations privées et publiques, messages avec réactions, pièces jointes |
| **Notifications** | Moyenne | Notifications système avec compteur de non-lues, marquage comme lu |
| **Recherche globale** | Moyenne | Recherche multi-entités (étudiants, enseignants, cours, etc.) |
| **Génération de rapports** | Basse | Export PDF/Excel des listes d'étudiants, notes, résultats |
| **Sauvegarde système** | Basse | Création de sauvegardes de la base de données |
| **Changement de mot de passe** | Moyenne | Modification du mot de passe avec confirmation |
| **Réinitialisation de mot de passe** | Basse | Envoi d'email de réinitialisation, validation par token |
| **Codes d'invitation admin** | Basse | Génération et distribution de codes pour l'inscription des administrateurs |

### 3.2 Diagramme de classes

#### Frontend - Modèles principaux

**`UserModel`**

| Élément | Détail |
|---|---|
| **Attributs** | `id`, `code`, `name`, `email`, `phone`, `avatar`, `status`, `role`, `emailVerifiedAt`, `createdAt`, `updatedAt` |
| **Méthodes** | `fromJson()`, `toJson()`, `copyWith()`, `isAdmin()`, `isTeacher()`, `isStudent()` |
| **Relations** | Utilisé par `AuthService`, `AuthNotifier` |

**`CourseModel`**

| Élément | Détail |
|---|---|
| **Attributs** | `id`, `subjectId`, `subjectName`, `teacherId`, `teacherName`, `levelId`, `levelName`, `classroomId`, `classroomName`, `semester`, `academicYear`, `code`, `status`, `createdAt`, `updatedAt` |
| **Méthodes** | `fromJson()`, `toJson()`, `copyWith()` |
| **Relations** | Agrège `SubjectModel`, `TeacherModel`, `LevelModel`, `ClassroomModel` par ID et nom |

**`StudentModel`**

| Élément | Détail |
|---|---|
| **Attributs** | `id`, `code`, `userId`, `studentNumber`, `dateOfBirth`, `address`, `phone`, `enrollmentDate`, `programId`, `levelId`, `programName`, `levelName`, `firstName`, `lastName`, `email`, `createdAt`, `updatedAt` |
| **Méthodes** | `fromJson()`, `toJson()`, `copyWith()`, `fullName()` |
| **Relations** | Référence `UserModel` (userId), `ProgramModel` (programId), `LevelModel` (levelId) |

**`ScheduleModel`**

| Élément | Détail |
|---|---|
| **Attributs** | `id`, `code`, `levelId`, `levelName`, `courseId`, `courseName`, `classroomId`, `classroomName`, `teacherId`, `teacherName`, `dayOfWeek`, `startTime`, `endTime`, `session`, `group`, `status`, `date` |
| **Méthodes** | `fromJson()`, `toJson()`, `copyWith()` |
| **Relations** | Référence `LevelModel`, `CourseModel`, `ClassroomModel`, `TeacherModel` |

**`GradeModel`**

| Élément | Détail |
|---|---|
| **Attributs** | `id`, `enrollmentId`, `subjectName`, `code`, `gradeType`, `grade`, `coefficient`, `comment`, `gradedBy`, `gradedByName` |
| **Méthodes** | `fromJson()` (résolution via enrollment → course → subject), `toJson()`, `copyWith()` |
| **Relations** | Référence `EnrollmentModel` (enrollmentId), `UserModel` (gradedBy) |

**`DashboardStatsModel`**

| Élément | Détail |
|---|---|
| **Attributs** | `totalStudents`, `totalTeachers`, `totalPrograms`, `totalCourses`, `totalDepartments`, `totalClassrooms`, `activeEnrollments`, `pendingResults` |
| **Sous-modèles** | `ProgramDistribution` (name, count, percentage), `GradeEvolution` (period, average, max, min), `RecentEnrollment` (studentName, programName, status...) |
| **Méthodes** | `fromJson()`, `toJson()`, `copyWith()` |

#### Frontend - Providers (StateNotifier)

**`AuthNotifier`**

| Élément | Détail |
|---|---|
| **État** | `AuthState` avec `status`, `user`, `error`, `token` |
| **Méthodes** | `checkAuth()`, `login()`, `registerStudent()`, `registerTeacher()`, `registerAdmin()`, `logout()`, `updateProfile()`, `changePassword()` |
| **Dépendances** | `AuthService`, `StorageService` |

**`CourseNotifier`**

| Élément | Détail |
|---|---|
| **État** | `CourseState` avec `courses`, `selectedCourse`, `isLoading`, `error`, `currentPage`, `lastPage`, `total` |
| **Méthodes** | `loadCourses()`, `createCourse()`, `updateCourse()`, `deleteCourse()`, `setSelectedCourse()` |
| **Dépendances** | `DioClient` |

#### Backend - Modèles Eloquent

**`User` (Eloquent)**

| Élément | Détail |
|---|---|
| **Table** | `users` |
| **Attributs** | `id`, `code`, `name`, `email`, `password`, `phone`, `avatar`, `status`, `role`, `email_verified_at`, `remember_token` |
| **Relations** | `hasOne(Profile)`, `hasOne(Student)`, `hasOne(Teacher)`, `belongsToMany(Role)` (Spatie) |
| **Traits** | `HasApiTokens` (JWT), `HasRoles` (Spatie) |

**`Student` (Eloquent)**

| Élément | Détail |
|---|---|
| **Table** | `students` |
| **Attributs** | `id`, `code`, `user_id`, `student_number`, `date_of_birth`, `address`, `phone`, `enrollment_date`, `program_id`, `level_id` |
| **Relations** | `belongsTo(User)`, `belongsTo(Program)`, `belongsTo(Level)`, `hasMany(Enrollment)`, `hasMany(Result)` |

**`Course` (Eloquent)**

| Élément | Détail |
|---|---|
| **Table** | `courses` |
| **Attributs** | `id`, `code`, `subject_id`, `teacher_id`, `level_id`, `classroom_id`, `semester`, `academic_year`, `status` |
| **Relations** | `belongsTo(Subject)`, `belongsTo(Teacher)`, `belongsTo(Level)`, `belongsTo(Classroom)`, `hasMany(Enrollment)`, `hasMany(Schedule)`, `hasMany(CourseResource)` |

**`Grade` (Eloquent)**

| Élément | Détail |
|---|---|
| **Table** | `grades` |
| **Attributs** | `id`, `code`, `enrollment_id`, `grade_type`, `grade_value`, `coefficient`, `comment`, `graded_by` |
| **Relations** | `belongsTo(Enrollment)`, `belongsTo(User, graded_by)` |

**`Schedule` (Eloquent)**

| Élément | Détail |
|---|---|
| **Table** | `schedules` |
| **Attributs** | `id`, `code`, `level_id`, `course_id`, `classroom_id`, `teacher_id`, `day_of_week`, `start_time`, `end_time`, `session`, `group`, `status`, `date` |
| **Relations** | `belongsTo(Level)`, `belongsTo(Course)`, `belongsTo(Classroom)`, `belongsTo(Teacher)` |

### 3.3 Diagramme de séquence

#### Scénario : Connexion d'un utilisateur et chargement du tableau de bord

| Étape | Émetteur | Récepteur | Action |
|---|---|---|---|
| 1 | Utilisateur | `LoginScreen` (UI) | Saisit email et mot de passe, appuie sur « Connexion » |
| 2 | `LoginScreen` | `AuthNotifier` | Appelle `login(email, password)` |
| 3 | `AuthNotifier` | `AuthService` | Appelle `login(email, password)` |
| 4 | `AuthService` | `DioClient` | Effectue une requête POST vers `/api/auth/login` |
| 5 | `DioClient` | Serveur Laravel | Envoie `{email, password}` au endpoint JWT |
| 6 | Serveur Laravel | Base PostgreSQL | Vérifie les identifiants dans la table `users` |
| 7 | Base PostgreSQL | Serveur Laravel | Retourne l'utilisateur si les identifiants sont valides |
| 8 | Serveur Laravel | `DioClient` | Génère JWT (access_token + refresh_token), retourne `{success, data: {access_token, user}}` |
| 9 | `AuthService` | `StorageService` | Sauvegarde `access_token` et `refresh_token` dans `flutter_secure_storage` |
| 10 | `AuthNotifier` | `AuthState` | Met à jour l'état : `status = authenticated`, `user = UserModel` |
| 11 | `GoRouter` (redirect) | `App` | Détecte l'authentification, redirige vers le dashboard du rôle (`/admin/dashboard`, `/teacher/dashboard` ou `/student/dashboard`) |
| 12 | `DashboardScreen` | `DashboardNotifier` | Appelle `loadDashboard()` (ou `loadTeacherDashboard()` / `loadStudentDashboard()`) |
| 13 | `DashboardNotifier` | `DioClient` | Effectue une requête GET vers `/api/admin/dashboard/stats` (ou équivalent par rôle) avec Bearer token |
| 14 | `DioClient` (intercepteur) | Headers | Attache le token JWT : `Authorization: Bearer <token>` |
| 15 | Serveur Laravel | Contrôleur | Vérifie le JWT via le middleware `auth:api`, puis le rôle via `role:admin/teacher/student` |
| 16 | Contrôleur | Service | `DashboardService` agrège les statistiques (total étudiants, enseignants, cours, inscriptions actives...) |
| 17 | Service | Modèles Eloquent | Exécute les requêtes SQL via l'ORM (COUNT, GROUP BY, JOIN) |
| 18 | Contrôleur | `DashboardResource` | Transforme les données en format JSON standardisé |
| 19 | `DioClient` | `DashboardNotifier` | Retourne les données structurées |
| 20 | `DashboardNotifier` | `DashboardState` | Met à jour l'état avec `DashboardStatsModel` et `isLoading = false` |
| 21 | `DashboardScreen` | UI | Affiche les KPI, graphiques (`fl_chart`), et liste des inscriptions récentes |

#### Scénario : Saisie de notes par lot (batch) par un enseignant

| Étape | Émetteur | Récepteur | Action |
|---|---|---|---|
| 1 | Enseignant | `GradeInputScreen` | Sélectionne un cours et un type d'évaluation |
| 2 | `GradeInputScreen` | `GradeNotifier` | Appelle `loadGrades(courseId, gradeType)` |
| 3 | `GradeNotifier` | `DioClient` | GET `/api/teacher/grades?course_id=X&grade_type=CC` |
| 4 | `GradeInputScreen` | UI | Affiche un tableau des étudiants avec champs de saisie |
| 5 | Enseignant | `GradeInputScreen` | Saisit les notes pour chaque étudiant |
| 6 | `GradeInputScreen` | `GradeNotifier` | Appelle `storeBatch(grades: [{enrollment_id, grade_value, comment}])` |
| 7 | `GradeNotifier` | `DioClient` | POST `/api/teacher/grades/batch` avec les données |
| 8 | Serveur Laravel | `GradeService` | Valide et enregistre chaque note dans la table `grades` |
| 9 | `GradeService` | Base PostgreSQL | INSERT INTO `grades` (batch transaction) |
| 10 | Serveur Laravel | `DioClient` | Retourne `{success: true, message, data}` |
| 11 | `GradeNotifier` | `GradeState` | Recharge les notes mises à jour |

---

## 4. Bibliographie

### Framework et langages

- **Flutter 3.44 Documentation** — https://docs.flutter.dev/
  Guide officiel du framework UI cross-platform de Google. Référence pour les widgets, le rendu, la compilation et le déploiement.

- **Dart 3.12 Documentation** — https://dart.dev/guides
  Langage de programmation utilisé par Flutter. Documentation sur le typage, l'asynchrone (async/await, Streams, Futures), et les isolate.

- **Laravel 12 Documentation** — https://laravel.com/docs/12.x
  Framework PHP utilisé pour le backend. Référence pour Eloquent ORM, les migrations, les middlewares, les events/listeners, les notifications, et le filesystem.

- **PHP 8.2 Documentation** — https://www.php.net/docs.php
  Langage serveur utilisé par le backend. Documentation sur les types, les attributs, les énumérations natives.

### Base de données

- **PostgreSQL 16 Documentation** — https://www.postgresql.org/docs/16/
  Système de gestion de base de données relationnelle. Référence pour le langage SQL, les index, les transactions et les fonctions avancées.

### Bibliothèques frontend

- **Riverpod 2.x Documentation** — https://riverpod.dev/
  Solution de gestion d'état pour Flutter. Utilisé avec les patterns `StateNotifierProvider`, `StreamProvider`, `FutureProvider` et l'injection de dépendances.

- **GoRouter 14.x Documentation** — https://pub.dev/packages/go_router
  Routeur déclaratif pour Flutter avec support de la redirection conditionnelle, des routes imbriquées et de la navigation profonde.

- **Dio 5.x Documentation** — https://pub.dev/packages/dio
  Client HTTP pour Dart avec intercepteurs (authentification JWT, retry, logging), gestion des timeouts, upload multipart et download avec progression.

- **Hive 2.x Documentation** — https://pub.dev/packages/hive
  Base de données NoSQL locale légère pour Flutter/Dart. Utilisée pour le cache des réponses API avec TTL et le stockage de préférences.

- **flutter_secure_storage Documentation** — https://pub.dev/packages/flutter_secure_storage
  Stockage sécurisé via Android Keystore pour les tokens JWT et les données sensibles.

- **fl_chart Documentation** — https://pub.dev/packages/fl_chart
  Bibliothèque de graphiques pour Flutter. Utilisée pour les diagrammes en barres, camemberts et courbes d'évolution sur le dashboard.

- **intl Documentation** — https://pub.dev/packages/intl
  Bibliothèque d'internationalisation et de formatage (dates, nombres, pluriels). Configuration locale `fr_FR`.

- **connectivity_plus Documentation** — https://pub.dev/packages/connectivity_plus
  Détection de l'état de connexion réseau (WiFi, données mobiles).

- **internet_connection_checker Documentation** — https://pub.dev/packages/internet_connection_checker
  Vérification de la connectivité Internet réelle via requêtes HTTP vers des serveurs de confiance.

- **cached_network_image Documentation** — https://pub.dev/packages/cached_network_image
  Chargement et mise en cache automatique des images réseau avec placeholder et gestion des erreurs.

### Bibliothèques backend

- **tymon/jwt-auth Documentation** — https://github.com/tymondesigns/jwt-auth
  Package d'authentification par JWT pour Laravel. Gestion des tokens d'accès et de refresh, TTL configurable.

- **spatie/laravel-permission Documentation** — https://spatie.be/docs/laravel-permission/v6/
  Gestion des rôles et permissions pour Laravel avec système de gates et middlewares.

- **barryvdh/laravel-dompdf Documentation** — https://github.com/barryvdh/laravel-dompdf
  Génération de documents PDF à partir de vues HTML/blade. Utilisé pour l'export des relevés de notes et procès-verbaux.

- **maatwebsite/excel Documentation** — https://docs.laravel-excel.com/
  Import et export de fichiers Excel pour Laravel. Utilisé pour les rapports et exports de données.

- **darkaonline/l5-swagger Documentation** — https://github.com/DarkaOnLine/L5-Swagger
  Génération de documentation Swagger/OpenAPI pour les API Laravel.

### Architecture et conception

- **Material Design 3 Documentation** — https://m3.material.io/
  Guide de conception Material You de Google. Thème dynamique avec couleurs adaptatives, composants Material 3 (NavigationDrawer, TopAppBar, etc.).

- **REST API Design** — https://restfulapi.net/
  Principes de conception d'API RESTful : ressources, méthodes HTTP, codes de statut, pagination.

- **JWT (JSON Web Token) Specification** — https://jwt.io/introduction
  RFC 7519 : Standard d'authentification par token avec signature HMAC ou RSA.
