import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 分段控制器形状（T3.3 枚举化）。
enum WotSegmentedShape { pill, square, round }

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

/// 分段控制器尺寸。
enum WotSegmentedSize { small, medium, large }

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
    this.shape = WotSegmentedShape.pill,
    this.size = WotSegmentedSize.medium,
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
  final WotSegmentedShape shape;

  /// 尺寸，默认 medium。
  final WotSegmentedSize size;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final active = activeColor ?? scheme.primaryOf(6);
    final radius = switch (shape) {
      WotSegmentedShape.square => BorderRadius.zero,
      WotSegmentedShape.round => BorderRadius.circular(4),
      WotSegmentedShape.pill => BorderRadius.circular(22),
    };
    final vPadding = switch (size) {
      WotSegmentedSize.small => 4.0,
      WotSegmentedSize.large => 10.0,
      WotSegmentedSize.medium => 7.0,
    };
    final fontSize = switch (size) {
      WotSegmentedSize.small => 12.0,
      WotSegmentedSize.large => 16.0,
      WotSegmentedSize.medium => 14.0,
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

    // 无障碍：整段读出「当前选中项」，读屏可感知分段选择器的状态。
    final selectedLabel =
        options.where((o) => o.value == modelValue).map((o) => o.label).join('、');
    return Semantics(
      value: selectedLabel.isEmpty ? null : '当前选中：$selectedLabel',
      child: block
          ? Container(child: container)
          : SizedBox(width: options.length * 88.0, child: container),
    );
  }
}