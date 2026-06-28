import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickAction {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}

class QuickActions extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActions({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actions.map((action) {
        return InkWell(
          onTap: () => context.go(action.route),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: (MediaQuery.of(context).size.width - 160) / 3,
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 160),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: action.color.withAlpha(10),
              border: Border.all(
                color: action.color.withAlpha(30),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: action.color.withAlpha(25),
                  ),
                  child: Icon(action.icon, color: action.color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
