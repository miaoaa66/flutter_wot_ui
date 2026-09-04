import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../overlay/wot_overlay.dart';

/// 弹出层定位。
enum WotPopupPosition { center, top, bottom, left, right }

/// 弹出层容器，对应 wot `wd-popup`。
///
/// 提供遮罩 + 平滑弹出动画的容器，作为 dialog/action-sheet 的基础。
/// 受控（[visible]/[onClose]，显隐由父级切换）。
class WotPopup extends StatefulWidget {
  const WotPopup({
    super.key,
    this.visible = false,
    this.show,
    this.onClose,
    this.onOpen,
    this.onClickOverlay,
    this.position = WotPopupPosition.bottom,
    this.round = true,
    this.modal = true,
    this.closeOnClickModal = true,
    this.closeOnClickOverlay,
    this.duration = const Duration(milliseconds: 250),
    this.padding = const EdgeInsets.all(16),
    this.popupStyle,
    this.customStyle,
    this.safeArea = false,
    this.safeAreaInsetBottom,
    this.overlayStyle,
    required this.child,
  });

  /// 是否显示弹出层（受控）。未设置 [show] 时生效。
  final bool visible;

  /// 是否展示弹出层（wot `show`，与 [visible] 互为别名；[show] 非空时优先）。
  final bool? show;

  /// 请求关闭回调（点击遮罩且 [closeOnClickOverlay] 时触发，或父级主动关闭时触发）。
  final VoidCallback? onClose;

  /// 弹出层打开时（显隐由关转为开）回调。
  final VoidCallback? onOpen;

  /// 点击遮罩层时回调（无论是否关闭都触发）。
  final VoidCallback? onClickOverlay;

  /// 弹出位置，默认底部。
  final WotPopupPosition position;

  /// 是否开启圆角，开启后按弹出位置自动适配：底部→上圆角、顶部→下圆角、
  /// 左侧→右圆角、右侧→左圆角、居中→四角圆角。
  final bool round;

  /// 是否显示遮罩。
  final bool modal;

  /// 点击遮罩是否请求关闭（wot `close-on-click-modal`）。
  final bool closeOnClickModal;

  /// 点击遮罩是否请求关闭（wot 事件名别名，与 [closeOnClickModal] 互为别名；
  /// [closeOnClickOverlay] 非空时优先）。
  final bool? closeOnClickOverlay;

  /// 打开/关闭动画时长。
  final Duration duration;

  /// 弹出层内容内边距。
  final EdgeInsets padding;

  /// 自定义弹层内边距样式（wot `custom-style` 的 Flutter 映射，作为内容外额外内边距）。
  final EdgeInsetsGeometry? popupStyle;

  /// 自定义弹层样式（wot `custom-style`，与 [popupStyle] 互为别名；
  /// [customStyle] 非空时优先）。
  final EdgeInsetsGeometry? customStyle;

  /// 是否适配系统安全区。
  final bool safeArea;

  /// 底部弹层是否适配底部安全区（wot `safe-area-inset-bottom`，与 [safeArea] 互为别名；
  /// 仅底部弹出时有意义；[safeAreaInsetBottom] 非空时优先）。
  final bool? safeAreaInsetBottom;

  /// 自定义遮罩颜色（优先于遮罩默认的主遮罩色）。
  final Color? overlayStyle;

  /// 弹出层内容。
  final Widget child;

  /// 圆角半径（wot `$radius-large`，约 12px）。
  static const double _radius = 12;

  @override
  State<WotPopup> createState() => _WotPopupState();
}

class _WotPopupState extends State<WotPopup> {
  /// 实际可见性：[show] 优先于 [visible]。
  bool get _visible => widget.show ?? widget.visible;

  /// 实际"点击遮罩关闭"开关：[closeOnClickOverlay] 优先于 [closeOnClickModal]。
  bool get _closeOnClickOverlay =>
      widget.closeOnClickOverlay ?? widget.closeOnClickModal;

  /// 实际弹层自定义内边距：[customStyle] 优先于 [popupStyle]。
  EdgeInsetsGeometry? get _style => widget.customStyle ?? widget.popupStyle;

  /// 因点击遮罩自关闭而触发的 onClose 已由点击处理器触发，避免在
  /// didUpdateWidget 中重复触发。
  bool _pendingSelfClose = false;

  @override
  void didUpdateWidget(covariant WotPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasOn = oldWidget.show ?? oldWidget.visible;
    final nowOn = _visible;
    if (!wasOn && nowOn) {
      widget.onOpen?.call();
      return;
    }
    if (wasOn && !nowOn) {
      if (_pendingSelfClose) {
        _pendingSelfClose = false;
      } else {
        widget.onClose?.call();
      }
    }
  }

  void _handleOverlayTap() {
    widget.onClickOverlay?.call();
    if (_closeOnClickOverlay) {
      _pendingSelfClose = true;
      widget.onClose?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final child = widget.child;
    final position = widget.position;

    final Radius radius = Radius.circular(WotPopup._radius);
    BorderRadius? borderRadius;
    if (widget.round) {
      borderRadius = switch (position) {
        WotPopupPosition.center => BorderRadius.circular(WotPopup._radius),
        WotPopupPosition.top =>
          BorderRadius.vertical(bottom: radius),
        WotPopupPosition.bottom =>
          BorderRadius.vertical(top: radius),
        WotPopupPosition.left =>
          BorderRadius.horizontal(right: radius),
        WotPopupPosition.right =>
          BorderRadius.horizontal(left: radius),
      };
    }

    // 内容内边距 + 自定义弹层样式（作为内容外层的额外内边距）。
    final style = _style;
    Widget padded = child;
    if (widget.padding != EdgeInsets.zero) {
      padded = Padding(padding: widget.padding, child: padded);
    }
    if (style != null) {
      padded = Padding(padding: style, child: padded);
    }

    Widget popup = Material(
      color: scheme.filledOppo,
      elevation: 0,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        left: position == WotPopupPosition.left || position == WotPopupPosition.center,
        right: position == WotPopupPosition.right || position == WotPopupPosition.center,
        top: position == WotPopupPosition.top,
        bottom: position == WotPopupPosition.bottom || position == WotPopupPosition.center,
        minimum: EdgeInsets.zero,
        child: padded,
      ),
    );

    // 定位与弹出动画。
    switch (position) {
      case WotPopupPosition.top:
        popup = SlideTransition(
          position: _slide(_visible, Alignment.topCenter, offset: const Offset(0, -1)),
          child: popup,
        );
        break;
      case WotPopupPosition.bottom:
        popup = SlideTransition(
          position: _slide(_visible, Alignment.bottomCenter, offset: const Offset(0, 1)),
          child: popup,
        );
        break;
      case WotPopupPosition.left:
        popup = SlideTransition(
          position: _slide(_visible, Alignment.centerLeft, offset: const Offset(-1, 0)),
          child: popup,
        );
        break;
      case WotPopupPosition.right:
        popup = SlideTransition(
          position: _slide(_visible, Alignment.centerRight, offset: const Offset(1, 0)),
          child: popup,
        );
        break;
      case WotPopupPosition.center:
        popup = ScaleTransition(
          scale: _scale(_visible),
          child: popup,
        );
        break;
    }

    final panel = Align(alignment: _alignment, child: popup);

    if (!widget.modal) {
      return Stack(
        fit: StackFit.expand,
        children: [panel],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        WotOverlay(
          visible: _visible,
          withAnimation: true,
          duration: widget.duration,
          onTap: _handleOverlayTap,
          color: widget.overlayStyle,
        ),
        IgnorePointer(ignoring: !_visible, child: panel),
      ],
    );
  }

  Alignment get _alignment => switch (widget.position) {
        WotPopupPosition.center => Alignment.center,
        WotPopupPosition.top => Alignment.topCenter,
        WotPopupPosition.bottom => Alignment.bottomCenter,
        WotPopupPosition.left => Alignment.centerLeft,
        WotPopupPosition.right => Alignment.centerRight,
      };

  Animation<Offset> _slide(bool on, Alignment align, {required Offset offset}) {
    return on
        ? const AlwaysStoppedAnimation(Offset.zero)
        : AlwaysStoppedAnimation(offset);
  }

  Animation<double> _scale(bool on) {
    return on ? const AlwaysStoppedAnimation(1.0) : const AlwaysStoppedAnimation(0.8);
  }
}