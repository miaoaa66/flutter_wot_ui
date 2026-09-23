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

  /// 是否四边全适配系统安全区，默认 false。
  ///
  /// false（默认）时只避让「贴屏幕边」的那一侧：底部弹层避让底部、
  /// 顶部弹层避让顶部、左右弹层避让各自贴边侧 + 上下、居中弹层四边中除顶部外的三边。
  /// true 时四边统一避让。
  final bool safeArea;

  /// 单独控制底边是否适配安全区（wot `safe-area-inset-bottom`）。
  /// 非空时覆盖 [safeArea] 与 position 推导出的底边取值。
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

class _WotPopupState extends State<WotPopup> with SingleTickerProviderStateMixin {
  /// 驱动弹层本体（滑入/缩放）的动画控制器；遮罩动画由 [WotOverlay] 自行管理。
  late AnimationController _controller;

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
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    // 初始即为可见时直接停在终态，避免首帧播放一次入场动画。
    if (_visible) _controller.value = 1.0;
  }

  /// 把回调延后到本帧构建结束后再发出，避免在 build 阶段触发调用方的 setState。
  void _notify(VoidCallback? cb) {
    if (cb == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      cb();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WotPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    final wasOn = oldWidget.show ?? oldWidget.visible;
    final nowOn = _visible;
    // didUpdateWidget 处于 build 阶段，回调必须延后一帧，
    // 否则调用方在回调里 setState 会撞上「setState() called during build」。
    if (!wasOn && nowOn) {
      _controller.forward();
      _notify(widget.onOpen);
      return;
    }
    if (wasOn && !nowOn) {
      _controller.reverse();
      if (_pendingSelfClose) {
        _pendingSelfClose = false;
      } else {
        _notify(widget.onClose);
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

    // 安全区适配：默认只避让「贴屏幕边」的那一侧（由 position 推导）；
    // safeArea: true 时四边全避让；safeAreaInsetBottom 非空时单独覆盖底边。
    final bottomInset = widget.safeAreaInsetBottom ??
        (widget.safeArea ||
            position == WotPopupPosition.bottom ||
            position == WotPopupPosition.center);
    final leftInset = widget.safeArea ||
        position == WotPopupPosition.left ||
        position == WotPopupPosition.center;
    final rightInset = widget.safeArea ||
        position == WotPopupPosition.right ||
        position == WotPopupPosition.center;
    final topInset = widget.safeArea || position == WotPopupPosition.top;

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
        left: leftInset,
        right: rightInset,
        top: topInset,
        bottom: bottomInset,
        minimum: EdgeInsets.zero,
        child: padded,
      ),
    );

    // 定位与弹出动画。
    switch (position) {
      case WotPopupPosition.top:
        popup = SlideTransition(
          position: _slide(const Offset(0, -1)),
          child: popup,
        );
        break;
      case WotPopupPosition.bottom:
        popup = SlideTransition(
          position: _slide(const Offset(0, 1)),
          child: popup,
        );
        break;
      case WotPopupPosition.left:
        popup = SlideTransition(
          position: _slide(const Offset(-1, 0)),
          child: popup,
        );
        break;
      case WotPopupPosition.right:
        popup = SlideTransition(
          position: _slide(const Offset(1, 0)),
          child: popup,
        );
        break;
      case WotPopupPosition.center:
        popup = ScaleTransition(
          scale: _scale(),
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

  /// 由 [offset] 滑入到原位（[WotPopup.duration] 时长，easeOutCubic）。
  Animation<Offset> _slide(Offset offset) {
    return Tween<Offset>(begin: offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  /// 由 0 放大到 1.0（居中弹层的入场动画）。
  /// 起点必须为 0：否则关闭态（controller 停在 0）仍残留 0.8 缩放、内容常驻可见。
  Animation<double> _scale() {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }
}