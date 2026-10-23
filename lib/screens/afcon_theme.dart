import 'package:flutter/material.dart';

/// Shared design tokens and base components for the AFCON editorial UI.
class Pitch {
  static const cafMaroon = Color(0xFF800000);
  static const cafMaroonDeep = Color(0xFF5C0000);
  static const live = Color(0xFFD94141);
  static const ink = Color(0xFF1E1E1E);
  static const muted = Color(0xFF666666);
  static const line = Color(0xFFE6EBE7);
  static const canvas = Color(0xFFF7F7F7);

  /// Fixed-width digits so scores and times line up in columns.
  static const tabular = [FontFeature.tabularFigures()];
}

ThemeData buildAfconTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Pitch.cafMaroon,
    primary: Pitch.cafMaroon,
    secondary: Pitch.cafMaroon,
    surface: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Pitch.canvas,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Pitch.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Pitch.ink,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Pitch.muted, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Pitch.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Pitch.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Pitch.cafMaroon, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Pitch.cafMaroon,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Pitch.cafMaroon.withValues(alpha: 0.1),
      height: 68,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? Pitch.cafMaroon
              : Pitch.muted,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Pitch.line, space: 1),
  );
}

/// CAF maroon gradient with subtle football pitch markings.
class PitchBackdrop extends StatelessWidget {
  const PitchBackdrop({super.key});

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Pitch.cafMaroonDeep, Pitch.cafMaroon],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: CustomPaint(painter: _PitchLinesPainter(), size: Size.infinite),
  );
}

class _PitchLinesPainter extends CustomPainter {
  const _PitchLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final centre = Offset(size.width * 0.82, size.height * 0.55);
    canvas.drawCircle(centre, size.height * 0.8, paint);
    canvas.drawLine(
      Offset(centre.dx, 0),
      Offset(centre.dx, size.height),
      paint,
    );
    canvas.drawCircle(centre, 3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TeamBadge extends StatelessWidget {
  const TeamBadge({
    super.key,
    required this.initial,
    required this.color,
    this.size = 28,
  });

  final String initial;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x26000000),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Text(
      initial,
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.46,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

/// Red pulse-dot pill for matches in play.
class LivePill extends StatelessWidget {
  const LivePill({super.key, required this.minute});

  final String minute;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Pitch.live,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 5),
      Text(
        minute,
        style: const TextStyle(
          color: Pitch.live,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          fontFeatures: Pitch.tabular,
        ),
      ),
    ],
  );
}
