import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 分割线类型。
enum WotDividerType { horizontal, vertical }

/// 文字在分割线中的位置。
enum WotDividerPosition { left, center, right }

/// 分割线组件，对应 wot `wd-divider`。
class WotDivider extends StatelessWidget {
  const WotDivider({
    super.key,
    this.type = WotDividerType.horizontal,
    this.hairline = true,
    this.text,
    this.textPosition = WotDividerPosition.center,
    this.lineColor,
    this.textColor,
    this.fontSize = 14,
    this.lineWidth,
    this.dashed = false,
    this.distance,
  });

  /// 分割线方向：horizontal 水平 / vertical 垂直，默认 horizontal。
  final WotDividerType type;

  /// 是否使用 0.5px 细线；默认 true（否则为 1px）。
  final bool hairline;

  /// 分割线中间文字；为空则不渲染文字。
  final String? text;

  /// 文字位置，可选 [WotDividerPosition]，默认 center。
  final WotDividerPosition textPosition;

  /// 分割线颜色；为空时取主题分隔线色。
  final Color? lineColor;

  /// 文字颜色；为空时取主题正文色。
  final Color? textColor;

  /// 文字字号（逻辑像素），默认 14。
  final double fontSize;

  /// 分割线宽度（厚度），默认 0.5（hairline 0.5，否则 1）。
  final double? lineWidth;

  /// 是否渲染为虚线；默认 false（实线）。水平/垂直均支持，虚线暂不支持自定义虚线段长。
  final bool dashed;

  /// 分割线相对两端内容/边缘的横向间距（逻辑像素）；默认 null 表示不额外缩进（沿用整宽布局）。
  final double? distance;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final color = lineColor ?? scheme.dividerMain;
    final thickness = lineWidth ?? (hairline ? 0.5 : 1.0);

    final Widget line = dashed
        ? CustomPaint(
            painter: _DashedLinePainter(color: color, thickness: thickness),
            size: Size(double.infinity, thickness),
          )
        : Container(height: thickness, color: color);

    // 垂直分割线：插槽文字不生效。
    if (type == WotDividerType.vertical) {
      if (dashed) {
        return CustomPaint(
          painter: _DashedLinePainter(color: color, thickness: thickness),
          size: Size(thickness, double.infinity),
        );
      }
      return Container(width: thickness, height: double.infinity, color: color);
    }

    if (text == null || text!.isEmpty) {
      return _applyDistance(line);
    }

    // 文字行样式。
    final label = Padding(
      padding: EdgeInsets.symmetric(horizontal: distance ?? 16),
      child: Text(
        text!,
        style: TextStyle(fontSize: fontSize, color: textColor ?? scheme.textMain),
      ),
    );

    final Widget row = switch (textPosition) {
      // left：文字靠左，分割线填充右侧。
      WotDividerPosition.left => Row(
          children: [label, Expanded(child: line)],
        ),
      // right：文字靠右，分割线填充左侧。
      WotDividerPosition.right => Row(
          children: [Expanded(child: line), label],
        ),
      // center：居中文字，两侧各一段分割线。
      WotDividerPosition.center => Row(
          children: [Expanded(child: line), label, Expanded(child: line)],
        ),
    };
    return _applyDistance(row);
  }

  Widget _applyDistance(Widget child) {
    if (distance == null) return child;
    return Padding(padding: EdgeInsets.symmetric(horizontal: distance!), child: child);
  }
}

/// 虚线绘制：沿水平或垂直方向画等距虚线段。
class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color, required this.thickness});

  final Color color;
  final double thickness;

  static const double _dash = 6;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.square;

    // 0.5px 细线虽为浮点，但以常量虚段/间隔绘制即可保证虚线效果。
    // 线以厚度方向居中绘制，避免 0.5px 高被裁剪掉一半。
    final horizontal = size.width >= size.height;
    final total = horizontal ? size.width : size.height;
    final cy = thickness / 2;
    double pos = 0;
    while (pos < total) {
      final end = (pos + _dash).clamp(0, total).toDouble();
      if (horizontal) {
        canvas.drawLine(Offset(pos, cy), Offset(end, cy), paint);
      } else {
        canvas.drawLine(Offset(cy, pos), Offset(cy, end), paint);
      }
      pos = end + _gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) =>
      old.color != color || old.thickness != thickness;
}