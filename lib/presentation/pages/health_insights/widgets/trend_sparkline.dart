import 'package:flutter/material.dart';

/// A minimal trend line for a Health Insights card, with a light axis:
/// the peak value labeled above (OY) and the first/last month labeled
/// below (OX, `MM/yy` \u2014 numeric, matches [AppDateFormatter]'s locale-free
/// convention). [points] should already be bounded to the reporting window
/// (the last 24 months) by the caller, so the OX range is naturally "the
/// last 2 years, or less if that's all there is".
class TrendSparkline extends StatelessWidget {
  const TrendSparkline({super.key, required this.points, this.height = 56, this.color});

  /// Ascending by date.
  final List<MapEntry<DateTime, double>> points;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    if (points.length < 2) return SizedBox(height: height);

    final labelStyle = tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10) ?? const TextStyle(fontSize: 10);
    final maxValue = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(alignment: Alignment.centerRight, child: Text('max ${_formatValue(maxValue)}', style: labelStyle)),
        const SizedBox(height: 2),
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _SparklinePainter(values: [for (final p in points) p.value], color: color ?? cs.primary)),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(_monthLabel(points.first.key), style: labelStyle), Text(_monthLabel(points.last.key), style: labelStyle)],
        ),
      ],
    );
  }

  String _formatValue(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  String _monthLabel(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final yy = (date.year % 100).toString().padLeft(2, '0');
    return '$mm/$yy';
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs() < 1e-9 ? 1.0 : maxValue - minValue;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final normalized = (values[i] - minValue) / range;
      final y = size.height - normalized * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.values != values || oldDelegate.color != color;
}

