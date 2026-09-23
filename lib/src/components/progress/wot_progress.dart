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
    final inside = textInside && showText;

    final bar = LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final hp = height ?? strokeWidth;
        // 整体高度按 strokeWidth（或显式 height）；textInside 不额外加高，避免文字把条撑粗
        final boxH = hp;
        // 轨道与填充段均按 strokeWidth 绘制（条粗细保持不变），文字居中落在填充段内
        final barH = strokeWidth;
        // 内部文字宽度（含左右内边距），保证填充段不窄于文字，
        // 使文字始终落在底色上而非浅色轨道（避免白字看不见）
        final labelW = inside ? _measureTextWidth(label, 11) + 16 : 0.0;
        final filledW = inside ? (frac * maxW).clamp(labelW, maxW) : frac * maxW;

        return SizedBox(
          height: boxH,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // 轨道（未填充背景）
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: barH,
                    decoration: BoxDecoration(
                      color: track,
                      borderRadius: BorderRadius.circular(strokeWidth / 2),
                    ),
                  ),
                ),
              ),
              // 已填充段：内部文字模式下文字置于其中、右对齐；宽度不小于文字宽度
              // （对应 wot-ui 的 min-width:max-content，避免低进度时文字溢出到浅色轨道而看不见）
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: filledW,
                  height: barH,
                  decoration: BoxDecoration(
                    color: filled,
                    borderRadius: BorderRadius.circular(strokeWidth / 2),
                  ),
                  alignment: Alignment.centerRight,
                  padding: inside ? const EdgeInsets.symmetric(horizontal: 6) : null,
                  child: inside
                      ? Text(label,
                          style: TextStyle(
                              fontSize: 11, color: textColor ?? Colors.white))
                      : null,
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
        Text(label, style: TextStyle(fontSize: 12, color: textColor ?? filled)),
      ],
    );
  }

  /// 测量给定文字在指定字号下的宽度，用于内部文字模式下保证填充段不被压窄。
  double _measureTextWidth(String text, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }
}