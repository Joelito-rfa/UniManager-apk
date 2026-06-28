import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

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
                child: Icon(Icons.lock_outline_rounded, size: 48, color: theme.colorScheme.error),
              ),
              const SizedBox(height: 24),
              Text('L\'accès n\'est pas autorisé', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Vous n\'avez pas les permissions nécessaires pour accéder à cette page.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
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
