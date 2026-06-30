# PARTIE IV — FONCTIONNALITÉS MÉTIER

## 31. Gestion des Départements

### Backend
- **Modèle** : `Department` (name, code, description)
- **Contrôleur** : `DepartmentController` (CRUD + statistiques)
- **Service** : `DepartmentService`
- **Validation** : `StoreDepartmentRequest`, `UpdateDepartmentRequest` (code unique, name requis, description max:1000)
- **Resource** : `DepartmentResource` / `DepartmentCollection`

### Frontend (Admin)
- **Screens** : `AdminDepartmentsScreen` (liste avec pagination), `AdminDepartmentFormScreen` (création/édition), `AdminDepartmentDetailScreen` (détail + stats)
- **Provider** : `departmentListProvider`, `departmentProvider`, `departmentFormProvider`

### Règles métier
- Code auto-généré si non fourni (ex: `DEPT-{random3chars}`)
- Suppression impossible si des programmes ou enseignants sont rattachés
- KPIs : nombre de programmes, enseignants, étudiants

## 32. Gestion des Programmes

### Backend
- **Modèle** : `Program` (name, code, description, duration, department_id, credits_total)
- **Contrôleur** : `ProgramController`
- **Service** : `ProgramService`
- **Validation** : code unique, department_id existe, duration ≥ 1

### Frontend (Admin)
- **Screens** : `AdminProgramsScreen`, `AdminProgramFormScreen`, `AdminProgramDetailScreen`

### Règles métier
- Lié à un département (FK obligatoire)
- credits_total = somme des crédits de toutes les matières
- Suppression impossible avec étudiants actifs

## 33. Gestion des Niveaux

### Backend
- **Modèle** : `Level` (name, code, program_id)
- **Contrôleur** : `LevelController` (CRUD + byProgram)
- **Service** : `LevelService`

### Frontend (Admin)
- **Screens** : `AdminLevelsScreen`, `AdminLevelFormScreen`

### Règles métier
- Appartient à un programme
- Code unique par programme (ex: L1, L2, L3, M1, M2)
- Un niveau peut avoir plusieurs étudiants, cours, résultats

## 34. Gestion des Matières

### Backend
- **Modèle** : `Subject` (name, code, description, credits, coefficient, program_id)
- **Contrôleur** : `SubjectController`
- **Service** : `SubjectService`

### Frontend (Admin)
- **Screens** : `AdminSubjectsScreen`, `AdminSubjectFormScreen`, `AdminSubjectDetailScreen`

### Règles métier
- Coefficient : 1.0 par défaut (float)
- Credits : entier, chaque matière contribue au total du programme
- Liée à un programme
- Peut avoir plusieurs cours (magistral + TD + TP)

## 35. Gestion des Cours

### Backend
- **Modèle** : `Course` (champs complets avec schedule JSON, status, course_type enum)
- **Contrôleur** : `CourseController` (CRUD + publish/unpublish + byTeacher/byStudent)
- **Service** : `CourseService` (inclut détection conflits horaires)
- **Validation** : Chevauchements horaires, capacité salle, charge max enseignant

### Frontend (Admin + Teacher)
- **Screens Admin** : `AdminCoursesScreen`, `AdminCourseFormScreen`, `AdminCourseDetailScreen`
- **Screens Teacher** : `TeacherCoursesScreen`, `TeacherCourseDetailScreen`
- **Screens Student** : `StudentCoursesScreen`, `StudentCourseDetailScreen`

### Règles métier
- Un cours est lié à : matière, enseignant, niveau, salle (optionnelle)
- Types : magistral, TD, TP, laboratoire
- Statuts : planifié, en cours, terminé, annulé
- Publication : un cours non publié n'est pas visible pour les étudiants
- Détection des conflits : même salle même créneau, même enseignant même créneau

## 36. Gestion des Salles

### Backend
- **Modèle** : `Room` (name, code, capacity, floor, building, type, équipements)
- **Contrôleur** : `RoomController` (CRUD + disponibilité + available)
- **Service** : `RoomService`

### Frontend (Admin)
- **Screens** : `AdminRoomsScreen`, `AdminRoomFormScreen`, `AdminRoomDetailScreen`

### Types de salle
- **Amphi** : Grand amphithéâtre
- **TD** : Salle de travaux dirigés
- **TP** : Salle de travaux pratiques
- **Labo** : Laboratoire

### Règles métier
- Capacité : entier positif
- Vérification disponibilité par créneau (jour + horaire)
- Suppression impossible si des cours ou séances y sont planifiés

## 37. Gestion des Étudiants

### Backend
- **Modèle** : `Student` (user_id, student_code, enrollment_date, enrollment_number, status, program_id, current_level_id)
- **Contrôleur** : `StudentController` (CRUD + grades + transcript)
- **Service** : `StudentService`
- **Génération matricule** : Format `ETU-YYYY-XXXXX` (année + 5 chiffres)

### Frontend (Admin)
- **Screens** : `AdminStudentsScreen`, `AdminStudentFormScreen`, `AdminStudentDetailScreen`
- **Teacher** : `TeacherStudentsScreen`

### Règles métier
- Un étudiant = un user (compte de connexion)
- Statuts : actif, diplômé, suspendu, exclu
- Lié à un programme et un niveau courant
- Le matricule est unique et auto-généré
- Création d'un étudiant → création automatique du compte User avec rôle 'student'

## 38. Gestion des Enseignants

### Backend
- **Modèle** : `Teacher` (user_id, employee_code, hire_date, specialization, qualifications, max_hours_per_week, department_id)
- **Contrôleur** : `TeacherController` (CRUD + workload + schedule)
- **Service** : `TeacherService`

### Frontend (Admin)
- **Screens** : `AdminTeachersScreen`, `AdminTeacherFormScreen`, `AdminTeacherDetailScreen`

### Règles métier
- Un enseignant = un user (compte de connexion)
- Code employé unique
- Charge horaire max configurable (heures/semaine)
- Spécialisation : domaine d'expertise
- Qualifications : texte libre (diplômes, certifications)

## 39. Gestion des Inscriptions

### Backend
- **Modèle** : `Enrollment` (student_id, course_id, program_id, enrollment_date, status, grade_final)
- **Contrôleur** : `EnrollmentController` (CRUD + byStudent + byCourse + students + batch)
- **Service** : `EnrollmentService`

### Frontend (Admin)
- **Screens** : `AdminEnrollmentsScreen`, `AdminEnrollmentFormScreen`

### Types d'inscription
- **Par cours** : L'étudiant s'inscrit à un cours spécifique (course_id)
- **Par programme** : L'étudiant s'inscrit à un programme (program_id)

### Règles métier
- Statuts : actif, terminé, abandonné
- grade_final : note finale calculée
- Un étudiant peut être inscrit à plusieurs cours par semestre
- Inscription batch : possibilité d'inscrire plusieurs étudiants à la fois

## 40. Gestion des Notes

### Backend
- **Modèle** : `Grade` (enrollment_id, subject_id, grade_type, score, coefficient, graded_by, graded_at, academic_year, semester)
- **Contrôleur** : `GradeController` (CRUD + byStudent + bySubject + batch + validate)
- **Service** : `GradeService`

### Frontend
- **Teacher** : `TeacherGradesScreen` (sélection cours), `TeacherGradeEntryScreen` (saisie tableau)
- **Admin** : `AdminGradesScreen` (consultation)
- **Student** : `StudentGradesScreen` (consultation)

### Types de notes (GradeType)
- **CC** : Contrôle Continu
- **TP** : Travaux Pratiques
- **Examen** : Examen final
- **Autre** : Autre type

### Règles métier
- Note sur 20 (score : 0-20 float)
- Coefficient : permet pondération (ex: CC × 0.3, Examen × 0.7)
- Saisie batch : entrer les notes de tous les étudiants d'un cours en une fois
- Une note est liée à une inscription ET une matière
- graded_by : identifie l'enseignant qui a saisi

## 41. Calcul des Résultats

### Backend
- **Modèle** : `Result` (student_id, level_id, academic_year, semester, total_average, credits_obtained, credits_total, mention, decision, validated_by)
- **Contrôleur** : `ResultController`
- **Service** : `ResultService`

### Règles de calcul
```
total_average = Σ(score × coefficient) / Σ(coefficient)
crédits obtenus = Σ crédits des matières où moyenne ≥ 10
```

### Calcul de la mention
| Seuil | Mention |
|-------|---------|
| ≥ 16 | Excellent |
| ≥ 14 | Très Bien |
| ≥ 12 | Bien |
| ≥ 11 | Assez Bien |
| ≥ 10 | Passable |
| < 10 | Échec |

### Décision
| Condition | Décision |
|-----------|----------|
| moyenne_générale ≥ 10 et tous crédits ≥ 10 | Admis |
| moyenne_générale ≥ 10 mais certains crédits < 10 | Rattrapage |
| moyenne_générale < 10 | Ajourné |

### Backend Frontend
- **Admin** : `AdminResultsScreen`, `AdminResultFormScreen`, `AdminResultDetailScreen`
- **Student** : consultation via `StudentGradesScreen`

## 42. Résultats par Niveau

### Statuts de session
- **PLANNED** = 'planned'
- **IN_PROGRESS** = 'in_progress'
- **COMPLETED** = 'completed'
- **CANCELLED** = 'cancelled'
- La session de validation doit être "completed" pour générer les résultats

## 43. Emploi du Temps

### Backend
- **Modèle** : `Schedule` (course_id, room_id, teacher_id, day_of_week, start_time, end_time, start_date, end_date, is_recurring)
- **Contrôleur** : `ScheduleController` (CRUD + weekly + byRoom + byTeacher)
- **Service** : `ScheduleService`

### Frontend
- **Admin** : `AdminSchedulesScreen`, `AdminScheduleFormScreen`
- **Teacher** : `TeacherScheduleScreen`
- **Student** : `StudentScheduleScreen`

### Règles métier
- Détection automatique de conflits :
  - Même salle, même jour, créneaux qui se chevauchent
  - Même enseignant, même jour, créneaux qui se chevauchent
- Jours : lundi au samedi (WeekDay enum)
- Récurence : un cours peut être récurrent (toutes les semaines) ou ponctuel

## 44. Messagerie

### Backend
- **Modèles** : `Conversation`, `Message`, `MessageReaction`
- **Contrôleurs** : `ConversationController`, `MessageController`, `MessageReactionController`
- **Services** : `ConversationService`, `MessageService`, `MessageReactionService`

### Frontend
- **Screens** : `ConversationScreen` (liste conversations), `MessageDetailScreen` (chat)
- Accessible depuis tous les rôles

### Types de conversation
- **Direct** : 1-1 entre deux utilisateurs
- **Groupe** : Plusieurs utilisateurs

### Fonctionnalités
- Envoi de messages texte
- Pièces jointes (images, fichiers)
- Réactions aux messages (7 types : text, thumbs_up, clap, celebrate, heart, funny, confused)
- Marqueur de lecture
- Compteur de messages non lus

## 45. Ressources Pédagogiques

### Backend
- **Modèle** : `Resource` (title, description, type, file_path, url, thumbnail, subject_id, uploaded_by, is_published)
- **Contrôleur** : `ResourceController`
- **Service** : `ResourceService`

### Frontend
- **Screens** : `ResourcesScreen` (tous rôles)

### Types de ressources
- **PDF** : Documents PDF uploadés
- **Video** : Fichiers vidéo
- **Link** : Liens externes
- **Document** : Autres documents (Word, etc.)
- **External Video** : Vidéos hébergées (YouTube, etc.)

### Règles métier
- Upload avec stockage local (storage/app/public/resources/)
- Miniature générée pour vidéos/PDF
- Publication : toggle public/privé
- Liée à une matière (subject)

## 46. Notifications

### Backend
- **Modèle** : `Notification` (Laravel database notifications)
- **Service** : `NotificationService`

### Frontend
- **Screen** : `NotificationsScreen`
- **Provider** : `notificationProvider`, `unreadCountProvider`
- **Service** : `NotificationService` Flutter + `flutter_local_notifications`

### Types
- INFO, WARNING, SUCCESS, ERROR

### Événements déclencheurs
- Inscription → notification de bienvenue
- Notes publiées → notification étudiants concernés
- Résultats validés → notification étudiants
- Nouveau message → notification conversation
- Cours terminé → mise à jour statut

## 47. Tableaux de Bord (KPIs)

### Dashboard Admin
- Nombre total d'utilisateurs
- Nombre d'étudiants, enseignants, départements
- Nombre de cours, programmes
- Taux de réussite global
- Graphiques : répartition étudiants/programme, notes par matière

### Dashboard Teacher
- Nombre de cours assignés
- Nombre d'étudiants total
- Prochaines séances
- Charge horaire hebdomadaire

### Dashboard Student
- Moyenne générale
- Crédits obtenus / total
- Cours en cours
- Prochain cours
- Graphique d'évolution des notes

## 48. Rapports et Exports

### PDF (DomPDF)
- **Bulletin étudiant** : Notes par matière, moyennes, crédits, mention, décision
- **Relevé de classe** : Tous les étudiants d'un niveau avec leurs résultats

### Excel (Laravel Excel)
- **Liste étudiants** : Export par programme/niveau avec matricule, email, statut
- **Export notes** : Notes d'un cours avec tous les étudiants

### Implémentation
- `ReportService` : Génération PDF avec DomPDF (view Blade → PDF)
- `ReportController` : Endpoints de téléchargement
- Routes protégées par rôle (admin/teacher)

## 49. Recherche Unifiée

### Backend
- **Service** : `SearchService`
- **Contrôleur** : `SearchController`
- Endpoint : `GET /api/search?q=terme&models[]=students,teachers,courses,users`

### Frontend
- **Screen** : `SearchScreen` (accessible depuis tous les rôles)
- **Widget** : `AppSearchBar` avec debounce (300ms)

### Entités recherchables
- Étudiants (nom, matricule, email)
- Enseignants (nom, code, spécialisation)
- Cours (nom, code, description)
- Utilisateurs (nom, email)
- Matières (nom, code)

### Score de pertinence
- Match exact sur code → score 100%
- Match sur nom → score 80%
- Match partiel → score 60%

## 50. Génération de Codes Métier

Chaque entité principale possède un code unique auto-généré :

| Entité | Format | Exemple |
|--------|--------|---------|
| Student | `ETU-{YYYY}-{NNNNN}` | `ETU-2025-00001` |
| Teacher | `EMP-{YYYY}-{NNNNN}` | `EMP-2025-00001` |
| Department | `DEPT-{CODE3}` | `DEPT-INF` |
| Program | `PROG-{CODE4}` | `PROG-INFO` |
| Subject | `SUBJ-{CODE4}` | `SUBJ-MATH` |
| Course | `CRS-{YYYY}-{NNNNN}` | `CRS-2025-00001` |
| Room | `RM-{TYPE}-{NNN}` | `RM-AMP-001` |

La génération est implémentée dans les services respectifs avec vérification d'unicité en base.
