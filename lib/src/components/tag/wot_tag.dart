import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../../theme/wot_scheme.dart';
import '../icon/wot_icon.dart';

/// 标签类型，对齐 wot `type`。
enum WotTagType { primary, success, info, warning, danger }

/// 标签明暗变体，对齐 wot `variant`。
enum WotTagVariant { dark, plain, light, linear, dashed }

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
      case WotTagVariant.dashed:
        // 虚线边框（D 类 P1）：透明底 + 虚线描边，配色语义与 plain 一致
        // （bgColor 同时充当边框色）。
        bg = bgColor ?? Colors.transparent;
        fg = textColor ?? main;
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

    final content = Row(
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
    );

    Widget chip;
    if (variant == WotTagVariant.dashed) {
      // 虚线变体（D 类 P1）：Flutter 无内建 dashed border，用前景自绘
      // 虚线圆角矩形（边框色与 plain 同源：bgColor ?? main）。
      final borderColor = bgColor ?? main;
      chip = CustomPaint(
        foregroundPainter: _DashedRRectPainter(color: borderColor, radius: radius),
        child: Container(
          color: bg,
          padding: EdgeInsets.symmetric(horizontal: vPadding == 0 ? 4 : 8, vertical: vPadding),
          child: content,
        ),
      );
    } else {
      // 注意：这里刻意用 DecoratedBox + Padding，而不是 Container。
      // Container 会把装饰的边框厚度叠加进 padding（其 _paddingIncludingDecoration
      // 取 padding.add(decoration.padding)，而 Border.dimensions 取 strokeInset，
      // 默认 strokeAlignInside 时 strokeInset == width），于是带 1px 边框的 plain
      // 变体会比 dark/light 等外形各多 2px。DecoratedBox 不参与布局、边框只画在
      // 盒子内侧，各变体外形尺寸严格一致（与 wot-ui Vue 的覆盖层描边行为对齐）。
      chip = DecoratedBox(
        decoration: BoxDecoration(color: bg, border: boxBorder, borderRadius: radius),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: vPadding == 0 ? 4 : 8, vertical: vPadding),
          child: content,
        ),
      );
    }

    if (onClick == null) return chip;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onClick, child: chip);
  }
}

/// 虚线圆角矩形描边（D 类 P1，tag dashed 变体专用）。
class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = radius.toRRect(Offset.zero & size);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dash = 3.0;
    const gap = 2.0;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final end = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) => old.color != color;
}