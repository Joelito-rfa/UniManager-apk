import 'package:flutter/material.dart';

class FilterOption<T> {
  final T? value;
  final String label;

  const FilterOption({required this.value, required this.label});
}

class FilterBar extends StatelessWidget {
  final List<FilterDropdown> dropdowns;

  const FilterBar({super.key, required this.dropdowns});

  @override
  Widget build(BuildContext context) {
    if (dropdowns.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: dropdowns.map((d) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: dropdowns.indexOf(d) > 0 ? 8 : 0,
                right: dropdowns.indexOf(d) < dropdowns.length - 1 ? 8 : 0,
              ),
              child: d,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String label;
  final dynamic value;
  final List<FilterOption> options;
  final ValueChanged<dynamic> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<dynamic>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        isDense: true,
      ),
      items: options.map((opt) {
        return DropdownMenuItem(
          value: opt.value,
          child: Text(
            opt.label,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
