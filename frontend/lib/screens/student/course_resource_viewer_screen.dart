import 'dart:io' show File;
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../models/course_resource_model.dart';
import '../../core/constants/api_constants.dart';
import '../../services/storage_service.dart';
import '../../core/network/dio_client.dart';
import '../../config/app_config.dart';
import '../../core/utils/file_utils.dart';
class CourseResourceViewerScreen extends ConsumerStatefulWidget {
  final CourseResourceModel resource;
  final String downloadBaseEndpoint;

  const CourseResourceViewerScreen({
    super.key,
    required this.resource,
    this.downloadBaseEndpoint = ApiConstants.studentResourceDownload,
  });

  @override
  ConsumerState<CourseResourceViewerScreen> createState() => _CourseResourceViewerScreenState();
}

enum _VideoState { preview, loading, ready, error }

class _CourseResourceViewerScreenState extends ConsumerState<CourseResourceViewerScreen> {
  VideoPlayerController? _videoController;
  _VideoState _videoState = _VideoState.preview;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initVideo() async {
    _videoController?.dispose();
    _videoController = null;
    setState(() => _videoState = _VideoState.loading);
    final endpoint = '${widget.downloadBaseEndpoint}/${widget.resource.id}/download';
    if (kIsWeb) {
      try {
        Uri videoUri;
        if (widget.resource.fileUrl != null) {
          videoUri = Uri.parse(widget.resource.fileUrl!);
        } else {
          final token = await ref.read(storageServiceProvider).getToken();
          videoUri = Uri.parse('${AppConfig.baseUrl}$endpoint?token=$token');
        }
        _videoController = VideoPlayerController.networkUrl(videoUri);
        await _videoController!.initialize();
        if (mounted) {
          setState(() => _videoState = _VideoState.ready);
          _videoController!.play();
          _isPlaying = true;
        }
      } catch (e) {
        developer.log('Video web init failed: $e');
        if (mounted) {
          try {
            final token = await ref.read(storageServiceProvider).getToken();
            final fallbackUri = Uri.parse('${AppConfig.baseUrl}$endpoint?token=$token');
            _videoController = VideoPlayerController.networkUrl(fallbackUri);
            await _videoController!.initialize();
            if (mounted) {
              setState(() => _videoState = _VideoState.ready);
              _videoController!.play();
              _isPlaying = true;
            }
          } catch (e2) {
            developer.log('Video web fallback failed: $e2');
            if (mounted) setState(() => _videoState = _VideoState.error);
          }
        }
      }
    } else {
      try {
        final dir = await getTemporaryDirectory();
        final fileName = widget.resource.fileName ?? '${widget.resource.title}.mp4';
        final savePath = '${dir.path}/$fileName';
        final dio = ref.read(dioClientProvider);
        await dio.download(endpoint, savePath);
        if (!mounted) return;
        _videoController = VideoPlayerController.file(File(savePath));
        await _videoController!.initialize();
        if (mounted) {
          setState(() => _videoState = _VideoState.ready);
          _videoController!.play();
          _isPlaying = true;
        }
      } catch (e) {
        developer.log('Video mobile init failed: $e');
        if (mounted) setState(() => _videoState = _VideoState.error);
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_videoController == null) return;
    if (_isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _webDownload(String endpoint) async {
    if (!kIsWeb) return;
    try {
      final token = await ref.read(storageServiceProvider).getToken();
      final url = '${AppConfig.baseUrl}$endpoint?token=$token';
      await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Téléchargement en cours...')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec du téléchargement : $e')),
        );
      }
    }
  }

  Future<void> _downloadAndOpen() async {
    final endpoint = '${widget.downloadBaseEndpoint}/${widget.resource.id}/download';
    if (kIsWeb) {
      try {
        final token = await ref.read(storageServiceProvider).getToken();
        final url = '${AppConfig.baseUrl}$endpoint?token=$token';
        openUrlInNewTab(url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ouverture du fichier...')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de l\'ouverture : $e')),
          );
        }
      }
    } else {
      try {
        final dir = await getTemporaryDirectory();
        final fileName = widget.resource.fileName ?? '${widget.resource.title}.${widget.resource.type}';
        final savePath = '${dir.path}/$fileName';
        final dio = ref.read(dioClientProvider);
        await dio.download(endpoint, savePath);
        if (mounted) {
          final result = await OpenFile.open(savePath);
          if (mounted && result.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fichier téléchargé : $savePath')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec du téléchargement : $e')),
          );
        }
      }
    }
  }

  Future<void> _downloadFile(String endpoint) async {
    if (kIsWeb) {
      await _webDownload(endpoint);
    } else {
      try {
        final dir = await getTemporaryDirectory();
        final fileName = widget.resource.fileName ?? '${widget.resource.title}.${widget.resource.type}';
        final savePath = '${dir.path}/$fileName';
        final dio = ref.read(dioClientProvider);
        await dio.download(endpoint, savePath);
        if (mounted) {
          final result = await OpenFile.open(savePath);
          if (mounted && result.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fichier téléchargé : $savePath')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec du téléchargement : $e')),
          );
        }
      }
    }
  }

  String _downloadEndpoint() => '${widget.downloadBaseEndpoint}/${widget.resource.id}/download';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('L\'ouverture du lien a échoué')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(widget.resource.title),
        actions: [
          if (widget.resource.fileUrl != null || widget.resource.filePath != null)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Télécharger',
              onPressed: () => _downloadFile(_downloadEndpoint()),
            ),
        ],
      ),
      body: widget.resource.type == 'link' && widget.resource.url != null
          ? _buildLinkView(context, theme)
          : widget.resource.type == 'pdf'
              ? _buildPdfView(context, theme)
              : widget.resource.type == 'video'
                  ? _buildVideoView(context, theme)
                  : _buildDocumentView(context, theme),
    );
  }

  Widget _buildPdfView(BuildContext context, ThemeData theme) {
    if (widget.resource.fileUrl == null && widget.resource.filePath == null) {
      return const Center(child: Text('Le fichier est indisponible'));
    }
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf_rounded, size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(widget.resource.fileName ?? widget.resource.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (widget.resource.fileSizeFormatted != null)
                  Text(widget.resource.fileSizeFormatted!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Ouvrir le PDF'),
                    onPressed: _downloadAndOpen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Télécharger'),
                    onPressed: () => _downloadFile(_downloadEndpoint()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoView(BuildContext context, ThemeData theme) {
    if (widget.resource.fileUrl == null && widget.resource.filePath == null) {
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

    switch (_videoState) {
      case _VideoState.preview:
        return _buildVideoPreview(theme);
      case _VideoState.loading:
        return _buildVideoLoading(theme);
      case _VideoState.error:
        return _buildVideoError(theme);
      case _VideoState.ready:
        return _buildVideoPlayer(theme);
    }
  }

  Widget _buildVideoPreview(ThemeData theme) {
    final hasThumbnail = widget.resource.thumbnailUrl != null;

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _initVideo,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: !hasThumbnail
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.secondaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (hasThumbnail)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: widget.resource.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: theme.colorScheme.primaryContainer,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: theme.colorScheme.primaryContainer,
                        ),
                      ),
                    ),
                  if (hasThumbnail)
                    Positioned.fill(
                      child: Container(color: Colors.black.withAlpha(80)),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_fill_rounded, size: 80,
                        color: Colors.white.withAlpha(200)),
                      const SizedBox(height: 16),
                      Text(widget.resource.title,
                        style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      if (widget.resource.fileSizeFormatted != null)
                        Text(widget.resource.fileSizeFormatted!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withAlpha(180))),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                            const SizedBox(width: 8),
                            Text('Lire la vidéo', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 3)),
          const SizedBox(height: 24),
          Text('Préparation de la vidéo...', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text('Téléchargement et initialisation en cours', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildVideoError(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Échec du chargement', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('La vidéo n\'a pas pu être chargée', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
            onPressed: _initVideo,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _togglePlay,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(child: VideoPlayer(_videoController!)),
                if (!_isPlaying)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(140),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                  ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                VideoProgressIndicator(_videoController!, allowScrubbing: true, colors: VideoProgressColors(playedColor: theme.colorScheme.primary, backgroundColor: theme.colorScheme.surfaceContainerHighest)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      onPressed: _togglePlay,
                    ),
                    Expanded(child: Text(widget.resource.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
                    IconButton(
                      icon: const Icon(Icons.download_rounded),
                      tooltip: 'Télécharger',
                      onPressed: () => _downloadFile(_downloadEndpoint()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkView(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.link_rounded, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(widget.resource.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.resource.url ?? '',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Ouvrir le lien'),
            onPressed: () => _openUrl(widget.resource.url!),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentView(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_rounded, size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(widget.resource.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (widget.resource.fileSizeFormatted != null)
                  Text(widget.resource.fileSizeFormatted!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        if (widget.resource.fileUrl != null || widget.resource.filePath != null)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.visibility_rounded),
                      label: const Text('Ouvrir'),
                      onPressed: _downloadAndOpen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Télécharger'),
                      onPressed: () => _downloadFile(_downloadEndpoint()),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
