import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 倒计时外部控制器（D 类 P1）：传入 [WotCountDown.controller] 后可
/// 从外部 start / pause / reset 倒计时。
class WotCountDownController {
  void Function()? _start;
  void Function()? _pause;
  void Function()? _reset;

  /// 供 State 挂载实现（勿手动调用）。
  void _bind(void Function() start, void Function() pause, void Function() reset) {
    _start = start;
    _pause = pause;
    _reset = reset;
  }

  /// 供 State 卸载（勿手动调用）。
  void _unbind() {
    _start = null;
    _pause = null;
    _reset = null;
  }

  /// 开始 / 恢复倒计时。
  void start() => _start?.call();

  /// 暂停倒计时（保留剩余时长）。
  void pause() => _pause?.call();

  /// 重置倒计时到 [WotCountDown.value] 并暂停。
  void reset() => _reset?.call();
}

/// 倒计时，对应 wot `wd-count-down`。受控（v-model:value，剩余毫秒）。
class WotCountDown extends StatefulWidget {
  const WotCountDown({
    super.key,
    this.value = 0,
    this.onChange,
    this.onFinish,
    this.format = 'HH:mm:ss',
    this.autoStart = true,
    this.millisecond = false,
    this.controller,
    this.textStyle,
  });

  /// 倒计时总时长，单位毫秒（v-model）。
  final num value;

  /// 剩余时间变化时触发的回调，参数为剩余时长。
  final ValueChanged<Duration>? onChange;

  /// 倒计时结束时触发的回调。
  final VoidCallback? onFinish;

  /// 时间展示格式，支持 `HH`/`mm`/`ss`/`SS`（百分秒）/`SSS`（毫秒）占位符，默认 `HH:mm:ss`。
  final String format;

  /// 是否自动开始倒计时，默认 true。
  final bool autoStart;

  /// 是否启用毫秒级刷新（D 类 P1）：true 时定时器改为 50ms 一跳，
  /// `SS` 占位符实时显示百分秒；默认 false（每秒一跳，与原行为一致）。
  final bool millisecond;

  /// 外部控制器（D 类 P1）：通过 [WotCountDownController] 从外部 start / pause / reset。
  final WotCountDownController? controller;

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
    widget.controller?._bind(_start, _pause, _reset);
    if (widget.autoStart) _start();
  }

  @override
  void didUpdateWidget(WotCountDown old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?._unbind();
      widget.controller?._bind(_start, _pause, _reset);
    }
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

  @override
  void dispose() {
    _timer?.cancel();
    widget.controller?._unbind();
    super.dispose();
  }

  /// tick 周期：millisecond 模式 50ms 一跳（SS 实时），否则 1s 一跳（原行为）。
  Duration get _tickInterval =>
      widget.millisecond ? const Duration(milliseconds: 50) : const Duration(seconds: 1);

  void _start() {
    if (_timer != null) return;
    _timer = Timer.periodic(_tickInterval, (_) {
      if (!mounted) return;
      final next = _remaining - _tickInterval;
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

  /// 暂停：仅取消定时器，保留剩余时长（D 类 P1）。
  void _pause() {
    _timer?.cancel();
    _timer = null;
  }

  /// 重置：回到 [WotCountDown.value] 并暂停（D 类 P1）。
  void _reset() {
    _timer?.cancel();
    _timer = null;
    setState(() => _remaining = Duration(milliseconds: widget.value.toInt()));
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
    // SS 为百分秒（两位）、SSS 为毫秒（三位）；millisecond=false 时定时器
    // 每秒一跳，SS/SSS 实际恒为 00/000，属预期表现。
    final cs = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds % 1000).toString().padLeft(3, '0');
    return widget.format
        .replaceAll('SSS', ms)
        .replaceAll('SS', cs)
        .replaceAll('HH', h)
        .replaceAll('mm', m)
        .replaceAll('ss', s);
  }
}