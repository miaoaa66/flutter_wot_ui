import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 文本类型：决定颜色语义。
enum WotTextType { main, secondary, auxiliary, disabled, placeholder, white }

/// 文本组件，对应 wot `wd-text`。
class WotText extends StatelessWidget {
  const WotText(
    this.text, {
    super.key,
    this.size,
    this.type,
    this.color,
    this.strong = false,
    this.disabled = false,
    this.lineClamp,
    this.textAlign,
    this.fontWeight,
    this.height,
    this.decoration,
  });

  final String text;
  final double? size;
  final WotTextType? type;
  final Color? color;

  /// 是否加粗。
  final bool strong;

  /// 是否禁用（使用禁用色）。
  final bool disabled;

  /// 最大行数，超出省略。
  final int? lineClamp;

  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final double? height;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final resolvedColor = color ??
        switch (type) {
          WotTextType.secondary => scheme.textSecondary,
          WotTextType.auxiliary => scheme.textAuxiliary,
          WotTextType.disabled => scheme.textDisabled,
          WotTextType.placeholder => scheme.textPlaceholder,
          WotTextType.white => scheme.textWhite,
          _ => disabled ? scheme.textDisabled : scheme.textMain,
        };
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: resolvedColor,
        fontWeight: strong ? FontWeight.w600 : fontWeight,
        height: height,
        decoration: decoration,
      ),
      textAlign: textAlign,
      maxLines: lineClamp,
      overflow: lineClamp == null ? null : TextOverflow.ellipsis,
    );
  }
}