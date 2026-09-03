import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 倒计时，对应 wot `wd-count-down`。受控（v-model:value，剩余毫秒）。
class WotCountDown extends StatefulWidget {
  const WotCountDown({
    super.key,
    this.value = 0,
    this.onChange,
    this.onFinish,
    this.format = 'HH:mm:ss',
    this.autoStart = true,
    this.textStyle,
  });

  final num value;
  final ValueChanged<Duration>? onChange;
  final VoidCallback? onFinish;
  final String format;
  final bool autoStart;
  final TextStyle? textStyle;

  @override
  State<WotCountDown> createState() => _WotCountDownState();
}

class _WotCountDownState extends State<WotCountDown> {
  Duration _remaining = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = Duration(milliseconds: widget.value.toInt());
    if (widget.autoStart) _start();
  }

  @override
  void didUpdateWidget(WotCountDown old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _remaining = Duration(milliseconds: widget.value.toInt());
    }
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (!mounted) return;
      final next = _remaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        _timer?.cancel();
        setState(() => _remaining = Duration.zero);
        widget.onFinish?.call();
      } else {
        setState(() => _remaining = next);
      }
      widget.onChange?.call(_remaining);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return Text(
      _format(_remaining),
      style: widget.textStyle ?? TextStyle(fontSize: 14, color: scheme.textMain),
    );
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds % 1000 ~/ 100).toString();
    return (widget.format
            .replaceAll('HH', h)
            .replaceAll('mm', m)
            .replaceAll('ss', s))
        .replaceAll('SSS', ms * 2);
  }
}