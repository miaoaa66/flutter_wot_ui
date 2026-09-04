import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 宫格，对应 wot `wd-grid`。
///
/// 参数对齐 wot：`columnNum`（列数）、`border`（是否显示边框）、`gap`（格子间距）、
/// `square`（是否固定为正方形）、`reverse`（内容是否反向）。子项通过 [children] 传入 [WotGridItem]。
class WotGrid extends StatelessWidget {
  const WotGrid({
    super.key,
    this.columnNum = 4,
    this.border = false,
    this.gap = 0,
    this.square = true,
    this.reverse = false,
    this.children = const [],
  });

  /// 列数。
  final int columnNum;

  /// 是否显示格子边框。
  final bool border;

  /// 格子间隔（逻辑像素）。
  final double gap;

  /// 是否将格子固定为正方形。
  final bool square;

  /// 是否反向显示内容（图标在文字下方时是否交换）。
  final bool reverse;

  /// 宫格子项列表。
  final List<Widget> children;

  /// 计算在给定总宽度下每个格子的宽度。
  double _cellWidth(double totalWidth, int count) {
    final gaps = (columnNum - 1) * gap;
    assert(totalWidth > gaps, '父容器宽度不足以容纳 $columnNum 列及其间距');
    return (totalWidth - gaps) / columnNum;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final cellWidth = _cellWidth(totalWidth, children.length);

        // 分组：按列数分成行。
        final rows = <List<Widget>>[];
        for (var i = 0; i < children.length; i += columnNum) {
          rows.add(children.sublist(i, (i + columnNum).clamp(0, children.length)));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var r = 0; r < rows.length; r++)
                Padding(
                  padding: EdgeInsets.only(bottom: r == rows.length - 1 ? 0 : gap, right: 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var c = 0; c < rows[r].length; c++)
                        Padding(
                          padding: EdgeInsets.only(right: c == rows[r].length - 1 ? 0 : gap),
                          child: SizedBox(
                            width: cellWidth,
                            // 开启 square 时格子的高与宽相等（正方形）。
                            height: square ? cellWidth : null,
                            child: rows[r][c],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 宫格子项，对应 wot `wd-grid-item`。
///
/// 参数对齐 wot：`text`（文字）、`iconName`（图标名）、`icon`（自绘图标）、
/// `color`（字体颜色）、`iconColor`（图标颜色）、`border`、`dot`（红点）、
/// `badge`（徽标数字）、`onClick`。
class WotGridItem extends StatelessWidget {
  const WotGridItem({
    super.key,
    this.text,
    this.iconName,
    this.icon,
    this.color,
    this.iconColor,
    this.border,
    this.dot = false,
    this.badge,
    this.max = 99,
    this.iconSize = 26,
    this.onClick,
    this.children,
  });

  /// 文字。
  final String? text;

  /// 图标名称（wot 命名）。
  final String? iconName;

  /// 自绘图标（优先级高于 [iconName]）。
  final Widget? icon;

  /// 字体颜色。
  final Color? color;

  /// 图标颜色。
  final Color? iconColor;

  /// 是否显示边框；为空时继承 [WotGrid.border]。
  final bool? border;

  /// 是否显示右上角红点。
  final bool dot;

  /// 右上角徽标数字。
  final num? badge;

  /// 徽标最大值，超过时显示为 `{max}+`，默认 99。
  final num max;

  /// 图标尺寸，默认 26。
  final double iconSize;

  /// 点击回调。
  final VoidCallback? onClick;

  /// 自定义内容（优先级最高，覆盖默认的图标+文字布局）。
  final Widget? children;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final fg = color ?? scheme.textMain;

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          icon!
        else if (iconName != null)
          WotIcon(name: iconName, size: iconSize, color: iconColor ?? scheme.iconMain),
        if (text != null) ...[
          const SizedBox(height: 6),
          Text(text!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: fg)),
        ],
      ],
    );

    // 右上角标记（红点 / 徽标）。
    Widget cell;
    if (dot || badge != null && badge! > 0) {
      cell = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            right: 4,
            top: 4,
            child: dot
                ? Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: scheme.dangerMain, shape: BoxShape.circle),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    constraints: const BoxConstraints(minHeight: 14, minWidth: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.dangerMain,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      badge! > max ? '$max+' : '$badge',
                      style: const TextStyle(fontSize: 9, color: Colors.white, height: 1),
                    ),
                  ),
          ),
        ],
      );
    } else {
      cell = content;
    }

    if (onClick != null) {
      cell = GestureDetector(behavior: HitTestBehavior.opaque, onTap: onClick, child: cell);
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: (border ?? true) ? Border(bottom: BorderSide(color: scheme.borderLight), right: BorderSide(color: scheme.borderLight)) : null,
      ),
      child: cell,
    );
  }
}