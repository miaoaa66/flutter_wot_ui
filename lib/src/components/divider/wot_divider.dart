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
  });

  final WotDividerType type;
  final bool hairline;
  final String? text;
  final WotDividerPosition textPosition;
  final Color? lineColor;
  final Color? textColor;
  final double fontSize;

  /// 分割线宽度（厚度），默认 0.5（hairline 0.5，否则 1）。
  final double? lineWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final color = lineColor ?? scheme.dividerMain;
    final thickness = lineWidth ?? (hairline ? 0.5 : 1.0);

    if (type == WotDividerType.vertical) {
      return Container(
        width: thickness,
        height: double.infinity,
        color: color,
      );
    }

    final line = Container(height: thickness, color: color);
    if (text == null || text!.isEmpty) return line;

    // 文字行样式。
    final label = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text!,
        style: TextStyle(fontSize: fontSize, color: textColor ?? scheme.textMain),
      ),
    );

    return switch (textPosition) {
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
  }
}