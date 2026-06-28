# Guide GitHub Collaboration - UniManager APP

## 1. Création du dépôt GitHub

### 1.1 Créer le dépôt sur GitHub.com

```bash
# Se connecter à GitHub, cliquer sur "New repository"
# Nom : UniManager-APP
# Description : Application mobile de gestion universitaire
# Public ou Private (selon préférence)
# Ne pas initialiser avec README (on va le faire localement)
```

### 1.2 Configurer le dépôt

```bash
# Aller dans Paramètres du dépôt → Branches
# Ajouter une règle de protection pour la branche main :
#   - "Require a pull request before merging"
#   - "Require approvals" (1 approve)
#   - "Dismiss stale pull request approvals"
#   - "Require status checks to pass before merging"
```

## 2. Initialisation Git locale

```bash
# Initialiser Git dans le projet
cd D:/étude/Projet/L3/dev mobile/UniManager APP
git init

# Créer le fichier .gitignore
echo "# OS files
.DS_Store
Thumbs.db
*.swp
*.swo

# IDE
.vscode/
.idea/
*.iml

# Flutter/Dart
frontend/.dart_tool/
frontend/.packages
frontend/build/
frontend/.flutter-plugins*
frontend/pubspec.lock

backend/vendor/
backend/.env
backend/.env.*
backend/storage/
backend/bootstrap/cache/
backend/node_modules/

# Logs
*.log
" > .gitignore

# Ajouter tous les fichiers
git add .
git commit -m "chore: initial project structure with documentation"
```

## 3. Connexion au dépôt distant

```bash
# Ajouter le remote origin
git remote add origin https://github.com/votre-username/UniManager-APP.git

# Pousser la branche main
git push -u origin main
```

## 4. Structure des branches

```
main
  │
  ├── develop
  │     │
  │     ├── feature/auth
  │     ├── feature/departments
  │     ├── feature/programs
  │     ├── feature/students
  │     ├── feature/teachers
  │     ├── feature/subjects
  │     ├── feature/courses
  │     ├── feature/classrooms
  │     ├── feature/schedules
  │     ├── feature/enrollments
  │     ├── feature/grades
  │     ├── feature/results
  │     ├── feature/dashboard
  │     ├── feature/reports
  │     └── feature/notifications
  │
  └── hotfix/xxx (en cas d'urgence)
```

### 4.1 Créer les branches

```bash
# Créer develop
git checkout -b develop
git push -u origin develop

# Créer les branches features
git checkout -b feature/auth
git push -u origin feature/auth

git checkout develop
git checkout -b feature/students
git push -u origin feature/students

# ... répéter pour chaque feature
```

## 5. Workflow de développement

### 5.1 Commencer une nouvelle fonctionnalité

```bash
# Se placer sur develop et mettre à jour
git checkout develop
git pull origin develop

# Créer la branche feature
git checkout -b feature/nom-feature

# Développer...
git add .
git commit -m "feat(scope): description concise"

# Pousser régulièrement
git push -u origin feature/nom-feature
```

### 5.2 Convention de commits

```
Format: type(scope): message

Types :
  feat     : Nouvelle fonctionnalité
  fix      : Correction de bug
  refactor : Refactoring sans changement fonctionnel
  docs     : Documentation
  style    : Formatage (espaces, points-virgules...)
  test     : Tests
  chore    : Tâches diverses (dépendances, config...)

Exemples :
  feat(auth): add JWT login endpoint
  fix(students): handle duplicate email on create
  refactor(courses): extract schedule validation
  docs(api): add Postman collection
  test(grades): add unit tests for grade calculation
  chore(deps): upgrade Laravel to 12.x
```

### 5.3 Créer une Pull Request

```bash
# Après avoir poussé la feature
# Aller sur GitHub.com → Pull Requests → New Pull Request

# Base: develop ← Compare: feature/nom-feature

# Titre : feat(scope): description
# Description :
#   ## Objectif
#   Description de la fonctionnalité
#
#   ## Modifications
#   - Fichier 1 : description
#   - Fichier 2 : description
#
#   ## Tests
#   - [ ] Tests unitaires passés
#   - [ ] Tests d'intégration passés
#
#   ## Reviewer
#   @professeur
```

### 5.4 Revue de code

```bash
# Le professeur review la PR
# Commentaires et suggestions
# Modifications si nécessaire
# Approbation
```

### 5.5 Merging

```bash
# Une fois approuvée :
# Option 1 : Merge via GitHub UI (bouton "Merge pull request")
# Option 2 : En ligne de commande

git checkout develop
git pull origin develop
git merge --no-ff feature/nom-feature
git push origin develop

# Supprimer la branche feature (optionnel)
git branch -d feature/nom-feature
git push origin --delete feature/nom-feature
```

## 6. Résolution des conflits

### 6.1 Identifier le conflit

```bash
# Lors du merge, Git indique les fichiers en conflit
# Exemple : CONFLICT (content): Merge conflict in app/Models/User.php

# Voir les fichiers en conflit
git status
# Les fichiers en conflit sont listés dans "both modified:"
```

### 6.2 Résoudre manuellement

```bash
# Ouvrir le fichier en conflit
# Chercher les marqueurs de conflit :
# <<<<<<< HEAD
# code actuel (develop)
# =======
# code entrant (feature)
# >>>>>>> feature/nom-feature

# Garder le code approprié, supprimer les marqueurs
# Puis :
git add fichier-resolu
git commit -m "fix: resolve merge conflict in fichier"
```

### 6.3 Utiliser un outil de merge

```bash
# Configurer un outil de diff (ex: VS Code)
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd "code --wait $MERGED"

# Lancer l'outil de résolution
git mergetool
```

## 7. Validation du code

### 7.1 Avant chaque commit

```bash
# Backend Laravel
cd backend
./vendor/bin/pint          # Formatage PSR-12
php artisan test --filter=NomFeature  # Tests

# Frontend Flutter
cd frontend
dart format lib/            # Formatage
flutter analyze             # Analyse statique
flutter test                # Tests
```

### 7.2 Hooks Git (optionnel)

```bash
# Créer .git/hooks/pre-commit

# .git/hooks/pre-commit
#!/bin/bash
echo "Running pre-commit checks..."

# Vérifier le formatage Laravel
cd backend && ./vendor/bin/pint --test
if [ $? -ne 0 ]; then
    echo "Pint failed: run ./vendor/bin/pint to fix formatting"
    exit 1
fi

# Vérifier le formatage Flutter
cd ../frontend && dart format --set-exit-if-changed lib/
if [ $? -ne 0 ]; then
    echo "Dart format failed: run 'dart format lib/' to fix"
    exit 1
fi

echo "All checks passed!"
exit 0
```

## 8. Rôles Git

```
👤 Étudiant (vous) :
  - Crée les branches features
  - Développe le code
  - Crée les Pull Requests
  - Intègre les retours du professeur

👨‍🏫 Professeur :
  - Review le code
  - Approuve les Pull Requests
  - Merge dans develop/main
  - Valide l'architecture

📋 Règles :
  1. Jamais de commit direct sur main ou develop
  2. Toujours passer par une Pull Request
  3. Chaque PR doit être approuvée
  4. Les tests doivent passer avant merge
  5. Le code doit suivre les conventions
```

## 9. Commandes essentielles

```bash
# Mise à jour quotidienne
git checkout develop
git pull origin develop

# Nouvelle feature
git checkout -b feature/ma-feature develop

# Sauvegarder son travail
git add -A
git commit -m "feat(scope): description"
git push origin feature/ma-feature

# Synchroniser avec develop
git checkout develop
git pull origin develop
git checkout feature/ma-feature
git merge develop

# Annuler des changements locaux
git checkout -- nom_fichier
git reset --soft HEAD~1   # Annuler dernier commit (garder les fichiers)
git reset --hard HEAD~1   # Annuler dernier commit (perdre les fichiers)
```
