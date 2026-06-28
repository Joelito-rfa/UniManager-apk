import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/connection_status_provider.dart';
import '../../core/localization/app_strings.dart';

class ConnectionStatus extends ConsumerWidget {
  const ConnectionStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = ref.watch(appStringsProvider);
    final async = ref.watch(connectionStatusProvider);

    return async.when(
      data: (isConnected) => Tooltip(
        message: isConnected ? s.online : s.offline,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: (isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withAlpha(10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isConnected ? s.online : s.offline,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const SizedBox(width: 48, height: 20),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
