import 'package:flutter/material.dart';

/// Centralized, commercial-grade theming. Light and dark variants share a
/// single seed so brand color stays consistent across the app.
class AppTheme {
  AppTheme._();

  static const Color brand = Color(0xff175cd3);
  static const Color _lightBg = Color(0xfff6f8fc);
  static const Color _darkBg = Color(0xff0d1117);

  static ThemeData light() => _build(Brightness.light, _lightBg);
  static ThemeData dark() => _build(Brightness.dark, _darkBg);

  static ThemeData _build(Brightness brightness, Color scaffold) {
    final scheme = ColorScheme.fromSeed(seedColor: brand, brightness: brightness);
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? const Color(0xff161b22) : Colors.white;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardColor: surface,
      dividerColor: scheme.outlineVariant.withOpacity(0.5),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Soft surface card used across list and detail screens.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
    this.borderWidth,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Optional border tint/width override (e.g. to highlight an unread row).
  final Color? borderColor;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ?? scheme.outlineVariant.withOpacity(0.6),
              width: borderWidth ?? 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
