import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../constants/weather_codes.dart';
import '../../models/daily_forecast.dart';
import '../../models/hourly_forecast.dart';
import 'glass_card.dart';

class _TimelineSlot {
  final String timeLabel;
  final HourlyForecast? forecast;
  final String? sunEventLabel; // 'Senja' or 'Terbit'
  final bool isSunrise;

  _TimelineSlot.hour(HourlyForecast item)
      : timeLabel = item.formattedHour,
        forecast = item,
        sunEventLabel = null,
        isSunrise = false;

  _TimelineSlot.sunEvent({
    required this.timeLabel,
    required this.sunEventLabel,
    required this.isSunrise,
  }) : forecast = null;

  bool get isSunEvent => sunEventLabel != null;
}

class HourlyForecastCard extends StatefulWidget {
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final String currentDescription;

  const HourlyForecastCard({
    super.key,
    required this.hourly,
    required this.daily,
    required this.currentDescription,
  });

  @override
  State<HourlyForecastCard> createState() => _HourlyForecastCardState();
}

class _HourlyForecastCardState extends State<HourlyForecastCard> {
  bool _show48Hours = false;
  static const double _columnWidth = 64.0;

  List<_TimelineSlot> _buildSlots() {
    final limit = _show48Hours ? 48 : 24;
    final hours = widget.hourly.take(limit).toList();
    if (hours.isEmpty) return [];

    // Collect sunrise/sunset markers within the displayed time range
    final firstTime = hours.first.time;
    final lastTime = hours.last.time;
    final List<MapEntry<DateTime, _TimelineSlot>> sunEvents = [];

    for (final day in widget.daily) {
      if (day.sunrise != null) {
        final sr = DateTime.tryParse(day.sunrise!);
        if (sr != null && sr.isAfter(firstTime) && sr.isBefore(lastTime)) {
          final label =
              '${sr.hour.toString().padLeft(2, '0')}.${sr.minute.toString().padLeft(2, '0')}';
          sunEvents.add(
            MapEntry(
              sr,
              _TimelineSlot.sunEvent(
                timeLabel: label,
                sunEventLabel: 'Terbit',
                isSunrise: true,
              ),
            ),
          );
        }
      }
      if (day.sunset != null) {
        final ss = DateTime.tryParse(day.sunset!);
        if (ss != null && ss.isAfter(firstTime) && ss.isBefore(lastTime)) {
          final label =
              '${ss.hour.toString().padLeft(2, '0')}.${ss.minute.toString().padLeft(2, '0')}';
          sunEvents.add(
            MapEntry(
              ss,
              _TimelineSlot.sunEvent(
                timeLabel: label,
                sunEventLabel: 'Senja',
                isSunrise: false,
              ),
            ),
          );
        }
      }
    }

    final List<_TimelineSlot> slots = [];
    for (int i = 0; i < hours.length; i++) {
      final current = hours[i];
      slots.add(_TimelineSlot.hour(current));

      if (i + 1 < hours.length) {
        final next = hours[i + 1];
        for (final event in sunEvents) {
          if (event.key.isAfter(current.time) &&
              !event.key.isAfter(next.time)) {
            slots.add(event.value);
          }
        }
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final slots = _buildSlots();
    if (slots.isEmpty) return const SizedBox.shrink();

    final today = widget.daily.isNotEmpty ? widget.daily.first : null;
    final summaryText = today != null
        ? '${widget.currentDescription}. Tinggi ${today.maxTemperature.round()}°C & rendah ${today.minTemperature.round()}°C'
        : widget.currentDescription;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summaryText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),

          // Scrollable Timeline + Synchronized Temperature Curve
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: slots.length * _columnWidth,
              child: Column(
                children: [
                  // Top row: Hour, Icon, Rain Prob / Sun Event
                  Row(
                    children: slots.map((slot) {
                      return SizedBox(
                        width: _columnWidth,
                        child: _buildColumnHeader(slot),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  // Temperature Curve Chart
                  SizedBox(
                    height: 68,
                    width: slots.length * _columnWidth,
                    child: CustomPaint(
                      painter: _TemperatureCurvePainter(
                        slots: slots,
                        columnWidth: _columnWidth,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          // Footer Action: Prakiraan cuaca 48 jam >
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _show48Hours = !_show48Hours;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _show48Hours
                          ? 'Tampilkan 24 jam'
                          : 'Prakiraan cuaca 48 jam',
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _show48Hours
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: Colors.white.withAlpha(220),
                      size: 18,
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

  Widget _buildColumnHeader(_TimelineSlot slot) {
    if (slot.isSunEvent) {
      return Column(
        children: [
          Text(
            slot.timeLabel,
            style: TextStyle(
              color: Colors.white.withAlpha(190),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          _SunHorizonIcon(isSunrise: slot.isSunrise),
          const SizedBox(height: 10),
          Text(
            slot.sunEventLabel!,
            style: TextStyle(
              color: Colors.white.withAlpha(210),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    final item = slot.forecast!;
    final isNight = item.time.hour >= 18 || item.time.hour < 6;
    final condition = WeatherCodes.getCondition(item.weatherCode, isNight: isNight);

    return Column(
      children: [
        Text(
          slot.timeLabel,
          style: TextStyle(
            color: Colors.white.withAlpha(190),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Icon(
          condition.icon,
          color: condition.iconColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.umbrella_rounded,
              size: 12,
              color: Colors.white.withAlpha(185),
            ),
            const SizedBox(width: 3),
            Text(
              '${item.precipitationProbability}%',
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SunHorizonIcon extends StatelessWidget {
  final bool isSunrise;

  const _SunHorizonIcon({required this.isSunrise});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _HorizonSunPainter(isSunrise: isSunrise),
      ),
    );
  }
}

class _HorizonSunPainter extends CustomPainter {
  final bool isSunrise;
  _HorizonSunPainter({required this.isSunrise});

  @override
  void paint(Canvas canvas, Size size) {
    final sunColor = isSunrise
        ? const Color(0xFFFBBF24)
        : const Color(0xFFF87171);

    final sunPaint = Paint()
      ..color = sunColor
      ..style = PaintingStyle.fill;

    final horizonY = size.height * 0.72;
    final center = Offset(size.width / 2, horizonY);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 9),
      math.pi,
      math.pi,
      true,
      sunPaint,
    );

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(2, horizonY),
      Offset(size.width - 2, horizonY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HorizonSunPainter oldDelegate) =>
      oldDelegate.isSunrise != isSunrise;
}

class _TemperatureCurvePainter extends CustomPainter {
  final List<_TimelineSlot> slots;
  final double columnWidth;

  _TemperatureCurvePainter({
    required this.slots,
    required this.columnWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hourPoints = <int, double>{};
    double minTemp = double.infinity;
    double maxTemp = double.negativeInfinity;

    for (int i = 0; i < slots.length; i++) {
      final f = slots[i].forecast;
      if (f != null) {
        hourPoints[i] = f.temperature;
        if (f.temperature < minTemp) minTemp = f.temperature;
        if (f.temperature > maxTemp) maxTemp = f.temperature;
      }
    }

    if (hourPoints.isEmpty) return;

    final tempRange = (maxTemp - minTemp).abs() < 0.5 ? 2.0 : (maxTemp - minTemp);
    const double topPadding = 26.0;
    const double bottomPadding = 12.0;
    final usableHeight = size.height - topPadding - bottomPadding;

    final List<Offset> curveOffsets = [];
    final List<MapEntry<Offset, double>> dotEntries = [];

    for (final entry in hourPoints.entries) {
      final x = entry.key * columnWidth + columnWidth / 2;
      final normalized = (entry.value - minTemp) / tempRange;
      final y = topPadding + usableHeight * (1.0 - normalized);
      final pt = Offset(x, y);
      curveOffsets.add(pt);
      dotEntries.add(MapEntry(pt, entry.value));
    }

    if (curveOffsets.length >= 2) {
      final path = Path()..moveTo(curveOffsets.first.dx, curveOffsets.first.dy);
      for (int i = 0; i < curveOffsets.length - 1; i++) {
        final p0 = curveOffsets[i];
        final p1 = curveOffsets[i + 1];
        final controlX = (p0.dx + p1.dx) / 2;
        path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      }

      final linePaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFDE68A), Color(0xFFFFFFFF)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, linePaint);
    }

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final entry in dotEntries) {
      final pt = entry.key;
      canvas.drawCircle(pt, 3.5, dotPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${entry.value.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(pt.dx - textPainter.width / 2, pt.dy - textPainter.height - 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TemperatureCurvePainter oldDelegate) =>
      oldDelegate.slots != slots;
}
