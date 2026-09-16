import 'package:flutter/material.dart';

/// 布局占位组件，对应 wot `wd-gap`。
class WotGap extends StatelessWidget {
  const WotGap({
    super.key,
    this.gap = 14,
    this.width,
    this.bgColor,
    this.flex = false,
  });

  /// 间距方向：true 为纵向（高度），false 为横向（宽度）。
  final bool flex;

  /// 间距大小（逻辑像素）。
  final num gap;

  /// 显式覆盖另一方向尺寸（如指定宽度/高度）。
  final num? width;

  /// 背景色。
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    // flex=true 表示垂直（占高）空隙；false 表示水平（占宽）空隙。
    final g = gap.toDouble();
    final size = flex ? Size(width?.toDouble() ?? g, g) : Size(g, width?.toDouble() ?? g);
    return DecoratedBox(
      decoration: BoxDecoration(color: bgColor),
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: SizedBox.expand(),
      ),
    );
  }
}