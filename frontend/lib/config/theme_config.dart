import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConfig {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double laptopBreakpoint = 1200;

  static const Color primaryColor = Color(0xFF7C3AED);
  static const Color secondaryColor = Color(0xFF0D9488);
  static const Color tertiaryColor = Color(0xFFE11D48);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF0F172A);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFF5F3FF),
      onPrimaryContainer: const Color(0xFF4C1D95),
      secondary: secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFCCFBF1),
      onSecondaryContainer: const Color(0xFF134E4A),
      tertiary: tertiaryColor,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFF1F2),
      onTertiaryContainer: const Color(0xFF881337),
      error: errorColor,
      onError: Colors.white,
      errorContainer: const Color(0xFFFEF2F2),
      onErrorContainer: const Color(0xFF991B1B),
      surface: Colors.white,
      onSurface: const Color(0xFF0F172A),
      surfaceContainerHighest: const Color(0xFFF1F5F9),
      onSurfaceVariant: const Color(0xFF475569),
      outline: const Color(0xFFCBD5E1),
      outlineVariant: const Color(0xFFE2E8F0),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8F7FF),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2),
        displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.25, height: 1.25),
        displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3),
        headlineLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, height: 1.35),
        headlineSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
        titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15, height: 1.4),
        titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.45),
        titleSmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.05, height: 1.45),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, height: 1.6),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 1.6),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, height: 1.5),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.4),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.4),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 64,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: colorScheme.primaryContainer,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withAlpha(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.25),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.25),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(100),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w500),
        suffixIconColor: colorScheme.onSurfaceVariant,
        prefixIconColor: colorScheme.onSurfaceVariant,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withAlpha(150), fontSize: 14),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withAlpha(120),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        shadowColor: Colors.black.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: colorScheme.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
      ),
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(4),
        thumbVisibility: WidgetStateProperty.all(true),
      ),
      drawerTheme: DrawerThemeData(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        elevation: 0,
        shadowColor: Colors.black.withAlpha(20),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withAlpha(100),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 1.5)),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          elevation: WidgetStateProperty.all(4),
          shadowColor: WidgetStateProperty.all(Colors.black.withAlpha(20)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: Colors.black.withAlpha(20),
      ),
      datePickerTheme: DatePickerThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      timePickerTheme: TimePickerThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFFA78BFA),
      onPrimary: const Color(0xFF1E1B4B),
      primaryContainer: const Color(0xFF5B21B6),
      onPrimaryContainer: const Color(0xFFEDE9FE),
      secondary: const Color(0xFF2DD4BF),
      onSecondary: const Color(0xFF042F2E),
      secondaryContainer: const Color(0xFF115E59),
      onSecondaryContainer: const Color(0xFFCCFBF1),
      tertiary: const Color(0xFFFB7185),
      onTertiary: const Color(0xFF4C0519),
      tertiaryContainer: const Color(0xFF9F1239),
      onTertiaryContainer: const Color(0xFFFFE4E6),
      error: const Color(0xFFF87171),
      onError: const Color(0xFF450A0A),
      errorContainer: const Color(0xFF7F1D1D),
      onErrorContainer: const Color(0xFFFEE2E2),
      surface: const Color(0xFF1E293B),
      onSurface: const Color(0xFFF1F5F9),
      surfaceContainerHighest: const Color(0xFF334155),
      onSurfaceVariant: const Color(0xFF94A3B8),
      outline: const Color(0xFF475569),
      outlineVariant: const Color(0xFF334155),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF1E1B4B),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2),
        displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.25, height: 1.25),
        displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3),
        headlineLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, height: 1.35),
        headlineSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
        titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15, height: 1.4),
        titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.45),
        titleSmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.05, height: 1.45),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, height: 1.6),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 1.6),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, height: 1.5),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.4),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.4),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 64,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: colorScheme.primaryContainer,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.25),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.25),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w500),
        suffixIconColor: colorScheme.onSurfaceVariant,
        prefixIconColor: colorScheme.onSurfaceVariant,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withAlpha(150), fontSize: 14),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        shadowColor: Colors.black.withAlpha(40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: colorScheme.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
      ),
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(4),
        thumbVisibility: WidgetStateProperty.all(true),
      ),
      drawerTheme: DrawerThemeData(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        elevation: 0,
        shadowColor: Colors.black.withAlpha(40),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 1.5)),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          elevation: WidgetStateProperty.all(4),
          shadowColor: WidgetStateProperty.all(Colors.black.withAlpha(40)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: Colors.black.withAlpha(40),
      ),
      datePickerTheme: DatePickerThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      timePickerTheme: TimePickerThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
