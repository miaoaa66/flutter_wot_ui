import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 单元格分组，对应 wot `wd-cell-group`。
///
/// 将若干 [WotCell] 包裹成卡片/分段列表；`inset` 为内嵌卡片（带圆角与边距），
/// `bordered` 控制是否显示分割线与边框。颜色取自语义令牌 `borderLight/borderStrong` 等。
class WotCellGroup extends StatelessWidget {
  const WotCellGroup({
    super.key,
    this.inset = false,
    this.bordered = false,
    this.rounded = true,
    this.space = 0,
    this.customStyle,
    required this.children,
  });

  /// 是否以内嵌卡片样式展示（带外边距与圆角）。
  final bool inset;

  /// 是否显示顶部/底部边框。
  final bool bordered;

  /// 是否圆角。
  final bool rounded;

  /// 每项间距。
  final double space;

  /// 透传 style（此处为非关键视觉扩展，可选）。
  final BoxDecoration? customStyle;

  /// 分组内展示的单元格列表。
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final borderColor = scheme.borderLight;

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0 && space > 0) SizedBox(height: space),
          children[i],
        ],
      ],
    );

    if (!inset) {
      if (!bordered) return column;
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(color: borderColor),
          ),
        ),
        child: column,
      );
    }

    // 内嵌卡片：外边距 + 圆角 + 整体边框。
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: (customStyle ?? const BoxDecoration()).copyWith(
          color: scheme.filledContent,
          borderRadius: rounded ? BorderRadius.circular(12) : null,
          border: bordered
              ? Border.all(color: borderColor)
              : (customStyle?.border),
        ),
        child: ClipRRect(
          borderRadius: rounded ? BorderRadius.circular(12) : BorderRadius.zero,
          child: column,
        ),
      ),
    );
  }
}