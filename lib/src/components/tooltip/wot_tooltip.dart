import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';

/// 气泡提示，对应 wot `wd-tooltip`。
///
/// 点击/悬浮/长按锚点弹出带气泡文案。支持受控显隐（[show]/[visible]）与非受控。
class WotTooltip extends StatefulWidget {
  const WotTooltip({
    super.key,
    this.content = '',
    this.show = false,
    this.visible,
    this.onChange,
    this.onShow,
    this.onHide,
    this.placement = WotTooltipPlacement.top,
    this.offset = Offset.zero,
    this.tooltipStyle,
    this.maxWidth = 200,
    this.trigger = 'hover',
    this.disabled = false,
    required this.child,
  });

  /// 提示文案。
  final String content;

  /// 受控显示（旧名，保留兼容）。
  final bool show;

  /// 受控显示（对齐 wot `model-value`/`visible`）；非空时优先于 [show]。
  final bool? visible;

  /// 显隐状态变化回调（参数为当前的显隐状态）。
  final ValueChanged<bool>? onChange;

  /// 提示层显示时触发回调。
  final VoidCallback? onShow;

  /// 提示层关闭时触发回调。
  final VoidCallback? onHide;

  /// 提示位置。
  final WotTooltipPlacement placement;

  /// 相对锚点的位置偏移量。
  final Offset offset;

  /// 提示层背景色；为空时用主题深色覆盖色。
  final Color? tooltipStyle;

  /// 提示层最大宽度。
  final double maxWidth;

  /// 触发方式：`hover`（悬浮）、`click`（点击）、`auto`（智能，桌面悬浮/移动点击）、`longpress`、`manual`。
  final String trigger;

  /// 是否禁用，禁用后不会显示提示层。
  final bool disabled;

  final Widget child;

  @override
  State<WotTooltip> createState() => _WotTooltipState();
}

enum WotTooltipPlacement {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
}

class _WotTooltipState extends State<WotTooltip> {
  bool _show = false;
  final _key = GlobalKey();
  OverlayEntry? _entry;

  bool get _hasVisible => widget.visible ?? widget.show;

  bool get _handleVisible => _hasVisible || (widget.trigger != 'manual' && _show);

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
    if (widget.disabled) return;
    if (_handleVisible) return;
    setState(() => _show = true);
    _ensureOverlay();
    final shown = _handleVisible;
    widget.onChange?.call(shown);
    if (shown) widget.onShow?.call();
  }

  void _close() {
    if (!_handleVisible) return;
    setState(() => _show = false);
    _removeOverlay();
    widget.onChange?.call(false);
    widget.onHide?.call();
  }

  void _toggle() => _handleVisible ? _close() : _open();

  @override
  void didUpdateWidget(covariant WotTooltip old) {
    super.didUpdateWidget(old);
    // 受控 external 变化（show/visible）与内部状态同步到 Overlay。
    if (old.visible != widget.visible || old.show != widget.show) {
      if (_handleVisible) {
        _ensureOverlay();
        if (!_show) setState(() => _show = true);
        widget.onShow?.call();
      } else if (_entry != null) {
        _removeOverlay();
        if (_show) setState(() => _show = false);
        widget.onHide?.call();
      }
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHover = widget.trigger == 'hover';
    final isAuto = widget.trigger == 'auto';
    final isLongPress = widget.trigger == 'longpress';
    final isClick = widget.trigger == 'click';

    final anchor = MouseRegion(
      onEnter: isHover || isAuto ? (_) => _open() : null,
      onExit: isHover || isAuto ? (_) => _close() : null,
      child: GestureDetector(
        key: _key,
        behavior: HitTestBehavior.opaque,
        onTap: isClick ? () => _toggle() : null,
        onLongPress: isLongPress ? () => _open() : null,
        child: widget.child,
      ),
    );

    // 有默认显示/已显示时，确保 Overlay 中渲染气泡。
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
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return Rect.zero;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Widget _buildOverlay() {
    final scheme = context.wotScheme;
    return Stack(
      children: [
        // 点击其它区域关闭（非 hover/manual 触发时）。
        if (widget.trigger == 'click' || widget.trigger == 'auto')
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _close(),
            ),
          ),
        CustomSingleChildLayout(
          delegate: _TooltipPosDelegate(_anchorRect(), widget.placement, widget.offset),
          child: IgnorePointer(child: _bubble(scheme)),
        ),
      ],
    );
  }

  Widget _bubble(WotScheme scheme) {
    final bg = widget.tooltipStyle ?? scheme.opacTooltipToastCover;
    return Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.content,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

/// 计算气泡相对锚点的定位（主轴向空间不足时自动翻转）。
class _TooltipPosDelegate extends SingleChildLayoutDelegate {
  _TooltipPosDelegate(this.anchor, this.placement, this.offset);

  final Rect anchor;
  final WotTooltipPlacement placement;
  final Offset offset;

  @override
  bool shouldRelayout(_TooltipPosDelegate old) =>
      old.anchor != anchor ||
      old.placement != placement ||
      old.offset != offset;

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  Offset getPositionForChild(Size size, Size child) {
    const gap = 6.0;
    double left, top;
    switch (placement) {
      case WotTooltipPlacement.top:
        top = anchor.top - child.height - gap;
        if (top < 0) top = anchor.bottom + gap;
        left = anchor.left + (anchor.width - child.width) / 2;
      case WotTooltipPlacement.topLeft:
        top = anchor.top - child.height - gap;
        if (top < 0) top = anchor.bottom + gap;
        left = anchor.left;
      case WotTooltipPlacement.topRight:
        top = anchor.top - child.height - gap;
        if (top < 0) top = anchor.bottom + gap;
        left = anchor.right - child.width;
      case WotTooltipPlacement.bottom:
        top = anchor.bottom + gap;
        if (top + child.height > size.height) top = anchor.top - child.height - gap;
        left = anchor.left + (anchor.width - child.width) / 2;
      case WotTooltipPlacement.left:
        left = anchor.left - child.width - gap;
        if (left < 0) left = anchor.right + gap;
        top = anchor.top + (anchor.height - child.height) / 2;
      case WotTooltipPlacement.right:
        left = anchor.right + gap;
        if (left + child.width > size.width) left = anchor.left - child.width - gap;
        top = anchor.top + (anchor.height - child.height) / 2;
    }
    left += offset.dx;
    top += offset.dy;
    final maxL = (size.width - child.width - 4).clamp(0.0, double.infinity);
    final maxT = (size.height - child.height - 4).clamp(0.0, double.infinity);
    left = left.clamp(0.0, maxL);
    top = top.clamp(0.0, maxT);
    return Offset(left, top);
  }
}