import 'package:flutter/material.dart';

import '../models/docking_result.dart';

class RamachandranPage extends StatelessWidget {
  final DockingResult? result;

  const RamachandranPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final points = result?.ramachandranPoints ?? const <RamachandranPoint>[];
    return Container(
      color: const Color(0xFF020B12),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ramachandran Analysis', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(
                result?.ramachandranMessage ?? 'Run docking to calculate backbone torsion angles from the downloaded PDB.',
                style: const TextStyle(color: Colors.white70),
              ),
              if (points.isEmpty) ...[
                const SizedBox(height: 18),
                const Card(
                  color: Color(0xFF0D1F2D),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No consecutive backbone phi/psi pairs are available for this structure.', style: TextStyle(color: Colors.white70)),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 18),
                Text('${points.length} residue angle pairs', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Card(
                  color: const Color(0xFF0D1F2D),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const Text('Phi (degrees)  /  Psi (degrees)', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 340,
                          width: double.infinity,
                          child: LayoutBuilder(
                            builder: (context, constraints) => CustomPaint(
                              size: Size(constraints.maxWidth, 340),
                              painter: _RamachandranPainter(points),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Residue angles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ...points.map((point) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF0D1F2D), borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        '${point.chain}:${point.residueName}${point.residueNumber}    phi ${point.phi}°    psi ${point.psi}°',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    )),
                const SizedBox(height: 12),
                const Text(
                  'Angles are calculated from atomic coordinates. Favored/allowed/outlier classification requires a reference distribution and is not inferred here.',
                  style: TextStyle(color: Colors.amberAccent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RamachandranPainter extends CustomPainter {
  final List<RamachandranPoint> points;

  const _RamachandranPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const top = 14.0;
    const right = 14.0;
    const bottom = 34.0;
    final plot = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final borderPaint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;
    final pointPaint = Paint()..color = Colors.greenAccent;

    canvas.drawRect(plot, borderPaint);
    for (var tick = -180; tick <= 180; tick += 90) {
      final x = plot.left + (tick + 180) / 360 * plot.width;
      final y = plot.bottom - (tick + 180) / 360 * plot.height;
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), gridPaint);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _drawLabel(canvas, '$tick', Offset(x - 12, plot.bottom + 6));
      _drawLabel(canvas, '$tick', Offset(2, y - 8));
    }

    for (final point in points) {
      final x = plot.left + (point.phi + 180) / 360 * plot.width;
      final y = plot.bottom - (point.psi + 180) / 360 * plot.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  void _drawLabel(Canvas canvas, String label, Offset offset) {
    final text = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _RamachandranPainter oldDelegate) => oldDelegate.points != points;
}