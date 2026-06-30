# PARTIE III — FRONTEND FLUTTER

## 20. Configuration et Dépendances

### pubspec.yaml — Dépendances clés
```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  
  # Routing
  go_router: ^14.6.2
  
  # HTTP Client
  dio: ^5.7.0
  
  # Local Storage
  hive: ^4.0.0
  hive_flutter: ^2.0.1
  shared_preferences: ^2.3.4
  
  # UI Components
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.2
  lottie: ^3.3.1
  fl_chart: ^0.69.2
  shimmer: ^3.0.0
  cached_network_image: ^3.4.1
  image_picker: ^1.1.2
  file_picker: ^8.1.7
  
  # Notifications
  flutter_local_notifications: ^18.0.1
  
  # Connectivity
  connectivity_plus: ^6.1.1
  internet_connection_checker: ^3.0.1
  
  # Utilities
  intl: ^0.19.0
  path_provider: ^2.1.5
  url_launcher: ^6.3.1
  share_plus: ^10.1.4
  open_file: ^3.5.10
```

### build.gradle.kts (android/app/)
```kotlin
android {
    compileSdk = 35
    defaultConfig {
        minSdk = 21
        targetSdk = 35
    }
    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

## 21. Thème Material 3

### theme_config.dart — Configuration du thème
- Mode **clair** et **foncé** supportés
- Couleurs Material 3 (seed color → palette générée dynamiquement)
- Utilisation de `google_fonts` (Poppins par défaut)
- Typographie Material 3 complète : display, headline, title, body, label
- Thème `Card`, `AppBar`, `BottomNavigationBar`, `FloatingActionButton`, `InputDecoration`, `ElevatedButton`, `OutlinedButton`, `TextButton`, `Chip`, `Switch`, `Checkbox`, `Radio`, `Slider`, `Dialog`, `SnackBar`, `BottomSheet`, `NavigationDrawer`, `TabBar`, `DataTable`, `Divider`

Configurations Material 3 activées :
- `useMaterial3: true`
- `colorSchemeSeed: Color(0xFF1565C0)` (bleu)
- `brightness: Brightness.light` / `dark`

### theme.dart — Point d'entrée
- `AppTheme` : classe statique avec `lightTheme`, `darkTheme`
- `_buildLightTheme()`, `_buildDarkTheme()`
- Application du thème via `MaterialApp(theme: ..., darkTheme: ...)`

## 22. Router et Navigation (go_router)

### router.dart — ~300 lignes de configuration

**Structure des routes** (~60 routes) :

```
/ → SplashScreen
/welcome → WelcomeScreen (choix rôle)
/login → LoginScreen
/register → RegisterScreen

/admin/ → ShellRoute (BottomNavigationBar)
  /admin/dashboard → AdminDashboardScreen
  /admin/users → AdminUsersScreen
  /admin/users/create → AdminUserFormScreen
  /admin/users/:id → AdminUserDetailScreen
  /admin/users/:id/edit → AdminUserFormScreen
  /admin/departments → AdminDepartmentsScreen
  /admin/departments/create → AdminDepartmentFormScreen
  /admin/departments/:id → AdminDepartmentDetailScreen
  /admin/programs → AdminProgramsScreen
  /admin/programs/create → AdminProgramFormScreen
  /admin/programs/:id → AdminProgramDetailScreen
  /admin/levels → AdminLevelsScreen
  /admin/levels/create → AdminLevelFormScreen
  /admin/subjects → AdminSubjectsScreen
  /admin/subjects/create → AdminSubjectFormScreen
  /admin/subjects/:id → AdminSubjectDetailScreen
  /admin/rooms → AdminRoomsScreen
  /admin/rooms/create → AdminRoomFormScreen
  /admin/rooms/:id → AdminRoomDetailScreen
  /admin/teachers → AdminTeachersScreen
  /admin/teachers/create → AdminTeacherFormScreen
  /admin/teachers/:id → AdminTeacherDetailScreen
  /admin/students → AdminStudentsScreen
  /admin/students/create → AdminStudentFormScreen
  /admin/students/:id → AdminStudentDetailScreen
  /admin/courses → AdminCoursesScreen
  /admin/courses/create → AdminCourseFormScreen
  /admin/courses/:id → AdminCourseDetailScreen
  /admin/enrollments → AdminEnrollmentsScreen
  /admin/enrollments/create → AdminEnrollmentFormScreen
  /admin/grades → AdminGradesScreen
  /admin/results → AdminResultsScreen
  /admin/results/create → AdminResultFormScreen
  /admin/results/:id → AdminResultDetailScreen
  /admin/schedules → AdminSchedulesScreen
  /admin/schedules/create → AdminScheduleFormScreen
  /admin/reports → AdminReportsScreen
  /admin/activity-logs → AdminActivityLogsScreen
  /admin/search → AdminSearchScreen

/teacher/ → ShellRoute (BottomNavigationBar)
  /teacher/dashboard → TeacherDashboardScreen
  /teacher/courses → TeacherCoursesScreen
  /teacher/courses/:id → TeacherCourseDetailScreen
  /teacher/grades → TeacherGradesScreen
  /teacher/grades/:courseId → TeacherGradeEntryScreen
  /teacher/schedule → TeacherScheduleScreen
  /teacher/students → TeacherStudentsScreen
  /teacher/messages → TeacherMessagesScreen
  /teacher/resources → TeacherResourcesScreen
  /teacher/search → TeacherSearchScreen

/student/ → ShellRoute (BottomNavigationBar)
  /student/dashboard → StudentDashboardScreen
  /student/courses → StudentCoursesScreen
  /student/courses/:id → StudentCourseDetailScreen
  /student/grades → StudentGradesScreen
  /student/schedule → StudentScheduleScreen
  /student/messages → StudentMessagesScreen
  /student/resources → StudentResourcesScreen
  /student/search → StudentSearchScreen

/messages/ → ConversationScreen
/messages/:id → MessageDetailScreen (chat)
/notifications → NotificationsScreen
/profile → ProfileScreen
```

**ShellRoute** : Utilisé pour `/admin`, `/teacher`, `/student` — préserve la BottomNavigationBar et le scaffold parent.

**Redirects** :
- `/` → `/welcome` si non connecté
- `/login` → `/admin/dashboard` si déjà connecté (selon rôle)
- Vérification du rôle pour chaque branche

## 23. Providers Riverpod (25 providers)

### Organisation
Les providers sont organisés par domaine dans `lib/providers/` :

### Auth Providers
- `authProvider` — StateNotifierProvider<AuthNotifier, AuthState> — Gère authentification, token, utilisateur courant
  - **AuthState** : `{User? user, bool isLoading, String? error, List<String> roles}`
- `authStateProvider` — Provider<AsyncValue<User?>> — État dérivé pour la navigation

### Dashboard Providers
- `adminDashboardProvider` — FutureProvider.family<AdminDashboard, void> — KPIs admin
- `teacherDashboardProvider` — FutureProvider.family<TeacherDashboard, void> — KPIs enseignant
- `studentDashboardProvider` — FutureProvider.family<StudentDashboard, void> — KPIs étudiant

### CRUD Providers (par entité)
Chaque entité suit ce pattern :
- `EntityProvider` — FutureProvider<Entity> pour un élément
- `EntityListProvider` — StateNotifierProvider pour une liste paginée/filtrée
- `EntityFormProvider` — StateNotifierProvider pour le formulaire (validation, soumission)

Entités couvertes :
- `departmentProvider`, `departmentListProvider`
- `programProvider`, `programListProvider`
- `levelProvider`, `levelListProvider`
- `subjectProvider`, `subjectListProvider`
- `roomProvider`, `roomListProvider`
- `teacherProvider`, `teacherListProvider`
- `studentProvider`, `studentListProvider`
- `courseProvider`, `courseListProvider`
- `enrollmentProvider`, `enrollmentListProvider`
- `gradeProvider`, `gradeListProvider`
- `resultProvider`, `resultListProvider`
- `scheduleProvider`, `scheduleListProvider`

### Messaging Providers
- `conversationListProvider` — Liste des conversations
- `conversationProvider` — Conversation spécifique
- `messageListProvider` — Messages d'une conversation

### Resource Provider
- `resourceListProvider` — Liste des ressources pédagogiques

### Notification Provider
- `notificationProvider` — Notifications
- `unreadCountProvider` — Compteur non lues

### Search Provider
- `searchProvider` — Recherche unifiée

### Connectivity Provider
- `connectivityProvider` — État de la connexion réseau
  - Utilise `connectivity_plus` + `internet_connection_checker`
  - Trois états : connected, disconnected, checking

### Theme Provider
- `themeModeProvider` — StateProvider<ThemeMode> — light/dark/system

### Cache Providers
- `cacheProvider` — Gestion du cache Hive
- Invalidation automatique basée sur TTL

## 24. Services Flutter (3 services)

### AuthService (lib/services/auth_service.dart)
- `login(String email, String password)` → Appelle `POST /auth/login`, stocke token JWT
- `register(String name, String email, String password)` → Appelle `POST /auth/register` avec rôle student
- `logout()` → Supprime token, déconnecte
- `refreshToken()` → Rafraîchit JWT
- `getCurrentUser()` → Appelle `GET /auth/me`
- **Stockage** : Token stocké dans `SharedPreferences` (clé: `auth_token`)
- **Restitution** : Token injecté dans le header `Authorization: Bearer <token>` via l'intercepteur Dio

### StorageService (lib/services/storage_service.dart)
- Wrapper autour de Hive pour le cache local
- `put<T>(String key, T value, {Duration ttl})` — Stocke avec TTL optionnel
- `get<T>(String key)` — Récupère si non expiré
- `delete(String key)` — Supprime
- `clear()` — Vide tout le cache
- `getTTL(String key)` — Durée restante avant expiration

### NotificationService (lib/services/notification_service.dart)
- Initialisation de `flutter_local_notifications`
- `showNotification(int id, String title, String body, String? payload)` — Affiche notification
- `onNotificationTap` — Callback de clic sur notification
- Permissions Android + iOS gérées
- Canal de notification configuré (channel ID: `unimanager_notifications`)

## 25. Modèles Dart (19 modèles)

Tous dans `lib/models/` avec `fromJson` factory + `toJson` method :

| Modèle | Champs clés | Relations |
|--------|-------------|-----------|
| `User` | id, name, email, phone, profilePhotoPath, isActive, isOnline, roles | profile, teacher, student |
| `Profile` | id, userId, firstName, lastName, dateOfBirth, address, bio | user |
| `Department` | id, name, code, description | programs, teachers |
| `Program` | id, name, code, description, duration, departmentId, creditsTotal | levels, subjects |
| `Level` | id, name, code, programId | program |
| `Subject` | id, name, code, description, credits, coefficient, programId | program |
| `Room` | id, name, code, capacity, floor, building, type, hasProjector, hasComputers, hasAC | courses, schedules |
| `Teacher` | id, userId, employeeCode, hireDate, specialization, qualifications, maxHours, departmentId | user, department, courses |
| `Student` | id, userId, studentCode, enrollmentDate, enrollmentNumber, status, programId, currentLevelId | user, program, level, enrollments |
| `Course` | id, name, code, description, credits, coefficient, semester, academicYear, maxStudents, subjectId, teacherId, levelId, roomId, courseType, schedule, status, isPublished | subject, teacher, level, room |
| `Enrollment` | id, studentId, courseId, programId, enrollmentDate, status, gradeFinal | student, course, program |
| `Grade` | id, enrollmentId, subjectId, gradeType, score, coefficient, gradedBy, gradedAt, academicYear, semester | enrollment, subject |
| `Result` | id, studentId, levelId, academicYear, semester, totalAverage, creditsObtained, creditsTotal, mention, decision, validatedBy | student, level |
| `Schedule` | id, courseId, roomId, teacherId, dayOfWeek, startTime, endTime, startDate, endDate, isRecurring | course, room, teacher |
| `Conversation` | id, title, type, createdBy, lastMessageAt | users, messages |
| `Message` | id, conversationId, senderId, content, type, filePath, fileName, fileSize, mimeType | conversation, sender, reactions |
| `MessageReaction` | id, messageId, userId, reaction, reactionText | message, user |
| `Resource` | id, title, description, type, filePath, url, thumbnail, subjectId, uploadedBy, isPublished | subject, uploader |
| `Notification` (Dart) | id, type, data (JSON), readAt | — |

## 26. Écrans (59 écrans)

### Organisation par dossier
```
lib/screens/
├── admin/ (21 screens)
├── teacher/ (9 screens)
├── student/ (8 screens)
├── shared/ (8 screens)
├── splash_screen.dart
├── welcome_screen.dart
├── login_screen.dart
├── register_screen.dart
├── profile_screen.dart
├── notifications_screen.dart
└── not_found_screen.dart
```

### Shared Screens (8)
- `ConversationScreen` — Liste des conversations
- `MessageDetailScreen` — Chat en temps réel
- `ResourcesScreen` — Ressources pédagogiques partagées
- `SearchScreen` — Recherche unifiée
- `ProfileScreen` — Paramètres du profil
- `NotificationsScreen` — Centre de notifications
- `NotFoundScreen` — Page 404 personnalisée
- `DashboardScreen` — Base pour tableaux de bord

### Admin Screens (21)
- `AdminDashboardScreen` — KPIs, graphiques (barres, camemberts), statistiques globales
- `AdminUsersScreen` — Liste paginée des utilisateurs avec filtres
- `AdminUserFormScreen` — Création/édition utilisateur avec sélection rôles
- `AdminUserDetailScreen` — Détail utilisateur avec profil et rôles
- `AdminDepartmentsScreen` — CRUD départements
- `AdminDepartmentFormScreen` — Formulaire département
- `AdminDepartmentDetailScreen` — Détail avec statistiques
- `AdminProgramsScreen` — CRUD programmes
- `AdminProgramFormScreen` — Formulaire programme
- `AdminProgramDetailScreen` — Détail avec niveaux/matières
- `AdminLevelsScreen` — CRUD niveaux
- `AdminLevelFormScreen` — Formulaire niveau
- `AdminSubjectsScreen` — CRUD matières
- `AdminSubjectFormScreen` — Formulaire matière
- `AdminSubjectDetailScreen` — Détail matière
- `AdminRoomsScreen` — CRUD salles
- `AdminRoomFormScreen` — Formulaire salle
- `AdminRoomDetailScreen` — Détail salle
- `AdminTeachersScreen` — CRUD enseignants
- `AdminTeacherFormScreen` — Formulaire enseignant
- `AdminTeacherDetailScreen` — Détail enseignant

### Teacher Screens (9)
- `TeacherDashboardScreen` — KPIs enseignant : cours, étudiants, emploi du temps
- `TeacherCoursesScreen` — Liste des cours avec statuts
- `TeacherCourseDetailScreen` — Détail cours avec étudiants inscrits
- `TeacherGradesScreen` — Sélection cours → saisie notes
- `TeacherGradeEntryScreen` — Saisie de notes (tableau étudiants × types)
- `TeacherScheduleScreen` — Emploi du temps hebdomadaire
- `TeacherStudentsScreen` — Liste des étudiants
- `TeacherMessagesScreen` — Messagerie
- `TeacherResourcesScreen` — Ressources pédagogiques
- `TeacherSearchScreen` — Recherche

### Student Screens (8)
- `StudentDashboardScreen` — KPIs étudiant : moyenne, crédits, cours
- `StudentCoursesScreen` — Cours inscrits
- `StudentCourseDetailScreen` — Détail cours avec syllabus
- `StudentGradesScreen` — Relevé de notes
- `StudentScheduleScreen` — Emploi du temps
- `StudentMessagesScreen` — Messagerie
- `StudentResourcesScreen` — Ressources pédagogiques
- `StudentSearchScreen` — Recherche
- `StudentProfileScreen` — Profil étudiant
