import 'dart:async';

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
    this.flip = true,
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

  /// 是否显示小箭头。箭头方位由生效后的 [placement]（含自动翻转）推导，
  /// 气泡与箭头由 [_BubblePainter] 一次性绘制为同一块面（连续边框 + 阴影，无接缝）。
  /// 气泡因空间不足翻转后，箭头方向会同步翻转并始终指向锚点。
  final bool showArrow;

  /// 空间不足时是否自动翻转到反向（默认 true）。
  /// 演示「真实方位」时可临时关闭，气泡会严格落在 [placement] 指定侧。
  final bool flip;

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
  Timer? _hoverTimer;
  bool _hoverAnchor = false;
  bool _hoverBubble = false;

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
    _hoverTimer?.cancel();
    if (_handleVisible) return;
    setState(() => _show = true);
    _ensureOverlay();
    widget.onChange?.call(true);
    widget.onOpen?.call();
  }

  void _close() {
    _hoverTimer?.cancel();
    _hoverAnchor = false;
    _hoverBubble = false;
    if (!_handleVisible) return;
    setState(() => _show = false);
    _removeOverlay();
    widget.onChange?.call(false);
    widget.onClose?.call();
  }

  void _toggle() => _handleVisible ? _close() : _open();

  /// 悬浮触发时延迟关闭，给「从锚点移到气泡」留过渡时间。
  /// 只有当鼠标既不在锚点、也不在气泡内时才真正关闭——从根本上避免抽搐闪烁。
  void _scheduleClose() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(_kHoverCloseDelay, () {
      if (mounted && !_hoverAnchor && !_hoverBubble) _close();
    });
  }

  /// 鼠标进入锚点或气泡时取消待关闭计时。
  void _cancelHover() => _hoverTimer?.cancel();

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
    _hoverTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isClick = widget.trigger == 'click';
    final isHover = widget.trigger == 'hover';

    final anchor = MouseRegion(
      onEnter: isHover
          ? (_) {
              _hoverAnchor = true;
              _open();
            }
          : null,
      onExit: isHover
          ? (_) {
              _hoverAnchor = false;
              _scheduleClose();
            }
          : null,
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
    final isHover = widget.trigger == 'hover';
    final anchor = _anchorRect();
    final screen = MediaQuery.of(context).size;
    final effective =
        widget.flip ? _resolvePlacement(widget.placement, anchor, screen) : widget.placement;
    final mask = ColoredBox(
      color: widget.mask ? scheme.opacMainCover : Colors.transparent,
    );
    return Stack(
      children: [
        // 遮罩：点击/受控模式拦截点击用于关闭；**悬浮模式彻底不参与命中测试**
        // （IgnorePointer），否则遮罩会盖住锚点、导致锚点 onExit → 关闭 → 重入 →
        // 打开 的无限循环（即「悬浮一直闪烁」）。悬浮关闭靠鼠标移出锚点/气泡。
        Positioned.fill(
          child: isHover
              ? IgnorePointer(child: mask)
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.closeOnClickOverlay ? () => _close() : null,
                  child: mask,
                ),
        ),
        CustomSingleChildLayout(
          delegate: _PopoverPosDelegate(anchor, effective),
          child: _bubble(scheme, effective),
        ),
      ],
    );
  }

  /// 根据可用空间推导气泡最终生效的 [WotPopoverPlacement]（空间不足时自动翻转）。
  ///
  /// 翻转决策用气泡尺寸的估算值（与 [_PopoverPosDelegate] 内部真实测量值基本一致），
  /// 把结果同时交给定位与箭头，保证「落点」与「箭头朝向」一致——
  /// 修复此前「气泡翻转后箭头仍指向旧方向、看起来和 placement 对不上」的问题。
  WotPopoverPlacement _resolvePlacement(
      WotPopoverPlacement p, Rect a, Size s) {
    const gap = 4.0;
    final horizontal =
        p == WotPopoverPlacement.left || p == WotPopoverPlacement.right;
    final bw = widget.width + (horizontal ? 6 : 0);
    final bh =
        widget.content.length * 40.0 + (widget.showArrow && !horizontal ? 6 : 0);
    switch (p) {
      case WotPopoverPlacement.top:
      case WotPopoverPlacement.topLeft:
      case WotPopoverPlacement.topRight:
        return a.top - bh - gap < 0 ? _flipVertical(p) : p;
      case WotPopoverPlacement.bottom:
      case WotPopoverPlacement.bottomLeft:
      case WotPopoverPlacement.bottomRight:
        return a.top + a.height + gap + bh > s.height ? _flipVertical(p) : p;
      case WotPopoverPlacement.left:
        return a.left - bw - gap < 0 ? WotPopoverPlacement.right : p;
      case WotPopoverPlacement.right:
        return a.right + gap + bw > s.width ? WotPopoverPlacement.left : p;
    }
  }

  WotPopoverPlacement _flipVertical(WotPopoverPlacement p) => switch (p) {
        WotPopoverPlacement.top => WotPopoverPlacement.bottom,
        WotPopoverPlacement.topLeft => WotPopoverPlacement.bottomLeft,
        WotPopoverPlacement.topRight => WotPopoverPlacement.bottomRight,
        WotPopoverPlacement.bottom => WotPopoverPlacement.top,
        WotPopoverPlacement.bottomLeft => WotPopoverPlacement.topLeft,
        WotPopoverPlacement.bottomRight => WotPopoverPlacement.topRight,
        WotPopoverPlacement.left || WotPopoverPlacement.right => p,
      };

  /// 气泡 + 箭头（[WotPopover.showArrow] 为 false 时只有气泡）。
  ///
  /// 箭头朝向由 [effectivePlacement]（已含自动翻转后的生效方位）推导，
  /// 因此气泡翻转后箭头也会跟着翻，始终指向锚点。气泡与箭头由 [_BubblePainter]
  /// 一次性绘制为同一块面（连续边框 + 阴影，无接缝）。
  Widget _bubble(WotScheme scheme, [WotPopoverPlacement? effectivePlacement]) {
    final placement = effectivePlacement ?? widget.placement;
    final isHover = widget.trigger == 'hover';
    final showArrow = widget.showArrow;
    final side = showArrow ? _arrowSideFor(placement) : null;
    final align = showArrow ? _arrowAlignFor(placement) : _ArrowAlign.center;
    final bw = widget.width;
    final bh = widget.content.isEmpty ? _kItemH : widget.content.length * _kItemH;
    final ah = showArrow ? _kArrowH : 0.0;
    final aw = showArrow ? _kArrowW : 0.0;

    final Size total;
    final Offset contentOffset;
    if (side == null) {
      total = Size(bw, bh);
      contentOffset = Offset.zero;
    } else if (side == _ArrowSide.top || side == _ArrowSide.bottom) {
      total = Size(bw, bh + ah);
      contentOffset = side == _ArrowSide.top ? Offset(0, ah) : Offset.zero;
    } else {
      total = Size(bw + ah, bh);
      contentOffset = side == _ArrowSide.left ? Offset(ah, 0) : Offset.zero;
    }

    final bubble = SizedBox(
      width: total.width,
      height: total.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: total,
            painter: _BubblePainter(
              color: scheme.filledOppo,
              borderColor: scheme.borderMain,
              borderWidth: 1,
              radius: _kRadius,
              shadowColor: const Color(0x1A000000),
              elevation: 6,
              bw: bw,
              bh: bh,
              aw: aw,
              ah: ah,
              side: side,
              align: align,
            ),
          ),
          Positioned(
            left: contentOffset.dx,
            top: contentOffset.dy,
            child: _popup(scheme, bw, bh),
          ),
        ],
      ),
    );

    if (!isHover) return bubble;
    // 悬浮触发时，鼠标移入气泡也要保活（否则移到气泡即关闭）。
    return MouseRegion(
      onEnter: (_) {
        _hoverBubble = true;
        _cancelHover();
      },
      onExit: (_) {
        _hoverBubble = false;
        _scheduleClose();
      },
      child: bubble,
    );
  }

  Widget _popup(WotScheme scheme, double bw, double bh) {
    final labels = widget.content;
    return ClipRRect(
      borderRadius: BorderRadius.circular(_kRadius),
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: bw,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < labels.length; i++)
                InkWell(
                  onTap: () => _onSelect(i),
                  child: SizedBox(
                    width: double.infinity,
                    height: _kItemH,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(fontSize: 14, color: scheme.textMain),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: labels[i],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
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

/// 箭头在被指向边上的对齐方式（相对气泡）。
enum _ArrowAlign { start, center, end }

/// 由 [WotPopoverPlacement] 推导箭头在被指向边上的对齐：
/// topLeft/bottomLeft 贴左，topRight/bottomRight 贴右，其余居中。
_ArrowAlign _arrowAlignFor(WotPopoverPlacement p) => switch (p) {
      WotPopoverPlacement.topLeft || WotPopoverPlacement.bottomLeft => _ArrowAlign.start,
      WotPopoverPlacement.topRight || WotPopoverPlacement.bottomRight => _ArrowAlign.end,
      _ => _ArrowAlign.center,
    };

const double _kArrowW = 12;
const double _kArrowH = 6;
const double _kRadius = 8;
const double _kItemH = 40;
const Duration _kHoverCloseDelay = Duration(milliseconds: 120);

/// 气泡外形（圆角矩形 + 朝向锚点的三角箭头，单一连续路径）。
///
/// 一次性绘制「填充 + 阴影 + 边框」，气泡与箭头因此是同一块面：无接缝发丝线、
/// 阴影与边框连续（修复此前箭头是独立层、与气泡间有发丝线/双重阴影、
/// 且箭头不带边框的问题）。箭头底边落在气泡矩形边上、不进入描边，故无接缝线。
class _BubblePainter extends CustomPainter {
  const _BubblePainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.radius,
    required this.shadowColor,
    required this.elevation,
    required this.bw,
    required this.bh,
    required this.aw,
    required this.ah,
    this.side,
    this.align = _ArrowAlign.center,
  });

  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final Color shadowColor;
  final double elevation;
  final double bw;
  final double bh;
  final double aw;
  final double ah;
  final _ArrowSide? side;
  final _ArrowAlign align;

  double _arrowOffset(double edge) => switch (align) {
        _ArrowAlign.start => 16,
        _ArrowAlign.end => edge - aw - 16,
        _ArrowAlign.center => (edge - aw) / 2,
      };

  Path _buildPath() {
    final r = radius;
    final path = Path();
    if (side == null) {
      path.addRRect(RRect.fromRectXY(Rect.fromLTWH(0, 0, bw, bh), r, r));
      return path;
    }
    switch (side!) {
      case _ArrowSide.bottom:
        final ao = _arrowOffset(bw);
        path
          ..moveTo(r, 0)
          ..lineTo(bw - r, 0)
          ..quadraticBezierTo(bw, 0, bw, r)
          ..lineTo(bw, bh - r)
          ..quadraticBezierTo(bw, bh, bw - r, bh)
          ..lineTo(ao + aw, bh)
          ..lineTo(ao + aw / 2, bh + ah)
          ..lineTo(ao, bh)
          ..lineTo(r, bh)
          ..quadraticBezierTo(0, bh, 0, bh - r)
          ..lineTo(0, r)
          ..quadraticBezierTo(0, 0, r, 0)
          ..close();
      case _ArrowSide.top:
        final ao = _arrowOffset(bw);
        path
          ..moveTo(r, ah)
          ..lineTo(ao, ah)
          ..lineTo(ao + aw / 2, 0)
          ..lineTo(ao + aw, ah)
          ..lineTo(bw - r, ah)
          ..quadraticBezierTo(bw, ah, bw, ah + r)
          ..lineTo(bw, ah + bh - r)
          ..quadraticBezierTo(bw, ah + bh, bw - r, ah + bh)
          ..lineTo(r, ah + bh)
          ..quadraticBezierTo(0, ah + bh, 0, ah + bh - r)
          ..lineTo(0, ah + r)
          ..quadraticBezierTo(0, ah, r, ah)
          ..close();
      case _ArrowSide.right:
        final ao = _arrowOffset(bh);
        path
          ..moveTo(r, 0)
          ..lineTo(bw - r, 0)
          ..quadraticBezierTo(bw, 0, bw, r)
          ..lineTo(bw, ao + aw)
          ..lineTo(bw + ah, ao + aw / 2)
          ..lineTo(bw, ao)
          ..lineTo(bw, bh - r)
          ..quadraticBezierTo(bw, bh, bw - r, bh)
          ..lineTo(r, bh)
          ..quadraticBezierTo(0, bh, 0, bh - r)
          ..lineTo(0, r)
          ..quadraticBezierTo(0, 0, r, 0)
          ..close();
      case _ArrowSide.left:
        final ao = _arrowOffset(bh);
        path
          ..moveTo(ah + r, 0)
          ..lineTo(ah + bw - r, 0)
          ..quadraticBezierTo(ah + bw, 0, ah + bw, r)
          ..lineTo(ah + bw, bh - r)
          ..quadraticBezierTo(ah + bw, bh, ah + bw - r, bh)
          ..lineTo(ah + r, bh)
          ..quadraticBezierTo(ah, bh, ah, bh - r)
          ..lineTo(ah, ao + aw)
          ..lineTo(0, ao + aw / 2)
          ..lineTo(ah, ao)
          ..lineTo(ah, r)
          ..quadraticBezierTo(ah, 0, ah + r, 0)
          ..close();
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath();
    canvas.drawShadow(path, shadowColor, elevation, false);
    canvas.drawPath(path, Paint()..color = color);
    if (borderWidth > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) =>
      old.color != color ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth ||
      old.radius != radius ||
      old.shadowColor != shadowColor ||
      old.elevation != elevation ||
      old.bw != bw ||
      old.bh != bh ||
      old.aw != aw ||
      old.ah != ah ||
      old.side != side ||
      old.align != align;
}

/// 按（已含自动翻转的）生效 [placement] 计算气泡相对锚点的定位，并 clamp 进可视区域。
/// 翻转决策统一在 [_resolvePlacement] 中完成，避免定位与箭头各算各的导致不一致。
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
        left = anchor.left + (anchor.width - child.width) / 2;
      case WotPopoverPlacement.topLeft:
        top = anchor.top - child.height - gap;
        left = anchor.left;
      case WotPopoverPlacement.topRight:
        top = anchor.top - child.height - gap;
        left = anchor.right - child.width;
      case WotPopoverPlacement.bottom:
        top = anchor.bottom + gap;
        left = anchor.left + (anchor.width - child.width) / 2;
      case WotPopoverPlacement.bottomLeft:
        top = anchor.bottom + gap;
        left = anchor.left;
      case WotPopoverPlacement.bottomRight:
        top = anchor.bottom + gap;
        left = anchor.right - child.width;
      case WotPopoverPlacement.left:
        left = anchor.left - child.width - gap;
        top = anchor.top + (anchor.height - child.height) / 2;
      case WotPopoverPlacement.right:
        left = anchor.right + gap;
        top = anchor.top + (anchor.height - child.height) / 2;
    }
    final maxL = (size.width - child.width - 4).clamp(0.0, double.infinity);
    final maxT = (size.height - child.height - 4).clamp(0.0, double.infinity);
    left = left.clamp(0.0, maxL);
    top = top.clamp(0.0, maxT);
    return Offset(left, top);
  }
}