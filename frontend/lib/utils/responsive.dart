import 'package:flutter/material.dart';

/// Centralized responsive layout constants and helper extensions for WhereIsMyBus
class ResponsiveBreakpoints {
  static const double mobileMax = 767.0;
  static const double tabletMin = 768.0;
  static const double tabletMax = 1199.0;
  static const double desktopMin = 1200.0;

  // Maximum content width to prevent awkward stretching on ultra-wide screens
  static const double maxContentWidth = 1080.0;
  static const double maxDashboardWidth = 1240.0;
  static const double maxCardWidth = 540.0;
  static const double sideNavWidth = 260.0;
  static const double navRailWidth = 76.0;
}

/// Extension on BuildContext for quick, ergonomic responsive querying
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => screenWidth < ResponsiveBreakpoints.tabletMin;
  bool get isTablet =>
      screenWidth >= ResponsiveBreakpoints.tabletMin &&
      screenWidth < ResponsiveBreakpoints.desktopMin;
  bool get isDesktop => screenWidth >= ResponsiveBreakpoints.desktopMin;
  bool get isTabletOrDesktop => screenWidth >= ResponsiveBreakpoints.tabletMin;

  /// Returns responsive value based on active screen breakpoint
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Ergonomic horizontal screen padding based on form factor
  EdgeInsets get screenPadding {
    if (isDesktop) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }
}

/// A responsive widget builder that renders mobile, tablet, or desktop layouts
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktopMin && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= ResponsiveBreakpoints.tabletMin && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

/// Constrains child content horizontally with maximum width bounds and auto-centering
class ContentConstraint extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ContentConstraint({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return content;
  }
}
