import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/errors/app_exception.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../config/theme_config.dart';
import '../../config/app_config.dart';

enum _RegisterRole { student, teacher, admin }

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  _RegisterRole _selectedRole = _RegisterRole.student;
  int _step = 1;

  final _studentNumberController = TextEditingController();
  final _teacherNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _invitationCodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isVerifying = false;
  String? _verificationError;
  Map<String, dynamic>? _verifiedInfo;
  DateTime? _selectedDate;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const _roleIcons = {
    _RegisterRole.student: Icons.school_rounded,
    _RegisterRole.teacher: Icons.menu_book_rounded,
    _RegisterRole.admin: Icons.admin_panel_settings_rounded,
  };

  static const _roleLabels = {
    _RegisterRole.student: 'Étudiant',
    _RegisterRole.teacher: 'Enseignant',
    _RegisterRole.admin: 'Administrateur',
  };

  static const _roleDescriptions = {
    _RegisterRole.student: 'Accédez à vos cours, notes et emploi du temps',
    _RegisterRole.teacher: 'Gérez vos cours et suivez vos étudiants',
    _RegisterRole.admin: 'Administrez l\'établissement',
  };

  static const _roleOrder = [
    _RegisterRole.student,
    _RegisterRole.teacher,
    _RegisterRole.admin,
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _studentNumberController.dispose();
    _teacherNumberController.dispose();
    _dateOfBirthController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _invitationCodeController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _step = 1;
      _verifiedInfo = null;
      _verificationError = null;
      _selectedDate = null;
      _studentNumberController.clear();
      _teacherNumberController.clear();
      _dateOfBirthController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _emailController.clear();
      _nameController.clear();
      _invitationCodeController.clear();
      _obscurePassword = true;
      _obscureConfirmPassword = true;
    });
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
                  Positioned(top: -120, left: -120,
                    child: Container(width: 350, height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B5CF6).withAlpha(35),
                      ),
                    ),
                  ),
                  Positioned(bottom: -100, right: -80,
                    child: Container(width: 280, height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7C3AED).withAlpha(30),
                      ),
                    ),
                  ),
                  Positioned(top: height * 0.4, right: -60,
                    child: Container(width: 180, height: 180,
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
                      : _buildMobileLayout(theme, authState),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, AuthState authState) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: _buildFormColumn(theme, authState),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildIllustrationPanel(theme),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme, AuthState authState) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogoHeader(theme),
                  const SizedBox(height: 32),
                  _buildFormCard(theme, authState),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormColumn(ThemeData theme, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogoHeader(theme),
        const SizedBox(height: 40),
        _buildFormCard(theme, authState),
      ],
    );
  }

  Widget _buildLogoHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/logo.png',
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppConfig.appName,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Créez votre compte',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(ThemeData theme, AuthState authState) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(200),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(100),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAuthToggle(theme),
              const SizedBox(height: 28),
              _buildRoleSelector(theme),
              const SizedBox(height: 28),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: KeyedSubtree(
                  key: ValueKey('${_selectedRole.name}_$_step'),
                  child: _buildRoleForm(theme, authState),
                ),
              ),
              if (authState.error != null && _selectedRole == _RegisterRole.admin) ...[
                const SizedBox(height: 16),
                _buildErrorDisplay(theme, authState.error!),
              ],
              const SizedBox(height: 20),
              _buildLoginLink(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Connexion',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Inscription',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez votre profil',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _roleOrder.map((role) {
            final isSelected = role == _selectedRole;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: role == _roleOrder.first ? 0 : 6,
                  right: role == _roleOrder.last ? 0 : 6,
                ),
                child: GestureDetector(
                  onTap: () {
                    if (role != _selectedRole) {
                      setState(() {
                        _selectedRole = role;
                      });
                      _resetForm();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer.withAlpha(180)
                          : theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant.withAlpha(80),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _roleIcons[role],
                          size: 24,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _roleLabels[role]!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Text(
                            _roleDescriptions[role]!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRoleForm(ThemeData theme, AuthState authState) {
    switch (_selectedRole) {
      case _RegisterRole.student:
        return _buildStudentForm(theme, authState);
      case _RegisterRole.teacher:
        return _buildTeacherForm(theme, authState);
      case _RegisterRole.admin:
        return _buildAdminForm(theme, authState);
    }
  }

  Widget _buildStudentForm(ThemeData theme, AuthState authState) {
    if (_step == 1) {
      return _buildStudentStep1(theme);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildVerifiedInfoCard(theme),
        const SizedBox(height: 20),
        _buildStudentStep2(theme, authState),
      ],
    );
  }

  Widget _buildStudentStep1(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Vérification du matricule',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _studentNumberController,
          decoration: const InputDecoration(
            labelText: 'Matricule',
            prefixIcon: Icon(Icons.badge_outlined),
            hintText: 'Entrez votre matricule étudiant',
          ),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: _isVerifying ? null : (_) => _handleCheckStudent(),
          validator: (v) => Validators.required(v, 'Le matricule'),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _isVerifying ? null : _handleCheckStudent,
            child: _isVerifying
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Vérifier'),
          ),
        ),
        if (_verificationError != null) ...[
          const SizedBox(height: 16),
          _buildErrorDisplay(theme, _verificationError!),
        ],
      ],
    );
  }

  Widget _buildStudentStep2(ThemeData theme, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _dateOfBirthController,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Date de naissance',
            prefixIcon: Icon(Icons.calendar_today_rounded),
          ),
          onTap: _pickDate,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'La date de naissance est requise';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildPasswordFields(theme),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: authState.status == AuthStatus.loading
                ? null
                : _handleRegisterStudent,
            child: authState.status == AuthStatus.loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Créer mon compte'),
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherForm(ThemeData theme, AuthState authState) {
    if (_step == 1) {
      return _buildTeacherStep1(theme);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildVerifiedInfoCard(theme),
        const SizedBox(height: 20),
        _buildTeacherStep2(theme, authState),
      ],
    );
  }

  Widget _buildTeacherStep1(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Vérification du matricule',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _teacherNumberController,
          decoration: const InputDecoration(
            labelText: 'Matricule',
            prefixIcon: Icon(Icons.badge_outlined),
            hintText: 'Entrez votre matricule enseignant',
          ),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: _isVerifying ? null : (_) => _handleCheckTeacher(),
          validator: (v) => Validators.required(v, 'Le matricule'),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _isVerifying ? null : _handleCheckTeacher,
            child: _isVerifying
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Vérifier'),
          ),
        ),
        if (_verificationError != null) ...[
          const SizedBox(height: 16),
          _buildErrorDisplay(theme, _verificationError!),
        ],
      ],
    );
  }

  Widget _buildTeacherStep2(ThemeData theme, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email professionnel',
            prefixIcon: Icon(Icons.email_outlined),
            hintText: 'exemple@universite.ci',
          ),
          validator: Validators.email,
        ),
        const SizedBox(height: 20),
        _buildPasswordFields(theme),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: authState.status == AuthStatus.loading
                ? null
                : _handleRegisterTeacher,
            child: authState.status == AuthStatus.loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Créer mon compte'),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminForm(ThemeData theme, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nom complet',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: (v) => Validators.name(v, 'Le nom'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: Validators.email,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _invitationCodeController,
          decoration: InputDecoration(
            labelText: "Code d'invitation",
            prefixIcon: const Icon(Icons.vpn_key_rounded),
            helperText: "Fourni par un administrateur existant",
            helperMaxLines: 2,
          ),
          validator: (v) => Validators.required(v, "Le code d'invitation"),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        _buildPasswordFields(theme),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: authState.status == AuthStatus.loading
                ? null
                : _handleRegisterAdmin,
            child: authState.status == AuthStatus.loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text("Créer mon compte"),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedInfoCard(ThemeData theme) {
    if (_verifiedInfo == null) return const SizedBox.shrink();

    final isStudent = _selectedRole == _RegisterRole.student;
    final name = _verifiedInfo!['name'] ?? _verifiedInfo!['first_name'] ?? '';
    final detail1 = isStudent
        ? _verifiedInfo!['program'] ?? _verifiedInfo!['program_name'] ?? ''
        : _verifiedInfo!['department'] ?? _verifiedInfo!['department_name'] ?? '';
    final detail2 = isStudent
        ? _verifiedInfo!['level'] ?? _verifiedInfo!['level_name'] ?? ''
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations vérifiées',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                size: 18,
                color: theme.colorScheme.primary.withAlpha(180),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (detail1.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  isStudent ? Icons.school_rounded : Icons.business_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(180),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    detail1,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (detail2 != null && detail2.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.grading_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(180),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    detail2,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: Validators.password,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirmation du mot de passe',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          validator: (v) =>
              Validators.confirmPassword(v, _passwordController.text),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ? ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Connectez-vous'),
        ),
      ],
    );
  }

  Widget _buildErrorDisplay(ThemeData theme, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
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
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(60),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    size: 56,
                    color: Colors.white.withAlpha(220),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Rejoignez la nouvelle génération de la gestion universitaire.',
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
                  'Créez votre compte en quelques instants et accédez à une plateforme performante, sécurisée et conçue pour toute la communauté universitaire.',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeatureItem(theme, Icons.verified_user_rounded, 'Sécurisé'),
                    _buildFeatureItem(theme, Icons.flash_on_rounded, 'Rapide'),
                    _buildFeatureItem(theme, Icons.devices_rounded, 'Accessible'),
                  ],
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    ThemeData theme,
    IconData icon,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 28, color: theme.colorScheme.primary),
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Sélectionnez votre date de naissance',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = DateFormatter.toDisplayDate(picked);
      });
    }
  }

  Future<void> _handleCheckStudent() async {
    final number = _studentNumberController.text.trim();
    if (number.isEmpty) {
      setState(() => _verificationError = 'Le matricule est requis');
      return;
    }

    setState(() {
      _isVerifying = true;
      _verificationError = null;
    });

    try {
      final response = await ref
          .read(authServiceProvider)
          .checkStudent(number);

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _verifiedInfo = response.data;
          _isVerifying = false;
          _step = 2;
        });
      } else {
        setState(() {
          _isVerifying = false;
          _verificationError =
              response.message ?? 'Étudiant non trouvé';
        });
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _verificationError = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _verificationError = 'Une erreur est survenue';
      });
    }
  }

  Future<void> _handleCheckTeacher() async {
    final number = _teacherNumberController.text.trim();
    if (number.isEmpty) {
      setState(() => _verificationError = 'Le matricule est requis');
      return;
    }

    setState(() {
      _isVerifying = true;
      _verificationError = null;
    });

    try {
      final response = await ref
          .read(authServiceProvider)
          .checkTeacher(number);

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _verifiedInfo = response.data;
          _isVerifying = false;
          _step = 2;
        });
      } else {
        setState(() {
          _isVerifying = false;
          _verificationError =
              response.message ?? 'Enseignant non trouvé';
        });
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _verificationError = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _verificationError = 'Une erreur est survenue';
      });
    }
  }

  Future<void> _handleRegisterStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await ref.read(authProvider.notifier).registerStudent(
          studentNumber: _studentNumberController.text.trim(),
          dateOfBirth: DateFormatter.toApiDate(_selectedDate),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Compte créé avec succès !'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _handleRegisterTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await ref.read(authProvider.notifier).registerTeacher(
          teacherNumber: _teacherNumberController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Compte créé avec succès !'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _handleRegisterAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await ref.read(authProvider.notifier).registerAdmin(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
          invitationCode: _invitationCodeController.text.trim(),
        );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Compte créé avec succès !'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
