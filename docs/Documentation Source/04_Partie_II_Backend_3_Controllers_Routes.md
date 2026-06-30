# PARTIE II (suite) — CONTRÔLEURS, REQUÊTES, RESSOURCES, ROUTES

## 9. Contrôleurs API (25 contrôleurs)

Tous les contrôleurs sont dans `app/Http/Controllers/Api/` et étendent la classe `Controller`.

### AuthController
- `POST /auth/login` — Authentification, retourne token JWT
- `POST /auth/logout` — Déconnexion, invalidation du token
- `POST /auth/refresh` — Rafraîchissement du token
- `GET /auth/me` — Informations de l'utilisateur connecté
- `POST /auth/register` — Inscription (rôle étudiant par défaut)

### ProfileController
- `GET /profile` — Profil de l'utilisateur connecté
- `PUT /profile` — Mise à jour du profil
- `PUT /profile/photo` — Upload photo de profil

### DashboardController
- `GET /dashboard/admin` — Tableau de bord administrateur
- `GET /dashboard/teacher` — Tableau de bord enseignant
- `GET /dashboard/student` — Tableau de bord étudiant

### UserController
- `GET /users` — Liste paginée des utilisateurs
- `GET /users/{id}` — Détail utilisateur
- `PUT /users/{id}` — Mise à jour utilisateur (admin)
- `DELETE /users/{id}` — Suppression utilisateur

### DepartmentController
- `CRUD complet : index, show, store, update, destroy`
- `GET /departments/{id}/statistics` — KPIs du département

### ProgramController
- `CRUD complet : index, show, store, update, destroy`
- `GET /programs/{id}/statistics` — KPIs du programme

### LevelController
- `CRUD complet : index, show, store, update, destroy`
- `GET /levels/by-program/{programId}` — Niveaux par programme

### SubjectController
- `CRUD complet : index, show, store, update, destroy`

### RoomController
- `CRUD complet : index, show, store, update, destroy`
- `GET /rooms/available` — Salles disponibles avec filtres jour/horaire
- `GET /rooms/{id}/availability` — Vérification disponibilité

### TeacherController
- `CRUD complet : index, show, store, update, destroy`
- `GET /teachers/{id}/workload` — Charge horaire
- `GET /teachers/{id}/schedule` — Emploi du temps

### StudentController
- `CRUD complet : index, show, store, update, destroy`
- `GET /students/{id}/grades` — Notes de l'étudiant
- `GET /students/{id}/transcript` — Relevé de notes

### CourseController
- `CRUD complet : index, show, store, update, destroy`
- `POST /courses/{id}/publish` — Publication
- `POST /courses/{id}/unpublish` — Dépublier
- `GET /courses/by-teacher/{teacherId}` — Cours par enseignant
- `GET /courses/by-student/{studentId}` — Cours d'un étudiant

### EnrollmentController
- `CRUD complet : index, show, store, update, destroy`
- `GET /enrollments/by-student/{studentId}` — Inscriptions étudiant
- `GET /enrollments/by-course/{courseId}` — Inscriptions cours
- `GET /enrollments/course/{courseId}/students` — Étudiants inscrits
- `POST /enrollments/batch` — Inscription en masse

### GradeController
- `CRUD complet : index, show, store, update, destroy`
- `GET /grades/by-student/{studentId}` — Notes étudiant
- `GET /grades/by-subject/{subjectId}` — Notes par matière
- `POST /grades/batch` — Saisie batch
- `POST /grades/validate` — Validation

### ResultController
- `CRUD complet : index, show, store, update, destroy`
- `GET /results/by-student/{studentId}` — Résultats étudiant
- `GET /results/by-level/{levelId}` — Résultats par niveau
- `GET /results/{id}/transcript` — Génération bulletin PDF
- `GET /results/statistics/{levelId}` — Statistiques

### ScheduleController
- `CRUD complet : index, show, store, update, destroy`
- `GET /schedule/weekly` — Planning hebdomadaire avec filtres
- `GET /schedule/by-room/{roomId}`
- `GET /schedule/by-teacher/{teacherId}`

### ConversationController
- `CRUD complet : index, show, store, update, destroy`
- `POST {id}/participants` — Ajout participants
- `DELETE {id}/participants/{userId}` — Retrait participant
- `POST {id}/read` — Marquer comme lu

### MessageController
- `CRUD complet : index, show, store, update, destroy`
- `GET /messages/by-conversation/{conversationId}` — Messages d'une conversation

### MessageReactionController
- `GET /reactions/by-message/{messageId}`
- `POST /reactions` — Ajout réaction
- `DELETE /reactions/{messageId}` — Suppression réaction

### ResourceController
- `CRUD complet : index, show, store, update, destroy`

### NotificationController
- `GET /notifications` — Liste notifications
- `GET /notifications/unread-count` — Compteur non lues
- `POST /notifications/{id}/read` — Marquer comme lue
- `POST /notifications/read-all` — Tout marquer lu
- `DELETE /notifications/{id}` — Supprimer

### SearchController
- `GET /search` — Recherche unifiée multi-entités

### ReportController
- `GET /reports/student/{studentId}` — Bulletin PDF étudiant
- `GET /reports/class/{levelId}` — Relevé classe PDF
- `GET /reports/student-list/{programId}` — Liste étudiants Excel
- `GET /reports/grades/{courseId}` — Relevé notes Excel

### ActivityLogController
- `GET /activity-logs` — Liste paginée des logs d'activité

## 10. Form Requests (30+ classes de validation)

Structure : `app/Http/Requests/` — chaque requête contient `authorize()` + `rules()` avec messages personnalisés.

Exemples :
- `StoreDepartmentRequest`, `UpdateDepartmentRequest`
- `StoreProgramRequest`, `UpdateProgramRequest`
- `StoreLevelRequest`, `UpdateLevelRequest`
- `StoreSubjectRequest`, `UpdateSubjectRequest`
- `StoreRoomRequest`, `UpdateRoomRequest`
- `StoreTeacherRequest`, `UpdateTeacherRequest`
- `StoreStudentRequest`, `UpdateStudentRequest`
- `StoreCourseRequest`, `UpdateCourseRequest`
- `StoreEnrollmentRequest`, `UpdateEnrollmentRequest`
- `StoreGradeRequest`, `UpdateGradeRequest`, `BatchGradeRequest`
- `StoreResultRequest`, `UpdateResultRequest`
- `StoreScheduleRequest`, `UpdateScheduleRequest`
- `StoreConversationRequest`
- `StoreMessageRequest`
- `StoreResourceRequest`, `UpdateResourceRequest`
- `RegisterRequest`, `LoginRequest`, `UpdateProfileRequest`, `UpdateUserRequest`

Chaque requête inclut :
- Vérification d'autorisation (`authorize()` basé sur Spatie roles)
- Règles de validation complètes (`rules()`)
- Messages d'erreur personnalisés en français/anglais
- Validation des contraintes métier (unicité, existance, cohérence)

## 11. API Resources (20 resources JSON)

Structure : `app/Http/Resources/` — transformation des modèles en JSON standardisé.

Chaque resource expose :
- `toArray($request)` — Champs exposés, formatés
- Clés standardisées : `id`, `type`, `attributes`, `relationships`

Resources :
- `UserResource`, `UserCollection`
- `ProfileResource`
- `DepartmentResource`, `DepartmentCollection`
- `ProgramResource`, `ProgramCollection`
- `LevelResource`, `LevelCollection`
- `SubjectResource`, `SubjectCollection`
- `RoomResource`, `RoomCollection`
- `TeacherResource`, `TeacherCollection`
- `StudentResource`, `StudentCollection`
- `CourseResource`, `CourseCollection`
- `EnrollmentResource`, `EnrollmentCollection`
- `GradeResource`, `GradeCollection`
- `ResultResource`, `ResultCollection`
- `ScheduleResource`, `ScheduleCollection`
- `ConversationResource`, `ConversationCollection`
- `MessageResource`, `MessageCollection`
- `MessageReactionResource`
- `ResourceResource` (ressource pédagogique)
- `NotificationResource`
- `ActivityLogResource`

## 12. Authentification JWT

Package : `tymon/jwt-auth` v2.1

Configuration `config/jwt.php` :
- **TTL** : 60 minutes (token)
- **Refresh TTL** : 20160 minutes (14 jours)
- **Algorithme** : HS256
- **Clé** : Base64 encodée, générée (`php artisan jwt:secret`)
- **Provider** : `auth.providers.users`

Le middleware `jwt.auth` protège toutes les routes authentifiées.
Le middleware `jwt.refresh` rafraîchit automatiquement le token à chaque requête.
Les routes d'auth (`login`, `register`) sont publiques.

## 13. RBAC — Spatie Permission v6

### Rôles prédéfinis (3 rôles)
1. **Super Admin** — Accès complet à toutes les routes
2. **Teacher** — Gestion des cours, notes, ressources, messagerie
3. **Student** — Consultation des notes, emploi du temps, ressources, messagerie

### Permissions par rôle

**Super Admin** (toutes permissions) :
- `manage-users`, `manage-departments`, `manage-programs`, `manage-levels`, `manage-subjects`, `manage-rooms`, `manage-teachers`, `manage-students`, `manage-courses`, `manage-enrollments`, `manage-grades`, `manage-results`, `manage-schedules`, `manage-conversations`, `manage-resources`, `manage-notifications`, `view-dashboard`, `view-reports`, `search-all`

**Teacher** :
- `view-courses`, `manage-course-own`, `view-students`, `manage-grades`, `manage-results-view`, `manage-schedules-view`, `manage-conversations`, `manage-resources`, `view-dashboard`

**Student** :
- `view-courses`, `view-grades-own`, `view-results-own`, `view-schedule-own`, `manage-conversations`, `view-resources`, `view-dashboard`

### Seeders de permissions
- `PermissionSeeder` — Crée toutes les permissions
- `RoleSeeder` — Crée les rôles et assigne les permissions
- `AdminSeeder` — Crée le super admin

## 14. Routes API (150+ endpoints)

Fichier : `routes/api.php`

Structure des routes par préfixe :
```
/api/auth/...          → AuthController (public + auth)
/api/profile/...       → ProfileController (auth)
/api/dashboard/...     → DashboardController (auth, role)
/api/users/...         → UserController (admin)
/api/departments/...   → DepartmentController (admin)
/api/programs/...      → ProgramController (admin)
/api/levels/...        → LevelController (admin)
/api/subjects/...      → SubjectController (admin)
/api/rooms/...         → RoomController (admin)
/api/teachers/...      → TeacherController (admin)
/api/students/...      → StudentController (admin)
/api/courses/...       → CourseController (teacher+)
/api/enrollments/...   → EnrollmentController (admin+teacher)
/api/grades/...        → GradeController (teacher+)
/api/results/...       → ResultController (admin+teacher)
/api/schedules/...     → ScheduleController (teacher+)
/api/conversations/... → ConversationController (auth)
/api/messages/...      → MessageController (auth)
/api/reactions/...     → MessageReactionController (auth)
/api/resources/...     → ResourceController (auth)
/api/notifications/... → NotificationController (auth)
/api/search/...        → SearchController (auth)
/api/reports/...       → ReportController (admin+teacher)
/api/activity-logs/... → ActivityLogController (admin)
```

Protection par middleware :
- `api` + `jwt.auth` pour toutes les routes authentifiées
- `role:super-admin` pour les routes admin
- `role:teacher|super-admin` pour les routes enseignant
- `role:student` pour les routes étudiant

## 15. Événements et Écouteurs

Fichiers dans `app/Events/` et `app/Listeners/` :

### Events
1. **UserRegistered** — Déclenché après inscription
2. **GradePublished** — Notes publiées par un enseignant
3. **CourseCompleted** — Cours marqué comme terminé
4. **NewMessage** — Nouveau message dans une conversation
5. **ResultPublished** — Résultats validés par l'admin

### Listeners
1. **SendWelcomeNotification** → Envoie notification de bienvenue
2. **NotifyStudentsGradePublished** → Notifie les étudiants concernés
3. **UpdateStudentStatus** → Met à jour le statut étudiant
4. **UpdateConversationTimestamp** → Met à jour last_message_at
5. **NotifyStudentsResultPublished** → Notifie les étudiants

## 16. Notifications (Base de données)

- Utilise le channel `database` de Laravel
- Les notifications sont stockées dans la table `notifications`
- Types : info, warning, success, error
- Data JSON : `{title, message, action_url, action_text, icon}`

## 17. Politiques d'Autorisation (8 policies)

Fichiers dans `app/Policies/` :
1. **UserPolicy** — viewAny, view, create, update, delete
2. **DepartmentPolicy** — viewAny, view, create, update, delete
3. **CoursePolicy** — viewAny, view, create, update, delete (vérifie teacher_id pour modification)
4. **GradePolicy** — viewAny, view, create, update, delete
5. **ResultPolicy** — viewAny, view, create, update, delete
6. **EnrollmentPolicy** — viewAny, view, create, update, delete
7. **MessagePolicy** — viewAny, view, create, update, delete (vérifie appartenance conversation)
8. **ResourcePolicy** — viewAny, view, create, update, delete

Enregistrement dans `AuthServiceProvider.php` via `$policies` array.

## 18. Seeders et Factories

### Seeders (15 seeders)
1. `PermissionSeeder` — 20+ permissions
2. `RoleSeeder` — 3 rôles avec permissions
3. `AdminSeeder` — Compte super admin
4. `UserSeeder` — 50 utilisateurs tests
5. `DepartmentSeeder` — Départements types (Informatique, Maths, Physique, etc.)
6. `ProgramSeeder` — Programmes (Informatique, MIAGE, etc.)
7. `LevelSeeder` — Niveaux (L1, L2, L3, M1, M2)
8. `SubjectSeeder` — Matières par programme
9. `RoomSeeder` — Salles (Amphis, TD, TP)
10. `TeacherSeeder` — Enseignants avec comptes
11. `StudentSeeder` — Étudiants avec comptes
12. `CourseSeeder` — Cours avec affectations
13. `ScheduleSeeder` — Emplois du temps
14. `ConversationSeeder` — Conversations de test
15. `DatabaseSeeder` — Orchestrateur (appelle tous les seeders dans l'ordre)

### Factories (4 factories)
1. `UserFactory` — Génération utilisateurs
2. `StudentFactory` — Génération étudiants
3. `TeacherFactory` — Génération enseignants
4. `CourseFactory` — Génération cours

## 19. Tests

Structure :
- `tests/Feature/` — Tests fonctionnels API
- `tests/Unit/` — Tests unitaires services

Les tests utilisent PHPUnit avec RefreshDatabase et des assertions JSON pour valider les réponses API complètes.
