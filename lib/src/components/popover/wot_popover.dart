import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 气泡弹出层（锚点触发），对应 wot `wd-popover`。
///
/// 简化实现：点击/受控显隐时在锚点下方弹出选项列表。
class WotPopover extends StatefulWidget {
  const WotPopover({
    super.key,
    this.modelValue = false,
    this.onChange,
    this.placement = WotPopoverPlacement.bottom,
    this.showArrow = true,
    this.trigger = 'click',
    this.content = const [],
    this.width = 120,
    required this.child,
    this.onClick,
  });

  final bool modelValue;
  final ValueChanged<bool>? onChange;
  final WotPopoverPlacement placement;
  final bool showArrow;
  final String trigger;
  final List<Widget> content;
  final double width;
  final Widget child;
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

  bool get _visible => widget.modelValue || _show;

  void _toggle() {
    setState(() => _show = !_show);
    widget.onChange?.call(!_show);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final anchor = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: widget.child,
    );

    final labels = widget.content;

    Widget? pop;
    if (_visible && labels.isNotEmpty) {
      pop = Material(
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
                  onTap: () {
                    widget.onClick?.call(i);
                    setState(() => _show = false);
                    widget.onChange?.call(false);
                  },
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        anchor,
        if (pop != null) Padding(padding: const EdgeInsets.only(top: 4), child: pop),
      ],
    );
  }
}