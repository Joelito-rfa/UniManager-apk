# Diagrammes de Séquence - UniManager APP

## 1. Authentification (Connexion)

```
┌─────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────┐
│ Utilis. │     │  Frontend     │     │  Backend API  │     │ PostgreSQL│
│ (Mobile)│     │  Flutter      │     │  Laravel      │     │          │
└────┬────┘     └──────┬───────┘     └──────┬───────┘     └────┬─────┘
     │                  │                    │                  │
     │ 1. Saisir email  │                    │                  │
     │    + mot de passe│                    │                  │
     │─────────────────►│                    │                  │
     │                  │                    │                  │
     │ 2. Cliquer       │                    │                  │
     │    "Connexion"   │                    │                  │
     │─────────────────►│                    │                  │
     │                  │ 3. POST /api/login │                  │
     │                  │   {email,password} │                  │
     │                  │───────────────────►│                  │
     │                  │                    │ 4. SELECT * FROM │
     │                  │                    │    users WHERE   │
     │                  │                    │    email = ?     │
     │                  │                    │─────────────────►│
     │                  │                    │                  │
     │                  │                    │ 5. Vérifier      │
     │                  │                    │    mot de passe  │
     │                  │                    │    (Hash: bcrypt)│
     │                  │                    │                  │
     │                  │                    │ 6. Générer JWT   │
     │                  │                    │    (tymon-jwt)   │
     │                  │                    │                  │
     │                  │ 7. {token, user,   │                  │
     │                  │    role}           │                  │
     │                  │◄───────────────────│                  │
     │                  │                    │                  │
     │ 8. Stocker token │                    │                  │
     │    (FlutterSecureStorage)             │                  │
     │    Rediriger     │                    │                  │
     │    dashboard     │                    │                  │
     │◄─────────────────│                    │                  │
     │                  │                    │                  │
```

## 2. Saisie des notes (Enseignant)

```
┌─────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────┐
│Enseignant│     │  Frontend     │     │  Backend API  │     │ PostgreSQL│
└────┬────┘     └──────┬───────┘     └──────┬───────┘     └────┬─────┘
     │                  │                    │                  │
     │ 1. Accéder       │                    │                  │
     │    "Mes cours"   │                    │                  │
     │─────────────────►│                    │                  │
     │                  │ 2. GET /api/teacher/courses           │
     │                  │    (Bearer token)  │                  │
     │                  │───────────────────►│                  │
     │                  │                    │ 3. Vérifier rôle │
     │                  │                    │    teacher       │
     │                  │                    │ 4. SELECT courses│
     │                  │                    │    WHERE teacher │
     │                  │                    │─────────────────►│
     │                  │                    │                  │
     │                  │ 5. Liste des cours │                  │
     │                  │◄───────────────────│                  │
     │ 6. Sélectionner  │                    │                  │
     │    un cours      │                    │                  │
     │─────────────────►│                    │                  │
     │                  │ 7. GET /api/teacher/courses/{id}/students
     │                  │───────────────────►│                  │
     │                  │                    │ 8. SELECT        │
     │                  │                    │    enrollments   │
     │                  │                    │    JOIN students │
     │                  │                    │─────────────────►│
     │                  │ 9. Liste étudiants │                  │
     │                  │◄───────────────────│                  │
     │ 10. Saisir notes │                    │                  │
     │     pour chaque  │                    │                  │
     │     étudiant     │                    │                  │
     │─────────────────►│                    │                  │
     │                  │ 11. POST /api/grades               │
     │                  │    {batch: [{      │                  │
     │                  │     enrollment_id, │                  │
     │                  │     grade_value,   │                  │
     │                  │     grade_type,    │                  │
     │                  │     coefficient}]} │                  │
     │                  │───────────────────►│                  │
     │                  │                    │ 12. Valider      │
     │                  │                    │     données      │
     │                  │                    │ 13. INSERT INTO  │
     │                  │                    │     grades        │
     │                  │                    │─────────────────►│
     │                  │ 14. {success: true, count: N}         │
     │                  │◄───────────────────│                  │
     │ 15. Confirmation │                    │                  │
     │◄─────────────────│                    │                  │
```

## 3. Consultation des notes (Étudiant)

```
┌─────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────┐
│ Étudiant│     │  Frontend     │     │  Backend API  │     │ PostgreSQL|
└────┬────┘     └──────┬───────┘     └──────┬───────┘     └────┬─────┘
     │                  │                    │                  │
     │ 1. Accéder       │                    │                  │
     │    "Mes notes"   │                    │                  │
     │─────────────────►│                    │                  │
     │                  │ 2. GET /api/student/grades            │
     │                  │    (Bearer token)  │                  │
     │                  │───────────────────►│                  │
     │                  │                    │ 3. Vérifier rôle │
     │                  │                    │    student      │
     │                  │                    │ 4. Récupérer     │
     │                  │                    │    student_id    │
     │                  │                    │    via user_id   │
     │                  │                    │ 5. SELECT grades │
     │                  │                    │    JOIN courses  │
     │                  │                    │    JOIN subjects │
     │                  │                    │─────────────────►│
     │                  │                    │                  │
     │                  │ 6. Notes avec      │                  │
     │                  │    matières,       │                  │
     │                  │    coefficients,   │                  │
     │                  │    moyennes        │                  │
     │                  │◄───────────────────│                  │
     │ 7. Afficher      │                    │                  │
     │    bulletin      │                    │                  │
     │◄─────────────────│                    │                  │
```

## 4. Création d'un emploi du temps (Administrateur)

```
┌─────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────┐
│ Admin    │     │  Frontend     │     │  Backend API  │     │ PostgreSQL│
└────┬────┘     └──────┬───────┘     └──────┬───────┘     └────┬─────┘
     │                  │                    │                  │
     │ 1. Accéder       │                    │                  │
     │    "Emplois du   │                    │                  │
     │    temps"        │                    │                  │
     │─────────────────►│                    │                  │
     │                  │ 2. GET /api/schedules               │
     │                  │───────────────────►│                  │
     │                  │                    │ 3. SELECT       │
     │                  │                    │    schedules    │
     │                  │                    │    JOIN courses │
     │                  │                    │─────────────────►│
     │                  │ 4. Liste EDT       │                  │
     │                  │◄───────────────────│                  │
     │ 5. Cliquer       │                    │                  │
     │    "Ajouter"     │                    │                  │
     │─────────────────►│                    │                  │
     │                  │ 6. GET /api/courses (liste déroulante)│
     │                  │    GET /api/classrooms               │
     │                  │───────────────────►│                  │
     │                  │ 7. Données         │                  │
     │                  │◄───────────────────│                  │
     │ 8. Remplir       │                    │                  │
     │    formulaire    │                    │                  │
     │    (cours, salle,│                    │                  │
     │     jour, heure) │                    │                  │
     │─────────────────►│                    │                  │
     │                  │ 9. POST /api/schedules              │
     │                  │    {course_id,     │                  │
     │                  │     classroom_id,  │                  │
     │                  │     day_of_week,   │                  │
     │                  │     start_time,    │                  │
     │                  │     end_time,      │                  │
     │                  │     type}          │                  │
     │                  │───────────────────►│                  │
     │                  │                    │ 10. Vérifier    │
     │                  │                    │     conflits    │
     │                  │                    │     horaires    │
     │                  │                    │ 11. INSERT      │
     │                  │                    │─────────────────►│
     │                  │ 12. EDT créé       │                  │
     │                  │◄───────────────────│                  │
     │ 13. Notification │                    │                  │
     │◄─────────────────│                    │                  │
```

## 5. Export PDF relevé de notes

```
┌─────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────┐
│ Étudiant│     │  Frontend     │     │  Backend API  │     │ PostgreSQL|
└────┬────┘     └──────┬───────┘     └──────┬───────┘     └────┬─────┘
     │                  │                    │                  │
     │ 1. Cliquer       │                    │                  │
     │    "Télécharger  │                    │                  │
     │    relevé"       │                    │                  │
     │─────────────────►│                    │                  │
     │                  │ 2. GET /api/student/transcript       │
     │                  │    (Bearer token)  │                  │
     │                  │───────────────────►│                  │
     │                  │                    │ 3. Récupérer     │
     │                  │                    │    notes+résultats│
     │                  │                    │─────────────────►│
     │                  │                    │                  │
     │                  │                    │ 4. Générer PDF   │
     │                  │                    │    (Barryvdh    │
     │                  │                    │    DomPDF)      │
     │                  │                    │                  │
     │                  │ 5. Fichier PDF     │                  │
     │                  │    (base64 ou URL) │                  │
     │                  │◄───────────────────│                  │
     │ 6. Download PDF  │                    │                  │
     │◄─────────────────│                    │                  │
```
