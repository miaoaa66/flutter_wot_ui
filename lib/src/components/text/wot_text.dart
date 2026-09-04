import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 文本主题类型，对齐 wot `wd-text` 的 `TextType`。
enum WotTextType {
  /// 默认灰（--wot-text-auxiliary）。
  wotDefault,

  /// 主色文字（--wot-primary-6）。
  primary,

  /// 成功色文字（--wot-success-main）。
  success,

  /// 警告色文字（--wot-warning-main）。
  warning,

  /// 错误色文字（--wot-danger-main）。
  error,
}

/// 文本组件，对应 wot `wd-text`。参数/事件对齐源码。
class WotText extends StatelessWidget {
  const WotText(
    this.text, {
    super.key,
    this.type = WotTextType.wotDefault,
    this.color,
    this.size,
    this.bold = false,
    this.decoration = TextDecoration.none,
    this.lines,
    this.lineHeight,
    this.prefix,
    this.suffix,
    this.textAlign,
    this.height,
    this.onTap,
  });

  /// 文本内容。
  final String text;

  /// 主题类型，决定文字颜色（wot 可选：default/primary/success/warning/error）。
  final WotTextType type;

  /// 自定义文字颜色，传入时优先生效并覆盖 [type] 颜色。
  final Color? color;

  /// 字体大小。
  final double? size;

  /// 是否加粗（对应 wot `bold`）。
  final bool bold;

  /// 文字装饰（下划线/中划线等）。
  final TextDecoration decoration;

  /// 展示行数，超出后省略（对应 wot `lines`）。
  final int? lines;

  /// 行高。
  final double? lineHeight;

  /// 前缀内容。
  final String? prefix;

  /// 后缀内容。
  final String? suffix;

  final TextAlign? textAlign;

  /// 行高（与 [lineHeight] 等价，二选一）。
  final double? height;

  /// 点击文本时触发（对应 wot `click` 事件）。
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final resolvedColor = color ??
        switch (type) {
          WotTextType.wotDefault => scheme.textAuxiliary,
          WotTextType.primary => scheme.primaryOf(6),
          WotTextType.success => scheme.successMain,
          WotTextType.warning => scheme.warningMain,
          WotTextType.error => scheme.dangerMain,
        };
    final body = (prefix ?? '') + text + (suffix ?? '');
    final child = Text(
      body,
      style: TextStyle(
        fontSize: size,
        color: resolvedColor,
        fontWeight: bold ? FontWeight.bold : null,
        decoration: decoration,
        height: height ?? lineHeight,
      ),
      textAlign: textAlign,
      maxLines: lines,
      overflow: lines == null ? null : TextOverflow.ellipsis,
    );
    if (onTap == null) return child;
    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}