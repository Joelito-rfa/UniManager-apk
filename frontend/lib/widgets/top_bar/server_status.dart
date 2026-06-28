import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/server_status_provider.dart';
import '../../core/localization/app_strings.dart';

class ServerStatus extends ConsumerStatefulWidget {
  const ServerStatus({super.key});

  @override
  ConsumerState<ServerStatus> createState() => _ServerStatusState();
}

class _ServerStatusState extends ConsumerState<ServerStatus> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serverStatusProvider.notifier).check();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(appStringsProvider);
    final state = ref.watch(serverStatusProvider);

    Color color;
    String label;

    switch (state.status) {
      case 'operational':
        color = const Color(0xFF10B981);
        label = s.operational;
      case 'maintenance':
        color = const Color(0xFFF59E0B);
        label = s.maintenance;
      default:
        color = const Color(0xFFEF4444);
        label = s.downtime;
    }

    return Tooltip(
      message: '${s.serverStatus}: $label (${state.responseTimeMs}ms)',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w500, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
