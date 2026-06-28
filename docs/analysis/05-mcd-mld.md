# Modèle Conceptuel de Données (MCD) et Modèle Logique de Données (MLD)

## 1. MCD - Modèle Conceptuel de Données

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          MODÈLE CONCEPTUEL DE DONNÉES                        │
│                                  UniManager APP                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────┐     ┌──────────┐     ┌──────────────────┐                        │
│  │ ROLE │◄────│-ASSIGN-│────►│      USER        │                        │
│  └──────┘ N   │   N:N    │ N   └──────────────────┘                        │
│              └──────────┘           │ 1                                      │
│                                     │                                        │
│  ┌──────────────┐                   │ 1                                      │
│  │ PERMISSION   │◄──────────────┐   │                                        │
│  └──────────────┘               │   ▼ 1                                     │
│                                 │ ┌──────────┐                              │
│                                 │ │ PROFILE  │◄── polymorphique ──┐         │
│                                 │ └──────────┘                    │         │
│                                 │                                 │         │
│  ┌──────────────┐     ┌──────────────────┐    ┌──────────────┐    │         │
│  │ DEPARTMENT   │─────│    PROGRAM       │────│    LEVEL     │    │         │
│  └──────────────┘ 1,N └──────────────────┘ 1,N└──────────────┘    │         │
│                               │ 1,N                               │         │
│                               │                                    │         │
│  ┌──────────────┐            │ 1,N                                │         │
│  │   SUBJECT    │◄────────────┘                                    │         │
│  └──────┬───────┘                                                  │         │
│         │ 1,N                                                      │         │
│         │                                                          │         │
│  ┌──────▼───────┐     ┌──────────────┐    ┌──────────────┐        │         │
│  │   COURSE     │─────│  CLASSROOM   │    │  TEACHER     │        │         │
│  └──────┬───────┘     └──────────────┘    └──────┬───────┘        │         │
│         │ 1,N                                     │ 1,N            │         │
│         │                                         │                │         │
│  ┌──────▼───────┐                        ┌───────▼───────┐       │         │
│  │  SCHEDULE    │                        │   STUDENT     │◄──────┘         │
│  └──────────────┘                        └───────┬───────┘                 │
│                                                   │                        │
│  ┌──────────────┐                        ┌───────▼───────┐               │
│  │  ENROLLMENT  │◄────────────────────────│               │               │
│  └──────┬───────┘    N:1 (Student)        │               │               │
│         │                                  │               │               │
│         │ N:1 (Course)                     │               │               │
│         │                                  └───────────────┘               │
│  ┌──────▼───────┐                                                         │
│  │    GRADE     │                                                         │
│  └──────────────┘                      ┌──────────────────┐              │
│                                        │     RESULT       │              │
│                                        └──────────────────┘              │
│                                                                          │
│  ┌──────────────────┐                                                    │
│  │  NOTIFICATION    │                                                    │
│  └──────────────────┘                                                    │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘

## Légende des entités

| Entité | Description |
|--------|-------------|
| USER | Compte utilisateur (authentification) |
| PROFILE | Profil polymorphe (Student/Teacher) |
| ROLE | Rôle utilisateur (Admin/Teacher/Student) |
| PERMISSION | Permission spécifique |
| DEPARTMENT | Département universitaire |
| PROGRAM | Filière/Programme d'études |
| LEVEL | Niveau d'étude (L1, L2, L3, M1, M2) |
| SUBJECT | Matière enseignée |
| COURSE | Cours (instance d'une matière) |
| CLASSROOM | Salle de cours |
| SCHEDULE | Emploi du temps (créneau) |
| TEACHER | Enseignant |
| STUDENT | Étudiant |
| ENROLLMENT | Inscription d'un étudiant à un cours |
| GRADE | Note d'un étudiant |
| RESULT | Résultat d'un étudiant par cours |
| NOTIFICATION | Notification utilisateur |

## Relations et cardinalités

| Relation | Type | Règle |
|----------|------|-------|
| USER - ROLE | N:N | Un user a plusieurs rôles, un rôle a plusieurs users |
| USER - PERMISSION | N:N | Un user a plusieurs permissions directes |
| USER - PROFILE | 1:1 | Un user a un profil (étudiant ou enseignant) |
| PROFILE - STUDENT | 1:1 | Polymorphisme : profil → étudiant |
| PROFILE - TEACHER | 1:1 | Polymorphisme : profil → enseignant |
| DEPARTMENT - PROGRAM | 1:N | Un département a plusieurs programmes |
| PROGRAM - LEVEL | 1:N | Un programme a plusieurs niveaux |
| PROGRAM - SUBJECT | 1:N | Un programme a plusieurs matières |
| TEACHER - SUBJECT | 1:N | Un enseignant enseigne plusieurs matières |
| TEACHER - COURSE | 1:N | Un enseignant donne plusieurs cours |
| SUBJECT - COURSE | 1:N | Une matière a plusieurs cours |
| CLASSROOM - COURSE | 1:N | Une salle accueille plusieurs cours |
| COURSE - SCHEDULE | 1:N | Un cours a plusieurs créneaux |
| COURSE - ENROLLMENT | 1:N | Un cours a plusieurs inscriptions |
| STUDENT - ENROLLMENT | 1:N | Un étudiant a plusieurs inscriptions |
| ENROLLMENT - GRADE | 1:N | Une inscription a plusieurs notes |
| STUDENT - RESULT | 1:N | Un étudiant a plusieurs résultats |
| USER - NOTIFICATION | 1:N | Un user a plusieurs notifications |

---

## 2. MLD - Modèle Logique de Données (Relations)

### Table : users
```
users (
    id              BIGSERIAL       PK,
    name            VARCHAR(255)    NOT NULL,
    email           VARCHAR(255)    NOT NULL    UNIQUE,
    password        VARCHAR(255)    NOT NULL,
    phone           VARCHAR(20)     NULL,
    avatar          VARCHAR(255)    NULL,
    status          ENUM('active','inactive','suspended') DEFAULT 'active',
    email_verified_at TIMESTAMP     NULL,
    remember_token  VARCHAR(100)    NULL,
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL
)
```

### Table : profiles
```
profiles (
    id              BIGSERIAL       PK,
    user_id         BIGINT          NOT NULL    FK -> users(id) ON DELETE CASCADE,
    profileable_id  BIGINT          NOT NULL,
    profileable_type VARCHAR(255)   NOT NULL,
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL,
    UNIQUE(user_id, profileable_type)
)
```

### Table : students
```
students (
    id              BIGSERIAL       PK,
    user_id         BIGINT          NOT NULL    FK -> users(id) ON DELETE CASCADE,
    student_number  VARCHAR(20)     NOT NULL    UNIQUE,
    date_of_birth   DATE            NULL,
    address         TEXT            NULL,
    phone           VARCHAR(20)     NULL,
    enrollment_date DATE            NOT NULL    DEFAULT CURRENT_DATE,
    program_id      BIGINT          NOT NULL    FK -> programs(id),
    level_id        BIGINT          NOT NULL    FK -> levels(id),
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL
)
```

### Table : teachers
```
teachers (
    id              BIGSERIAL       PK,
    user_id         BIGINT          NOT NULL    FK -> users(id) ON DELETE CASCADE,
    teacher_number  VARCHAR(20)     NOT NULL    UNIQUE,
    speciality      VARCHAR(255)    NULL,
    date_of_birth   DATE            NULL,
    address         TEXT            NULL,
    phone           VARCHAR(20)     NULL,
    hire_date       DATE            NOT NULL    DEFAULT CURRENT_DATE,
    department_id   BIGINT          NULL        FK -> departments(id),
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL
)
```

### Table : departments
```
departments (
    id              BIGSERIAL       PK,
    name            VARCHAR(255)    NOT NULL,
    code            VARCHAR(20)     NOT NULL    UNIQUE,
    description     TEXT            NULL,
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL
)
```

### Table : programs
```
programs (
    id              BIGSERIAL       PK,
    name            VARCHAR(255)    NOT NULL,
    code            VARCHAR(20)     NOT NULL    UNIQUE,
    description     TEXT            NULL,
    department_id   BIGINT          NOT NULL    FK -> departments(id) ON DELETE CASCADE,
    duration        INTEGER         NOT NULL    DEFAULT 3,
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL
)
```

### Table : levels
```
levels (
    id              BIGSERIAL       PK,
    name            VARCHAR(255)    NOT NULL,
    code            VARCHAR(20)     NOT NULL    UNIQUE,
    program_id      BIGINT          NOT NULL    FK -> programs(id) ON DELETE CASCADE,
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL
)
```

### Table : subjects
```
subjects (
    id              BIGSERIAL       PK,
    name            VARCHAR(255)    NOT NULL,
    code            VARCHAR(20)     NOT NULL    UNIQUE,
    description     TEXT            NULL,
    credits         INTEGER         NOT NULL    DEFAULT 3,
    coefficient     DECIMAL(4,2)    NOT NULL    DEFAULT 1.0,
    program_id      BIGINT          NOT NULL    FK -> programs(id) ON DELETE CASCADE,
    teacher_id      BIGINT          NULL        FK -> teachers(id) ON DELETE SET NULL,
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL
)
```

### Table : classrooms
```
classrooms (
    id              BIGSERIAL       PK,
    name            VARCHAR(255)    NOT NULL,
    code            VARCHAR(20)     NOT NULL    UNIQUE,
    capacity        INTEGER         NOT NULL,
    building        VARCHAR(255)    NULL,
    floor           VARCHAR(50)     NULL,
    type            ENUM('amphi','td','tp','labo') DEFAULT 'td',
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL
)
```

### Table : courses
```
courses (
    id              BIGSERIAL       PK,
    subject_id      BIGINT          NOT NULL    FK -> subjects(id) ON DELETE CASCADE,
    teacher_id      BIGINT          NOT NULL    FK -> teachers(id) ON DELETE CASCADE,
    classroom_id    BIGINT          NULL        FK -> classrooms(id) ON DELETE SET NULL,
    semester        VARCHAR(20)     NOT NULL,
    academic_year   VARCHAR(20)     NOT NULL,
    group_name      VARCHAR(100)    NULL,
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL,
    UNIQUE(subject_id, teacher_id, semester, academic_year, group_name)
)
```

### Table : schedules
```
schedules (
    id              BIGSERIAL       PK,
    course_id       BIGINT          NOT NULL    FK -> courses(id) ON DELETE CASCADE,
    classroom_id    BIGINT          NOT NULL    FK -> classrooms(id) ON DELETE CASCADE,
    day_of_week     ENUM('monday','tuesday','wednesday','thursday','friday','saturday') NOT NULL,
    start_time      TIME            NOT NULL,
    end_time        TIME            NOT NULL,
    type            ENUM('CM','TD','TP') DEFAULT 'CM',
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL,
    CONSTRAINT check_time CHECK (start_time < end_time)
)
```

### Table : enrollments
```
enrollments (
    id              BIGSERIAL       PK,
    student_id      BIGINT          NOT NULL    FK -> students(id) ON DELETE CASCADE,
    course_id       BIGINT          NOT NULL    FK -> courses(id) ON DELETE CASCADE,
    enrollment_date DATE            NOT NULL    DEFAULT CURRENT_DATE,
    status          ENUM('active','completed','dropped') DEFAULT 'active',
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL,
    UNIQUE(student_id, course_id)
)
```

### Table : grades
```
grades (
    id              BIGSERIAL       PK,
    enrollment_id   BIGINT          NOT NULL    FK -> enrollments(id) ON DELETE CASCADE,
    grade_type      ENUM('CC','TP','Exam') NOT NULL,
    grade_value     DECIMAL(5,2)    NOT NULL,
    coefficient     DECIMAL(4,2)    NOT NULL    DEFAULT 1.0,
    comment         TEXT            NULL,
    graded_by       BIGINT          NOT NULL    FK -> users(id),
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL,
    CONSTRAINT check_grade_value CHECK (grade_value >= 0 AND grade_value <= 20)
)
```

### Table : results
```
results (
    id              BIGSERIAL       PK,
    student_id      BIGINT          NOT NULL    FK -> students(id) ON DELETE CASCADE,
    course_id       BIGINT          NOT NULL    FK -> courses(id) ON DELETE CASCADE,
    semester        VARCHAR(20)     NOT NULL,
    academic_year   VARCHAR(20)     NOT NULL,
    average         DECIMAL(5,2)    NOT NULL,
    credits_obtained INTEGER        NOT NULL    DEFAULT 0,
    status          ENUM('validated','failed') DEFAULT 'failed',
    validated_by    BIGINT          NULL        FK -> users(id),
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL,
    UNIQUE(student_id, course_id, semester, academic_year)
)
```

### Table : notifications
```
notifications (
    id              BIGSERIAL       PK,
    user_id         BIGINT          NOT NULL    FK -> users(id) ON DELETE CASCADE,
    title           VARCHAR(255)    NOT NULL,
    message         TEXT            NOT NULL,
    type            ENUM('info','warning','success','error') DEFAULT 'info',
    read_at         TIMESTAMP       NULL,
    created_at      TIMESTAMP       NULL,
    updated_at      TIMESTAMP       NULL
)
```

## 3. Indexes recommandés

```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_profiles_profileable ON profiles(profileable_id, profileable_type);
CREATE INDEX idx_students_program_id ON students(program_id);
CREATE INDEX idx_students_level_id ON students(level_id);
CREATE INDEX idx_teachers_department_id ON teachers(department_id);
CREATE INDEX idx_programs_department_id ON programs(department_id);
CREATE INDEX idx_levels_program_id ON levels(program_id);
CREATE INDEX idx_subjects_program_id ON subjects(program_id);
CREATE INDEX idx_subjects_teacher_id ON subjects(teacher_id);
CREATE INDEX idx_courses_subject_id ON courses(subject_id);
CREATE INDEX idx_courses_teacher_id ON courses(teacher_id);
CREATE INDEX idx_schedules_course_id ON schedules(course_id);
CREATE INDEX idx_schedules_classroom_id ON schedules(classroom_id);
CREATE INDEX idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX idx_enrollments_course_id ON enrollments(course_id);
CREATE INDEX idx_grades_enrollment_id ON grades(enrollment_id);
CREATE INDEX idx_results_student_id ON results(student_id);
CREATE INDEX idx_results_course_id ON results(course_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
```
