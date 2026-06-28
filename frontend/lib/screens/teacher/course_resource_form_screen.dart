import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/course_resource_provider.dart';
import '../../models/course_model.dart';

class CourseResourceFormScreen extends ConsumerStatefulWidget {
  final CourseModel course;

  const CourseResourceFormScreen({super.key, required this.course});

  @override
  ConsumerState<CourseResourceFormScreen> createState() => _CourseResourceFormScreenState();
}

class _CourseResourceFormScreenState extends ConsumerState<CourseResourceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedType = 'pdf';
  String? _selectedFilePath;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  String get _endpoint => '${ApiConstants.teacherCourses}/${widget.course.id}/resources';

  Future<void> _pickFile() async {
    try {
      final result = await pickFileDialog();
      if (result != null && mounted) {
        setState(() {
          _selectedFilePath = result.path;
          _selectedFileName = result.name;
          _selectedFileSize = result.size;
        });
      }
    } catch (_) {}
  }

  Future<PlatformFile?> pickFileDialog() async {
    final type = _selectedType;
    final allowedExtensions = type == 'pdf'
        ? ['pdf']
        : type == 'video'
            ? ['mp4', 'mov', 'avi', 'mkv', 'webm']
            : type == 'document'
                ? ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt', 'csv', 'zip', 'rar', '7z', 'jpg', 'jpeg', 'png', 'gif', 'webp']
                : ['pdf'];
    final result = await FilePicker.platform.pickFiles(
      type: type == 'video' ? FileType.video : FileType.custom,
      allowedExtensions: type != 'video' ? allowedExtensions : null,
    );
    if (result != null && result.files.single.path != null) {
      return result.files.single;
    }
    return null;
  }

  Future<void> _previewFile() async {
    if (_selectedFilePath == null) return;
    try {
      await OpenFile.open(_selectedFilePath!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir le fichier : $e')),
        );
      }
    }
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes o';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} Ko';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType != 'link' && _selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir un fichier')),
      );
      return;
    }

    if (_selectedType == 'link' && _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez fournir une URL')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final success = await ref.read(courseResourceProvider(_endpoint).notifier).uploadResource(
      _endpoint,
      title: _titleController.text.trim(),
      type: _selectedType,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      url: _selectedType == 'link' ? _urlController.text.trim() : null,
      filePath: _selectedFilePath,
    );

    if (mounted) {
      setState(() => _isUploading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ressource ajoutée avec succès')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('L\'ajout a échoué')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une ressource')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  hintText: 'Ex: Chapitre 1 - Introduction',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Le titre est requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                  hintText: 'Description de la ressource...',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Type *'),
                items: const [
                  DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                  DropdownMenuItem(value: 'video', child: Text('Vidéo')),
                  DropdownMenuItem(value: 'link', child: Text('Lien')),
                  DropdownMenuItem(value: 'document', child: Text('Document')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
              ),
              const SizedBox(height: 16),
              if (_selectedType == 'link') ...[
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL *',
                    hintText: 'https://...',
                  ),
                  keyboardType: TextInputType.url,
                  validator: (v) {
                    if (_selectedType == 'link' && (v == null || v.trim().isEmpty)) {
                      return 'L\'URL est requise';
                    }
                    return null;
                  },
                ),
              ] else ...[
                if (_selectedFilePath != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.primaryContainer.withAlpha(60),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.insert_drive_file_rounded,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFileName ?? 'Fichier sélectionné',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_selectedFileSize != null)
                                    Text(
                                      _formatFileSize(_selectedFileSize),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.remove_red_eye_rounded),
                                tooltip: 'Aperçu',
                                onPressed: _previewFile,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                            label: const Text('Changer de fichier'),
                            onPressed: _pickFile,
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  InkWell(
                    onTap: _pickFile,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline.withAlpha(80),
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.upload_file_rounded,
                            size: 40,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cliquez pour choisir un fichier',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isUploading ? null : _submit,
                icon: _isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.upload_rounded),
                label: Text(_isUploading ? 'Upload en cours...' : 'Publier la ressource'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
