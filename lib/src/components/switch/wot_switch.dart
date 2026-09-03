import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 开关，对应 wot `wd-switch`。受控（v-model:value，true/false）。
class WotSwitch extends StatelessWidget {
  const WotSwitch({
    super.key,
    this.modelValue = false,
    this.onChange,
    this.disabled = false,
    this.activeColor,
    this.inactiveColor,
    this.activeText,
    this.inactiveText,
    this.size = 24,
    this.name,
  });

  final bool modelValue;
  final ValueChanged<bool>? onChange;
  final bool disabled;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? activeText;
  final String? inactiveText;
  final double size;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final on = modelValue;
    final trackColor = on
        ? (activeColor ?? scheme.primaryOf(6))
        : (inactiveColor ?? scheme.filledStrong);
    final width = size * 2;
    final height = size;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled
          ? null
          : () {
              onChange?.call(!on);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(height * 0.15),
            child: Container(
              width: height * 0.7,
              height: height * 0.7,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}