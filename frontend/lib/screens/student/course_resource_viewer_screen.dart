import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/course_resource_model.dart';
import '../../core/constants/api_constants.dart';
import '../../config/app_config.dart';
import '../../core/network/dio_client.dart';

class CourseResourceViewerScreen extends ConsumerWidget {
  final CourseResourceModel resource;
  final String downloadBaseEndpoint;

  const CourseResourceViewerScreen({
    super.key,
    required this.resource,
    this.downloadBaseEndpoint = ApiConstants.studentResourceDownload,
  });

  String _fullUrl(String? path) {
    if (path == null) return '';
    if (path.startsWith('http')) return path;
    final base = AppConfig.baseUrl.replaceAll('/api', '');
    return '$base$path';
  }

  Future<void> _downloadFile(BuildContext context, WidgetRef ref, String endpoint) async {
    try {
      final dir = await getTemporaryDirectory();
      final fileName = resource.fileName ?? '${resource.title}.${resource.type}';
      final savePath = '${dir.path}/$fileName';

      final dio = ref.read(dioClientProvider);
      await dio.download(endpoint, savePath);

      if (context.mounted) {
        final result = await OpenFile.open(savePath);
        if (context.mounted && result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fichier téléchargé : $savePath')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Le téléchargement a échoué : $e')),
        );
      }
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('L\'ouverture du lien a échoué')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(resource.title),
        actions: [
          if (resource.fileUrl != null)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Télécharger',
              onPressed: () {
                final endpoint = '$downloadBaseEndpoint/${resource.id}/download';
                _downloadFile(context, ref, endpoint);
              },
            ),
        ],
      ),
      body: resource.type == 'link' && resource.url != null
          ? _buildLinkView(context, theme, ref)
          : resource.type == 'pdf'
              ? _buildPdfView(context, theme, ref)
              : resource.type == 'video'
                  ? _buildVideoView(context, theme, ref)
                  : _buildDocumentView(context, theme, ref),
    );
  }

  Widget _buildPdfView(BuildContext context, ThemeData theme, WidgetRef ref) {
    if (resource.fileUrl == null) {
      return const Center(child: Text('Le fichier est indisponible'));
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf_rounded, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(resource.fileName ?? resource.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (resource.fileSizeFormatted != null)
            Text(resource.fileSizeFormatted!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.visibility_rounded),
            label: const Text('Ouvrir le PDF'),
            onPressed: () {
              final fileUrl = _fullUrl(resource.fileUrl);
              _openUrl(context, fileUrl);
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.download_rounded),
            label: const Text('Télécharger'),
            onPressed: () {
              final endpoint = '$downloadBaseEndpoint/${resource.id}/download';
              _downloadFile(context, ref, endpoint);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoView(BuildContext context, ThemeData theme, WidgetRef ref) {
    if (resource.fileUrl != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_rounded, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Vidéo: ${resource.title}', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (resource.fileSizeFormatted != null)
              Text(resource.fileSizeFormatted!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Lire la vidéo'),
              onPressed: () {
                final fileUrl = _fullUrl(resource.fileUrl);
                _openUrl(context, fileUrl);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.download_rounded),
              label: const Text('Télécharger'),
              onPressed: () {
                final endpoint = '$downloadBaseEndpoint/${resource.id}/download';
                _downloadFile(context, ref, endpoint);
              },
            ),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('La vidéo est indisponible', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildLinkView(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.link_rounded, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(resource.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              resource.url ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Ouvrir le lien'),
            onPressed: () {
              _openUrl(context, resource.url!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentView(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_rounded, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(resource.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (resource.fileSizeFormatted != null)
            Text(resource.fileSizeFormatted!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          if (resource.fileUrl != null) ...[
            FilledButton.icon(
              icon: const Icon(Icons.visibility_rounded),
              label: const Text('Ouvrir'),
              onPressed: () {
                final fileUrl = _fullUrl(resource.fileUrl);
                _openUrl(context, fileUrl);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.download_rounded),
              label: const Text('Télécharger'),
              onPressed: () {
                final endpoint = '$downloadBaseEndpoint/${resource.id}/download';
                _downloadFile(context, ref, endpoint);
              },
            ),
          ],
        ],
      ),
    );
  }
}
