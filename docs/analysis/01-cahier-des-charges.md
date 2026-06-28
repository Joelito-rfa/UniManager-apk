# Cahier des Charges - UniManager APP

## 1. Présentation du projet

### 1.1 Contexte
UniManager APP est une application mobile professionnelle de gestion universitaire destinée aux établissements d'enseignement supérieur. Elle permet de gérer l'ensemble des activités académiques et administratives via une interface mobile moderne et responsive.

### 1.2 Objectifs
- Centraliser la gestion des données universitaires
- Faciliter la communication entre les acteurs (administration, enseignants, étudiants)
- Automatiser les processus pédagogiques (inscriptions, notes, résultats)
- Fournir des tableaux de bord et des rapports en temps réel
- Garantir la sécurité et l'intégrité des données

### 1.3 Périmètre
L'application couvre :
- Gestion des utilisateurs et authentification
- Gestion académique (étudiants, enseignants, départements, filières)
- Gestion pédagogique (cours, emplois du temps, notes, résultats)
- Génération de rapports (PDF, Excel)
- Tableaux de bord statistiques

## 2. Acteurs du système

### 2.1 Administrateur
- Accès complet à toutes les fonctionnalités
- Gestion des utilisateurs, rôles et permissions
- Configuration du système

### 2.2 Enseignant
- Gestion de ses cours et emplois du temps
- Saisie et modification des notes
- Consultation des étudiants et résultats

### 2.3 Étudiant
- Consultation de son profil, matières, emploi du temps
- Consultation des notes et résultats
- Téléchargement des relevés de notes

## 3. Fonctionnalités détaillées

### 3.1 Module Authentification
| Fonctionnalité | Admin | Enseignant | Étudiant |
|---------------|-------|------------|----------|
| Connexion | ✓ | ✓ | ✓ |
| Déconnexion | ✓ | ✓ | ✓ |
| Réinitialisation mot de passe | ✓ | ✓ | ✓ |
| Gestion des rôles | ✓ | ✗ | ✗ |

### 3.2 Module Gestion académique
| Fonctionnalité | Admin | Enseignant | Étudiant |
|---------------|-------|------------|----------|
| CRUD Étudiants | ✓ | ✗ | ✗ |
| CRUD Enseignants | ✓ | ✗ | ✗ |
| CRUD Départements | ✓ | ✗ | ✗ |
| CRUD Filières | ✓ | ✗ | ✗ |
| CRUD Matières | ✓ | ✗ | ✗ |
| CRUD Cours | ✓ | ✗ | ✗ |
| CRUD Salles | ✓ | ✗ | ✗ |
| CRUD Emplois du temps | ✓ | ✗ | ✗ |

### 3.3 Module Gestion pédagogique
| Fonctionnalité | Admin | Enseignant | Étudiant |
|---------------|-------|------------|----------|
| Inscriptions | ✓ | ✗ | ✗ |
| Saisie notes | ✓ | ✓ | ✗ |
| Modification notes | ✓ | ✓ | ✗ |
| Consultation notes | ✓ | ✓ | ✓ |
| Résultats | ✓ | ✓ | ✓ |
| Bulletins | ✓ | ✓ | ✓ |

### 3.4 Module Dashboard
- Nombre d'étudiants, enseignants, filières
- Statistiques des résultats
- Graphiques d'évolution

### 3.5 Module Rapports
- Export PDF des relevés de notes
- Export Excel des listes
- Impression des bulletins

## 4. Contraintes techniques

### 4.1 Frontend
- Flutter dernière version stable
- Dart
- Material 3 Design
- Riverpod pour la gestion d'état
- Go Router pour la navigation
- Responsive Design (mobile + tablette)

### 4.2 Backend
- Laravel 12 API REST
- PostgreSQL
- JWT Authentication
- Gestion des rôles et permissions (Spatie Laravel-permission)

### 4.3 Sécurité
- Authentification JWT
- Hachage des mots de passe (bcrypt)
- Validation des données côté serveur
- Protection CSRF
- Rate limiting
- CORS configuration

## 5. Contraintes fonctionnelles

### 5.1 Performance
- Temps de réponse API < 500ms
- Chargement initial < 3s
- Support offline partiel

### 5.2 Disponibilité
- Application disponible 24h/24
- Maintenance programmée

### 5.3 Compatibilité
- Android 8.0+ (API 26+)
- iOS 15+

## 6. Livrables

### 6.1 Documentation
- Cahier des charges
- Diagrammes UML (cas d'utilisation, classes, séquence)
- Modèle conceptuel de données (MCD)
- Modèle logique de données (MLD)
- Guide d'installation et déploiement

### 6.2 Code source
- Application Flutter complète
- API Laravel complète
- Scripts de base de données

### 6.3 Tests
- Tests unitaires (backend)
- Tests d'intégration (backend)
- Tests de widgets (frontend)

## 7. Planning prévisionnel

| Phase | Durée | Livrables |
|-------|-------|-----------|
| Analyse | 1 semaine | Cahier des charges, diagrammes, MCD/MLD |
| Backend | 2 semaines | API REST complète |
| Frontend | 3 semaines | Application Flutter |
| Tests | 1 semaine | Tests et déploiement |
