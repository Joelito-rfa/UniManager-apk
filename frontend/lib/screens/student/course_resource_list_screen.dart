import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/course_resource_provider.dart';
import '../../models/course_model.dart';
import '../../models/course_resource_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';

class StudentCourseResourceListScreen extends ConsumerStatefulWidget {
  final CourseModel course;

  const StudentCourseResourceListScreen({super.key, required this.course});

  @override
  ConsumerState<StudentCourseResourceListScreen> createState() => _StudentCourseResourceListScreenState();
}

class _StudentCourseResourceListScreenState extends ConsumerState<StudentCourseResourceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResources();
    });
  }

  String get _endpoint => '${ApiConstants.studentResources}/${widget.course.id}/resources';

  void _loadResources() {
    ref.read(courseResourceProvider(_endpoint).notifier).loadResources(_endpoint);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseResourceProvider(_endpoint));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Ressources - ${widget.course.subjectName ?? ''}')),
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
      return const EmptyState(
        title: 'Aucune ressource',
        subtitle: 'Aucune ressource disponible pour ce cours.',
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
    IconData icon;
    Color iconColor;
    String label;
    switch (resource.type) {
      case 'pdf':
        icon = Icons.picture_as_pdf_rounded;
        iconColor = const Color(0xFFE11D48);
        label = 'PDF';
        break;
      case 'video':
        icon = Icons.videocam_rounded;
        iconColor = const Color(0xFF6366F1);
        label = 'Vidéo';
        break;
      case 'link':
        icon = Icons.link_rounded;
        iconColor = const Color(0xFF0EA5E9);
        label = 'Lien';
        break;
      default:
        icon = Icons.description_rounded;
        iconColor = const Color(0xFF10B981);
        label = 'Document';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (resource.fileUrl != null) {
            context.push('/student/resources/${resource.id}/view', extra: resource);
          } else if (resource.url != null) {
            context.push('/student/resources/${resource.id}/view', extra: resource);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: iconColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (resource.fileSizeFormatted != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${resource.fileSizeFormatted}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
