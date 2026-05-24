import 'package:flutter/material.dart';

// Neobrutalist custom colors extensions
class SmartBirthColors extends ThemeExtension<SmartBirthColors> {
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgTertiary;
  final Color primaryPink;
  final Color primaryPinkHover;
  final Color accentBlue;
  final Color successGreen;
  final Color chocolateBrown;
  final Color textSecondary;

  const SmartBirthColors({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.primaryPink,
    required this.primaryPinkHover,
    required this.accentBlue,
    required this.successGreen,
    required this.chocolateBrown,
    required this.textSecondary,
  });

  @override
  ThemeExtension<SmartBirthColors> copyWith({
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgTertiary,
    Color? primaryPink,
    Color? primaryPinkHover,
    Color? accentBlue,
    Color? successGreen,
    Color? chocolateBrown,
    Color? textSecondary,
  }) {
    return SmartBirthColors(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgTertiary: bgTertiary ?? this.bgTertiary,
      primaryPink: primaryPink ?? this.primaryPink,
      primaryPinkHover: primaryPinkHover ?? this.primaryPinkHover,
      accentBlue: accentBlue ?? this.accentBlue,
      successGreen: successGreen ?? this.successGreen,
      chocolateBrown: chocolateBrown ?? this.chocolateBrown,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  ThemeExtension<SmartBirthColors> lerp(
    ThemeExtension<SmartBirthColors>? other,
    double t,
  ) {
    if (other is! SmartBirthColors) {
      return this;
    }
    return SmartBirthColors(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgTertiary: Color.lerp(bgTertiary, other.bgTertiary, t)!,
      primaryPink: Color.lerp(primaryPink, other.primaryPink, t)!,
      primaryPinkHover: Color.lerp(primaryPinkHover, other.primaryPinkHover, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      successGreen: Color.lerp(successGreen, other.successGreen, t)!,
      chocolateBrown: Color.lerp(chocolateBrown, other.chocolateBrown, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

// Warm Theme preset (Original Cozy Pink/Cream)
const warmColors = SmartBirthColors(
  bgPrimary: Color(0xFFFFFDF9),
  bgSecondary: Color(0xFFFFFFFF),
  bgTertiary: Color(0xFFFDF0DD),
  primaryPink: Color(0xFFFF758F),
  primaryPinkHover: Color(0xFFFF4D6D),
  accentBlue: Color(0xFF4EA8DE),
  successGreen: Color(0xFF52B788),
  chocolateBrown: Color(0xFF4E3D30),
  textSecondary: Color(0xFF7C6351),
);

// Blue Theme preset (Cool Blue/Teal)
const blueColors = SmartBirthColors(
  bgPrimary: Color(0xFFEEF7FC),
  bgSecondary: Color(0xFFFFFFFF),
  bgTertiary: Color(0xFFDBEEFC),
  primaryPink: Color(0xFF4EA8DE),
  primaryPinkHover: Color(0xFF3A8EC1),
  accentBlue: Color(0xFFFF758F),
  successGreen: Color(0xFF52B788),
  chocolateBrown: Color(0xFF2B3947),
  textSecondary: Color(0xFF4D5E70),
);

// Color constants for backward compatibility (fallbacks)
const Color kBgPrimary = Color(0xFFFFFDF9);
const Color kBgSecondary = Color(0xFFFFFFFF);
const Color kBgTertiary = Color(0xFFFDF0DD);
const Color kPrimaryPink = Color(0xFFFF758F);
const Color kPrimaryPinkHover = Color(0xFFFF4D6D);
const Color kAccentBlue = Color(0xFF4EA8DE);
const Color kSuccessGreen = Color(0xFF52B788);
const Color kChocolateBrown = Color(0xFF4E3D30);
const Color kTextSecondary = Color(0xFF7C6351);

ThemeData buildSmartBirthTheme({required String themeName}) {
  final activeColors = themeName == 'blue' ? blueColors : warmColors;

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: activeColors.bgPrimary,
    fontFamily: 'Nunito',
    primaryColor: activeColors.primaryPink,
    colorScheme: ColorScheme.fromSeed(
      seedColor: activeColors.primaryPink,
      primary: activeColors.primaryPink,
      secondary: activeColors.accentBlue,
      background: activeColors.bgPrimary,
    ),
    extensions: [activeColors],
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: activeColors.chocolateBrown, fontSize: 32),
      titleLarge: TextStyle(fontWeight: FontWeight.w900, color: activeColors.chocolateBrown, fontSize: 22),
      bodyLarge: TextStyle(fontWeight: FontWeight.w700, color: activeColors.chocolateBrown, fontSize: 16),
      bodyMedium: TextStyle(fontWeight: FontWeight.w600, color: activeColors.textSecondary, fontSize: 14),
    ),
  );
}

// Custom Neobrutalist tactile button
class NeobrutalistButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final double paddingVertical;
  final double paddingHorizontal;

  const NeobrutalistButton({
    super.key,
    required this.child,
    required this.onTap,
    this.backgroundColor,
    this.paddingVertical = 12.0,
    this.paddingHorizontal = 24.0,
  });

  @override
  State<NeobrutalistButton> createState() => _NeobrutalistButtonState();
}

class _NeobrutalistButtonState extends State<NeobrutalistButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;
    final bgColor = widget.backgroundColor ?? colors.bgSecondary;
    final borderShadowColor = colors.chocolateBrown;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeIn,
        transform: _isPressed
            ? Matrix4.translationValues(3, 3, 0)
            : Matrix4.translationValues(0, 0, 0),
        padding: EdgeInsets.symmetric(
          vertical: widget.paddingVertical,
          horizontal: widget.paddingHorizontal,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderShadowColor, width: 3),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: borderShadowColor,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: widget.child,
      ),
    );
  }
}

// Neobrutalist Card / Panel
class NeobrutalistCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double padding;

  const NeobrutalistCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;
    final bgColor = backgroundColor ?? colors.bgSecondary;
    final borderShadowColor = colors.chocolateBrown;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderShadowColor, width: 3),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: borderShadowColor,
            offset: const Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

// Responsive layout utility for Mobile, Tablet, and Desktop separation
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) {
      return desktop;
    } else if (width >= 600 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}
