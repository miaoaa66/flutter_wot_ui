import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/wot_state.dart';
import '../../theme/wot_theme.dart';
import '../form/wot_form.dart';

/// 数字输入框，对应 wot `wd-input-number`。受控（v-model:value）。
class WotInputNumber extends StatefulWidget {
  const WotInputNumber({
    super.key,
    this.modelValue = 0,
    this.onChange,
    this.min = 1,
    this.max = 9007199254740991,
    this.step = 1,
    this.precision,
    this.disabled = false,
    this.readonly = false,
    this.error = false,
    this.inputWidth = 40,
    this.buttonSize = 28,
    this.longPress = false,
    this.name,
  });

  /// 当前值（受控，v-model:value），会自动夹在 [min]、[max] 之间。
  final num modelValue;

  /// 值变化时回调。
  final ValueChanged<num>? onChange;

  /// 最小值；默认 1（对齐 wot），小于该值的输入会被夹取到该值。
  final num min;

  /// 最大值；默认 Number.MAX_SAFE_INTEGER（对齐 wot）。
  final num max;

  /// 每次增减的步长；默认 1。
  final num step;

  /// 数值精度（保留的小数位数），为空表示不限制小数位数。
  final int? precision;

  /// 是否禁用（按钮与输入框均不可操作），禁用时输入框灰化。
  final bool disabled;

  /// 是否只读（仅按钮可操作，输入框不可编辑）。
  final bool readonly;

  /// 是否处于校验失败态（error 态）。命中时输入框描红边。
  final bool error;

  /// 输入框宽度（逻辑像素）。
  final double inputWidth;

  /// 加减按钮直径（逻辑像素）。
  final double buttonSize;

  /// 是否支持长按按钮连续增减。
  final bool longPress;

  /// 表单字段名；传入后在 [WotFormScope] 中按该名称关联取值。
  final String? name;

  @override
  State<WotInputNumber> createState() => _WotInputNumberState();
}

class _WotInputNumberState extends State<WotInputNumber> {
  late final TextEditingController _c;
  late num _value;

  /// 长按连续增减的定时器；仅 [WotInputNumber.longPress] 为 true 时启用。
  Timer? _repeatTimer;

  /// 长按触发间隔（毫秒）。
  static const int _repeatInterval = 120;

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  void _startRepeat(num delta) {
    if (!widget.longPress) return;
    _stopRepeat();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: _repeatInterval), (_) {
      // 到达 min/max 后 _step 不再变化，此时主动停止，避免空转。
      if (!_step(delta)) _stopRepeat();
    });
  }

  @override
  void initState() {
    super.initState();
    _value = _round((widget.modelValue).clamp(widget.min, widget.max));
    _c = TextEditingController(text: _fmt(_value));
  }

  @override
  void didUpdateWidget(WotInputNumber old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) {
      _value = _round((widget.modelValue).clamp(widget.min, widget.max).toDouble());
      _syncText();
    }
  }

  @override
  void dispose() {
    _stopRepeat();
    _c.dispose();
    super.dispose();
  }

  /// 按 [WotInputNumber.precision] 对数值做四舍五入约束；未设置时原样返回。
  num _round(num v) {
    final p = widget.precision;
    if (p == null) return v;
    final factor = math.pow(10, p).toDouble();
    return (v * factor).round() / factor;
  }

  String _fmt(num v) {
    final p = widget.precision;
    if (p != null) return v.toStringAsFixed(p);
    return v.toInt() == v ? v.toInt().toString() : v.toString();
  }

  void _syncText() {
    _c.value = _c.value.copyWith(text: _fmt(_value));
  }

  void _emit(num v) {
    _value = v;
    wotFormPushValue(context, widget.name, v);
    widget.onChange?.call(v);
  }

  /// 是否锁定交互：显式 disabled / readonly，或父级 WotFieldScope 下发的禁用 / 只读。
  /// 用 [WotFieldScope.read]（不建立依赖），以便在回调中安全调用。
  bool get _isLocked {
    if (widget.disabled || widget.readonly) return true;
    final s = WotFieldScope.read(context)?.state;
    return s == WotFieldState.disabled || s == WotFieldState.readonly;
  }

  /// 步进一次；返回数值是否真的发生变化（到边界时为 false）。
  bool _step(num delta) {
    if (_isLocked) return false;
    final next = _round((_value + delta * widget.step).clamp(widget.min, widget.max).toDouble());
    if (next == _value) return false;
    setState(() {
      _value = next;
      _syncText();
      _emit(next);
    });
    return true;
  }

  void _parseAndEmit(String s) {
    if (s.isEmpty) return;
    final v = double.tryParse(s);
    if (v == null) {
      _syncText();
      return;
    }
    final clamped = _round(v.clamp(widget.min, widget.max).toDouble());
    setState(() {
      _value = clamped;
      _syncText();
      _emit(clamped);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    // 三态：显式 disabled / readonly 优先，其次取父级 WotFieldScope 下发。
    final fieldScope = WotFieldScope.of(context);
    final disabled = widget.disabled || (fieldScope?.state == WotFieldState.disabled);
    final readonly = widget.readonly || (fieldScope?.state == WotFieldState.readonly);
    final hasError = widget.error || (fieldScope?.error ?? false);
    final locked = disabled || readonly;
    final style = wotFieldStyle(
      scheme,
      disabled ? WotFieldState.disabled : WotFieldState.editable,
      error: hasError,
      baseBorder: scheme.borderLight,
    );
    final btnColor = disabled ? scheme.textDisabled : scheme.primaryOf(6);
    final disableMinus = _value <= widget.min;
    final disablePlus = _value >= widget.max;

    final minus = _button(Icons.remove, disableMinus || disabled, -1, btnColor);
    final plus = _button(Icons.add, disablePlus || disabled, 1, btnColor);

    final field = SizedBox(
      width: widget.inputWidth,
      child: TextField(
        controller: _c,
        enabled: !locked,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(fontSize: 14, color: style.text),
        onSubmitted: _parseAndEmit,
        onChanged: (s) => setState(() {}),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          filled: disabled,
          fillColor: style.background,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: style.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: hasError ? scheme.dangerMain : scheme.primaryOf(6))),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: style.border)),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        minus,
        SizedBox(width: 4),
        field,
        SizedBox(width: 4),
        plus,
      ],
    );
  }

  Widget _button(IconData icon, bool disabled, num delta, Color color) {
    final scheme = context.wotScheme;
    final border = disabled ? scheme.borderLight : scheme.borderMain;
    final canLongPress = !disabled && widget.longPress;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : () => _step(delta),
      onLongPressStart: canLongPress ? (_) => _startRepeat(delta) : null,
      onLongPressEnd: canLongPress ? (_) => _stopRepeat() : null,
      onLongPressCancel: canLongPress ? _stopRepeat : null,
      child: Container(
        width: widget.buttonSize,
        height: widget.buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: disabled ? border : color),
      ),
    );
  }
}