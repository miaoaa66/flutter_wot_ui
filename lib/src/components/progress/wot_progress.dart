import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 进度条，对应 wot `wd-progress`。受控（v-model:value，0-100）。
class WotProgress extends StatelessWidget {
  const WotProgress({
    super.key,
    this.modelValue = 0,
    this.color,
    this.trackColor,
    this.strokeWidth = 6,
    this.showText = true,
    this.textInside = false,
    this.textColor,
    this.format,
    this.height,
  });

  final num modelValue;
  final Color? color;
  final Color? trackColor;
  final double strokeWidth;
  final bool showText;
  final bool textInside;
  final Color? textColor;
  final String Function(num)? format;
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