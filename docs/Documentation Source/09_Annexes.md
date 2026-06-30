# ANNEXES

## Annexe A : Guide d'Installation et Déploiement

### Prérequis
- PHP 8.2+
- Composer 2.x
- PostgreSQL 16
- Flutter 3.29+ / Dart 3.x
- Node.js 20+ (optionnel, pour Laravel Mix/Assets)

### Installation Backend
```bash
git clone <repo-url>
cd backend

# Installer les dépendances PHP
composer install

# Copier la configuration
cp .env.example .env
# → Configurer DB_CONNECTION=pgsql
# → Configurer DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD
# → Configurer JWT_SECRET (sera généré)

# Générer la clé JWT
php artisan jwt:secret

# Créer la base de données
php artisan db:create  # ou créer manuellement dans PostgreSQL

# Exécuter les migrations
php artisan migrate

# Seeders (données de test + rôles/permissions)
php artisan db:seed

# Lancer le serveur
php artisan serve --host=0.0.0.0 --port=8000

# Générer la documentation Swagger
php artisan l5-swagger:generate
```

### Installation Frontend
```bash
cd frontend

# Installer les dépendances Flutter
flutter pub get

# Lancer l'application (Android)
flutter run

# Build APK de production
flutter build apk --release
```

### Configuration réseau (émulateur Android)
- L'émulateur Android accède à `localhost` via `10.0.2.2`
- Configuré dans Dio : `baseUrl: 'http://10.0.2.2:8000/api'`

## Annexe B : Référence API Complète

### Endpoints d'Authentification

| Méthode | Endpoint | Description | Auth | Rôle |
|---------|----------|-------------|------|------|
| POST | `/api/auth/login` | Connexion | Non | — |
| POST | `/api/auth/register` | Inscription (student) | Non | — |
| POST | `/api/auth/logout` | Déconnexion | Oui | Tous |
| POST | `/api/auth/refresh` | Rafraîchir token | Oui | Tous |
| GET | `/api/auth/me` | Infos utilisateur | Oui | Tous |

### Endpoints Dashboard

| Méthode | Endpoint | Description | Rôle |
|---------|----------|-------------|------|
| GET | `/api/dashboard/admin` | KPIs admin | Super Admin |
| GET | `/api/dashboard/teacher` | KPIs enseignant | Teacher |
| GET | `/api/dashboard/student` | KPIs étudiant | Student |

### Endpoints CRUD (schéma commun)

Pour chaque entité `resource` :

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/{resource}` | Liste paginée |
| GET | `/api/{resource}/{id}` | Détail |
| POST | `/api/{resource}` | Création |
| PUT | `/api/{resource}/{id}` | Mise à jour |
| DELETE | `/api/{resource}/{id}` | Suppression |

### Endpoints spécifiques

| Méthode | Endpoint | Rôle |
|---------|----------|------|
| GET | `/api/departments/{id}/statistics` | Super Admin |
| GET | `/api/programs/{id}/statistics` | Super Admin |
| GET | `/api/levels/by-program/{programId}` | Super Admin |
| GET | `/api/rooms/available` | Super Admin |
| GET | `/api/rooms/{id}/availability` | Super Admin |
| GET | `/api/teachers/{id}/workload` | Super Admin |
| GET | `/api/teachers/{id}/schedule` | Teacher+ |
| GET | `/api/students/{id}/grades` | Teacher+ |
| GET | `/api/students/{id}/transcript` | Teacher+ |
| POST | `/api/courses/{id}/publish` | Teacher+ |
| POST | `/api/courses/{id}/unpublish` | Teacher+ |
| GET | `/api/courses/by-teacher/{teacherId}` | Teacher+ |
| GET | `/api/courses/by-student/{studentId}` | Student+ |
| GET | `/api/enrollments/by-student/{studentId}` | Teacher+ |
| GET | `/api/enrollments/by-course/{courseId}` | Teacher+ |
| GET | `/api/enrollments/course/{courseId}/students` | Teacher+ |
| POST | `/api/enrollments/batch` | Super Admin |
| GET | `/api/grades/by-student/{studentId}` | Teacher+ |
| GET | `/api/grades/by-subject/{subjectId}` | Teacher+ |
| POST | `/api/grades/batch` | Teacher+ |
| POST | `/api/grades/validate` | Teacher+ |
| GET | `/api/results/by-student/{studentId}` | Student+ |
| GET | `/api/results/by-level/{levelId}` | Super Admin |
| GET | `/api/results/{id}/transcript` | Teacher+ |
| GET | `/api/results/statistics/{levelId}` | Super Admin |
| GET | `/api/schedule/weekly` | Teacher+ |
| GET | `/api/schedule/by-room/{roomId}` | Teacher+ |
| GET | `/api/schedule/by-teacher/{teacherId}` | Teacher+ |
| POST | `/api/conversations/{id}/participants` | Auth |
| DELETE | `/api/conversations/{id}/participants/{userId}` | Auth |
| POST | `/api/conversations/{id}/read` | Auth |
| GET | `/api/messages/by-conversation/{conversationId}` | Auth |
| GET | `/api/reactions/by-message/{messageId}` | Auth |
| GET | `/api/notifications/unread-count` | Auth |
| POST | `/api/notifications/{id}/read` | Auth |
| POST | `/api/notifications/read-all` | Auth |
| GET | `/api/search` | Auth |
| GET | `/api/reports/student/{studentId}` | Teacher+ |
| GET | `/api/reports/class/{levelId}` | Super Admin |
| GET | `/api/reports/student-list/{programId}` | Super Admin |
| GET | `/api/reports/grades/{courseId}` | Teacher+ |
| GET | `/api/activity-logs` | Super Admin |

## Annexe C : Structure Complète de la Base de Données

### Liste des 20 tables + 3 tables pivot + 1 table polymorphique

| Table | Type | Description |
|-------|------|-------------|
| `users` | Principale | Utilisateurs de l'application |
| `profiles` | 1:1 | Profils étendus des utilisateurs |
| `permissions` | Spatie | Permissions du système |
| `roles` | Spatie | Rôles du système |
| `model_has_permissions` | Pivot | Liaison modèle → permission |
| `model_has_roles` | Pivot | Liaison modèle → rôle |
| `role_has_permissions` | Pivot | Liaison rôle → permission |
| `departments` | Principale | Départements |
| `programs` | Principale | Programmes de formation |
| `levels` | Principale | Niveaux d'étude |
| `subjects` | Principale | Matières |
| `rooms` | Principale | Salles |
| `teachers` | Principale | Enseignants |
| `students` | Principale | Étudiants |
| `courses` | Principale | Cours |
| `enrollments` | Principale | Inscriptions |
| `grades` | Principale | Notes |
| `results` | Principale | Résultats |
| `schedules` | Principale | Emplois du temps |
| `conversations` | Principale | Conversations |
| `conversation_user` | Pivot | Participants conversation |
| `messages` | Principale | Messages |
| `message_reactions` | Principale | Réactions aux messages |
| `resources` | Principale | Ressources pédagogiques |
| `notifications` | Polymorphique | Notifications |
| `activity_logs` | Principale | Logs d'activité |
| `personal_access_tokens` | Sanctum | Tokens API |

## Annexe D : Dépendances et Versions

### Backend (composer.json — 22 packages)
| Package | Version | Utilité |
|---------|---------|---------|
| laravel/framework | ^12.0 | Framework PHP |
| tymon/jwt-auth | ^2.1 | Auth JWT |
| spatie/laravel-permission | ^6.0 | RBAC |
| darkaonline/l5-swagger | ^9.1 | Doc API |
| barryvdh/laravel-dompdf | ^3.1 | PDF |
| maatwebsite/laravel-excel | ^3.1 | Excel |
| laravel/sanctum | ^4.0 | API tokens |
| laravel/tinker | ^2.9 | REPL |
| fakerphp/faker | ^1.23 | Faker |
| mockery/mockery | ^1.6 | Mocking |
| phpunit/phpunit | ^11.0 | Tests |
| laravel/sail | ^1.26 | Docker |
| laravel/pint | ^1.13 | Code style |

### Frontend (pubspec.yaml — 20+ packages)
| Package | Version | Utilité |
|---------|---------|---------|
| flutter_riverpod | ^2.6.1 | State management |
| go_router | ^14.6.2 | Routing |
| dio | ^5.7.0 | HTTP client |
| hive | ^4.0.0 | Cache local |
| shared_preferences | ^2.3.4 | Stockage clé-valeur |
| google_fonts | ^6.2.1 | Polices |
| flutter_animate | ^4.5.2 | Animations |
| lottie | ^3.3.1 | Animations Lottie |
| fl_chart | ^0.69.2 | Graphiques |
| shimmer | ^3.0.0 | Loading |
| cached_network_image | ^3.4.1 | Images |
| image_picker | ^1.1.2 | Photos |
| file_picker | ^8.1.7 | Fichiers |
| flutter_local_notifications | ^18.0.1 | Notifications |
| connectivity_plus | ^6.1.1 | Connectivité |
| internet_connection_checker | ^3.0.1 | Vérification Internet |
| intl | ^0.19.0 | Internationalisation |
| url_launcher | ^6.3.1 | Liens externes |
| share_plus | ^10.1.4 | Partage |
| open_file | ^3.5.10 | Ouverture fichiers |

## Annexe E : Glossaire Technique

| Terme | Définition |
|-------|------------|
| **RBAC** | Role-Based Access Control — Contrôle d'accès basé sur les rôles |
| **JWT** | JSON Web Token — Token d'authentification JSON |
| **TTL** | Time To Live — Durée de validité d'un token ou cache |
| **MVVM** | Model-View-ViewModel — Pattern d'architecture Flutter |
| **Eloquent** | ORM de Laravel — Active Record pattern |
| **Form Request** | Classe de validation dédiée dans Laravel |
| **API Resource** | Transformation de modèles en JSON dans Laravel |
| **Provider** | Objet Riverpod gérant l'état et la logique |
| **ShellRoute** | Route go_router avec scaffold persistant |
| **Hive** | Base de données NoSQL locale pour Flutter |
| **Dio** | Client HTTP pour Dart/Flutter avec intercepteurs |
| **Seeder** | Classe Laravel qui peuple la base avec des données de test |
| **Factory** | Générateur de données aléatoires pour tests |
| **Policy** | Classe d'autorisation Laravel par entité |
| **Scope** | Filtre Eloquent réutilisable |
| **Observer** | Écouteur d'événements Eloquent (creating, created, etc.) |
| **Listener** | Récepteur d'événements Laravel |
| **DomPDF** | Moteur de rendu HTML → PDF pour Laravel |
| **Riverpod** | Bibliothèque de gestion d'état pour Flutter |
| **go_router** | Routeur déclaratif pour Flutter |
| **Debounce** | Technique qui retarde l'exécution après un délai d'inactivité |
| **Eager Loading** | Chargement anticipé des relations Eloquent |
| **LengthAwarePaginator** | Paginateur Laravel avec métadonnées complètes |
| **Backoff exponentiel** | Stratégie d'attente croissante entre tentatives |
| **ProGuard** | Optimiseur et obfuscateur de code Android |
