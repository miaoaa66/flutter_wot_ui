import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 幕布位置。
enum WotCurtainPosition { center, bottom, top, left, right }

/// 幕布，对应 wot `wd-curtain`。
///
/// 用于整屏遮挡并展示广告/公告等内容。参数对齐 wot：`modelValue`（是否可见）、
/// `maskClose`（点击遮罩关闭）、`closeIcon`（关闭图标名）、`closeIconSize`、`closeIconColor`、
/// `position`（面板位置）、`onOpen`/`onClose`。
class WotCurtain extends StatefulWidget {
  const WotCurtain({
    super.key,
    this.modelValue = false,
    this.maskClose = true,
    this.closeIcon = 'close',
    this.closeIconSize = 24,
    this.closeIconColor,
    this.position = WotCurtainPosition.center,
    this.onOpen,
    this.onClose,
    this.onModelUpdate,
    this.child,
  });

  final bool modelValue;
  final bool maskClose;
  final String closeIcon;
  final double closeIconSize;
  final Color? closeIconColor;
  final WotCurtainPosition position;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  /// 可见状态变化回调。
  final ValueChanged<bool>? onModelUpdate;

  final Widget? child;

  @override
  State<WotCurtain> createState() => _WotCurtainState();
}

class _WotCurtainState extends State<WotCurtain> {
  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;

    if (!widget.modelValue) return const SizedBox.shrink();

    final panel = widget.child ?? const SizedBox.shrink();

    Alignment align;
    switch (widget.position) {
      case WotCurtainPosition.center:
        align = Alignment.center;
      case WotCurtainPosition.top:
        align = Alignment.topCenter;
      case WotCurtainPosition.bottom:
        align = Alignment.bottomCenter;
      case WotCurtainPosition.left:
        align = Alignment.centerLeft;
      case WotCurtainPosition.right:
        align = Alignment.centerRight;
    }

    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                // 遮罩。
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.maskClose ? _close : null,
                    child: Container(color: scheme.opacMainCover),
                  ),
                ),
                // 面板。
                Align(
                  alignment: align,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        panel,
                        // 关闭按钮。
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Transform.translate(
                            offset: const Offset(18, -18),
                            child: GestureDetector(
                              onTap: _close,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: WotIcon(
                                  name: widget.closeIcon,
                                  size: widget.closeIconSize,
                                  color: widget.closeIconColor ?? Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _close() {
    widget.onModelUpdate?.call(false);
    widget.onClose?.call();
  }
}