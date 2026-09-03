import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 数字滚动到目标值，对应 wot `wd-count-to`。受控（end，0~end 动画）。
class WotCountTo extends StatefulWidget {
  const WotCountTo({
    super.key,
    this.modelValue = 0,
    this.onChange,
    this.duration = const Duration(milliseconds: 2000),
    this.decimals = 0,
    this.speed,
    this.autoplay = true,
    this.prefix = '',
    this.suffix = '',
    this.thousands = true,
    this.textStyle,
  });

  final num modelValue;
  final ValueChanged<num>? onChange;
  final Duration duration;
  final int decimals;
  final num? speed;
  final bool autoplay;
  final String prefix;
  final String suffix;
  final bool thousands;
  final TextStyle? textStyle;

  @override
  State<WotCountTo> createState() => _WotCountToState();
}

class _WotCountToState extends State<WotCountTo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  double _current = 0;

  @override
  void initState() {
    super.initState();
    _current = widget.modelValue.toDouble();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: widget.modelValue.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    if (widget.autoplay) _play();
  }

  void _play() {
    _anim = Tween<double>(begin: _current, end: widget.modelValue.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller
      ..duration = widget.duration
      ..forward(from: 0);
    _controller.addListener(() {
      setState(() => _current = _anim.value);
      widget.onChange?.call(_current);
    });
  }

  @override
  void didUpdateWidget(WotCountTo old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) {
      _play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final text = _format(_current);
    return Text(
      '${widget.prefix}$text${widget.suffix}',
      style: widget.textStyle ?? TextStyle(fontSize: 14, color: scheme.textMain),
    );
  }

  String _format(double v) {
    var s = v.toStringAsFixed(widget.decimals);
    if (widget.thousands && widget.decimals == 0 && v >= 1000) {
      final parts = v.round().toString();
      final buf = StringBuffer();
      for (var i = 0; i < parts.length; i++) {
        if (i > 0 && (parts.length - i) % 3 == 0) buf.write(',');
        buf.write(parts[i]);
      }
      s = buf.toString();
    }
    return s;
  }
}