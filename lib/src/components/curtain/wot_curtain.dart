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
///
/// 实现：通过 [showGeneralDialog] 挂到**根 Navigator/Overlay**（天然全屏），
/// 避免就地嵌套 `Overlay` 在无界约束（如 ListView）下无法定尺寸。
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

  /// 是否显示幕布（v-model）。
  final bool modelValue;

  /// 是否支持点击遮罩关闭，默认 true。
  final bool maskClose;

  /// 关闭按钮图标名，默认 `close`。
  final String closeIcon;

  /// 关闭按钮图标尺寸，默认 24。
  final double closeIconSize;

  /// 关闭按钮图标颜色，缺省为白色。
  final Color? closeIconColor;

  /// 面板展示位置，可选 `center`/`bottom`/`top`/`left`/`right`，默认 `center`。
  final WotCurtainPosition position;

  /// 幕布打开时触发的回调。
  final VoidCallback? onOpen;

  /// 幕布关闭时触发的回调。
  final VoidCallback? onClose;

  /// 可见状态变化回调。
  final ValueChanged<bool>? onModelUpdate;

  /// 幕布内容。
  final Widget? child;

  @override
  State<WotCurtain> createState() => _WotCurtainState();
}

class _WotCurtainState extends State<WotCurtain> {
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    if (widget.modelValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _open();
      });
    }
  }

  // 幕布经全屏 Dialog 展示，组件自身仅作占位。
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  void didUpdateWidget(WotCurtain oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.modelValue && !_opened) {
      _open();
    } else if (!widget.modelValue && _opened) {
      _opened = false;
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  void _open() {
    if (_opened) return;
    _opened = true;
    widget.onOpen?.call();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: widget.maskClose,
        barrierColor: Colors.transparent,
        barrierLabel: 'curtain',
        transitionDuration: const Duration(milliseconds: 200),
        transitionBuilder: (context, animation, _, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        pageBuilder: (ctx, _, _) => _buildCurtain(ctx),
      ).whenComplete(() {
        _opened = false;
        if (mounted) {
          widget.onModelUpdate?.call(false);
          widget.onClose?.call();
        }
      });
    });
  }

  Widget _buildCurtain(BuildContext context) {
    final scheme = context.wotScheme;
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

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 遮罩。
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.maskClose ? _close : null,
            child: Container(color: scheme.opacMainCover),
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
    );
  }

  void _close() {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop();
  }
}