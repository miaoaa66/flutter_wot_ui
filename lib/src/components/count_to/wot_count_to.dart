import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 数字滚动到目标值，对应 wot `wd-count-to`。受控（end，0~end 动画）。
class WotCountTo extends StatefulWidget {
  const WotCountTo({
    super.key,
    this.modelValue = 0,
    this.onChange,
    this.duration = const Duration(milliseconds: 3000),
    this.decimals = 0,
    this.speed,
    this.autoplay = true,
    this.startVal = 0,
    this.prefix = '',
    this.suffix = '',
    this.thousands = true,
    this.textStyle,
  });

  /// 目标数值（0 到该值动画，v-model）。
  final num modelValue;

  /// 数值变化时触发的回调。
  final ValueChanged<num>? onChange;

  /// 动画时长，默认 3000 毫秒。
  final Duration duration;

  /// 保留的小数位数，默认 0。
  final int decimals;

  /// 动画速度（每秒递增的数值），指定后覆盖 [duration]。
  ///
  /// 换算关系：`duration = |modelValue| / speed`（秒）。`speed` 非正数时回退到 [duration]。
  final num? speed;

  /// 是否自动播放动画，默认 true。
  final bool autoplay;

  /// 起始数值（D 类 P1），默认 0；autoplay 时从该值滚动到 [modelValue]，
  /// 非 autoplay 时初始直接显示 [modelValue]。
  final num startVal;

  /// 数字前缀。
  final String prefix;

  /// 数字后缀。
  final String suffix;

  /// 是否启用千分位分隔，默认 true。
  final bool thousands;

  /// 文字样式，缺省使用主题默认文字样式。
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
    // autoplay 时从 startVal（D 类 P1，默认 0）滚动到 modelValue；否则直接显示目标值。
    _current = widget.autoplay ? widget.startVal.toDouble() : widget.modelValue.toDouble();
    _controller = AnimationController(vsync: this, duration: _effectiveDuration());
    _anim = Tween<double>(begin: _current, end: widget.modelValue.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    // 只在初始挂载时加一次监听，避免重复累加导致多次 setState/onChange。
    _controller.addListener(_onTick);
    if (widget.autoplay) _startForward();
  }

  /// 监听回调：仅在挂载后更新，避免在 build 阶段触发父组件 setState。
  void _onTick() {
    if (!mounted) return;
    setState(() => _current = _anim.value);
    widget.onChange?.call(_current);
  }

  /// 延迟到首帧之后启动动画。
  ///
  /// [AnimationController.forward] 会同步把 value 设为起始值并立即
  /// [notifyListeners]，若在 initState / didUpdateWidget 阶段直接调用，
  /// 回调中的 [State.setState] / onChange 会命中父组件正在 build 的窗口，
  /// 抛 "setState() called during build"。首帧后再启动即可规避。
  void _startForward() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.forward(from: 0);
    });
  }

  /// [WotCountTo.speed] 优先：由「每秒递增数值」反推总时长；未指定或非法时用 [WotCountTo.duration]。
  Duration _effectiveDuration() {
    final s = widget.speed;
    if (s == null || s <= 0) return widget.duration;
    final seconds = widget.modelValue.abs() / s;
    if (!seconds.isFinite || seconds <= 0) return widget.duration;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  void _play() {
    _anim = Tween<double>(begin: _current, end: widget.modelValue.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.duration = _effectiveDuration();
    // didUpdateWidget 同样处于更新/构建窗口内，必须延迟到首帧后启动。
    _startForward();
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