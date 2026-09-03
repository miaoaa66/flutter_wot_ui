import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';

/// 气泡提示，对应 wot `wd-tooltip`。
///
/// 点击/长按锚点弹出带小箭头的气泡文案。受控（[show]/[onChange] 显隐）。
class WotTooltip extends StatefulWidget {
  const WotTooltip({
    super.key,
    this.content = '',
    this.show = false,
    this.onChange,
    this.placement = WotTooltipPlacement.top,
    this.offset = const Offset(0, 6),
    this.tooltipStyle,
    this.maxWidth = 200,
    this.trigger = 'hover',
    this.disabled = false,
    required this.child,
  });

  final String content;
  final bool show;
  final ValueChanged<bool>? onChange;
  final WotTooltipPlacement placement;
  final Offset offset;
  final Color? tooltipStyle;
  final double maxWidth;
  final String trigger;
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

  bool get _visible => widget.show || (widget.trigger != 'manual' && _show);

  void _open() {
    if (widget.disabled) return;
    setState(() => _show = true);
    widget.onChange?.call(true);
  }

  void _close() {
    setState(() => _show = false);
    widget.onChange?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final isHover = widget.trigger == 'hover';
    final isLongPress = widget.trigger == 'longpress';
    final isClick = widget.trigger == 'click';

    final anchor = MouseRegion(
      onEnter: isHover ? (_) => _open() : null,
      onExit: isHover ? (_) => _close() : null,
      child: GestureDetector(
        key: _key,
        behavior: HitTestBehavior.opaque,
        onTap: isClick ? (_visible ? _close : _open) : null,
        onLongPress: isLongPress ? _open : null,
        child: widget.child,
      ),
    );

    if (!_visible) return anchor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        anchor,
        _bubble(context, scheme),
      ],
    );
  }

  Widget _bubble(BuildContext context, WotScheme scheme) {
    final bg = widget.tooltipStyle ?? scheme.opacTooltipToastCover;
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Container(
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
        ),
      ),
    );
  }
}