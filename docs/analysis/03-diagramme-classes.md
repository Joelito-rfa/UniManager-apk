# Diagramme de Classes UML - UniManager APP

## 1. Diagramme de classes complet

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              DIAGRAMME DE CLASSES UML                                │
│                                  UniManager APP                                       │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                       │
│  ┌──────────────────────┐          ┌──────────────────────┐                           │
│  │        User           │          │        Role           │                          │
│  ├──────────────────────┤          ├──────────────────────┤                          │
│  │ - id: int             │◄────────│ - id: int             │                          │
│  │ - name: string        │  N:N     │ - name: string        │                          │
│  │ - email: string       │          │ - guard_name: string  │                          │
│  │ - password: string    │          │ └──────────────────────┘                          │
│  │ - phone: string       │                       ▲                                     │
│  │ - avatar: string|null │                       │                                     │
│  │ - status: enum        │                       │                                     │
│  │ - email_verified_at   │          ┌──────────────────────┐                           │
│  │ - timestamps          │          │     Permission       │                           │
│  └──────┬───────────────┘          ├──────────────────────┤                           │
│         │                          │ - id: int             │                           │
│         │ 1                        │ - name: string        │                           │
│         │                          │ - guard_name: string  │                           │
│  ┌──────┴────────────────┐         └──────────────────────┘                           │
│  │   Profile (polymorphe) │                                                           │
│  ├──────────────────────┤         ┌──────────────────────┐                           │
│  │ - id: int             │         │     Department        │                           │
│  │ - user_id: int        │◄────────│──────────────────────┤                           │
│  │ - profileable_id:int  │         │ - id: int             │──────┐                    │
│  │ - profileable_type    │         │ - name: string        │      │                    │
│  └──────────────────────┘         │ - code: string        │      │                    │
│                                   │ - description: text    │      │ 1                  │
│  ┌──────────────────────┐         │ - timestamps           │      │                    │
│  │      Student          │         └──────────────────────┘      │                    │
│  ├──────────────────────┤                       ▲                │                    │
│  │ - id: int             │                       │                │                    │
│  │ - user_id: int        │───────────────────────┘                │                    │
│  │ - student_number: str │                                        │                    │
│  │ - date_of_birth: date │         ┌──────────────────────┐      │                    │
│  │ - address: text       │         │      Program          │      │                    │
│  │ - phone: string       │         ├──────────────────────┤      │                    │
│  │ - enrollment_date: dt │         │ - id: int             │      │                    │
│  │ - program_id: int     │────────►│ - name: string        │──────┤                    │
│  │ - level_id: int       │────────►│ - code: string        │      │                    │
│  │ - timestamps          │         │ - description: text    │      │                    │
│  └──────────────────────┘         │ - department_id: int   │──────┘                    │
│                                   │ - duration: int        │                          │
│  ┌──────────────────────┐         │ - timestamps           │                          │
│  │      Teacher          │         └──────────────────────┘                          │
│  ├──────────────────────┤                       ▲                                    │
│  │ - id: int             │                       │                                    │
│  │ - user_id: int        │───────────────────────┘                                    │
│  │ - teacher_number: str │                                                            │
│  │ - speciality: string  │         ┌──────────────────────┐                           │
│  │ - date_of_birth: date │         │       Level           │                          │
│  │ - address: text       │         ├──────────────────────┤                           │
│  │ - phone: string       │         │ - id: int             │                           │
│  │ - hire_date: date     │         │ - name: string        │                           │
│  │ - timestamps          │         │ - code: string        │                           │
│  └──────────┬───────────┘         │ - program_id: int     │────────►┐                  │
│             │                     │ - timestamps           │         │                  │
│             │ N                   └──────────────────────┘         │                  │
│             │                                                       │                  │
│             ▼ 1                                                    │                  │
│  ┌──────────────────────┐         ┌──────────────────────┐         │                  │
│  │       Subject         │         │      Classroom        │         │                  │
│  ├──────────────────────┤         ├──────────────────────┤         │                  │
│  │ - id: int             │         │ - id: int             │         │                  │
│  │ - name: string        │         │ - name: string        │         │                  │
│  │ - code: string        │         │ - code: string        │         │                  │
│  │ - description: text   │         │ - capacity: int       │         │                  │
│  │ - credits: int        │         │ - building: string    │         │                  │
│  │ - coefficient: float  │         │ - floor: string       │         │                  │
│  │ - program_id: int     │────────►│ - type: enum          │         │                  │
│  │ - timestamps          │         │ - timestamps          │         │                  │
│  └──────────┬───────────┘         └──────────────────────┘         │                  │
│             │                                                       │                  │
│             │ N                                                    │                  │
│             │                                                       │                  │
│  ┌──────────▼───────────────────────────────────────────────────────┴──────────────┐  │
│  │                                 Course                                            │  │
│  ├──────────────────────────────────────────────────────────────────────────────────┤  │
│  │ - id: int                                                                        │  │
│  │ - subject_id: int                                                                │  │
│  │ - teacher_id: int                                                                │  │
│  │ - classroom_id: int                                                              │  │
│  │ - semester: string                                                               │  │
│  │ - academic_year: string                                                          │  │
│  │ - group_name: string                                                             │  │
│  │ - timestamps                                                                     │  │
│  └──────────────────────────────────────────────────────────────────────────────────┘  │
│                                   │                                                    │
│                                   │ 1                                                  │
│                                   │                                                    │
│  ┌──────────────────────────────────▼──────────────────────────────────────────────┐  │
│  │                                 Schedule                                          │  │
│  ├──────────────────────────────────────────────────────────────────────────────────┤  │
│  │ - id: int                                                                        │  │
│  │ - course_id: int                                                                 │  │
│  │ - day_of_week: enum (Monday-Saturday)                                            │  │
│  │ - start_time: time                                                               │  │
│  │ - end_time: time                                                                 │  │
│  │ - type: enum (CM/TD/TP)                                                          │  │
│  │ - timestamps                                                                     │  │
│  └───┬──────────────────────────────────────────────────────────────────────────────┘  │
│      │                                                                                 │
│      │ 1                                                                               │
│      ▼                                                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│  │                              Enrollments                                          │  │
│  ├──────────────────────────────────────────────────────────────────────────────────┤  │
│  │ - id: int                                                                        │  │
│  │ - student_id: int                                                                │  │
│  │ - course_id: int                                                                 │  │
│  │ - enrollment_date: date                                                           │  │
│  │ - status: enum (active/completed/dropped)                                         │  │
│  │ - timestamps                                                                     │  │
│  └───┬──────────────────────────────────────────────────────────────────────────────┘  │
│      │                                                                                 │
│      │ 1                                                                               │
│      ▼                                                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│  │                                Grade                                              │  │
│  ├──────────────────────────────────────────────────────────────────────────────────┤  │
│  │ - id: int                                                                        │  │
│  │ - enrollment_id: int                                                             │  │
│  │ - grade_type: enum (CC/TP/Examen)                                                │  │
│  │ - grade_value: decimal(5,2)                                                       │  │
│  │ - coefficient: float                                                              │  │
│  │ - comment: text|null                                                              │  │
│  │ - graded_by: int                                                                 │  │
│  │ - timestamps                                                                     │  │
│  └──────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                       │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│  │                                Result                                             │  │
│  ├──────────────────────────────────────────────────────────────────────────────────┤  │
│  │ - id: int                                                                        │  │
│  │ - student_id: int                                                                │  │
│  │ - course_id: int                                                                 │  │
│  │ - semester: string                                                               │  │
│  │ - academic_year: string                                                          │  │
│  │ - average: decimal(5,2)                                                          │  │
│  │ - credits_obtained: int                                                          │  │
│  │ - status: enum (validated/failed)                                                │  │
│  │ - timestamps                                                                     │  │
│  │ - validated_by: int                                                              │  │
│  └──────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                       │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│  │                             Notification                                          │  │
│  ├──────────────────────────────────────────────────────────────────────────────────┤  │
│  │ - id: int                                                                        │  │
│  │ - user_id: int                                                                   │  │
│  │ - title: string                                                                  │  │
│  │ - message: text                                                                  │  │
│  │ - type: enum (info/warning/success/error)                                        │  │
│  │ - read_at: timestamp|null                                                        │  │
│  │ - timestamps                                                                     │  │
│  └──────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                       │
└─────────────────────────────────────────────────────────────────────────────────────┘

## 2. Relations et cardinalités

| Relation | Type | Cardinalité |
|----------|------|-------------|
| User - Profile | One-to-One polymorphic | 1..1 - 1..1 |
| Profile - Student | One-to-One polymorphic | 1..1 - 1..1 |
| Profile - Teacher | One-to-One polymorphic | 1..1 - 1..1 |
| User - Role | Many-to-Many | N..N |
| User - Permission | Many-to-Many | N..N |
| Department - Program | One-to-Many | 1..N |
| Program - Level | One-to-Many | 1..N |
| Program - Subject | One-to-Many | 1..N |
| Student - Program | Many-to-One | N..1 |
| Student - Level | Many-to-One | N..1 |
| Teacher - Subject | One-to-Many | 1..N |
| Subject - Course | One-to-Many | 1..N |
| Teacher - Course | One-to-Many | 1..N |
| Classroom - Course | One-to-Many | 1..N |
| Course - Schedule | One-to-Many | 1..N |
| Course - Enrollment | One-to-Many | 1..N |
| Student - Enrollment | One-to-Many | 1..N |
| Enrollment - Grade | One-to-Many | 1..N |
| Student - Result | One-to-Many | 1..N |
| Course - Result | One-to-Many | 1..N |
| User - Notification | One-to-Many | 1..N |
