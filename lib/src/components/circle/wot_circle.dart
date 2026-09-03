import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 环形进度，对应 wot `wd-circle`。受控（v-model:value，0-100）。
class WotCircle extends StatelessWidget {
  const WotCircle({
    super.key,
    this.modelValue = 0,
    this.size = 100,
    this.strokeWidth = 6,
    this.color,
    this.trackColor,
    this.showText = true,
    this.textFormat,
    this.lineCap,
  });

  final num modelValue;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;
  final bool showText;
  final String Function(num)? textFormat;
  final StrokeCap? lineCap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final frac = (modelValue.clamp(0, 100).toDouble() / 100).clamp(0.0, 1.0);
    final filled = color ?? scheme.primaryOf(6);
    final track = trackColor ?? scheme.borderLight;
    final label = textFormat != null
        ? textFormat!(modelValue)
        : '${modelValue.toInt()}%';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _CirclePainter(
              frac: frac,
              strokeWidth: strokeWidth,
              filled: filled,
              track: track,
              cap: lineCap ?? StrokeCap.round,
            ),
          ),
          if (showText)
            Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: size * 0.16,
                  fontWeight: FontWeight.w600,
                  color: scheme.textMain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  _CirclePainter({
    required this.frac,
    required this.strokeWidth,
    required this.filled,
    required this.track,
    required this.cap,
  });

  final double frac;
  final double strokeWidth;
  final Color filled;
  final Color track;
  final StrokeCap cap;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 轨道：从顶部开始整圆。
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = track;
    canvas.drawArc(rect, 0, 3.14159 * 2, false, trackPaint);

    // 进度：从顶部（-90°）开始。
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = cap
      ..color = filled;
    canvas.drawArc(rect, -1.5708, 3.14159 * 2 * frac, false, progressPaint);
  }

  @override
  bool shouldRepaint(_CirclePainter old) =>
      old.frac != frac ||
      old.filled != filled ||
      old.track != track ||
      old.strokeWidth != strokeWidth;
}