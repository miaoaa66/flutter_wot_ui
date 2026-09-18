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
          // 上下三角：自绘，尺寸/清晰度可控（Material 的 arrow_drop_* 自带大量留白且偏小）。
          SizedBox(
            width: 12,
            height: 15,
            child: CustomPaint(
              painter: _SortArrowsPainter(
                ascendingActive: _dir == WotSortDirection.ascending,
                descendingActive: _dir == WotSortDirection.descending,
                activeColor: fg,
                inactiveColor: scheme.iconAuxiliary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 排序按钮的上下三角指示器（自绘，保证尺寸与清晰度）。
class _SortArrowsPainter extends CustomPainter {
  const _SortArrowsPainter({
    required this.ascendingActive,
    required this.descendingActive,
    required this.activeColor,
    required this.inactiveColor,
  });

  final bool ascendingActive;
  final bool descendingActive;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final up = Paint()..color = ascendingActive ? activeColor : inactiveColor;
    final down = Paint()..color = descendingActive ? activeColor : inactiveColor;

    // 上三角：apex 在顶部中央，底边在下。
    final upPath = Path()
      ..moveTo(w / 2, 1)
      ..lineTo(1, 8)
      ..lineTo(w - 1, 8)
      ..close();
    // 下三角：apex 在底部中央，底边在上。
    final downPath = Path()
      ..moveTo(w / 2, size.height - 1)
      ..lineTo(1, size.height - 8)
      ..lineTo(w - 1, size.height - 8)
      ..close();

    canvas
      ..drawPath(upPath, up)
      ..drawPath(downPath, down);
  }

  @override
  bool shouldRepaint(_SortArrowsPainter old) =>
      old.ascendingActive != ascendingActive ||
      old.descendingActive != descendingActive ||
      old.activeColor != activeColor ||
      old.inactiveColor != inactiveColor;
}