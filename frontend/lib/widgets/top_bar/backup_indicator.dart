import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/backup_provider.dart';
import '../../core/localization/app_strings.dart';

class BackupIndicator extends ConsumerStatefulWidget {
  const BackupIndicator({super.key});

  @override
  ConsumerState<BackupIndicator> createState() => _BackupIndicatorState();
}

class _BackupIndicatorState extends ConsumerState<BackupIndicator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backupProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(appStringsProvider);
    final state = ref.watch(backupProvider);

    return Tooltip(
      message: state.isCreating ? s.loading : (s.backupNow),
      child: InkWell(
        onTap: state.isCreating ? null : () => ref.read(backupProvider.notifier).create(),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withAlpha(10),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: const Color(0xFF10B981).withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: state.isCreating
                    ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF10B981)))
                    : Icon(Icons.backup_rounded, color: const Color(0xFF10B981), size: 16),
              ),
              const SizedBox(width: 6),
              Text(
                state.lastBackup != null ? s.lastBackup : s.backupNow,
                style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF10B981), fontWeight: FontWeight.w500, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
