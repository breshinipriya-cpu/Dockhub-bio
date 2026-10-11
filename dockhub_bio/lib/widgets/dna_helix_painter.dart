import 'dart:math' as math;
import 'package:flutter/material.dart';

class DnaHelixWidget extends StatefulWidget {
  final double width;
  final double height;
  final bool isLightTheme;
  final double radiusFraction;
  final double opacityMultiplier;

  const DnaHelixWidget({
    super.key,
    this.width = 320,
    this.height = 500,
    this.isLightTheme = false,
    this.radiusFraction = 0.36,
    this.opacityMultiplier = 1.0,
  });

  @override
  State<DnaHelixWidget> createState() => _DnaHelixWidgetState();
}

class _DnaHelixWidgetState extends State<DnaHelixWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: DnaHelixPainter(
            progress: _controller.value,
            isLightTheme: widget.isLightTheme,
            radiusFraction: widget.radiusFraction,
            opacityMultiplier: widget.opacityMultiplier,
          ),
        );
      },
    );
  }
}

class DnaHelixPainter extends CustomPainter {
  final double progress;
  final bool isLightTheme;
  final double radiusFraction;
  final double opacityMultiplier;

  DnaHelixPainter({
    required this.progress,
    this.isLightTheme = false,
    this.radiusFraction = 0.36,
    this.opacityMultiplier = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final helixRadius = size.width * radiusFraction;
    final totalHeight = size.height;

    const numBasePairs = 26;
    const turns = 3.0;

    // Light-colored glowing palette for dark backgrounds
    final strandAColor = isLightTheme
        ? const Color(0xFF0284C7)
        : const Color(0xFF00F2FE); // Electric Light Cyan
    final strandBColor = isLightTheme
        ? const Color(0xFF0D9488)
        : const Color(0xFF2DD4BF); // Vibrant Mint Teal
    final nodeColorA = isLightTheme
        ? const Color(0xFF2563EB)
        : const Color(0xFF38BDF8); // Glowing Sky Blue
    final nodeColorB = isLightTheme
        ? const Color(0xFF059669)
        : const Color(0xFF64FFDA); // Light Emerald / Cyan-White
    final connectorLineColor = isLightTheme
        ? Colors.black.withValues(alpha: 0.15 * opacityMultiplier)
        : Colors.white.withValues(alpha: 0.40 * opacityMultiplier);

    // Objects list to sort by Z-depth (3D effect)
    final List<_RenderableElement> elements = [];

    // Generate Base Pairs
    for (int i = 0; i <= numBasePairs; i++) {
      final t = i / numBasePairs;
      final y = 10.0 + t * (totalHeight - 20.0);
      final angle = t * turns * 2 * math.pi + progress * 2 * math.pi;

      final cosA = math.cos(angle);
      final sinA = math.sin(angle);

      final x1 = centerX + helixRadius * cosA;
      final z1 = helixRadius * sinA;

      final x2 = centerX - helixRadius * cosA;
      final z2 = -helixRadius * sinA;

      elements.add(
        _RenderableElement(
          z: (z1 + z2) / 2,
          type: _ElementType.rung,
          p1: Offset(x1, y),
          p2: Offset(x2, y),
          alpha: (0.4 + 0.6 * ((z1 + helixRadius) / (2 * helixRadius))) * opacityMultiplier,
        ),
      );

      elements.add(
        _RenderableElement(
          z: z1,
          type: _ElementType.node,
          p1: Offset(x1, y),
          color: nodeColorA,
          radius: (5.5 + 3.5 * ((z1 + helixRadius) / (2 * helixRadius))),
          alpha: (0.35 + 0.65 * ((z1 + helixRadius) / (2 * helixRadius))) * opacityMultiplier,
        ),
      );

      elements.add(
        _RenderableElement(
          z: z2,
          type: _ElementType.node,
          p1: Offset(x2, y),
          color: nodeColorB,
          radius: (5.5 + 3.5 * ((z2 + helixRadius) / (2 * helixRadius))),
          alpha: (0.35 + 0.65 * ((z2 + helixRadius) / (2 * helixRadius))) * opacityMultiplier,
        ),
      );
    }

    // Floating particles
    final particleRandom = math.Random(101);
    for (int p = 0; p < 35; p++) {
      final px = particleRandom.nextDouble() * size.width;
      final pyInitial = particleRandom.nextDouble() * size.height;
      final speed = 0.15 + particleRandom.nextDouble() * 0.4;
      final py = (pyInitial - progress * size.height * speed) % size.height;
      final pRadius = 1.5 + particleRandom.nextDouble() * 3.0;

      canvas.drawCircle(
        Offset(px, py),
        pRadius,
        Paint()
          ..color = (isLightTheme ? const Color(0xFF0284C7) : const Color(0xFF00F2FE))
              .withValues(alpha: (0.2 + 0.3 * particleRandom.nextDouble()) * opacityMultiplier),
      );
    }

    // Sort Z depth back to front
    elements.sort((a, b) => a.z.compareTo(b.z));

    // Draw continuous backbone curves
    _drawBackboneStrand(canvas, size, progress, turns, 0, strandAColor, helixRadius, centerX);
    _drawBackboneStrand(canvas, size, progress, turns, math.pi, strandBColor, helixRadius, centerX);

    // Render sorted elements
    for (final element in elements) {
      if (element.type == _ElementType.rung) {
        final paint = Paint()
          ..color = connectorLineColor.withValues(alpha: element.alpha * 0.6)
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(element.p1, element.p2!, paint);
      } else if (element.type == _ElementType.node) {
        final glowPaint = Paint()
          ..color = element.color!.withValues(alpha: element.alpha * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(element.p1, element.radius! * 1.8, glowPaint);

        final nodePaint = Paint()
          ..color = element.color!.withValues(alpha: element.alpha);
        canvas.drawCircle(element.p1, element.radius!, nodePaint);
      }
    }
  }

  void _drawBackboneStrand(
    Canvas canvas,
    Size size,
    double progress,
    double turns,
    double phaseOffset,
    Color color,
    double helixRadius,
    double centerX,
  ) {
    final path = Path();
    const steps = 120;
    final totalHeight = size.height;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final y = 10.0 + t * (totalHeight - 20.0);
      final angle = t * turns * 2 * math.pi + progress * 2 * math.pi + phaseOffset;
      final x = centerX + helixRadius * math.cos(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.45 * opacityMultiplier)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glowPaint);

    final linePaint = Paint()
      ..color = color.withValues(alpha: opacityMultiplier)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant DnaHelixPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isLightTheme != isLightTheme ||
        oldDelegate.opacityMultiplier != opacityMultiplier ||
        oldDelegate.radiusFraction != radiusFraction;
  }
}

enum _ElementType { rung, node }

class _RenderableElement {
  final double z;
  final _ElementType type;
  final Offset p1;
  final Offset? p2;
  final Color? color;
  final double? radius;
  final double alpha;

  _RenderableElement({
    required this.z,
    required this.type,
    required this.p1,
    this.p2,
    this.color,
    this.radius,
    required this.alpha,
  });
}
