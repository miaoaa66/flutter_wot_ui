import 'package:flutter/material.dart';

/// 行布局组件，对应 wot `wd-row`（flex 的 24 栅格容器）。
///
/// 直接子级若为 [WotCol]，宽度 = 行宽 × span/24，offset 在其左侧插入
/// 行宽 × offset/24 的空白；其余空间由 [justify] 分配（对齐 wot 的 CSS
/// flex 语义）。其他子级原样放置。
class WotRow extends StatelessWidget {
  const WotRow({
    super.key,
    this.gutter = 0,
    this.align = CrossAxisAlignment.start,
    this.justify = MainAxisAlignment.start,
    required this.children,
    this.onClick,
  });

  /// 栅格间距（每个 [WotCol] 左右 padding 之和）。
  final double gutter;

  /// 垂直对齐（`align-items`，等价于 [CrossAxisAlignment]）。
  final CrossAxisAlignment align;

  /// 水平分布（`justify-content`）。
  final MainAxisAlignment justify;

  /// 子元素列表（[WotCol] 按栅格分配，其他原样放置）。
  final List<Widget> children;

  /// 点击回调。
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bounded = constraints.maxWidth.isFinite;
      final unit = bounded ? constraints.maxWidth / 24.0 : 0.0;

      final items = <Widget>[
        for (final child in children)
          if (child is WotCol && bounded)
            SizedBox(
              width: unit * (child.offset + child.span),
              child: Row(
                children: [
                  if (child.offset > 0) SizedBox(width: unit * child.offset),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: gutter / 2),
                      child: child.child,
                    ),
                  ),
                ],
              ),
            )
          else if (child is WotCol)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: gutter / 2),
              child: child.child,
            )
          else
            child,
      ];

      final row = Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: justify,
        crossAxisAlignment: align,
        children: items,
      );

      final content = onClick == null
          ? row
          : InkWell(onTap: onClick, child: row);
      return content;
    });
  }
}

/// 列组件，对应 wot `wd-col`。栅格 0-24，须作为 [WotRow] 的直接子级。
class WotCol extends StatelessWidget {
  const WotCol({
    super.key,
    this.span = 24,
    this.offset = 0,
    required this.child,
  });

  /// 占据栅格数（0-24）。
  final int span;

  /// 偏移栅格数（0-24）。
  final int offset;

  /// 该列内容。
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
