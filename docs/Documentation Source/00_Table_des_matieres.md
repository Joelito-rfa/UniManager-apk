# Documentation Source — UniManager

## Table des Matières

### PARTIE I : PRÉSENTATION GÉNÉRALE
1. **Introduction** — Contexte, objectifs, périmètre
2. **Architecture Globale** — Vue d'ensemble, stack technique, diagrammes de déploiement
3. **Structure du Projet** — Arborescence commentée

### PARTIE II : BACKEND — LARAVEL 12
4. **Configuration et Dépendances** — composer.json, .env, config/
5. **Architecture des Données** — Migrations, Schéma PostgreSQL, Relations
6. **Modèles Eloquent** — 22 modèles, traits, relations, scopes
7. **Enums** — 10 énums typées PHP 8.2
8. **Services** — 22 services métier détaillés
9. **Contrôleurs API** — 25 contrôleurs REST organisés par rôle
10. **Requêtes de Validation** — 30+ form requests avec règles métier
11. **Ressources API** — 20 resources JSON (transformation des réponses)
12. **Authentification JWT** — tymon/jwt-auth, refresh token, roles
13. **Permissions et Rôles** — Spatie Permission v6, RBAC complet
14. **Routes API** — 150+ endpoints REST documentés
15. **Événements et Écouteurs** — 5 événements, 5 listeners
16. **Notifications** — Système de notifications base de données
17. **Politiques d'Autorisation** — 8 policies par entité
18. **Seeders et Factories** — 15 seeders, 4 factories
19. **Tests** — Tests unitaires et fonctionnels

### PARTIE III : FRONTEND — FLUTTER
20. **Configuration et Dépendances** — pubspec.yaml, build.gradle.kts
21. **Thème Material 3** — theme_config.dart, dark/light mode
22. **Router et Navigation** — go_router, 60+ routes, ShellRoute
23. **Providers Riverpod** — 25 providers, StateNotifier, StreamProvider
24. **Services Flutter** — Auth, Storage, Notification
25. **Modèles Dart** — 19 modèles avec fromJson/toJson
26. **Écrans** — 59 écrans organisés par rôle
27. **Widgets** — 34 widgets partagés
28. **Cache et Hors-ligne** — Hive, TTL, bannière offline
29. **Connectivité** — Double vérification (connectivity_plus + internet_connection_checker)
30. **Client HTTP** — Dio, intercepteurs auth/retry/cache

### PARTIE IV : FONCTIONNALITÉS MÉTIER
31. **Gestion des Départements** — CRUD, services, UI
32. **Gestion des Programmes** — CRUD, dépendances
33. **Gestion des Niveaux** — CRUD, hiérarchie
34. **Gestion des Matières** — CRUD, coefficients, crédits
35. **Gestion des Cours** — Affectation enseignants, emploi du temps
36. **Gestion des Salles** — Types (Amphi/TD/TP/Labo), capacité
37. **Gestion des Étudiants** — Inscription, matricule, programme
38. **Gestion des Enseignants** — Recrutement, spécialités
39. **Gestion des Inscriptions** — Inscription par cours ou programme
40. **Gestion des Notes** — CC/TP/Exam, coefficients, batch
41. **Calcul des Résultats** — Moyennes, crédits, mentions
42. **Résultats par Niveau** — Décision Admis/Rattrapage/Ajourné
43. **Emploi du Temps** — Planification, conflits salle/prof
44. **Messagerie** — Conversations, pièces jointes, réactions
45. **Ressources Pédagogiques** — PDF, vidéo, liens, thumbnails
46. **Notifications** — Système interne, événements
47. **Tableaux de Bord** — KPIs, graphiques, statistiques
48. **Rapports et Exports** — PDF (DomPDF), Excel (Laravel Excel)
49. **Recherche Unifiée** — Recherche multi-entités
50. **Génération de Codes** — Identifiants métier automatiques

### PARTIE V : ARCHITECTURE TECHNIQUE
51. **Patterns et Principes** — SOLID, Clean Architecture, Service Layer
52. **Sécurité** — JWT, CORS, validation, policies
53. **Performances** — Cache, pagination, eager loading, index BDD
54. **Optimisations** — ProGuard, minSdk, compression, lazy loading
55. **Diagrammes UML** — Cas d'utilisation, classes, séquence, activité, composants, déploiement
56. **Améliorations Possibles** — Roadmap, scalabilité, v2

### ANNEXES
A. Guide d'Installation et Déploiement
B. Référence API Complète (150+ endpoints)
C. Structure Complète de la Base de Données
D. Dépendances et Versions
E. Glossaire Technique
