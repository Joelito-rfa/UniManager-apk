import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

extension ResponsiveBreakpoint on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => screenWidth < ThemeConfig.mobileBreakpoint;
  bool get isTablet => screenWidth >= ThemeConfig.mobileBreakpoint && screenWidth < ThemeConfig.tabletBreakpoint;
  bool get isLaptop => screenWidth >= ThemeConfig.tabletBreakpoint && screenWidth < ThemeConfig.laptopBreakpoint;
  bool get isDesktop => screenWidth >= ThemeConfig.laptopBreakpoint;

  bool get isMobileOrTablet => screenWidth < ThemeConfig.tabletBreakpoint;
  bool get isTabletOrLarger => screenWidth >= ThemeConfig.mobileBreakpoint;

  T responsive<T>({
    required T mobile,
    T? tablet,
    T? laptop,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isLaptop && laptop != null) return laptop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  EdgeInsets screenPadding({double mobile = 12, double tablet = 16, double desktop = 24}) {
    return EdgeInsets.all(responsive(mobile: mobile, tablet: tablet, desktop: desktop));
  }

  double contentWidth({double maxWidth = 1200}) {
    final width = screenWidth - (responsive(mobile: 24, tablet: 32, desktop: 48));
    return width > maxWidth ? maxWidth : width;
  }
}
