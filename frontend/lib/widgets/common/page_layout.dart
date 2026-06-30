import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'loading_widget.dart';
import 'error_widget.dart';
import 'empty_state.dart';

class PageLayout extends StatelessWidget {
  final bool isLoading;
  final String? loadingMessage;
  final String? error;
  final VoidCallback? onRetry;
  final bool isEmpty;
  final String? emptyMessage;
  final Widget Function() bodyBuilder;
  final Future<void> Function()? onRefresh;

  const PageLayout({
    super.key,
    this.isLoading = false,
    this.loadingMessage,
    this.error,
    this.onRetry,
    this.isEmpty = false,
    this.emptyMessage,
    required this.bodyBuilder,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && !_hasData) {
      return _buildLoading(context);
    }

    if (error != null && !_hasData) {
      return _buildError();
    }

    if (isEmpty) {
      return _buildEmpty();
    }

    final body = bodyBuilder();

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: _isScrollable(body) ? body : _wrapInScrollView(body),
      );
    }

    return body;
  }

  bool get _hasData => error == null && !isEmpty;

  Widget _buildLoading(BuildContext context) {
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 400,
            child: LoadingWidget(message: loadingMessage),
          ),
        ),
      );
    }
    return LoadingWidget(message: loadingMessage);
  }

  Widget _buildError() {
    return AppErrorWidget(
      message: error!,
      onRetry: onRetry,
    );
  }

  Widget _buildEmpty() {
    return EmptyState(title: emptyMessage ?? 'Aucune donnée disponible');
  }

  bool _isScrollable(Widget widget) {
    return widget is Scrollable || widget is ListView || widget is GridView || widget is CustomScrollView;
  }

  Widget _wrapInScrollView(Widget child) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: child,
    );
  }
}

extension AnimatedEntry on Widget {
  Widget fadeIn({int delay = 0, Duration duration = const Duration(milliseconds: 200)}) {
    return animate()
        .fadeIn(duration: duration, delay: delay.ms)
        .slideX(begin: 0.05, duration: duration, delay: delay.ms);
  }

  Widget scaleIn({int delay = 0}) {
    return animate()
        .scale(delay: delay.ms, duration: 300.ms, begin: Offset(0.95, 0.95), curve: Curves.easeOutBack);
  }

  Widget slideUp({int delay = 0}) {
    return animate()
        .slideY(begin: 0.1, duration: 300.ms, delay: delay.ms, curve: Curves.easeOut)
        .fadeIn(duration: 200.ms, delay: delay.ms);
  }
}
