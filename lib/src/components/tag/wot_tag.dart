import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../../theme/wot_scheme.dart';
import '../icon/wot_icon.dart';

/// 标签类型，对齐 wot `type`。
enum WotTagType { primary, success, info, warning, danger }

/// 标签明暗变体，对齐 wot `variant`。
enum WotTagVariant { dark, plain, light, linear }

/// 标签尺寸。
enum WotTagSize { large, medium, small, mini }

/// 标签，对应 wot `wd-tag`。
class WotTag extends StatelessWidget {
  const WotTag({
    super.key,
    required this.text,
    this.type = WotTagType.primary,
    this.variant = WotTagVariant.light,
    this.size = WotTagSize.medium,
    this.round = true,
    this.mark = false,
    this.closable = false,
    this.color,
    this.bgColor,
    this.textColor,
    this.icon,
    this.iconSize,
    this.textStyle,
    this.onClick,
    this.onClose,
  });

  final String text;

  /// 标签类型（主色），可选 `primary`/`success`/`info`/`warning`/`danger`，默认 primary。
  final WotTagType type;

  /// 标签变体，可选 `dark`/`plain`/`light`/`linear`，默认 light。
  final WotTagVariant variant;

  /// 标签尺寸，可选 `large`/`medium`/`small`/`mini`，默认 medium。
  final WotTagSize size;

  /// 是否圆角，默认 true。
  final bool round;

  /// 是否为卷标（标记）样式：如图 `mark` 时使用不对称大圆角模拟标签角，默认 false。
  final bool mark;

  /// 是否可关闭；为 true 时在标签右侧显示关闭图标，点击触发 [onClose]。
  final bool closable;

  /// 自定义标签主题色（覆盖 [type] 的默认主色）；为空时取 [type] 对应主题色。
  final Color? color;

  /// 自定义背景色与边框色（覆盖变体默认背景）；为空时按 [variant] 推导。
  final Color? bgColor;

  /// 自定义文字颜色（覆盖变体默认前景色）；为空时按 [variant] 推导。
  final Color? textColor;

  /// 左侧图标名称（wot icon）；为空则不显示图标。
  final String? icon;

  /// 左侧图标尺寸（逻辑像素）；为空时按 [size] 推导。
  final double? iconSize;

  /// 文案自定义样式；为空时使用内置样式。
  final TextStyle? textStyle;

  /// 点击标签时触发的回调。
  final VoidCallback? onClick;

  /// 点击关闭按钮（[closable] 为 true）时触发的回调。
  final VoidCallback? onClose;

  Color _main(WotScheme s) => switch (type) {
        WotTagType.primary => s.primaryOf(6),
        WotTagType.success => s.successMain,
        WotTagType.info => s.textSecondary,
        WotTagType.warning => s.warningMain,
        WotTagType.danger => s.dangerMain,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final main = color ?? _main(scheme);

    // 几何尺寸。
    final vPadding = switch (size) {
      WotTagSize.mini => 0.0,
      WotTagSize.small => 1.0,
      WotTagSize.large => 6.0,
      WotTagSize.medium => 3.0,
    };
    final fontSize = switch (size) {
      WotTagSize.mini => 9.0,
      WotTagSize.small => 10.0,
      WotTagSize.large => 14.0,
      WotTagSize.medium => 12.0,
    };
    final iconSz = iconSize ?? fontSize + 2;

    // 变体着色。
    late final Color bg;
    late final Color fg;
    late final BoxBorder boxBorder;
    switch (variant) {
      case WotTagVariant.dark:
        bg = bgColor ?? main;
        fg = textColor ?? Colors.white;
        boxBorder = Border.all(color: Colors.transparent, width: 0);
      case WotTagVariant.plain:
        final b = bgColor ?? main;
        bg = bgColor ?? Colors.transparent;
        fg = textColor ?? main;
        boxBorder = Border.all(color: b, width: 1);
      case WotTagVariant.light:
        bg = bgColor ?? main.withValues(alpha: 0.1);
        fg = textColor ?? main;
        boxBorder = Border.all(color: Colors.transparent, width: 0);
      case WotTagVariant.linear:
        bg = bgColor ?? main;
        fg = textColor ?? Colors.white;
        boxBorder = Border.all(color: Colors.transparent, width: 0);
    }

    // 圆角：round 为统一小圆角；mark 为不对称大圆角（卷标样式），mark 优先。
    final radius = mark
        ? const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(3),
            bottomLeft: Radius.circular(3),
            bottomRight: Radius.circular(3),
          )
        : BorderRadius.circular(round ? 4 : 2);

    final chip = Container(
      padding: EdgeInsets.symmetric(horizontal: vPadding == 0 ? 4 : 8, vertical: vPadding),
      decoration: BoxDecoration(color: bg, border: boxBorder, borderRadius: radius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && icon!.isNotEmpty) ...[
            WotIcon(name: icon!, size: iconSz, color: fg),
            const SizedBox(width: 2),
          ],
          Text(
            text,
            style: textStyle ??
                TextStyle(fontSize: fontSize, color: fg, height: 1.2),
          ),
          if (closable) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close, size: fontSize, color: fg),
            ),
          ],
        ],
      ),
    );

    if (onClick == null) return chip;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onClick, child: chip);
  }
}