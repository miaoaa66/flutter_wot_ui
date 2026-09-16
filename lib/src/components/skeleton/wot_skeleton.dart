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
    this.hideTitles = false,
    this.child,
  });

  /// 是否处于加载中骨架屏状态，默认 true。
  final bool loading;

  /// 是否显示头像占位，默认 false。
  final bool avatar;

  /// 头像占位边长，默认 32。
  final double avatarSize;

  /// 头像占位形状，round（圆形）/square（方形），默认 round。
  final WotSkeletonAvatarShape avatarShape;

  /// 是否显示标题行占位，默认 true。
  final bool title;

  /// 文本行数，0 表示无多行文本，默认 0。
  final int row;

  /// 行宽，可为百分比字符串（如 `40%`）或具体像素数。
  final Object rowWidth;

  /// 每行高度，默认 14。
  final double rowHeight;

  /// 是否开启动画（闪烁效果），默认 true。
  final bool animate;

  /// 是否隐藏所有文本占位（标题与行），仅保留头像；默认 false。
  final bool hideTitles;

  /// 内容组件，加载完成后显示。
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
                      if (widget.title && !widget.hideTitles)
                        _block(context, _resolveWidth(widget.rowWidth, boxWidth) ?? boxWidth * 0.4, 16),
                      if (widget.row > 0 && !widget.hideTitles) ...[
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
class WotSkeletonItem extends StatefulWidget {
  const WotSkeletonItem({
    super.key,
    this.type = WotSkeletonItemType.text,
    this.animate = true,
    this.width,
    this.height,
    this.size = 32,
  });

  /// 元素类型：text/rect/image/circular，默认 text。
  final WotSkeletonItemType type;

  /// 是否开启动画，默认 true。
  final bool animate;

  /// 元素宽度，未设置时按类型取默认宽度。
  final double? width;

  /// 元素高度，未设置时按类型取默认高度。
  final double? height;

  /// 图片/圆形占位的边长。
  final double size;

  @override
  State<WotSkeletonItem> createState() => _WotSkeletonItemState();
}

class _WotSkeletonItemState extends State<WotSkeletonItem>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void didUpdateWidget(WotSkeletonItem old) {
    super.didUpdateWidget(old);
    if (old.animate != widget.animate) _syncController();
  }

  /// [WotSkeletonItem.animate] 为 false 时不创建/销毁控制器，避免空转。
  void _syncController() {
    if (widget.animate) {
      _controller ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
    } else {
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final type = widget.type;
    final width = widget.width;
    final height = widget.height;
    final size = widget.size;
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
    final controller = _controller;
    if (controller == null) return block;
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.4).animate(controller),
      child: block,
    );
  }
}

/// 骨架屏元素类型。
enum WotSkeletonItemType { image, circular, rect, text }