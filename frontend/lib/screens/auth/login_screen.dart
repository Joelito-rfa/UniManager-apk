import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';
import '../../config/theme_config.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _errorSlideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
    ));
    _errorSlideAnimation = Tween<double>(
      begin: -20,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutBack,
    ));

    _emailFocusNode.addListener(_onEmailFocusChange);
    _passwordFocusNode.addListener(_onPasswordFocusChange);

    _fadeController.forward();
  }

  void _onEmailFocusChange() {
    if (_isEmailFocused != _emailFocusNode.hasFocus) {
      setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
    }
  }

  void _onPasswordFocusChange() {
    if (_isPasswordFocused != _passwordFocusNode.hasFocus) {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        final role = next.user?.role;
        switch (role) {
          case 'admin':
            context.go('/admin/dashboard');
          case 'teacher':
            context.go('/teacher/dashboard');
          case 'student':
            context.go('/student/dashboard');
        }
      }
    });

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final isDesktop = width >= ThemeConfig.laptopBreakpoint;
          final isMobile = width < 700;

          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  const Color(0xFF8B5CF6).withAlpha(35),
                  theme.colorScheme.surface,
                  const Color(0xFF7C3AED).withAlpha(150),
                ],
              ),
            ),
            child: Stack(
              children: [
                if (isDesktop) ...[
                  Positioned(
                    top: -120, left: -120,
                    child: Container(
                      width: 350, height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B5CF6).withAlpha(35),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100, right: -80,
                    child: Container(
                      width: 280, height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7C3AED).withAlpha(30),
                      ),
                    ),
                  ),
                  Positioned(
                    top: height * 0.4, right: -60,
                    child: Container(
                      width: 180, height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFA78BFA).withAlpha(25),
                      ),
                    ),
                  ),
                ],
                SafeArea(
                  child: isDesktop
                      ? _buildDesktopLayout(theme, authState)
                      : isMobile
                          ? _buildMobileLayout(theme, authState)
                          : _buildTabletLayout(theme, authState),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormContent(ThemeData theme, AuthState authState, {bool isMobile = false}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            _buildLogoHeader(theme, centered: isMobile),
            SizedBox(height: isMobile ? 36 : 48),
            _buildGlassCard(theme, authState, compact: isMobile),
            SizedBox(height: isMobile ? 24 : 32),
            _buildRegisterLink(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, AuthState authState) {
    return ClipRect(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _buildFormContent(theme, authState, isMobile: false),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildIllustrationPanel(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(ThemeData theme, AuthState authState) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: _buildFormContent(theme, authState, isMobile: false),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, AuthState authState) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _buildFormContent(theme, authState, isMobile: true),
        ),
      ),
    );
  }

  Widget _buildLogoHeader(ThemeData theme, {bool centered = false}) {
    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: centered ? 48 : 56,
              height: centered ? 48 : 56,
              child: Image.asset(
                'assets/logo.png',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: centered ? 16 : 24),
        Text(
          AppConfig.appName,
          textAlign: centered ? TextAlign.center : null,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Connectez-vous à votre espace',
          textAlign: centered ? TextAlign.center : null,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard(ThemeData theme, AuthState authState, {bool compact = false}) {
    final paddingVal = compact ? 24.0 : 36.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 22 : 28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(compact ? 22 : 28),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(paddingVal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: _isEmailFocused
                          ? const Color(0xFF8B5CF6)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(
                      Icons.lock_outlined,
                      color: _isPasswordFocused
                          ? const Color(0xFF8B5CF6)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    suffixIcon: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          key: ValueKey(_obscurePassword),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: Validators.required,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (v) {
                              setState(() => _rememberMe = v ?? false);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            activeColor: const Color(0xFF8B5CF6),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _rememberMe = !_rememberMe);
                            },
                            child: Text(
                              'Se souvenir de moi',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Mot de passe oublié?',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLoginButton(theme, authState),
                if (authState.status == AuthStatus.error &&
                    authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _buildErrorBanner(theme, authState.error!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme, AuthState authState) {
    final isLoading = authState.status == AuthStatus.loading;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: isMobile ? 48 : 54,
      child: FilledButton(
        onPressed: isLoading ? null : _handleLogin,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF7C3AED).withAlpha(100),
          disabledForegroundColor:
              Colors.white.withAlpha(150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: const Color(0xFF8B5CF6).withAlpha(80),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Se connecter'),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(ThemeData theme, String error) {
    return AnimatedBuilder(
      animation: _errorSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _errorSlideAnimation.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.error.withAlpha(60),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: theme.colorScheme.onError,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Vous n'avez pas de compte?",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () => context.push('/register'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
            child: Text(
              'Créer un compte',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF8B5CF6),
                fontWeight: FontWeight.w700,
              ),
            ),
        ),
      ],
    );
  }

  Widget _buildIllustrationPanel(ThemeData theme) {
    return ClipRect(
      child: Stack(
        clipBehavior: Clip.hardEdge,
      children: [
        ClipRRect(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                image: AssetImage('assets/images/univ.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF5B21B6).withAlpha(160),
                      const Color(0xFF1E1B4B).withAlpha(180),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withAlpha(25),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFA78BFA).withAlpha(20),
            ),
          ),
        ),
        Positioned(
          top: 120,
          right: 40,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C3AED).withAlpha(25),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          right: 100,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFC4B5FD).withAlpha(20),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E1B4B),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withAlpha(80),
                      blurRadius: 50,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withAlpha(50),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Toute votre université. Une seule plateforme.',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.35,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Centralisez la gestion des étudiants, enseignants, cours, notes, emplois du temps et activités académiques grâce à une plateforme moderne, sécurisée, rapide et intuitive.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(200),
                  height: 1.6,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 56),
            _buildFeatureRow(),
            const Spacer(flex: 3),
          ],
        ),
      ],
      ),
    );
  }

  Widget _buildFeatureRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFeatureItem('👨‍💼', 'Administration'),
          _buildFeatureItem('👨‍🏫', 'Enseignement'),
          _buildFeatureItem('🎓', 'Étudiants'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withAlpha(200),
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }
}
