import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../overlay/wot_overlay.dart';

/// 弹出层定位。
enum WotPopupPosition { center, top, bottom, left, right }

/// 弹出层容器，对应 wot `wd-popup`。
///
/// 提供遮罩 + 平滑弹出动画的容器，作为 dialog/action-sheet 的基础。
/// 受控（[visible]/[onClose]，显隐由父级切换）。
class WotPopup extends StatelessWidget {
  const WotPopup({
    super.key,
    this.visible = false,
    this.onClose,
    this.position = WotPopupPosition.bottom,
    this.round = true,
    this.modal = true,
    this.closeOnClickModal = true,
    this.duration = const Duration(milliseconds: 250),
    this.padding = const EdgeInsets.all(16),
    this.popupStyle,
    this.safeArea = false,
    this.overlayStyle,
    required this.child,
  });

  final bool visible;
  final VoidCallback? onClose;
  final WotPopupPosition position;
  final bool round;
  final bool modal;
  final bool closeOnClickModal;
  final Duration duration;
  final EdgeInsets padding;
  final EdgeInsetsGeometry? popupStyle;
  final bool safeArea;
  final Color? overlayStyle;
  final Widget child;

  Alignment get _alignment => switch (position) {
        WotPopupPosition.center => Alignment.center,
        WotPopupPosition.top => Alignment.topCenter,
        WotPopupPosition.bottom => Alignment.bottomCenter,
        WotPopupPosition.left => Alignment.centerLeft,
        WotPopupPosition.right => Alignment.centerRight,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final child = this.child;

    Widget popup = Material(
      color: scheme.filledOppo,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        left: position == WotPopupPosition.left || position == WotPopupPosition.center,
        right: position == WotPopupPosition.right || position == WotPopupPosition.center,
        top: position == WotPopupPosition.top,
        bottom: position == WotPopupPosition.bottom || position == WotPopupPosition.center,
        minimum: EdgeInsets.zero,
        child: Padding(padding: padding, child: child),
      ),
    );

    // 定位与弹出动画。
    switch (position) {
      case WotPopupPosition.top:
        popup = SlideTransition(
          position: _slide(visible, Alignment.topCenter, offset: const Offset(0, -1)),
          child: popup,
        );
        break;
      case WotPopupPosition.bottom:
        popup = SlideTransition(
          position: _slide(visible, Alignment.bottomCenter, offset: const Offset(0, 1)),
          child: popup,
        );
        break;
      case WotPopupPosition.left:
        popup = SlideTransition(
          position: _slide(visible, Alignment.centerLeft, offset: const Offset(-1, 0)),
          child: popup,
        );
        break;
      case WotPopupPosition.right:
        popup = SlideTransition(
          position: _slide(visible, Alignment.centerRight, offset: const Offset(1, 0)),
          child: popup,
        );
        break;
      case WotPopupPosition.center:
        popup = ScaleTransition(
          scale: _scale(visible),
          child: popup,
        );
        break;
    }

    final panel = Align(alignment: _alignment, child: popup);

    if (!modal) {
      return Stack(
        fit: StackFit.expand,
        children: [panel],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        WotOverlay(
          visible: visible,
          withAnimation: true,
          duration: duration,
          onTap: closeOnClickModal ? onClose : null,
          color: overlayStyle,
        ),
        IgnorePointer(ignoring: !visible, child: panel),
      ],
    );
  }

  Animation<Offset> _slide(bool on, Alignment align, {required Offset offset}) {
    return on
        ? const AlwaysStoppedAnimation(Offset.zero)
        : AlwaysStoppedAnimation(offset);
  }

  Animation<double> _scale(bool on) {
    return on ? const AlwaysStoppedAnimation(1.0) : const AlwaysStoppedAnimation(0.8);
  }
}