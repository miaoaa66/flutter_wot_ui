import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 遮罩层，对应 wot `wd-overlay`。
class WotOverlay extends StatefulWidget {
  const WotOverlay({
    super.key,
    this.visible = true,
    this.show,
    this.opacity,
    this.color,
    this.duration = const Duration(milliseconds: 300),
    this.onClick,
    this.onTap,
    this.child,
    this.withAnimation = true,
    this.zIndex,
    this.clickToClose = false,
  });

  /// 是否显示遮罩层（受控）。未设置 [show] 时生效。
  final bool visible;

  /// 是否展示遮罩层（wot `show`，与 [visible] 互为别名；[show] 非空时优先）。
  final bool? show;

  /// 遮罩透明度（0-1），未设置时使用语义主遮罩。
  final double? opacity;

  /// 自定义遮罩颜色（优先于 [opacity]）。
  final Color? color;

  /// 显隐动画时长。
  final Duration duration;

  /// 点击遮罩层时回调。
  final VoidCallback? onClick;

  /// 点击遮罩层时回调（兼容旧命名；[onClick] 优先）。
  final VoidCallback? onTap;

  /// 遮罩上叠加的内容。
  final Widget? child;

  /// 是否播放显隐动画；为 false 时瞬间显隐。
  final bool withAnimation;

  /// 层级（wot `z-index`，默认 10）。
  ///
  /// Flutter 中同层级的上下顺序由父级 `Stack` 的子节点渲染顺序决定，
  /// 此参数主要用于 API 对齐与可读性标记；多个遮罩需调整层级时，
  /// 请在父级 `Stack` 中调整顺序。
  final int? zIndex;

  /// 点击遮罩层后是否自动隐藏本次遮罩（仅当遮罩为"一次性"提示时需要；
  /// 受控场景请使用 [onClick]/[onTap] 由父级控制显隐）。
  final bool clickToClose;

  @override
  State<WotOverlay> createState() => _WotOverlayState();
}

class _WotOverlayState extends State<WotOverlay> {
  /// 由点击遮罩自隐藏时标记为 true，用于覆盖受控的 [visible]/[show]。
  bool _hiddenByTap = false;

  /// 实际可见性：[show] 优先于 [visible]，且点击自隐藏后不可见。
  bool get _visible => (widget.show ?? widget.visible) && !_hiddenByTap;

  @override
  void didUpdateWidget(covariant WotOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasOn = oldWidget.show ?? oldWidget.visible;
    final nowOn = widget.show ?? widget.visible;
    // 父级重新打开时，清除点击自隐藏状态。
    if (!wasOn && nowOn) {
      _hiddenByTap = false;
    }
  }

  void _handleTap() {
    (widget.onClick ?? widget.onTap)?.call();
    if (widget.clickToClose) {
      setState(() => _hiddenByTap = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final baseColor = widget.color ?? scheme.opacMainCover;
    return IgnorePointer(
      ignoring: !_visible,
      child: AnimatedOpacity(
        opacity: _visible ? (widget.opacity ?? 1) : 0,
        duration: widget.withAnimation ? widget.duration : Duration.zero,
        curve: Curves.easeOut,
        child: Container(
          color: baseColor,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: _handleTap,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}