# Diagramme de Cas d'Utilisation - UniManager APP

## 1. Acteurs

```
┌─────────────────────────────────────────────────────────┐
│                    UniManager APP                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────┐  ┌──────────────────┐            │
│  │   Administrateur  │  │    Enseignant     │            │
│  │  (Rôle: admin)    │  │  (Rôle: teacher)  │            │
│  └────────┬─────────┘  └────────┬─────────┘            │
│           │                      │                       │
│           │    ┌──────────────────┐                     │
│           │    │    Étudiant      │                     │
│           │    │  (Rôle: student) │                     │
│           │    └──────────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

## 2. Cas d'utilisation par acteur

### 2.1 Administrateur (+ Extends Enseignant et Étudiant)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        UniManager APP                                        │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Administrateur                                │   │
│  │                                                                     │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │   │
│  │  │  Gérer Étudiants │  │ Gérer Enseignants│  │ Gérer Départements│   │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘     │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │   │
│  │  │  Gérer Filières  │  │  Gérer Niveaux   │  │  Gérer Matières  │     │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘     │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │   │
│  │  │  Gérer Cours     │  │ Gérer EmploisTps│  │  Gérer Salles    │     │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘     │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │   │
│  │  │ Gérer Inscriptions│  │  Gérer Notes    │  │ Gérer Résultats  │     │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘     │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │   │
│  │  │ Gérer Utilisateurs│  │  Voir Stats     │  │ Gérer Rôles      │     │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘     │   │
│  │  ┌─────────────────┐  ┌─────────────────┐                           │   │
│  │  │  Exporter PDF    │  │  Exporter Excel  │                           │   │
│  │  └─────────────────┘  └─────────────────┘                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Enseignant                                    │   │
│  │                                                                     │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │   │
│  │  │ Consulter Cours  │  │ Consulter EDT    │  │ Ajouter Notes    │     │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘     │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │   │
│  │  │ Modifier Notes   │  │ Consulter Étudi.│  │ Consulter Résul. │     │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Étudiant                                      │   │
│  │                                                                     │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │   │
│  │  │ Consulter Profil │  │ Consulter Matières│  │ Consulter EDT    │     │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘     │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │   │
│  │  │ Consulter Notes  │  │ Consulter Résul.│  │ Télécharger Rel. │     │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │            Relations entre acteurs                                    │   │
│  │  Administrateur <<extends>> Enseignant (héritage de fonctionnalités)  │   │
│  │  Enseignant    <<extends>> Étudiant    (héritage de consultation)     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 3. Description détaillée des cas d'utilisation

### UC-01 : Authentification
| Élément | Description |
|---------|-------------|
| Acteur | Tous |
| Précondition | Utilisateur non connecté |
| Postcondition | Utilisateur connecté avec JWT |
| Scénario | 1. Saisir email + mot de passe 2. Valider 3. Recevoir JWT 4. Rediriger vers dashboard |

### UC-02 : Gestion des étudiants (CRUD)
| Élément | Description |
|---------|-------------|
| Acteur | Administrateur |
| Précondition | Administrateur connecté |
| Postcondition | Étudiant créé/modifié/supprimé |
| Scénario | 1. Accéder liste étudiants 2. Ajouter/Modifier/Supprimer 3. Valider formulaire |

### UC-03 : Saisie des notes
| Élément | Description |
|---------|-------------|
| Acteur | Enseignant |
| Précondition | Enseignant connecté, cours assigné |
| Postcondition | Notes enregistrées |
| Scénario | 1. Sélectionner cours 2. Voir liste étudiants 3. Saisir notes 4. Valider |

### UC-04 : Consultation des résultats
| Élément | Description |
|---------|-------------|
| Acteur | Étudiant |
| Précondition | Étudiant connecté, inscrit à des cours |
| Postcondition | Affichage des résultats |
| Scénario | 1. Accéder à "Mes résultats" 2. Sélectionner semestre 3. Visualiser notes |

### UC-05 : Génération de rapports
| Élément | Description |
|---------|-------------|
| Acteur | Administrateur |
| Précondition | Données disponibles |
| Postcondition | Fichier PDF/Excel généré |
| Scénario | 1. Sélectionner type rapport 2. Filtrer données 3. Générer 4. Télécharger |
