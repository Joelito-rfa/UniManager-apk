import 'package:flutter/material.dart';

class PopupAction {
  final String value;
  final IconData icon;
  final String label;
  final Color? color;

  const PopupAction({
    required this.value,
    required this.icon,
    required this.label,
    this.color,
  });
}

class ActionPopupMenu extends StatelessWidget {
  final List<PopupAction> actions;
  final ValueChanged<String> onSelected;

  const ActionPopupMenu({
    super.key,
    required this.actions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      shadowColor: Colors.black.withAlpha(20),
      onSelected: onSelected,
      itemBuilder: (context) => actions.map((action) {
        final isDestructive = action.color == Colors.red ||
            action.color == theme.colorScheme.error;
        return PopupMenuItem(
          value: action.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (action.color ?? theme.colorScheme.primary)
                        .withAlpha(isDestructive ? 20 : 15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color ?? theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  action.label,
                  style: TextStyle(
                    color: action.color ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(60),
          ),
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }
}
