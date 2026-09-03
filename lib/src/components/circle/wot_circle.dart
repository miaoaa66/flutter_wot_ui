import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../theme/wot_theme.dart';

/// 环形进度，对应 wot `wd-circle`。受控（v-model:value，0-100）。
///
/// 内部用 [Container] 固定 [width]/[height]（缺省取 [size]）打底撑起尺寸，
/// 圆环与文字完全绘制在容器内，绝不超出包裹它的容器。
class WotCircle extends StatelessWidget {
  const WotCircle({
    super.key,
    this.modelValue = 0,
    this.size = 100,
    this.width,
    this.height,
    this.strokeWidth = 6,
    this.color,
    this.trackColor,
    this.showText = true,
    this.textFormat,
    this.lineCap,
  });

  final num modelValue;

  /// 默认边长（当 [width]/[height] 未给出时使用）。
  final double size;

  /// 显式宽度，为空时用 [size]。
  final double? width;

  /// 显式高度，为空时用 [size]。
  final double? height;

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

    // 圆头仅在有进度时启用：frac=0 用平头，避免顶部出现孤立圆点。
    final cap = frac <= 0 ? StrokeCap.butt : (lineCap ?? StrokeCap.round);

    final w = width ?? size;
    final h = height ?? size;
    // 圆环取短边半径，保证任意宽高下都完整内含。
    final side = math.min(w, h);

    // Container 打底撑起尺寸，圆环与文字绘制在容器内部。
    return Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            size: Size(w, h),
            painter: _CirclePainter(
              frac: frac,
              strokeWidth: strokeWidth,
              filled: filled,
              track: track,
              cap: cap,
            ),
          ),
          if (showText)
            Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: side * 0.16,
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
    // 以短边为基准，并内缩半根 stroke，使圆环完整内含且不贴边。
    final side = math.min(size.width, size.height);
    final radius = (side - strokeWidth) / 2 - strokeWidth / 2;
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