import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/course_resource_provider.dart';
import '../../models/course_model.dart';
import '../../models/course_resource_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';

class AdminCourseResourceListScreen extends ConsumerStatefulWidget {
  final CourseModel course;

  const AdminCourseResourceListScreen({super.key, required this.course});

  @override
  ConsumerState<AdminCourseResourceListScreen> createState() => _AdminCourseResourceListScreenState();
}

class _AdminCourseResourceListScreenState extends ConsumerState<AdminCourseResourceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResources();
    });
  }

  String get _endpoint => '${ApiConstants.courses}/${widget.course.id}/resources';

  void _loadResources() {
    ref.read(courseResourceProvider(_endpoint).notifier).loadResources(_endpoint);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseResourceProvider(_endpoint));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ressources - ${widget.course.subjectName ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Ajouter une ressource',
            onPressed: () => _showAddDialog(),
          ),
        ],
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(CourseResourceState state, ThemeData theme) {
    if (state.isLoading && state.resources.isEmpty) {
      return const LoadingWidget(message: 'Chargement des ressources...');
    }
    if (state.error != null && state.resources.isEmpty) {
      return AppErrorWidget(message: state.error!, onRetry: _loadResources);
    }
    if (state.resources.isEmpty) {
      return EmptyState(
        title: 'Aucune ressource',
        subtitle: 'Ce cours n\'a pas encore de ressources.',
        icon: Icons.folder_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadResources(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.resources.length,
        itemBuilder: (context, index) {
          final resource = state.resources[index];
          return _buildResourceCard(theme, resource);
        },
      ),
    );
  }

  Widget _buildResourceCard(ThemeData theme, CourseResourceModel resource) {
    final isVideo = resource.type == 'video';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (resource.fileUrl != null || resource.filePath != null || resource.url != null) {
            context.push('/admin/resources/${resource.id}/view', extra: resource);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isVideo && resource.thumbnailUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: resource.thumbnailUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(color: const Color(0xFF6366F1).withAlpha(20)),
                      errorWidget: (_, __, ___) => Container(color: const Color(0xFF6366F1).withAlpha(20)),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(Icons.delete_outlined, color: Colors.white, size: 20,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                        onPressed: () => _confirmDelete(resource),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.all(isVideo && resource.thumbnailUrl != null ? 8 : 14),
              child: Row(
                children: [
                  if (!(isVideo && resource.thumbnailUrl != null))
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _iconColor(resource.type).withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_iconData(resource.type), color: _iconColor(resource.type), size: 24),
                    ),
                  if (!(isVideo && resource.thumbnailUrl != null))
                    const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.title,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              resource.type.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _iconColor(resource.type),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (resource.fileSizeFormatted != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• ${resource.fileSizeFormatted}',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!(isVideo && resource.thumbnailUrl != null))
                    IconButton(
                      icon: Icon(Icons.delete_outlined, color: theme.colorScheme.error, size: 20),
                      onPressed: () => _confirmDelete(resource),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconData(String type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'video': return Icons.videocam_rounded;
      case 'link': return Icons.link_rounded;
      default: return Icons.description_rounded;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'pdf': return const Color(0xFFE11D48);
      case 'video': return const Color(0xFF6366F1);
      case 'link': return const Color(0xFF0EA5E9);
      default: return const Color(0xFF10B981);
    }
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    String type = 'pdf';
    String? selectedFilePath;
    Uint8List? selectedFileBytes;

    String? selectedFilePathFull;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajouter une ressource'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Titre *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description (optionnelle)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                    DropdownMenuItem(value: 'video', child: Text('Vidéo')),
                    DropdownMenuItem(value: 'document', child: Text('Document')),
                    DropdownMenuItem(value: 'link', child: Text('Lien')),
                  ],
                  onChanged: (v) {
                    setDialogState(() {
                      type = v ?? 'pdf';
                      selectedFilePath = null;
                      selectedFileBytes = null;
                      selectedFilePathFull = null;
                    });
                  },
                ),
                const SizedBox(height: 8),
                if (type == 'link')
                  TextField(
                    controller: urlCtrl,
                    decoration: const InputDecoration(labelText: 'URL *'),
                    keyboardType: TextInputType.url,
                  )
                else if (selectedFilePath != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(60),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.insert_drive_file_rounded, size: 20,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedFilePath!.split('\\').last.split('/').last,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
                                tooltip: 'Aperçu',
                                onPressed: () async {
                                  if (!kIsWeb && selectedFilePathFull != null) {
                                    await OpenFile.open(selectedFilePathFull!);
                                  }
                                },
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                            label: const Text('Changer de fichier', style: TextStyle(fontSize: 12)),
                            onPressed: () async {
                              final allowedExtensions = type == 'pdf'
                                  ? ['pdf']
                                  : type == 'video'
                                      ? ['mp4', 'mov', 'avi']
                                      : ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'zip', 'rar'];
                              final result = await FilePicker.pickFiles(
                                type: type == 'video' ? FileType.video : FileType.custom,
                                allowedExtensions: type != 'video' ? allowedExtensions : null,
                                withData: true,
                              );
                              if (result != null && result.files.single.bytes != null) {
                                final file = result.files.single;
                                setDialogState(() {
                                  selectedFilePath = file.name;
                                  selectedFileBytes = file.bytes;
                                  selectedFilePathFull = kIsWeb ? null : file.path;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  InkWell(
                    onTap: () async {
                      final allowedExtensions = type == 'pdf'
                          ? ['pdf']
                          : type == 'video'
                              ? ['mp4', 'mov', 'avi']
                              : ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'zip', 'rar'];
                      final result = await FilePicker.pickFiles(
                        type: type == 'video' ? FileType.video : FileType.custom,
                        allowedExtensions: type != 'video' ? allowedExtensions : null,
                        withData: true,
                      );
                      if (result != null && result.files.single.bytes != null) {
                                final file = result.files.single;
                                setDialogState(() {
                                  selectedFilePath = file.name;
                                  selectedFileBytes = file.bytes;
                                  selectedFilePathFull = kIsWeb ? null : file.path;
                                });
                              }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withAlpha(80),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.upload_file_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Choisir un fichier'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                if (type != 'link' && selectedFilePath == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez choisir un fichier')),
                  );
                  return;
                }
                if (type == 'link' && urlCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez fournir une URL')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final success = await ref.read(courseResourceProvider(_endpoint).notifier).uploadResource(
                  _endpoint,
                  title: titleCtrl.text.trim(),
                  type: type,
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  url: type == 'link' ? urlCtrl.text.trim() : null,
                  fileBytes: selectedFileBytes,
                  fileName: selectedFilePath,
                );
                if (!success) {
                  final state = ref.read(courseResourceProvider(_endpoint));
                  if (state.error != null) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(state.error!)),
                      );
                    }
                  }
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(CourseResourceModel resource) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Supprimer',
      message: 'Supprimer "${resource.title}" ?',
      isDestructive: true,
      confirmLabel: 'Supprimer',
    );
    if (confirmed == true) {
      final success = await ref.read(courseResourceProvider(_endpoint).notifier)
          .deleteResource('${ApiConstants.adminResourceDownload}/${resource.id}');
      if (success) _loadResources();
    }
  }
}
