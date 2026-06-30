# PARTIE II — BACKEND LARAVEL 12

## 4. Configuration et Dépendances

### composer.json — Dépendances clés
```json
{
  "require": {
    "php": ">=8.2",
    "laravel/framework": "^12.0",
    "tymon/jwt-auth": "^2.1",
    "spatie/laravel-permission": "^6.0",
    "darkaonline/l5-swagger": "^9.1",
    "barryvdh/laravel-dompdf": "^3.1",
    "maatwebsite/laravel-excel": "^3.1",
    "laravel/sanctum": "^4.0"
  }
}
```

### Structure du répertoire config/
- **app.php** : Configuration générale de l'application
- **auth.php** : Guards et providers (JWT + web)
- **database.php** : Connexion PostgreSQL, chargement du schéma, types personnalisés
- **cors.php** : CORS configuré pour permettre au frontend Flutter
- **jwt.php** : TTL du token, refresh TTL, algorithme, clé
- **permission.php** : Spatie Permission v6 models + cache
- **sanctum.php** : Configuration Sanctum (stateful API)
- **l5-swagger.php** : Documentation API auto-générée (routes, annotations)
- **filesystems.php** : Disques locaux + S3 ready
- **logging.php** : Logs stack (daily, slack)
- **cache.php** : Redis ready, cache TTL configurable
- **mail.php** : SMTP (Mailtrap dev)
- **queue.php** : Base de données queue
- **services.php** : API externes (OpenAI, etc.)
- **session.php** : File-based session
- **hashing.php** : Bcrypt
- **view.php** : Blade views
- **broadcasting.php** : Pusher channels
- **dompdf.php** : Configuration PDF (orientation, margins, font)
- **excel.php** : Settings Laravel Excel

## 5. Architecture des Données

### Base de données PostgreSQL
Le schéma utilise des types personnalisés PostgreSQL :
- `grade_type` (enum) : cc, tp, exam, other
- `exam_type` (enum) : cc, tp, exam, other
- `week_day` (enum) : monday, tuesday, wednesday, thursday, friday, saturday
- `course_type` (enum) : magistral, tutorial, practical, lab
- `session_status` (enum) : planned, in_progress, completed, cancelled
- `mention_quality` (enum) : excellent, very_good, good, fair, sufficient, pass, fail
- `decision_type` (enum) : admitted, resit, failed
- `resource_type` (enum) : pdf, video, link, document, external_video
- `notification_type` (enum) : info, warning, success, error
- `reaction_type` (enum) : text, thumbs_up, clap, celebrate, heart, funny, confused

### Liste des 26 migrations (ordre chronologique)
1. `create_users_table` — id, name, email, password, phone, avatar, email_verified_at, is_active
2. `create_profiles_table` — user_id (FK), first_name, last_name, date_of_birth, address, bio
3. `create_permission_tables` — Spatie : permissions, roles, model_has_permissions, model_has_roles, role_has_permissions
4. `create_departments_table` — id, name, code (unique), description
5. `create_programs_table` — id, name, code (unique), description, duration, department_id (FK), credits_total
6. `create_levels_table` — id, name, code, program_id (FK)
7. `create_subjects_table` — id, name, code (unique), description, credits, coefficient, program_id (FK)
8. `create_rooms_table` — id, name, code (unique), capacity, floor, building, type (amphi/td/tp/labo), has_projector, has_computers, has_air_conditioning
9. `create_teachers_table` — id, user_id (unique FK), employee_code (unique), hire_date, specialization, qualifications, max_hours_per_week, department_id (FK)
10. `create_students_table` — id, user_id (unique FK), student_code (unique), enrollment_date, enrollment_number, status (active/graduated/suspended/expelled), program_id (FK), current_level_id (FK)
11. `create_courses_table` — id, name, code (unique), description, credits, coefficient, semester, academic_year, max_students, subject_id (FK), teacher_id (FK), level_id (FK), room_id (FK nullable), course_type (enum: magistral/tutorial/practical/lab), schedule (JSON), status (enum: planned/in_progress/completed/cancelled), is_published
12. `create_enrollments_table` — id, student_id (FK), course_id (FK nullable), program_id (FK nullable), enrollment_date, status (active/completed/dropped), grade_final
13. `create_grades_table` — id, enrollment_id (FK), subject_id (FK), grade_type (enum: cc/tp/exam/other), score, coefficient, graded_by (FK users), graded_at, academic_year, semester
14. `create_results_table` — id, student_id (FK), level_id (FK), academic_year, semester, total_average, credits_obtained, credits_total, mention (enum), decision (enum: admitted/resit/failed), validated_by (FK users)
15. `create_schedules_table` — id, course_id (FK), room_id (FK), teacher_id (FK), day_of_week (enum), start_time, end_time, start_date, end_date, is_recurring
16. `create_conversations_table` — id, title, type (direct/group), created_by (FK users), last_message_at
17. `create_conversation_user_table` — conversation_id (FK), user_id (FK), joined_at, last_read_at
18. `create_messages_table` — id, conversation_id (FK), sender_id (FK users), content, type (text/image/file), file_path, file_name, file_size, mime_type
19. `create_message_reactions_table` — id, message_id (FK), user_id (FK), reaction (enum: text/thumbs_up/clap/celebrate/heart/funny/confused), reaction_text
20. `create_resources_table` — id, title, description, type (enum: pdf/video/link/document/external_video), file_path, url, thumbnail, subject_id (FK), uploaded_by (FK users), is_published
21. `create_notifications_table` — id, type (enum), notifiable_type, notifiable_id, data (JSON), read_at
22. `create_activity_logs_table` — id, user_id (FK nullable), action, model_type, model_id, changes (JSON), ip_address, user_agent
23. `create_personal_access_tokens_table` — Sanctum tokens
24. `add_profile_photo_to_users` — Ajout du champ profile_photo_path
25. `add_is_online_to_users` — Ajout du champ is_online
26. `add_preferences_to_users` — Ajout du champ preferences (JSON)

### Relations principales entre tables
```
users ─1:1─> profile
users ─1:1─> teachers
users ─1:1─> students
departments ─1:N─> programs ─1:N─> levels
programs ─1:N─> subjects
teachers ─N:1─> departments
students ─N:1─> programs
students ─N:1─> levels
courses ─N:1─> subjects
courses ─N:1─> teachers
courses ─N:1─> levels
courses ─N:1─> rooms
enrollments ─N:1─> students ─N:1─> courses ─N:1─> programs
grades ─N:1─> enrollments ─N:1─> subjects
results ─N:1─> students ─N:1─> levels
schedules ─N:1─> courses ─N:1─> rooms ─N:1─> teachers
conversations ─N:M─> users (via conversation_user)
messages ─N:1─> conversations ─N:1─> users
message_reactions ─N:1─> messages ─N:1─> users
resources ─N:1─> subjects ─N:1─> users
```

## 6. Modèles Eloquent (22 modèles)

### User (app/Models/User.php)
- **Traits** : HasFactory, Notifiable
- **fillable** : name, email, password, phone, profile_photo_path, is_active, is_online, preferences
- **hidden** : password, remember_token
- **casts** : email_verified_at (datetime), is_active (boolean), is_online (boolean), preferences (json)
- **Relations** : hasOne(Profile), hasOne(Teacher), hasOne(Student), hasMany(Message), hasMany(Notification), hasMany(ActivityLog)
- **Accessors** : getIsTeacherAttribute(), getIsStudentAttribute(), getIsAdminAttribute() — via Spatie roles

### Profile (app/Models/Profile.php)
- **fillable** : user_id, first_name, last_name, date_of_birth, address, bio
- **casts** : date_of_birth (date)
- **Relation** : belongsTo(User)

### Department (app/Models/Department.php)
- **fillable** : name, code, description
- **Relations** : hasMany(Program), hasMany(Teacher)
- **Scopes locaux** : withProgramsCount()

### Program (app/Models/Program.php)
- **fillable** : name, code, description, duration, department_id, credits_total
- **casts** : credits_total (integer)
- **Relations** : belongsTo(Department), hasMany(Level), hasMany(Subject), hasMany(Student), hasMany(Enrollment)

### Level (app/Models/Level.php)
- **fillable** : name, code, program_id
- **Relations** : belongsTo(Program), hasMany(Student), hasMany(Course), hasMany(Result)

### Subject (app/Models/Subject.php)
- **fillable** : name, code, description, credits, coefficient, program_id
- **casts** : credits (integer), coefficient (float)
- **Relations** : belongsTo(Program), hasMany(Course), hasMany(Grade), hasMany(Resource)
- **Scopes** : withCoursesCount()

### Room (app/Models/Room.php)
- **fillable** : name, code, capacity, floor, building, type, has_projector, has_computers, has_air_conditioning
- **casts** : capacity (integer), has_projector (boolean), has_computers (boolean), has_air_conditioning (boolean)
- **Relations** : hasMany(Course), hasMany(Schedule)

### Teacher (app/Models/Teacher.php)
- **fillable** : user_id, employee_code, hire_date, specialization, qualifications, max_hours_per_week, department_id
- **casts** : hire_date (date), max_hours_per_week (integer)
- **Relations** : belongsTo(User), belongsTo(Department), hasMany(Course), hasMany(Schedule)

### Student (app/Models/Student.php)
- **fillable** : user_id, student_code, enrollment_date, enrollment_number, status, program_id, current_level_id
- **casts** : enrollment_date (date)
- **Relations** : belongsTo(User), belongsTo(Program), belongsTo(Level, 'current_level_id'), hasMany(Enrollment), hasMany(Result), hasMany(Grade)
- **Scopes** : scopeActive(), scopeByProgram()

### Course (app/Models/Course.php)
- **fillable** : name, code, description, credits, coefficient, semester, academic_year, max_students, subject_id, teacher_id, level_id, room_id, course_type, schedule (JSON), status, is_published
- **casts** : credits (integer), coefficient (float), max_students (integer), schedule (json), is_published (boolean)
- **Relations** : belongsTo(Subject), belongsTo(Teacher), belongsTo(Level), belongsTo(Room), hasMany(Enrollment), hasMany(Schedule)

### Enrollment (app/Models/Enrollment.php)
- **fillable** : student_id, course_id, program_id, enrollment_date, status, grade_final
- **casts** : enrollment_date (date), grade_final (float)
- **Relations** : belongsTo(Student), belongsTo(Course), belongsTo(Program), hasMany(Grade)

### Grade (app/Models/Grade.php)
- **fillable** : enrollment_id, subject_id, grade_type, score, coefficient, graded_by, graded_at, academic_year, semester
- **casts** : score (float), coefficient (float), graded_at (datetime)
- **Relations** : belongsTo(Enrollment), belongsTo(Subject), belongsTo(User, 'graded_by')

### Result (app/Models/Result.php)
- **fillable** : student_id, level_id, academic_year, semester, total_average, credits_obtained, credits_total, mention, decision, validated_by
- **casts** : total_average (float), credits_obtained (integer), credits_total (integer)
- **Relations** : belongsTo(Student), belongsTo(Level), belongsTo(User, 'validated_by')

### Schedule (app/Models/Schedule.php)
- **fillable** : course_id, room_id, teacher_id, day_of_week, start_time, end_time, start_date, end_date, is_recurring
- **casts** : start_time (string), end_time (string), start_date (date), end_date (date), is_recurring (boolean)
- **Relations** : belongsTo(Course), belongsTo(Room), belongsTo(Teacher)

### Conversation (app/Models/Conversation.php)
- **fillable** : title, type, created_by, last_message_at
- **casts** : last_message_at (datetime)
- **Relations** : belongsTo(User, 'created_by'), belongsToMany(User)->withPivot('joined_at', 'last_read_at'), hasMany(Message)

### Message (app/Models/Message.php)
- **fillable** : conversation_id, sender_id, content, type, file_path, file_name, file_size, mime_type
- **casts** : file_size (integer)
- **Relations** : belongsTo(Conversation), belongsTo(User, 'sender_id'), hasMany(MessageReaction)

### MessageReaction (app/Models/MessageReaction.php)
- **fillable** : message_id, user_id, reaction, reaction_text
- **Relations** : belongsTo(Message), belongsTo(User)

### Resource (app/Models/Resource.php)
- **fillable** : title, description, type, file_path, url, thumbnail, subject_id, uploaded_by, is_published
- **casts** : is_published (boolean)
- **Relations** : belongsTo(Subject), belongsTo(User, 'uploaded_by')

### Notification (app/Models/Notification.php)
- **fillable** : type, notifiable_type, notifiable_id, data, read_at
- **casts** : data (json), read_at (datetime)

### ActivityLog (app/Models/ActivityLog.php)
- **fillable** : user_id, action, model_type, model_id, changes, ip_address, user_agent
- **casts** : changes (json)
- **Relations** : belongsTo(User)

### Permission (Spatie\Models\Permission)
- Géré par Spatie Permission v6

### Role (Spatie\Models\Role)
- Géré par Spatie Permission v6

## 7. Énumérations (10 Enums PHP 8.2)

### CourseType (app/Enums/CourseType.php)
- MAGISTRAL = 'magistral' — Cours magistral
- TUTORIAL = 'tutorial' — TD
- PRACTICAL = 'practical' — TP
- LAB = 'lab' — Travaux de laboratoire

### DecisionType (app/Enums/DecisionType.php)
- ADMITTED = 'admitted' — Admis
- RESIT = 'resit' — Rattrapage
- FAILED = 'failed' — Ajourné

### ExamType (app/Enums/ExamType.php)
- CC = 'cc' — Contrôle Continu
- TP = 'tp' — Travaux Pratiques
- EXAM = 'exam' — Examen
- OTHER = 'other' — Autre

### GradeType (app/Enums/GradeType.php)
- CC = 'cc' — Note de Contrôle Continu
- TP = 'tp' — Note de TP
- EXAM = 'exam' — Note d'Examen
- OTHER = 'other' — Autre

### MentionQuality (app/Enums/MentionQuality.php)
- EXCELLENT = 'excellent' — ≥ 16
- VERY_GOOD = 'very_good' — ≥ 14
- GOOD = 'good' — ≥ 12
- FAIR = 'fair' — ≥ 11
- SUFFICIENT = 'sufficient' — ≥ 10
- PASS = 'pass' — ≥ 10 (sans mention)
- FAIL = 'fail' — < 10

### NotificationType (app/Enums/NotificationType.php)
- INFO = 'info'
- WARNING = 'warning'
- SUCCESS = 'success'
- ERROR = 'error'

### ReactionType (app/Enums/ReactionType.php)
- TEXT = 'text'
- THUMBS_UP = 'thumbs_up'
- CLAP = 'clap'
- CELEBRATE = 'celebrate'
- HEART = 'heart'
- FUNNY = 'funny'
- CONFUSED = 'confused'

### ResourceType (app/Enums/ResourceType.php)
- PDF = 'pdf'
- VIDEO = 'video'
- LINK = 'link'
- DOCUMENT = 'document'
- EXTERNAL_VIDEO = 'external_video'

### SessionStatus (app/Enums/SessionStatus.php)
- PLANNED = 'planned'
- IN_PROGRESS = 'in_progress'
- COMPLETED = 'completed'
- CANCELLED = 'cancelled'

### WeekDay (app/Enums/WeekDay.php)
- MONDAY = 'monday'
- TUESDAY = 'tuesday'
- WEDNESDAY = 'wednesday'
- THURSDAY = 'thursday'
- FRIDAY = 'friday'
- SATURDAY = 'saturday'
