import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 进度条，对应 wot `wd-progress`。受控（v-model:value，0-100）。
class WotProgress extends StatelessWidget {
  const WotProgress({
    super.key,
    this.modelValue = 0,
    this.color,
    this.trackColor,
    this.strokeWidth = 14,
    this.showText = true,
    this.textInside = false,
    this.textColor,
    this.format,
    this.height,
  });

  /// 进度值，0~100，受控。
  final num modelValue;

  /// 进度条颜色（已填充段），默认使用主题主色。
  final Color? color;

  /// 轨道颜色（未填充背景），默认使用主题填充色。
  final Color? trackColor;

  /// 进度条高度（粗细），默认 14。
  final double strokeWidth;

  /// 是否显示文字，默认 true。
  final bool showText;

  /// 文字是否内置在进度条内部，默认 false（显示在右侧）。
  final bool textInside;

  /// 文字颜色，默认随进度条颜色。
  final Color? textColor;

  /// 自定义进度文字格式化函数，入参为 0~100 的数值。
  final String Function(num)? format;

  /// 进度条整体高度，未设置时按 [strokeWidth] 计算。
  final double? height;

  String _label() {
    final v = modelValue.clamp(0, 100).toDouble();
    return format != null ? format!(v) : '${v.toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final frac = (modelValue.clamp(0, 100).toDouble() / 100).clamp(0.0, 1.0);
    final filled = color ?? scheme.primaryOf(6);
    final track = trackColor ?? scheme.filledStrong;
    final label = _label();

    final bar = LayoutBuilder(
      builder: (context, constraints) {
        final hp = height ?? strokeWidth;
        return SizedBox(
          height: hp + (textInside && showText ? 18 : 0),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: strokeWidth,
                decoration: BoxDecoration(
                  color: track,
                  borderRadius: BorderRadius.circular(strokeWidth / 2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: frac,
                child: Container(
                  height: strokeWidth,
                  decoration: BoxDecoration(
                    color: filled,
                    borderRadius: BorderRadius.circular(strokeWidth / 2),
                  ),
                ),
              ),
              if (textInside && showText)
                Center(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (!showText || textInside) return bar;
    return Row(
      children: [
        Expanded(child: bar),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(fontSize: 12, color: textColor ?? filled)),
      ],
    );
  }
}