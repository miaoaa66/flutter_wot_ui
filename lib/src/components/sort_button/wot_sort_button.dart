import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 排序方向。
enum WotSortDirection {
  none,
  ascending,
  descending,
}

/// 排序按钮，对应 wot `wd-sort-button`。
class WotSortButton extends StatefulWidget {
  const WotSortButton({
    super.key,
    this.modelValue = WotSortDirection.none,
    this.onChange,
    this.text = '排序',
    this.color,
    this.activeColor,
    this.disabled = false,
  });

  final WotSortDirection modelValue;
  final ValueChanged<WotSortDirection>? onChange;
  final String text;
  final Color? color;
  final Color? activeColor;
  final bool disabled;

  @override
  State<WotSortButton> createState() => _WotSortButtonState();
}

class _WotSortButtonState extends State<WotSortButton> {
  late WotSortDirection _dir;

  @override
  void initState() {
    super.initState();
    _dir = widget.modelValue;
  }

  @override
  void didUpdateWidget(WotSortButton old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) _dir = widget.modelValue;
  }

  void _tap() {
    if (widget.disabled) return;
    final next = switch (_dir) {
      WotSortDirection.none => WotSortDirection.ascending,
      WotSortDirection.ascending => WotSortDirection.descending,
      WotSortDirection.descending => WotSortDirection.none,
    };
    setState(() => _dir = next);
    widget.onChange?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final active = _dir != WotSortDirection.none;
    final fg = active ? (widget.activeColor ?? scheme.primaryOf(6)) : (widget.color ?? scheme.textMain);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.disabled ? null : _tap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.text,
              style: TextStyle(fontSize: 14, color: widget.disabled ? scheme.textDisabled : fg)),
          const SizedBox(width: 4),
          // 上下箭头：用 Stack 紧凑叠放，避免固定高内 Column(flex) 溢出。
          SizedBox(
            width: 10,
            height: 14,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Icon(Icons.arrow_drop_up,
                      size: 12,
                      color: _dir == WotSortDirection.ascending
                          ? fg
                          : (active ? fg.withValues(alpha: 0.4) : scheme.iconDisabled)),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Icon(Icons.arrow_drop_down,
                      size: 12,
                      color: _dir == WotSortDirection.descending ? fg : scheme.iconDisabled),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}