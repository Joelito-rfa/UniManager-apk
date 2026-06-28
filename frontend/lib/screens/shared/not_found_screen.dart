import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withAlpha(120),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
              ),
              const SizedBox(height: 16),
              Text('404', style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.error)),
              const SizedBox(height: 8),
              Text('La page est introuvable', style: theme.textTheme.titleLarge),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
