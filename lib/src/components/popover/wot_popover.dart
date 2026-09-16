import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';

/// 气泡弹出层（锚点触发），对应 wot `wd-popover`。
///
/// 点击/悬浮/受控显隐时在锚点附近弹出内容（自动翻转方向），支持点击遮罩关闭。
class WotPopover extends StatefulWidget {
  const WotPopover({
    super.key,
    this.modelValue = false,
    this.visible,
    this.onChange,
    this.onOpen,
    this.onClose,
    this.placement = WotPopoverPlacement.bottom,
    this.showArrow = true,
    this.trigger = 'click',
    this.content = const [],
    this.width = 120,
    this.mask = false,
    this.closeOnClickOverlay = true,
    this.onSelect,
    required this.child,
    this.onClick,
  });

  /// 受控显示（旧名，保留兼容）。
  final bool modelValue;

  /// 受控显示（对齐 wot `visible`）；非空时优先于 [modelValue]。
  final bool? visible;

  /// 显隐状态变化回调。
  final ValueChanged<bool>? onChange;

  /// 气泡显示时触发回调。
  final VoidCallback? onOpen;

  /// 气泡隐藏时触发回调。
  final VoidCallback? onClose;

  /// 弹出位置。
  final WotPopoverPlacement placement;

  /// 是否显示小箭头（保留参数，暂未绘制箭头形状）。
  final bool showArrow;

  /// 触发方式：`click`（点击）、`hover`（悬浮）、`manual`（仅受控）。
  final String trigger;

  /// 内容列表（通常是菜单项）。
  final List<Widget> content;

  /// 气泡宽度。
  final double width;

  /// 是否显示半透明遮罩（默认 false，遮罩透明仅用于拦截点击关闭）。
  final bool mask;

  /// 点击遮罩/其它区域时是否关闭，默认 true。
  final bool closeOnClickOverlay;

  /// 点击内容项时回调（含下标 index）。
  final ValueChanged<int>? onSelect;

  final Widget child;

  /// 点击内容项时回调（旧名，保留兼容）。
  final ValueChanged<int>? onClick;

  @override
  State<WotPopover> createState() => _WotPopoverState();
}

enum WotPopoverPlacement {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _WotPopoverState extends State<WotPopover> {
  bool _show = false;
  final _anchorKey = GlobalKey();
  OverlayEntry? _entry;

  bool get _handleVisible => widget.visible ?? widget.modelValue || _show;

  void _ensureOverlay() {
    if (_entry != null) return;
    _entry = OverlayEntry(builder: (_) => _buildOverlay());
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  void _open() {
    if (_handleVisible) return;
    setState(() => _show = true);
    _ensureOverlay();
    widget.onChange?.call(true);
    widget.onOpen?.call();
  }

  void _close() {
    if (!_handleVisible) return;
    setState(() => _show = false);
    _removeOverlay();
    widget.onChange?.call(false);
    widget.onClose?.call();
  }

  void _toggle() => _handleVisible ? _close() : _open();

  void _onSelect(int i) {
    widget.onSelect?.call(i);
    widget.onClick?.call(i);
    _close();
  }

  @override
  void didUpdateWidget(covariant WotPopover old) {
    super.didUpdateWidget(old);
    if (old.visible != widget.visible || old.modelValue != widget.modelValue) {
      final opening = _handleVisible;
      if (!opening && _entry == null) return;
      // didUpdateWidget 处于 build 阶段：OverlayEntry 的 insert/remove 会让 Overlay
      // 这个祖先节点 markNeedsBuild，回调里调用方也可能 setState，
      // 两者都会撞上「setState() called during build」，故整体延后一帧。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (opening) {
          _ensureOverlay();
          if (!_show) setState(() => _show = true);
          widget.onOpen?.call();
        } else if (_entry != null) {
          _removeOverlay();
          if (_show) setState(() => _show = false);
          widget.onClose?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isClick = widget.trigger == 'click';
    final isHover = widget.trigger == 'hover';

    final anchor = MouseRegion(
      onEnter: isHover ? (_) => _open() : null,
      onExit: isHover ? (_) => _close() : null,
      child: GestureDetector(
        key: _anchorKey,
        behavior: HitTestBehavior.opaque,
        onTap: isClick ? () => _toggle() : null,
        child: widget.child,
      ),
    );

    if (_handleVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _handleVisible) _ensureOverlay();
      });
    } else if (_entry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_handleVisible) _removeOverlay();
      });
    }

    return anchor;
  }

  Rect _anchorRect() {
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return Rect.zero;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Widget _buildOverlay() {
    final scheme = context.wotScheme;
    return Stack(
      children: [
        // 遮罩：拦截点击用于关闭。
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.closeOnClickOverlay ? () => _close() : null,
            child: ColoredBox(
              color: widget.mask ? scheme.opacMainCover : Colors.transparent,
            ),
          ),
        ),
        CustomSingleChildLayout(
          delegate: _PopoverPosDelegate(_anchorRect(), widget.placement),
          child: _bubble(scheme),
        ),
      ],
    );
  }

  /// 气泡 + 箭头（[WotPopover.showArrow] 为 false 时只有气泡）。
  ///
  /// 箭头朝向由 [WotPopover.placement] 推导。**已知限制**：当空间不足触发
  /// [_PopoverPosDelegate] 自动翻转时，箭头方向不会跟着翻转。
  Widget _bubble(WotScheme scheme) {
    if (!widget.showArrow) return _popup(scheme);
    final side = _arrowSideFor(widget.placement);
    final arrow = CustomPaint(
      size: side == _ArrowSide.top || side == _ArrowSide.bottom
          ? const Size(12, 6)
          : const Size(6, 12),
      painter: _ArrowPainter(color: scheme.filledOppo, side: side),
    );
    switch (side) {
      case _ArrowSide.top:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [arrow, _popup(scheme)],
        );
      case _ArrowSide.bottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_popup(scheme), arrow],
        );
      case _ArrowSide.left:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [arrow, Flexible(child: _popup(scheme))],
        );
      case _ArrowSide.right:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Flexible(child: _popup(scheme)), arrow],
        );
    }
  }

  Widget _popup(WotScheme scheme) {
    final labels = widget.content;
    return Material(
      color: scheme.filledOppo,
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: widget.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < labels.length; i++)
              InkWell(
                onTap: () => _onSelect(i),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(fontSize: 14, color: scheme.textMain),
                    child: labels[i],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 箭头所在的一侧（相对气泡本体）。
enum _ArrowSide { top, bottom, left, right }

/// 由 [WotPopoverPlacement] 推导箭头方位：气泡在锚点上方时箭头朝下，依此类推。
_ArrowSide _arrowSideFor(WotPopoverPlacement p) => switch (p) {
      WotPopoverPlacement.top ||
      WotPopoverPlacement.topLeft ||
      WotPopoverPlacement.topRight =>
        _ArrowSide.bottom,
      WotPopoverPlacement.bottom ||
      WotPopoverPlacement.bottomLeft ||
      WotPopoverPlacement.bottomRight =>
        _ArrowSide.top,
      WotPopoverPlacement.left => _ArrowSide.right,
      WotPopoverPlacement.right => _ArrowSide.left,
    };

/// 气泡箭头（纯三角形）。
class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.color, required this.side});

  final Color color;
  final _ArrowSide side;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    switch (side) {
      case _ArrowSide.bottom:
        path
          ..moveTo(0, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width / 2, size.height);
      case _ArrowSide.top:
        path
          ..moveTo(0, size.height)
          ..lineTo(size.width, size.height)
          ..lineTo(size.width / 2, 0);
      case _ArrowSide.right:
        path
          ..moveTo(0, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, size.height / 2);
      case _ArrowSide.left:
        path
          ..moveTo(size.width, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height / 2);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) =>
      old.color != color || old.side != side;
}

/// 计算气泡相对锚点的定位（主轴向空间不足时自动翻转）。
class _PopoverPosDelegate extends SingleChildLayoutDelegate {
  _PopoverPosDelegate(this.anchor, this.placement);

  final Rect anchor;
  final WotPopoverPlacement placement;

  @override
  bool shouldRelayout(_PopoverPosDelegate old) =>
      old.anchor != anchor || old.placement != placement;

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  Offset getPositionForChild(Size size, Size child) {
    const gap = 4.0;
    double left, top;
    switch (placement) {
      case WotPopoverPlacement.top:
        top = anchor.top - child.height - gap;
        if (top < 0) top = anchor.bottom + gap;
        left = anchor.left + (anchor.width - child.width) / 2;
      case WotPopoverPlacement.topLeft:
        top = anchor.top - child.height - gap;
        if (top < 0) top = anchor.bottom + gap;
        left = anchor.left;
      case WotPopoverPlacement.topRight:
        top = anchor.top - child.height - gap;
        if (top < 0) top = anchor.bottom + gap;
        left = anchor.right - child.width;
      case WotPopoverPlacement.bottom:
        top = anchor.bottom + gap;
        if (top + child.height > size.height) top = anchor.top - child.height - gap;
        left = anchor.left + (anchor.width - child.width) / 2;
      case WotPopoverPlacement.bottomLeft:
        top = anchor.bottom + gap;
        if (top + child.height > size.height) top = anchor.top - child.height - gap;
        left = anchor.left;
      case WotPopoverPlacement.bottomRight:
        top = anchor.bottom + gap;
        if (top + child.height > size.height) top = anchor.top - child.height - gap;
        left = anchor.right - child.width;
      case WotPopoverPlacement.left:
        left = anchor.left - child.width - gap;
        if (left < 0) left = anchor.right + gap;
        top = anchor.top + (anchor.height - child.height) / 2;
      case WotPopoverPlacement.right:
        left = anchor.right + gap;
        if (left + child.width > size.width) left = anchor.left - child.width - gap;
        top = anchor.top + (anchor.height - child.height) / 2;
    }
    final maxL = (size.width - child.width - 4).clamp(0.0, double.infinity);
    final maxT = (size.height - child.height - 4).clamp(0.0, double.infinity);
    left = left.clamp(0.0, maxL);
    top = top.clamp(0.0, maxT);
    return Offset(left, top);
  }
}