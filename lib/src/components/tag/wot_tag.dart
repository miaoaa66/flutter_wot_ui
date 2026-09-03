import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../../theme/wot_scheme.dart';

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
    this.closable = false,
    this.color,
    this.textStyle,
    this.onClick,
    this.onClose,
  });

  final String text;
  final WotTagType type;
  final WotTagVariant variant;
  final WotTagSize size;
  final bool round;
  final bool closable;
  final Color? color;
  final TextStyle? textStyle;
  final VoidCallback? onClick;
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

    // 变体着色。
    late final Color bg;
    late final Color fg;
    late final BoxBorder boxBorder;
    switch (variant) {
      case WotTagVariant.dark:
        bg = main;
        fg = Colors.white;
        boxBorder = Border.all(color: Colors.transparent, width: 0);
      case WotTagVariant.plain:
        bg = Colors.transparent;
        fg = main;
        boxBorder = Border.all(color: main, width: 1);
      case WotTagVariant.light:
        bg = main.withValues(alpha: 0.1);
        fg = main;
        boxBorder = Border.all(color: Colors.transparent, width: 0);
      case WotTagVariant.linear:
        bg = main;
        fg = Colors.white;
        boxBorder = Border.all(color: Colors.transparent, width: 0);
    }

    final chip = Container(
      padding: EdgeInsets.symmetric(horizontal: vPadding == 0 ? 4 : 8, vertical: vPadding),
      decoration: BoxDecoration(
        color: bg,
        border: boxBorder,
        borderRadius: BorderRadius.circular(round ? 4 : 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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