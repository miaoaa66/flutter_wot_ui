import 'package:flutter/material.dart';

import '../../locale/wot_messages.dart';
import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 幕布位置。
enum WotCurtainPosition { center, bottom, top, left, right }

/// 关闭按钮位置（D 类 P1）。
enum WotCurtainClosePosition { outside, inside }

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
    this.maskClose = false,
    this.closeIcon = 'close',
    this.closeIconSize = 24,
    this.closeIconColor,
    this.position = WotCurtainPosition.center,
    this.onOpen,
    this.onClose,
    this.onModelUpdate,
    this.src,
    this.width,
    this.height,
    this.closePosition = WotCurtainClosePosition.outside,
    this.child,
  });

  /// 幕布背景图链接（D 类 P1）：传入后面板渲染为该图片（src 图片能力，
  /// 典型广告幕布用法），尺寸由 [width]/[height] 控制，缺省 300×360；
  /// [child] 传入时优先于 [src]。
  final String? src;

  /// [src] 图片宽度，缺省 300。
  final double? width;

  /// [src] 图片高度，缺省 360。
  final double? height;

  /// 关闭按钮位置（D 类 P1）：outside 悬出面板右上角（默认，与历史行为一致，
  /// 布局预留 18px 保证命中可达）；inside 叠在面板内右上角，面板更贴合内容。
  final WotCurtainClosePosition closePosition;

  /// 是否显示幕布（v-model）。
  final bool modelValue;

  /// 是否支持点击遮罩关闭，默认 false（仅 × 可关闭）。
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
      // didUpdateWidget 处于 build 阶段，而 _open 会同步回调 onOpen，
      // 调用方在其中 setState 会撞上「setState() called during build」。故延后一帧。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _open();
      });
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
    // 面板内容（D 类 P1）：src 图片模式优先级低于 child；缺省 300×360。
    final Widget panel;
    if (widget.child != null) {
      panel = widget.child!;
    } else if (widget.src != null && widget.src!.isNotEmpty) {
      panel = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.src!,
          width: widget.width ?? 300,
          height: widget.height ?? 360,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: widget.width ?? 300,
            height: widget.height ?? 360,
            color: scheme.filledStrong,
            alignment: Alignment.center,
            child: WotIcon(name: 'error', size: 24, color: scheme.iconDisabled),
          ),
        ),
      );
    } else {
      panel = const SizedBox.shrink();
    }

    // 关闭按钮位置：outside 悬出（布局预留 18px 保证命中可达，历史行为），
    // inside 叠在面板内右上角、无预留。
    final outside =
        widget.closePosition == WotCurtainClosePosition.outside;

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
          // 面板。外层 6 + 内层 18 = 面板距屏幕边缘 24，与旧实现一致。
          // 关闭按钮悬出面板 18px：Flutter 命中测试不会到达父级边界之外
          // （Clip.none 只影响绘制），故把悬出量做进本 Stack 的尺寸——
          // 内层 Padding 预留 18px，按钮 Positioned 落在边界内，命中可达。
          Align(
            alignment: align,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.all(outside ? 18 : 0),
                    child: panel,
                  ),
                  // 关闭按钮：outside 时中心恰在面板右上角（悬出 18px 的视觉效果不变）。
                  Positioned(
                    top: outside ? 0 : 4,
                    right: outside ? 0 : 4,
                    // 无障碍：关闭是图标按钮，补 button 角色 + 文案（图标本身对读屏不可读）；
                    // 遮罩点击不进语义树（读屏用户走本按钮），符合惯例。
                    child: Semantics(
                      button: true,
                      label: tr(context, 'wot.common.close'),
                      onTap: _close,
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