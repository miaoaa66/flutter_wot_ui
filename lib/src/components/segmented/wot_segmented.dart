import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 分段选项。
class WotSegmentedOption {
  const WotSegmentedOption({
    required this.label,
    this.value,
    this.disabled = false,
    this.icon,
  });

  /// 选项显示文案。
  final String label;

  /// 选项值，用于与选中值（v-model:value）匹配。
  final Object? value;

  /// 是否禁用该选项，默认 false。
  final bool disabled;

  /// 选项图标名。
  final String? icon;
}

/// 分段控制器，对应 wot `wd-segmented`。
///
/// 受控（v-model:value）：通过 [modelValue]/[onChange] 匹配 [WotSegmentedOption.value]。
class WotSegmented extends StatelessWidget {
  const WotSegmented({
    super.key,
    this.modelValue,
    this.onChange,
    this.options = const [],
    this.block = false,
    this.activeColor,
    this.shape = 'pill',
    this.size = 'medium',
  });

  /// 当前选中的值（受控）。
  final Object? modelValue;

  /// 选中值变化回调。
  final ValueChanged<Object?>? onChange;

  /// 分段选项列表。
  final List<WotSegmentedOption> options;

  /// 是否占满父容器宽度。
  final bool block;

  /// 激活色。
  final Color? activeColor;

  /// 形状：pill（胶囊）/round（圆角）/square（方形）。
  final String shape;

  /// 尺寸：small/medium/large。
  final String size;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final active = activeColor ?? scheme.primaryOf(6);
    final radius = switch (shape) {
      'square' => BorderRadius.zero,
      'round' => BorderRadius.circular(4),
      _ => BorderRadius.circular(22),
    };
    final vPadding = switch (size) {
      'small' => 4.0,
      'large' => 10.0,
      _ => 7.0,
    };
    final fontSize = switch (size) {
      'small' => 12.0,
      'large' => 16.0,
      _ => 14.0,
    };

    final row = Row(
      children: [
        for (final opt in options)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: opt.disabled
                  ? null
                  : () {
                      if (modelValue != opt.value) onChange?.call(opt.value);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                constraints: const BoxConstraints(minHeight: 32),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: 12),
                decoration: BoxDecoration(
                  color: modelValue == opt.value ? active : Colors.transparent,
                  borderRadius: radius,
                ),
                child: Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: modelValue == opt.value ? FontWeight.w600 : FontWeight.w400,
                    color: modelValue == opt.value
                        ? Colors.white
                        : (opt.disabled ? scheme.textDisabled : scheme.textMain),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    final container = Container(
      decoration: BoxDecoration(
        color: scheme.filledStrong,
        borderRadius: radius,
      ),
      padding: const EdgeInsets.all(2),
      child: row,
    );

    return block
        ? Container(child: container)
        : SizedBox(width: options.length * 88.0, child: container);
  }
}