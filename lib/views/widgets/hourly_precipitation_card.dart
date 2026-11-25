import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/hourly_forecast.dart';
import 'glass_card.dart';

class HourlyPrecipitationCard extends StatelessWidget {
  final List<HourlyForecast> hourly;

  const HourlyPrecipitationCard({
    super.key,
    required this.hourly,
  });

  @override
  Widget build(BuildContext context) {
    final hours = hourly.take(12).toList();
    if (hours.isEmpty) return const SizedBox.shrink();

    const double columnWidth = 54.0;

    return GlassCard(
      tintColor: const Color(0xFF1D4F7A).withAlpha(115),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left fixed axis column: droplets icon + unit label
          SizedBox(
            width: 34,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white.withAlpha(210),
                  size: 20,
                ),
                const Spacer(),
                Text(
                  'mm',
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable precipitation chart
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: hours.length * columnWidth,
                child: Column(
                  children: [
                    // Time labels row
                    Row(
                      children: hours.map((h) {
                        return SizedBox(
                          width: columnWidth,
                          child: Center(
                            child: Text(
                              h.formattedHour,
                              style: TextStyle(
                                color: Colors.white.withAlpha(190),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    // Chart Canvas
                    SizedBox(
                      height: 92,
                      width: hours.length * columnWidth,
                      child: CustomPaint(
                        painter: _PrecipitationChartPainter(
                          hours: hours,
                          columnWidth: columnWidth,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Millimeter labels row
                    Row(
                      children: hours.map((h) {
                        return SizedBox(
                          width: columnWidth,
                          child: Center(
                            child: Text(
                              h.precipitation.toStringAsFixed(2),
                              style: TextStyle(
                                color: Colors.white.withAlpha(160),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrecipitationChartPainter extends CustomPainter {
  final List<HourlyForecast> hours;
  final double columnWidth;

  _PrecipitationChartPainter({
    required this.hours,
    required this.columnWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw 4 subtle horizontal gridlines
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(28)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (hours.isEmpty) return;

    double maxVal = 0.5;
    for (final h in hours) {
      maxVal = math.max(maxVal, h.precipitation);
    }

    final List<Offset> points = [];
    for (int i = 0; i < hours.length; i++) {
      final x = i * columnWidth + columnWidth / 2;
      final ratio = (hours[i].precipitation / maxVal).clamp(0.0, 1.0);
      final y = size.height - (ratio * (size.height - 12)) - 2;
      points.add(Offset(x, y));
    }

    if (points.length >= 2) {
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final cx = (p0.dx + p1.dx) / 2;
        linePath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
      }

      final areaPath = Path.from(linePath)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF7DD3FC).withAlpha(115),
            const Color(0xFF7DD3FC).withAlpha(10),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(areaPath, fillPaint);

      final strokePaint = Paint()
        ..color = const Color(0xFFBAE6FD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(linePath, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PrecipitationChartPainter oldDelegate) =>
      oldDelegate.hours != hours;
}
