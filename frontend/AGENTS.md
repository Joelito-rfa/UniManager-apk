# UniManager APP — Session Recap

## Goal
Transformer le frontend Flutter d'UniManager en une application Android native prête pour la production avec toutes les optimisations.

## Constraints & Preferences
- Conserver toute la logique métier existante, ne supprimer aucune fonctionnalité.
- Utiliser uniquement les bonnes pratiques Flutter, Material 3.
- Compatible Android 8 à 16 (minSdk 24, compileSdk 35).
- Doit compiler sans erreur avec `flutter clean && flutter pub get && flutter build apk --release` et `flutter build appbundle --release`.
- Rapports finaux en français.

## Progress
### Done
- **Correction bug navigation prof ressources :** `context.go()` → `context.push()` dans `teacher/course_resource_list_screen.dart:103` et `admin/course_resource_list_screen.dart:100` pour que le bouton retour ramène à la liste des ressources.
- **Blanc pur zones de texte admin :** `filter_bar.dart:82`, `data_table_widget.dart:89`, `schedule_list_screen.dart:80`, `grade_management_screen.dart:94` changés en `Colors.white`.
- **PHASE 1 — Config Android :** `AndroidManifest.xml` (INTERNET, CAMERA, STORAGE, label "UniManager", largeHeap, cleartext), `build.gradle.kts` (minSdk=24, targetSdk=35, versionCode/Name, split ABIs, release signing config + proguard), `gradle.properties` (parallel, caching, daemon), `proguard-rules.pro` créé, `app_config.dart` réécrit (baseUrl Android 10.0.2.2, timeouts, retry config).
- **PHASE 2 — Cache, offline, connectivité :** `connectivity_service.dart` (connectivity_plus + internet_connection_checker), `cache_service.dart` (Hive box cache + responses TTL), `dio_client.dart` réécrit (auth interceptor avec refresh token auto, retry interceptor, cache interceptor, upload/download methods, offline fallback vers cache).
- **PHASE 2 — Dépendances :** `pubspec.yaml` enrichi (hive, flutter_cache_manager, flutter_animate, lottie, skeletonizer, permission_handler, internet_connection_checker, freezed, logger, etc.).
- **PHASE 2 — main.dart réécrit :** Initialisation Hive + SharedPreferences + orientation lock, splash screen animé (gradient violet + logo UM + fadeIn/scale), `_ConnectivityBanner` (banner rouge quand offline), `routerProvider` + `themeModeProvider`.
- **Pagination :** `pagination_model.dart` créé (PaginatedResponse, PaginationParams, fromJson paginé Laravel).
- **Génération code invitation admin :** `api_constants.dart` (+generateInvitationCode), `auth_service.dart` (+generateInvitationCode()), `settings_screen.dart` (+ section "Codes d'invitation administrateur" avec bouton + dialogue copie presse-papier).
- **PHASE 2 — Infrastructure restante :** `app_exception.dart` (gestion erreurs Dio), `skeleton_loading.dart` (SkeletonLoading, SkeletonCard, SkeletonList, SkeletonTable), `offline_widget.dart` (OfflineAwareWidget, NoInternetScreen).

### In Progress
- *(none)*

### Blocked
- *(none)*

## Key Decisions
- **minSdk 24** pour Android 7+ avec compatibilité optimale et support Hive/plugins modernes.
- **Hive** pour le cache local plutôt que SQLite : plus rapide, sans requêtes SQL, adapté au stockage clé-valeur d'API.
- **Double vérification connectivité** (connectivity_plus pour réseau, internet_connection_checker pour vrai accès internet) pour fiabilité.
- **Rolling retry** avec délai progressif (retryDelay * (attempt+1)) pour éviter la thundering herd.
- **Splash custom animé** plutôt que flutter_native_splash pure pour un aspect plus professionnel.

## Next Steps
- **PHASE 3 :** UI/UX — Ajouter skeleton loading (skeletonizer), animations fluides (flutter_animate), pull-to-refresh systématique, responsive breakpoints.
- **PHASE 4 :** Optimisations — Images (cached_network_image déjà), vidéos (preloading), mémoire (dispose providers), Riverpod (autoDispose, family).
- **PHASE 5 :** Build — Générer key.properties + keystore, configurer Play Store listing, tester compilation release.
- Ajouter écran de chargement élégant (lottie animations) sur chaque dashboard.

## Critical Context
- Le backend utilise PostgreSQL et JWT ; le refresh token est géré via l'intercepteur Dio.
- `flutter compileSdkVersion` / `flutter minSdkVersion` ont été remplacés par des valeurs explicites (35/24) dans le build.gradle.kts.
- La signature release nécessite un fichier `android/key.properties` (storeFile, storePassword, keyAlias, keyPassword) — pas encore créé.
- La bannière offline utilise `connectivityStatusProvider` (StreamProvider) pour réagir en temps réel.

## Relevant Files
- `frontend/android/app/build.gradle.kts` : configuration complète Android (SDK, ABIs, signing, ProGuard)
- `frontend/android/app/src/main/AndroidManifest.xml` : permissions et configuration app
- `frontend/android/app/proguard-rules.pro` : règles ProGuard Flutter/Dio/Riverpod
- `frontend/lib/main.dart` : point d'entrée avec splash, connectivity banner, providers
- `frontend/lib/config/app_config.dart` : baseUrl, timeouts, pagination settings
- `frontend/lib/core/network/dio_client.dart` : client HTTP avec auth, retry, cache, offline
- `frontend/lib/core/connectivity/connectivity_service.dart` : détection internet temps réel
- `frontend/lib/core/cache/cache_service.dart` : cache Hive avec TTL
- `frontend/lib/core/pagination/pagination_model.dart` : modèle de pagination Laravel
- `frontend/lib/core/errors/app_exception.dart` : gestion erreurs réseau
- `frontend/lib/widgets/common/skeleton_loading.dart` : composants skeleton
- `frontend/lib/widgets/common/offline_widget.dart` : composants offline
- `frontend/lib/widgets/common/data_table_widget.dart` : fillColor blanc + icones adaptées
- `frontend/lib/widgets/common/filter_bar.dart` : fillColor blanc
- `frontend/lib/screens/admin/settings_screen.dart` : section codes d'invitation admin
