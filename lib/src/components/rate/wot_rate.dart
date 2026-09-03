import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 评分，对应 wot `wd-rate`。受控（v-model:value，0~`count`）。
class WotRate extends StatelessWidget {
  const WotRate({
    super.key,
    this.modelValue = 0,
    this.onChange,
    this.count = 5,
    this.size = 24,
    this.color,
    this.activeColor,
    this.gutter = 8,
    this.readonly = false,
    this.disabled = false,
    this.allowHalf = false,
    this.name,
  });

  final int modelValue;
  final ValueChanged<int>? onChange;
  final int count;
  final double size;
  final Color? color;
  final Color? activeColor;
  final double gutter;
  final bool readonly;
  final bool disabled;
  final bool allowHalf;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final active = activeColor ?? scheme.warningMain;
    final inactive = color ?? scheme.borderLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= count; i++) ...[
          if (i > 1) SizedBox(width: gutter),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (readonly || disabled)
                ? null
                : () {
                    onChange?.call(i);
                  },
            child: Icon(
              Icons.star,
              size: size,
              color: i <= modelValue ? active : inactive,
            ),
          ),
        ],
      ],
    );
  }
}
