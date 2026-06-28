import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sidebar.dart';
import '../top_bar/app_top_bar.dart';

class AppScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  bool _isCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isTablet = width >= 600 && width < 900;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          Sidebar(isCollapsed: _isCollapsed, onToggle: _toggleSidebar),
          Expanded(
            child: Container(
              decoration: _buildPurpleGradient(),
              child: Column(
                children: [
                  const AppTopBar(isMobile: false),
                  Expanded(child: _buildTransparentChild()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          Sidebar(isCollapsed: _isCollapsed, onToggle: _toggleSidebar),
          Expanded(
            child: Container(
              decoration: _buildPurpleGradient(),
              child: Column(
                children: [
                  AppTopBar(isMobile: true, onMenuTap: _toggleSidebar),
                  Expanded(child: _buildTransparentChild()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        elevation: 0,
        child: Sidebar(
          isCollapsed: false,
          onToggle: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: _buildPurpleGradient(),
        child: Column(
          children: [
            AppTopBar(
              isMobile: true,
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(child: _buildTransparentChild()),
          ],
        ),
      ),
    );
  }

  Widget _buildTransparentChild() {
    final base = Theme.of(context);
    final isDark = base.brightness == Brightness.dark;
    return Theme(
      data: base.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        colorScheme: base.colorScheme.copyWith(
          surfaceContainerHighest: isDark
              ? const Color(0xFF7C3AED).withAlpha(25)
              : const Color(0xFF8B5CF6).withAlpha(18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: widget.child,
        ),
      ),
    );
  }

  BoxDecoration _buildPurpleGradient() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topLeft,
        radius: 1.5,
        colors: isDark
            ? [
                const Color(0xFF8B5CF6).withAlpha(20),
                const Color(0xFF1E1B4B),
                const Color(0xFF7C3AED).withAlpha(80),
              ]
            : [
                const Color(0xFF8B5CF6).withAlpha(30),
                const Color(0xFFF5F3FF),
                const Color(0xFF7C3AED).withAlpha(120),
              ],
      ),
    );
  }

  void _toggleSidebar() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }
}
