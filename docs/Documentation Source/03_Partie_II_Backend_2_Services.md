# PARTIE II (suite) — SERVICES

## 8. Services Métier (22 services)

Chaque service encapsule la logique métier d'un domaine. Les contrôleurs déléguent aux services.

### AuthService (app/Services/AuthService.php)
- `login(array $credentials): array` — Authentifie l'utilisateur, retourne le token JWT + infos utilisateur + rôles
- `logout(): void` — Invalide le token JWT
- `refresh(): array` — Rafraîchit le token JWT
- `me(): User` — Retourne l'utilisateur connecté
- `register(array $data): User` — Crée un compte user, assigne le rôle 'student'

### UserService (app/Services/UserService.php)
- `getAllUsers(array $filters): LengthAwarePaginator` — Liste paginée avec filtres (role, active, search)
- `getUserById(int $id): User` — Détail utilisateur avec profile et rôles
- `updateUser(int $id, array $data): User` — Mise à jour utilisateur + synchronisation rôles
- `deleteUser(int $id): void` — Suppression utilisateur
- `getUsersByRole(string $role): Collection` — Filtrage par rôle Spatie

### DepartmentService (app/Services/DepartmentService.php)
- `getAll(array $filters): LengthAwarePaginator` — Pagination + filtre par code
- `getById(int $id): Department` — Avec programmes et enseignants
- `create(array $data): Department` — Génération auto du code si non fourni
- `update(int $id, array $data): Department`
- `delete(int $id): void` — Vérifie contraintes avant suppression
- `getStatistics(int $id): array` — KPIs : nb programmes, enseignants, étudiants

### ProgramService (app/Services/ProgramService.php)
- `getAll(array $filters): LengthAwarePaginator` — Pagination + filtre department_id
- `getById(int $id): Program` — Avec niveaux, matières, étudiants
- `create(array $data): Program`
- `update(int $id, array $data): Program`
- `delete(int $id): void`
- `getStatistics(int $id): array` — Nb niveaux, matières, étudiants

### LevelService (app/Services/LevelService.php)
- `getAll(array $filters): LengthAwarePaginator`
- `getById(int $id): Level`
- `create(array $data): Level`
- `update(int $id, array $data): Level`
- `delete(int $id): void`
- `getByProgram(int $programId): Collection` — Filtrage par programme

### SubjectService (app/Services/SubjectService.php)
- `getAll(array $filters): LengthAwarePaginator`
- `getById(int $id): Subject`
- `create(array $data): Subject`
- `update(int $id, array $data): Subject`
- `delete(int $id): void`
- `getByProgram(int $programId): Collection`

### RoomService (app/Services/RoomService.php)
- `getAll(array $filters): LengthAwarePaginator` — Filtres : type, capacity_min, building
- `getById(int $id): Room`
- `create(array $data): Room`
- `update(int $id, array $data): Room`
- `delete(int $id): void`
- `checkAvailability(int $roomId, string $day, string $startTime, string $endTime): bool` — Vérifie disponibilité salle
- `getAvailableRooms(string $day, string $startTime, string $endTime, ?string $type): Collection`

### TeacherService (app/Services/TeacherService.php)
- `getAll(array $filters): LengthAwarePaginator` — Filtres : department_id, specialization, search
- `getById(int $id): Teacher` — Avec user, département, cours
- `create(array $data): Teacher` — Crée user associé + assigne rôle 'teacher'
- `update(int $id, array $data): Teacher`
- `delete(int $id): void`
- `getWorkload(int $id): array` — Charge horaire hebdomadaire
- `getSchedule(int $id): Collection` — Emploi du temps de l'enseignant

### StudentService (app/Services/StudentService.php)
- `getAll(array $filters): LengthAwarePaginator` — Filtres : program_id, level_id, status, search
- `getById(int $id): Student` — Avec user, programme, niveau, inscriptions, notes
- `create(array $data): Student` — Crée user associé + assigne rôle 'student', génère matricule
- `update(int $id, array $data): Student`
- `delete(int $id): void`
- `generateStudentCode(): string` — Génère code unique (format: ETU-YYYY-NNNNN)
- `getGrades(int $id): Collection` — Toutes les notes de l'étudiant
- `getTranscript(int $id): array` — Relevé de notes complet

### CourseService (app/Services/CourseService.php)
- `getAll(array $filters): LengthAwarePaginator` — Filtres : subject_id, teacher_id, level_id, semester, academic_year, status, course_type
- `getById(int $id): Course` — Avec toutes les relations
- `create(array $data): Course`
- `update(int $id, array $data): Course`
- `delete(int $id): void`
- `publish(int $id): Course`
- `unpublish(int $id): Course`
- `getByTeacher(int $teacherId): Collection`
- `getByStudent(int $studentId): Collection`
- `checkConflicts(int $courseId, array $scheduleData): array` — Détection conflits horaires

### EnrollmentService (app/Services/EnrollmentService.php)
- `getAll(array $filters): LengthAwarePaginator`
- `getById(int $id): Enrollment`
- `create(array $data): Enrollment` — Inscription à un cours ou programme
- `update(int $id, array $data): Enrollment`
- `delete(int $id): void`
- `getByStudent(int $studentId): Collection`
- `getByCourse(int $courseId): Collection`
- `getEnrolledStudents(int $courseId): LengthAwarePaginator` — Liste des étudiants d'un cours
- `batchEnroll(array $studentIds, int $courseId): Collection` — Inscription en masse

### GradeService (app/Services/GradeService.php)
- `getAll(array $filters): LengthAwarePaginator` — Filtres : enrollment_id, subject_id, grade_type, academic_year, semester
- `getById(int $id): Grade`
- `create(array $data): Grade` — Saisie de note
- `update(int $id, array $data): Grade`
- `delete(int $id): void`
- `getByEnrollment(int $enrollmentId): Collection` — Notes d'une inscription
- `getByStudent(int $studentId): Collection` — Notes d'un étudiant
- `getBySubjectAndStudent(int $subjectId, int $studentId): Collection`
- `calculateAverage(array $grades): float` — Calcul moyenne pondérée
- `batchCreate(array $gradesData): Collection` — Saisie batch de notes
- `validateGrades(int $subjectId, int $studentId): array` — Validation des notes

### ResultService (app/Services/ResultService.php)
- `getAll(array $filters): LengthAwarePaginator` — Filtres : student_id, level_id, academic_year, semester, decision, mention
- `getById(int $id): Result`
- `create(array $data): Result` — Génération d'un résultat (calculé automatiquement)
- `update(int $id, array $data): Result`
- `delete(int $id): void`
- `calculateResult(int $studentId, int $levelId, string $academicYear, string $semester): array` — Calcul complet
- `getByStudent(int $studentId): Collection`
- `getByLevel(int $levelId): Collection`
- `generateTranscript(int $studentId, int $levelId, string $academicYear): array` — Bulletin PDF
- `getStatistics(int $levelId, string $academicYear, string $semester): array` — Stats par niveau
- `calculateMention(float $average): string` — Calcul mention selon seuils
- `calculateDecision(float $average): string` — Décision Admis/Rattrapage/Ajourné

### ScheduleService (app/Services/ScheduleService.php)
- `getAll(array $filters): LengthAwarePaginator`
- `getById(int $id): Schedule`
- `create(array $data): Schedule` — Vérifie conflits avant création
- `update(int $id, array $data): Schedule`
- `delete(int $id): void`
- `getByCourse(int $courseId): Collection`
- `getByRoom(int $roomId): Collection`
- `getByTeacher(int $teacherId): Collection`
- `getByDay(string $day): Collection`
- `checkRoomAvailability(int $roomId, string $day, string $startTime, string $endTime): bool`
- `checkTeacherAvailability(int $teacherId, string $day, string $startTime, string $endTime): bool`
- `getWeeklySchedule(?int $roomId, ?int $teacherId): Collection`

### ConversationService (app/Services/ConversationService.php)
- `getAll(int $userId): LengthAwarePaginator` — Conversations de l'utilisateur
- `getById(int $id): Conversation`
- `create(array $data): Conversation` — Crée conversation directe ou de groupe
- `addParticipants(int $conversationId, array $userIds): void`
- `removeParticipant(int $conversationId, int $userId): void`
- `markAsRead(int $conversationId, int $userId): void`
- `getUnreadCount(int $userId): int`

### MessageService (app/Services/MessageService.php)
- `getAll(int $conversationId): LengthAwarePaginator`
- `getById(int $id): Message`
- `create(array $data): Message` — Envoi de message (texte + fichier optionnel)
- `update(int $id, array $data): Message`
- `delete(int $id): void`
- `getBySender(int $userId): Collection`
- `uploadFile($file, string $path = 'messages'): string` — Upload avec stockage local

### MessageReactionService (app/Services/MessageReactionService.php)
- `getByMessage(int $messageId): Collection`
- `create(array $data): MessageReaction`
- `remove(int $messageId, int $userId): void`

### ResourceService (app/Services/ResourceService.php)
- `getAll(array $filters): LengthAwarePaginator` — Filtres : subject_id, type, uploaded_by, is_published
- `getById(int $id): Resource`
- `create(array $data): Resource` — Upload fichier + génération thumbnail
- `update(int $id, array $data): Resource`
- `delete(int $id): void`
- `getBySubject(int $subjectId): Collection`
- `uploadResource($file, string $type): string` — Upload avec routage par type
- `generateThumbnail($file, string $type): ?string` — Miniature vidéo/PDF

### NotificationService (app/Services/NotificationService.php)
- `getAll(int $userId): LengthAwarePaginator` — Notifications de l'utilisateur
- `getUnreadCount(int $userId): int`
- `markAsRead(int $id): void`
- `markAllAsRead(int $userId): void`
- `create(array $data): Notification`
- `delete(int $id): void`
- `sendToUser(int $userId, string $type, string $title, string $message): Notification`
- `sendToRole(string $role, string $type, string $title, string $message): void`
- `sendToAllUsers(string $type, string $title, string $message): void`

### DashboardService (app/Services/DashboardService.php)
- `getAdminDashboard(): array` — KPIs admin : nb utilisateurs, étudiants, enseignants, cours, taux réussite
- `getTeacherDashboard(int $teacherId): array` — KPIs enseignant : nb cours, étudiants, séances
- `getStudentDashboard(int $studentId): array` — KPIs étudiant : moyenne, crédits, cours en cours

### SearchService (app/Services/SearchService.php)
- `search(string $query, array $models = []): array` — Recherche unifiée multi-entités avec score de pertinence
- `searchStudents(string $query): Collection`
- `searchTeachers(string $query): Collection`
- `searchCourses(string $query): Collection`
- `searchUsers(string $query): Collection`

### ReportService (app/Services/ReportService.php)
- `generateStudentReport(int $studentId, string $academicYear): mixed` — Bulletin individuel PDF
- `generateClassReport(int $levelId, string $academicYear, string $semester): mixed` — Relevé de classe PDF
- `generateStudentList(int $programId, ?int $levelId): mixed` — Liste étudiants Excel
- `generateGradeReport(int $courseId, string $academicYear, string $semester): mixed` — Relevé notes Excel
- `exportStudentGrades(int $studentId): mixed` — Export notes Excel
