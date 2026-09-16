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

  /// 倒计时总时长，单位毫秒（v-model）。
  final num value;

  /// 剩余时间变化时触发的回调，参数为剩余时长。
  final ValueChanged<Duration>? onChange;

  /// 倒计时结束时触发的回调。
  final VoidCallback? onFinish;

  /// 时间展示格式，支持 `HH`/`mm`/`ss`/`SS` 占位符，默认 `HH:mm:ss`。
  final String format;

  /// 是否自动开始倒计时，默认 true。
  final bool autoStart;

  /// 文字样式，缺省使用主题默认文字样式。
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
    final valueChanged = old.value != widget.value;
    final autoStartChanged = old.autoStart != widget.autoStart;
    if (!valueChanged && !autoStartChanged) return;

    if (valueChanged) {
      _remaining = Duration(milliseconds: widget.value.toInt());
    }
    // 重置数值或切换自动启动后，定时器的运行态必须与入参重新对齐；
    // 否则会出现「数字变了但计时没重启 / 没停」的受控失效。
    _timer?.cancel();
    _timer = null;
    setState(() {});
    if (widget.autoStart) _start();
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