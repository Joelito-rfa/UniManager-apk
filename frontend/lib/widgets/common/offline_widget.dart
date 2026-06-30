import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connectivity/connectivity_service.dart';

class OfflineAwareWidget extends ConsumerWidget {
  final Widget child;
  final Widget? offlineChild;

  const OfflineAwareWidget({
    super.key,
    required this.child,
    this.offlineChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityStatusProvider);
    final isOffline = connectivity.value == ConnectivityStatus.disconnected;

    if (isOffline && offlineChild != null) return offlineChild!;

    return Column(
      children: [
        if (isOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFDC2626),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Mode hors ligne',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: theme.colorScheme.error.withAlpha(100),
            ),
            const SizedBox(height: 24),
            Text(
              'Pas de connexion internet',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez votre connexion et réessayez.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
          ],
        ),
      ),
    );
  }
}
