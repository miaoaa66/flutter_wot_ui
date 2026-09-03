import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 骨架屏，对应 wot `wd-skeleton`。
///
/// 参数对齐 wot：`loading`（是否显示骨架）、`avatar`（是否显示头像占位）、
/// `avatarSize`、`avatarShape`、`title`、`row`（文本行数）、`rowWidth`（行宽，可传字符串形式）、
/// `rowHeight`、`animate`（是否闪烁动画）。内容显示时展示 [child]。
class WotSkeleton extends StatefulWidget {
  const WotSkeleton({
    super.key,
    this.loading = true,
    this.avatar = false,
    this.avatarSize = 32,
    this.avatarShape = WotSkeletonAvatarShape.round,
    this.title = true,
    this.row = 0,
    this.rowWidth = '100%',
    this.rowHeight = 14,
    this.animate = true,
    this.child,
  });

  final bool loading;
  final bool avatar;
  final double avatarSize;
  final WotSkeletonAvatarShape avatarShape;
  final bool title;
  final int row;

  /// 行宽，可为百分比字符串（如 `40%`）或具体像素数。
  final Object rowWidth;

  final double rowHeight;
  final bool animate;
  final Widget? child;

  @override
  State<WotSkeleton> createState() => _WotSkeletonState();
}

/// 头像占位形状。
enum WotSkeletonAvatarShape { round, square }

class _WotSkeletonState extends State<WotSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? _resolveWidth(Object w, double boxWidth) {
    if (w is num) return w.toDouble();
    final s = w.toString().trim();
    if (s.endsWith('%')) {
      final p = double.tryParse(s.substring(0, s.length - 1));
      if (p != null) return boxWidth * p / 100;
    }
    return null;
  }

  Widget _block(BuildContext context, double width, double height) {
    final scheme = context.wotScheme;
    final base = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: scheme.filledStrong, borderRadius: BorderRadius.circular(4)),
    );
    if (!widget.animate) return base;
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.4).animate(_controller),
      child: base,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    if (!widget.loading) return widget.child ?? const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.maxWidth;

        Widget body = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.avatar) ...[
                  Container(
                    width: widget.avatarSize,
                    height: widget.avatarSize,
                    decoration: BoxDecoration(
                      color: scheme.filledStrong,
                      shape: widget.avatarShape == WotSkeletonAvatarShape.square ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: widget.avatarShape == WotSkeletonAvatarShape.square ? BorderRadius.circular(6) : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.title) _block(context, _resolveWidth(widget.rowWidth, boxWidth) ?? boxWidth * 0.4, 16),
                      if (widget.row > 0) ...[
                        const SizedBox(height: 10),
                        for (var i = 0; i < widget.row; i++)
                          Padding(
                            padding: EdgeInsets.only(bottom: i == widget.row - 1 ? 0 : 8),
                            child: _block(context, _resolveWidth(widget.rowWidth, boxWidth) ?? boxWidth, widget.rowHeight),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        );

        return ClipRect(
          child: body,
        );
      },
    );
  }
}

/// 骨架屏元素，对应 wot `wd-skeleton-item`。
class WotSkeletonItem extends StatelessWidget {
  const WotSkeletonItem({
    super.key,
    this.type = WotSkeletonItemType.text,
    this.animate = true,
    this.width,
    this.height,
    this.size = 32,
  });

  final WotSkeletonItemType type;
  final bool animate;
  final double? width;
  final double? height;

  /// 图片/圆形占位的边长。
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    Widget block;
    switch (type) {
      case WotSkeletonItemType.image:
        block = Container(
          width: width ?? size,
          height: height ?? size,
          decoration: BoxDecoration(color: scheme.filledStrong, borderRadius: BorderRadius.circular(4)),
        );
      case WotSkeletonItemType.circular:
        block = Container(width: size, height: size, decoration: BoxDecoration(color: scheme.filledStrong, shape: BoxShape.circle));
      case WotSkeletonItemType.rect:
        block = Container(
          width: width ?? double.infinity,
          height: height ?? 18,
          decoration: BoxDecoration(color: scheme.filledStrong, borderRadius: BorderRadius.circular(4)),
        );
      case WotSkeletonItemType.text:
        block = Container(
          width: width ?? double.infinity,
          height: height ?? 14,
          decoration: BoxDecoration(color: scheme.filledStrong, borderRadius: BorderRadius.circular(4)),
        );
    }
    return block;
  }
}

/// 骨架屏元素类型。
enum WotSkeletonItemType { image, circular, rect, text }