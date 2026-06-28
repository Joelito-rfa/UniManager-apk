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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Photo de profil', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(ctx, Icons.camera_alt_rounded, 'Appareil', ImageSource.camera),
                  _buildImageOption(ctx, Icons.photo_library_rounded, 'Galerie', ImageSource.gallery),
                ],
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

  Widget _buildImageOption(BuildContext ctx, IconData icon, String label, ImageSource source) {
    final theme = Theme.of(ctx);
    return GestureDetector(
      onTap: () => Navigator.pop(ctx, source),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(80)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(120),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 28),
            ),
            const SizedBox(height: 10),
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final role = user?.role ?? 'student';
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                        : [theme.colorScheme.primary, theme.colorScheme.primary.withAlpha(180)],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(8),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(6),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Spacer(),
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withAlpha(80), width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(40),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.white.withAlpha(30),
                                backgroundImage: _avatarImage(user?.avatar),
                                child: user?.avatar == null
                                    ? Icon(Icons.person_rounded, size: 48, color: Colors.white.withAlpha(180))
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
                                    border: Border.all(color: Colors.white, width: 2.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(30),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: _uploading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?.name ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user?.email ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: _getRoleColor(role).withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withAlpha(50)),
                          ),
                          child: Text(
                            _getRoleLabel(role),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  _buildSectionTitle(theme, Icons.info_rounded, 'Informations'),
                  const SizedBox(height: 12),
                  _buildModernInfoCard(theme, <Widget>[
                    _buildInfoRow(theme, Icons.email_rounded, 'Email', user?.email ?? ''),
                    _buildInfoRow(theme, Icons.badge_rounded, 'Rôle', _getRoleLabel(role)),
                    _buildInfoRow(theme, Icons.phone_rounded, 'Téléphone', user?.phone ?? 'Non renseigné'),
                    _buildInfoRow(theme, Icons.info_rounded, 'Statut', user?.status == 'active' ? 'Actif' : user?.status ?? ''),
                  ]),
                ] + _buildStatsSection(theme, role) + <Widget>[
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      '${AppConfig.appName} v1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatsSection(ThemeData theme, String role) {
    if (role == 'student') {
      return <Widget>[
        const SizedBox(height: 24),
        _buildSectionTitle(theme, Icons.analytics_rounded, 'Statistiques'),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(child: _buildModernStatBox(theme, 'Moyenne', '14.5/20', const Color(0xFF059669), Icons.trending_up_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildModernStatBox(theme, 'Classement', '8e/45', const Color(0xFF4F46E5), Icons.leaderboard_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildModernStatBox(theme, 'Crédits', '42/60', const Color(0xFFD97706), Icons.auto_awesome_rounded)),
          ],
        ),
      ];
    }
    if (role == 'teacher') {
      return <Widget>[
        const SizedBox(height: 24),
        _buildSectionTitle(theme, Icons.analytics_rounded, 'Statistiques'),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(child: _buildModernStatBox(theme, 'Cours', '4', const Color(0xFF4F46E5), Icons.menu_book_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildModernStatBox(theme, 'Étudiants', '86', const Color(0xFF0D9488), Icons.people_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildModernStatBox(theme, 'Réussite', '78%', const Color(0xFF059669), Icons.emoji_events_rounded)),
          ],
        ),
      ];
    }
    if (role == 'admin') {
      return <Widget>[
        const SizedBox(height: 24),
        _buildSectionTitle(theme, Icons.analytics_rounded, 'Statistiques'),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(child: _buildModernStatBox(theme, 'Utilisateurs', '245', const Color(0xFF4F46E5), Icons.people_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildModernStatBox(theme, 'Actifs', '92%', const Color(0xFF0D9488), Icons.check_circle_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildModernStatBox(theme, 'Examens', '12', const Color(0xFFE11D48), Icons.quiz_rounded)),
          ],
        ),
      ];
    }
    return <Widget>[];
  }

  Widget _buildSectionTitle(ThemeData theme, IconData icon, String title) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withAlpha(120),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildModernInfoCard(ThemeData theme, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(80)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: rows),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outlineVariant, size: 20),
        ],
      ),
    );
  }

  Widget _buildModernStatBox(ThemeData theme, String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withAlpha(8),
        border: Border.all(color: color.withAlpha(20)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          ),
          const SizedBox(height: 4),
          Text(label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return const Color(0xFF4F46E5);
      case 'teacher': return const Color(0xFF0D9488);
      case 'student': return const Color(0xFFE11D48);
      default: return const Color(0xFF64748B);
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin': return 'ADMIN';
      case 'teacher': return 'ENSEIGNANT';
      case 'student': return 'ÉTUDIANT';
      default: return role.toUpperCase();
    }
  }
}
