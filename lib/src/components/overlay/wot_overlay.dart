import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 遮罩层，对应 wot `wd-overlay`。
class WotOverlay extends StatelessWidget {
  const WotOverlay({
    super.key,
    this.visible = true,
    this.opacity,
    this.color,
    this.duration = const Duration(milliseconds: 300),
    this.onClick,
    this.onTap,
    this.child,
    this.withAnimation = true,
  });

  final bool visible;

  /// 遮罩透明度（0-1），未设置时使用语义主遮罩。
  final double? opacity;

  /// 自定义遮罩颜色（优先于 [opacity]）。
  final Color? color;

  /// 显隐动画时长。
  final Duration duration;

  final VoidCallback? onClick;
  final VoidCallback? onTap;
  final Widget? child;
  final bool withAnimation;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final baseColor = color ?? scheme.opacMainCover;
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? (opacity ?? 1) : 0,
        duration: withAnimation ? duration : Duration.zero,
        curve: Curves.easeOut,
        child: Container(
          color: baseColor,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: onClick ?? onTap,
            child: child,
          ),
        ),
      ),
    );
  }
}