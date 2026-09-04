import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 加载指示器，对应 wot `wd-loading`。
class WotLoading extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final iconColor = loadingColor ??
        color ??
        (inheritColor ? scheme.primaryOf(6) : scheme.iconAuxiliary);

    final spinner = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? size / 7,
        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
      ),
    );

    if (text == null) return spinner;

    return vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              spinner,
              const SizedBox(height: 10),
              Text(
                text!,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor ?? scheme.textAuxiliary,
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
                text!,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor ?? scheme.textAuxiliary,
                ),
              ),
            ],
          );
  }
}