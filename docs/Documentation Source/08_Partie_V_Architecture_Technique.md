# PARTIE V — ARCHITECTURE TECHNIQUE

## 51. Patterns et Principes

### SOLID — Application dans UniManager

**S — Single Responsibility Principle**
- Chaque service a une responsabilité unique : `GradeService` ne gère que les notes
- Chaque contrôleur ne gère qu'une entité
- Les Form Requests isolent la validation

**O — Open/Closed Principle**
- Services extensibles sans modification (injection de dépendances)
- Ajout de nouveaux types de notes/évaluations sans casser existant

**L — Liskov Substitution**
- API Resources interchangeables (Resource/Collection)
- Providers Riverpod homogènes

**I — Interface Segregation**
- Services métier spécifiques plutôt qu'un énorme service
- Providers atomiques

**D — Dependency Inversion**
- Les contrôleurs dépendent des services (abstractions), pas des implémentations concrètes
- Les services utilisent Eloquent (abstraction base de données)

### Clean Architecture (adaptée)

```
┌──────────────┐
│  Controllers │ ← Point d'entrée HTTP
├──────────────┤
│   Services   │ ← Logique métier
├──────────────┤
│   Models     │ ← ORM / Data Access
├──────────────┤
│  PostgreSQL  │ ← Stockage
└──────────────┘
```

### Service Layer Pattern
- Toute la logique métier est encapsulée dans des services
- Les contrôleurs sont "minces" : validation (Request) → délégation (Service) → réponse (Resource)
- Les services sont facilement testables unitairement

### Repository Pattern (via Eloquent)
- Eloquent sert de Repository
- Les queries complexes sont encapsulées dans des scopes locaux
- Eager loading explicite pour éviter N+1

## 52. Sécurité

### Authentification JWT
- **Package** : tymon/jwt-auth v2.1
- **Algorithme** : HS256 (HMAC-SHA256)
- **TTL token** : 60 minutes
- **Refresh TTL** : 14 jours
- **Stockage** : Côté client (SharedPreferences Flutter), pas de cookie
- **Transmission** : Header `Authorization: Bearer <token>` sur chaque requête

### Autorisation RBAC
- **Package** : Spatie Laravel Permission v6
- **3 rôles** : Super Admin, Teacher, Student
- **Permissions** : 20+ permissions granulaires
- **Middleware** : `role:super-admin`, `role:teacher|super-admin`
- **Policies** : 8 policies pour les autorisations par entité

### Validation des Entrées
- **Form Requests** : 30+ classes de validation dédiées
- Règles : required, unique, exists, min, max, enum, regex
- Messages d'erreur personnalisés
- Validation côté serveur uniquement (le frontend ne fait que l'affichage)

### Protection CORS
- Configuration `config/cors.php` :
  - Origins autorisés : `*` (développement) ou domaine spécifique (production)
  - Methods : GET, POST, PUT, DELETE, OPTIONS
  - Headers : Content-Type, Authorization, X-Requested-With
  - Exposed headers : Authorization
  - Support credentials

### Sécurisation des endpoints
- Middleware `jwt.auth` sur toutes les routes protégées
- Middleware `role:` pour le contrôle d'accès basé sur les rôles
- Vérification des contraintes métier dans les services (ex: un étudiant ne peut voir que ses propres notes)

## 53. Performances

### Cache
- **Backend** : Cache Laravel (prêt Redis, défaut file)
  - Cache des permissions Spatie
  - Cache des queries fréquentes (config, settings)
- **Frontend** : Hive 4.x
  - Cache des réponses API avec TTL (5 min défaut)
  - Fonctionnement hors-ligne

### Pagination
- **Backend** : `LengthAwarePaginator` sur toutes les listes
  - Paramètres : `?page=1&per_page=15&sort=created_at&order=desc`
  - Retour : `{data: [...], meta: {current_page, last_page, per_page, total}}`
- **Frontend** : Scroll infini (load more) ou pagination manuelle

### Eager Loading
- Toutes les relations chargées via `with()` pour éviter N+1
  - Ex: `Course::with(['subject', 'teacher.user', 'level', 'room'])->paginate()`

### Indexation Base de Données
- Index sur toutes les clés étrangères
- Index uniques sur les codes métier (student_code, employee_code, course_code...)
- Index composites sur les recherches fréquentes (academic_year + semester, student_id + course_id)

### Optimisations Flutter
- `const` widgets partout où possible
- `ListView.builder` (lazy loading) pour les longues listes
- `cached_network_image` pour les images
- Images redimensionnées côté backend avant upload
- Shimmer loading pour les états de chargement

## 54. Optimisations Spécifiques

### ProGuard (Android minification)
- Activation dans `build.gradle.kts` : `isMinifyEnabled = true`
- Règles ProGuard pour Hive, Dio, Flutter

### Gestion des Assets
- Images : compression avant upload backend
- Police : Google Fonts (Poppins) chargée une fois

### Lazy Loading
- Écrans chargés à la demande (go_router routes)
- Providers chargés uniquement quand consommés

### Taille APK
- minSdk 21 (couvre 95%+ des appareils)
- split APK par ABI (armeabi-v7a, arm64-v8a, x86_64)
- Optimisation des assets non utilisés

## 55. Diagrammes UML (Specifications)

### Diagramme de Cas d'Utilisation
```
Actors:
  ┌─ Super Admin ───────────────────────────────────┐
  │  Gérer utilisateurs, départements, programmes,  │
  │  niveaux, matières, salles, enseignants,        │
  │  étudiants, inscriptions, notes, résultats,     │
  │  emplois du temps, notifications, rapports      │
  └─────────────────────────────────────────────────┘
  
  ┌─ Teacher ───────────────────────────────────────┐
  │  Voir cours, gérer notes, consulter emploi      │
  │  du temps, messagerie, ressources               │
  └─────────────────────────────────────────────────┘
  
  ┌─ Student ───────────────────────────────────────┐
  │  Voir cours, notes, résultats, emploi du temps, │
  │  messagerie, ressources                         │
  └─────────────────────────────────────────────────┘
```

### Diagramme de Classes (Simplifié)
```
User ◄── Profile
User ◄── Teacher ──► Department
User ◄── Student ──► Program ◄── Department
Level ◄── Program
Subject ◄── Program
Course ◄── Subject, Teacher, Level, Room
Course ◄── Schedule
Course ◄── Enrollment ◄── Student
Enrollment ◄── Grade ◄── Subject
Student ◄── Result ◄── Level
Conversation ◄── Message ◄── MessageReaction
Subject ◄── Resource
```

### Diagramme de Séquence — Saisie de Notes
```
Teacher → Frontend: Ouvre écran saisie notes
Frontend → API: GET /courses/{id} (liste étudiants)
API → Controller: CourseController.show()
Controller → TeacherService: getCourseStudents()
TeacherService → Enrollment: where('course_id', $id)
Enrollment → DB: SELECT * FROM enrollments WHERE course_id = ?
TeacherService → Student: whereIn($ids)
Teacher → Frontend: Liste étudiants + leurs notes existantes
Teacher → Frontend: Saisit notes (CC, TP, Exam)
Frontend → API: POST /grades/batch
API → GradeController: batchStore()
GradeController → GradeService: batchCreate($gradesData)
GradeService → Grade: create() pour chaque note
GradeService → DB: INSERT INTO grades
GradeService → GradePublished: dispatch event
Event → Listener: NotifyStudentsGradePublished()
Frontend → Teacher: Confirmation + màj affichage
```

### Diagramme de Composants
```
[Flutter App] ←→ [Dio HTTP Client] ←→ [Laravel API]
                                            ↓
                                    [Service Layer]
                                            ↓
                                    [Eloquent ORM]
                                            ↓
                                    [PostgreSQL]
```

### Diagramme de Déploiement
```
┌─────────────────────────────────────────┐
│  Client Mobile                          │
│  ┌─────────────────────────────────┐   │
│  │  Flutter App                    │   │
│  │  - Hive Cache (local)           │   │
│  │  - SharedPreferences (token)    │   │
│  └──────────────┬──────────────────┘   │
│                 │ HTTPS                │
└─────────────────┼───────────────────────┘
                  │
┌─────────────────┼───────────────────────┐
│  Serveur        │                       │
│  ┌──────────────┴──────────────────┐   │
│  │  Nginx / Apache                 │   │
│  └──────────────┬──────────────────┘   │
│                 │                      │
│  ┌──────────────┴──────────────────┐   │
│  │  Laravel API                    │   │
│  │  - PHP 8.2+                     │   │
│  │  - JWT Auth                     │   │
│  │  - Spatie Permission            │   │
│  │  - Storage (uploads)            │   │
│  └──────────────┬──────────────────┘   │
│                 │                      │
│  ┌──────────────┴──────────────────┐   │
│  │  PostgreSQL 16                  │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

## 56. Améliorations Possibles (Roadmap)

### Court terme (v1.1)
- Mode hors-ligne complet avec synchronisation différée
- Notifications push (Firebase Cloud Messaging)
- Thème dark mode complet
- Traduction multilingue (FR/EN)
- Tests unitaires et widget Flutter

### Moyen terme (v1.2)
- Emploi du temps avec glisser-déposer
- Graphiques interactifs détaillés
- Export PDF avec templates personnalisables
- Scan de QR code pour présence cours
- Chat en temps réel avec WebSockets (Laravel Echo + Pusher)
- Système de fichiers cloud (S3)

### Long terme (v2.0)
- Application iOS complète (testée)
- CI/CD (GitHub Actions)
- Déploiement Docker
- Monitoring (Sentry, Laravel Telescope)
- PWA companion
- API publique pour intégrations tierces
- Intelligence Artificielle : prédiction résultats, recommandation cours
- Système de paiement en ligne (frais inscription)
