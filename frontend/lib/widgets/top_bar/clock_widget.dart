import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ClockWidget extends ConsumerStatefulWidget {
  final bool compact;

  const ClockWidget({super.key, this.compact = false});

  @override
  ConsumerState<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends ConsumerState<ClockWidget> {
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF4F46E5).withAlpha(10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          DateFormat('HH:mm', 'fr').format(_now),
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF4F46E5),
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withAlpha(10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: const Color(0xFF4F46E5), size: 14),
              const SizedBox(width: 6),
              Text(
                DateFormat('d MMM yyyy', 'fr').format(_now),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF4F46E5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A5F).withAlpha(10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            DateFormat('HH:mm:ss', 'fr').format(_now),
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF1E3A5F),
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
