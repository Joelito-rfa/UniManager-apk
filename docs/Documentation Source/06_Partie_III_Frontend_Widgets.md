# PARTIE III (suite) — WIDGETS, CACHE, CONNECTIVITÉ, HTTP

## 27. Widgets Partagés (34 widgets)

Tous dans `lib/widgets/` :

### Layout & Structure
1. **AppShell** — Scaffold avec AppBar + BottomNavigationBar (utilisé par ShellRoute)
2. **PageLayout** — Widget responsive avec padding adaptatif, titre, sous-titre, actions
3. **ResponsiveBuilder** — Builder qui expose les breakpoints (mobile/tablette/desktop)

### Data Display
4. **DataTable** — Tableau générique avec pagination, tri, sélection
5. **DataCard** — Carte d'affichage de données avec label et valeur
6. **StatCard** — Carte de statistique avec icône, valeur, variation
7. **InfoTile** — Tuile d'information avec icône et label
8. **EmptyState** — État vide avec image, message, action
9. **LoadingState** — État de chargement avec Shimmer ou spinner
10. **ErrorState** — État d'erreur avec message, refresh
11. **SectionHeader** — En-tête de section avec titre optionnel

### Form & Input
12. **AppTextField** — Champ de texte stylé Material 3
13. **AppDropdown** — Menu déroulant stylé
14. **AppDatePicker** — Sélecteur de date
15. **AppTimePicker** — Sélecteur d'heure
16. **AppMultiSelect** — Sélection multiple avec chips
17. **AppImagePicker** — Sélecteur d'image (galerie/camera)
18. **AppFilePicker** — Sélecteur de fichier
19. **FormSection** — Section de formulaire avec titre
20. **FormActions** — Boutons Enregistrer/Annuler en bas de formulaire

### Feedback & Status
21. **StatusBadge** — Badge de statut (actif/inactif, planifié/terminé, etc.)
22. **GradeBadge** — Badge de note avec code couleur
23. **MentionBadge** — Badge de mention avec couleur
24. **DecisionBadge** — Badge Admis/Rattrapage/Ajourné
25. **NotificationBadge** — Badge de notification non lue
26. **ConnectivityBanner** — Bannière "Vous êtes hors ligne" avec animation
27. **ConnectivityIndicator** — Indicateur de connectivité (icône cercle vert/rouge)

### Navigation & Action
28. **AppSearchBar** — Barre de recherche avec debounce
29. **FilterChips** — Chips de filtrage horizontal
30. **ActionMenu** — Menu d'actions popup
31. **QuickActionGrid** — Grille d'actions rapides (dashboard)
32. **Breadcrumb** — Fil d'Ariane

### Animation & Feedback
33. **AnimatedEntry** — Extension `BuildContext` pour animations (`fadeIn()`, `scaleIn()`, `slideUp()`) via `flutter_animate`

### Responsive Helper
34. **responsive_helper.dart** — Extension `BuildContext` :
    - `isMobile` → < 600px
    - `isTablet` → 600-1024px
    - `isDesktop` → > 1024px
    - `responsive<T>({T? mobile, T? tablet, T? desktop})` → Valeur conditionnelle

## 28. Cache et Mode Hors-ligne

### Architecture du Cache (Hive 4.x)
- **Stockage local** NoSQL (clé-valeur)
- Les données API sont mises en cache avec TTL configurable
- Le cache est invalidé automatiquement à l'expiration du TTL
- En mode hors-ligne, les données sont lues depuis Hive

### Stratégie de cache
- **Lecture** : Vérifier cache → si présent et non expiré → retourner cache
- **Écriture** : Récupérer API → stocker dans Hive avec timestamp → retourner donnée
- **Hors-ligne** : Détecté par connectivityProvider → lecture seule depuis cache
- **TTL** : Configurable par type de donnée (défaut : 5 minutes)

### StorageService (lib/services/storage_service.dart)
- Initialisation : `await Hive.initFlutter()`
- Ouverture box : `await Hive.openBox('unimanager_cache')`
- `put<T>(key, value, {ttl})` : Stocke avec `{data: value, timestamp: now, ttl: ttl}`
- `get<T>(key)` : Vérifie timestamp + TTL, retourne null si expiré

## 29. Connectivité — Double Vérification

### connectivity_provider.dart
Utilise **deux** packages pour une fiabilité maximale :

1. **connectivity_plus** — Détection rapide de l'état réseau (WiFi/4G/aucun)
2. **internet_connection_checker** — Vérification réelle de la connexion Internet (adresses configurées : jsonplaceholder, google.com, cloudflare.com)

### États de connectivité
```dart
enum ConnectivityStatus { connected, disconnected, checking }
```

### ConnectivityBanner
- Bannière rouge animée "Vous êtes hors ligne. Certaines fonctionnalités peuvent être limitées."
- Apparaît/disparaît avec slide animation
- S'affiche uniquement dans les écrans qui consomment le provider

## 30. Client HTTP — Dio avec Intercepteurs

### Configuration Dio
```dart
Dio dio = Dio(BaseOptions(
  baseUrl: 'http://10.0.2.2:8000/api', // Android Emulator → localhost
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 10),
  headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
));
```

### Intercepteurs
1. **AuthInterceptor** — Injecte `Authorization: Bearer <token>` depuis SharedPreferences dans chaque requête. Gère le refresh automatique du token (403 → refresh → retry).
2. **CacheInterceptor** — Intercepte les réponses GET, les stocke dans Hive avec TTL. En mode hors-ligne, sert les données depuis le cache.
3. **RetryInterceptor** — Retry automatique (3 tentatives) avec backoff exponentiel en cas d'erreur réseau.
4. **LoggingInterceptor** — Log des requêtes et réponses en mode debug.
5. **ErrorInterceptor** — Mapping des codes HTTP en exceptions Dart métier (UnauthorizedException, NotFoundException, ValidationException, ServerException).
