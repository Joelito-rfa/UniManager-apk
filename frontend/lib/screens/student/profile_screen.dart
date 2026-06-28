import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploading = false;

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Changer la photo', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Appareil photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Galerie'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 512);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await picked.readAsBytes();
      final base64 = base64Encode(bytes);
      await ref.read(authProvider.notifier).updateProfile({'avatar': base64});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le chargement de l\'image a échoué')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.primaryContainer.withAlpha(180),
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.transparent,
                    backgroundImage: _avatarImage(user?.avatar),
                    child: user?.avatar == null
                        ? Icon(Icons.person_rounded, size: 46, color: theme.colorScheme.primary)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: _uploading ? null : _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.surface, width: 2),
                      ),
                      child: _uploading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Icon(Icons.camera_alt_rounded, size: 18, color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(user?.name ?? '', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(user?.email ?? '', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(leading: Icon(Icons.email_rounded, color: theme.colorScheme.primary), title: const Text('Email'), subtitle: Text(user?.email ?? '')),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  ListTile(leading: Icon(Icons.badge_rounded, color: theme.colorScheme.primary), title: const Text('Rôle'), subtitle: Text(_getRoleLabel(user?.role ?? ''))),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  ListTile(leading: Icon(Icons.phone_rounded, color: theme.colorScheme.primary), title: const Text('Téléphone'), subtitle: Text(user?.phone ?? 'Non renseigné')),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  ListTile(leading: Icon(Icons.info_rounded, color: theme.colorScheme.primary), title: const Text('Statut'), subtitle: Text(user?.status ?? '')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('${AppConfig.appName} v1.0.0', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }

  ImageProvider? _avatarImage(String? avatar) {
    if (avatar == null || avatar.isEmpty) return null;
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return NetworkImage(avatar);
    }
    try {
      return MemoryImage(base64Decode(avatar));
    } catch (_) {
      return null;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin': return 'Administrateur';
      case 'teacher': return 'Enseignant';
      case 'student': return 'Étudiant';
      default: return role;
    }
  }
}
