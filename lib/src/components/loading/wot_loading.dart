import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 加载指示器动画类型。
enum WotLoadingAnimationType {
  /// 旋转 + 弧长呼吸伸缩（Material 风格）。
  breathing,

  /// 匀速旋转，固定弧长（半圆）。
  uniform,

  /// 整个圆环缩放脉动。
  pulse,
}

/// 加载指示器，对应 wot `wd-loading`。
class WotLoading extends StatefulWidget {
  const WotLoading({
    super.key,
    this.size = 20,
    this.color,
    this.text,
    this.vertical = false,
    this.inheritColor = false,
    this.textColor,
    this.loadingColor,
    this.strokeWidth,
    this.animationType = WotLoadingAnimationType.breathing,
  });

  /// 直径（逻辑像素）。
  final double size;

  /// 指示器颜色。
  final Color? color;

  /// 伴随文字。
  final String? text;

  /// 是否纵向排布（图标在上、文字在下）。
  final bool vertical;

  /// 是否继承主题色（未显式传色时）。
  final bool inheritColor;

  /// 伴随文字颜色；不传时用辅助文字色。
  final Color? textColor;

  /// 旧参数名：指示器颜色。
  final Color? loadingColor;

  /// 指示器描边宽度；不传时按 `size / 7` 计算。
  final double? strokeWidth;

  /// 动画类型，默认 [WotLoadingAnimationType.breathing]。
  final WotLoadingAnimationType animationType;

  @override
  State<WotLoading> createState() => _WotLoadingState();
}

class _WotLoadingState extends State<WotLoading> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final iconColor = widget.loadingColor ??
        widget.color ??
        (widget.inheritColor ? scheme.primaryOf(6) : scheme.iconAuxiliary);
    final sw = widget.strokeWidth ?? widget.size / 7;

    final spinner = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WotSpinnerPainter(iconColor, sw, _controller.value, widget.animationType),
          );
        },
      ),
    );

    if (widget.text == null) return spinner;

    return widget.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              spinner,
              const SizedBox(height: 10),
              Text(
                widget.text!,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.textColor ?? scheme.textAuxiliary,
                ),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              spinner,
              const SizedBox(width: 8),
              Text(
                widget.text!,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.textColor ?? scheme.textAuxiliary,
                ),
              ),
            ],
          );
  }
}

/// 圆形加载指示器自绘，保证在任何约束下都是正圆。
class _WotSpinnerPainter extends CustomPainter {
  _WotSpinnerPainter(this.color, this.strokeWidth, this.animationValue, this.animationType);

  final Color color;
  final double strokeWidth;
  final double animationValue;
  final WotLoadingAnimationType animationType;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 取最短边保证正圆
    final dim = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);

    switch (animationType) {
      case WotLoadingAnimationType.breathing:
        // 旋转 + 弧长呼吸伸缩
        final radius = (dim - strokeWidth) / 2;
        if (radius <= 0) return;
        final rect = Rect.fromCircle(center: center, radius: radius);
        final startAngle = 2 * math.pi * animationValue - math.pi / 2;
        final sweep = (40 + 230 * (0.5 + 0.5 * math.sin(2 * math.pi * animationValue))) * math.pi / 180;
        canvas.drawArc(rect, startAngle, sweep, false, paint);

      case WotLoadingAnimationType.uniform:
        // 匀速旋转，固定半圆
        final radius = (dim - strokeWidth) / 2;
        if (radius <= 0) return;
        final rect = Rect.fromCircle(center: center, radius: radius);
        final startAngle = 2 * math.pi * animationValue - math.pi / 2;
        canvas.drawArc(rect, startAngle, math.pi, false, paint);

      case WotLoadingAnimationType.pulse:
        // 整个圆环缩放脉动
        final minRadius = (dim - strokeWidth) / 2 * 0.6;
        final maxRadius = (dim - strokeWidth) / 2;
        // 正弦脉动：0 -> 1 -> 0
        final scale = 0.5 + 0.5 * math.sin(2 * math.pi * animationValue);
        final radius = minRadius + (maxRadius - minRadius) * scale;
        if (radius <= 0) return;
        canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_WotSpinnerPainter old) =>
      color != old.color ||
      strokeWidth != old.strokeWidth ||
      animationValue != old.animationValue ||
      animationType != old.animationType;
}
