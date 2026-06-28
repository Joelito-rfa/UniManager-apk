import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/preferences_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);

    final flags = {
      'fr': '🇫🇷',
      'en': '🇬🇧',
      'mg': '🇲🇬',
    };

    final labels = {
      'fr': 'FR',
      'en': 'EN',
      'mg': 'MG',
    };

    return Tooltip(
      message: 'Langue',
      child: PopupMenuButton<String>(
        offset: const Offset(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        onSelected: (value) => ref.read(languageProvider.notifier).setLanguage(value),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF14B8A6).withAlpha(10),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14B8A6).withAlpha(10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            labels[currentLang] ?? 'FR',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF14B8A6),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(value: 'fr', child: Text('${flags['fr']}  Français')),
          PopupMenuItem(value: 'en', child: Text('${flags['en']}  English')),
          PopupMenuItem(value: 'mg', child: Text('${flags['mg']}  Malagasy')),
        ],
      ),
    );
  }
}
