import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 数字输入框，对应 wot `wd-input-number`。受控（v-model:value）。
class WotInputNumber extends StatefulWidget {
  const WotInputNumber({
    super.key,
    this.modelValue = 0,
    this.onChange,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.disabled = false,
    this.readonly = false,
    this.inputWidth = 40,
    this.buttonSize = 28,
    this.longPress = false,
    this.name,
  });

  final num modelValue;
  final ValueChanged<num>? onChange;
  final num min;
  final num max;
  final num step;
  final bool disabled;
  final bool readonly;
  final double inputWidth;
  final double buttonSize;
  final bool longPress;
  final String? name;

  @override
  State<WotInputNumber> createState() => _WotInputNumberState();
}

class _WotInputNumberState extends State<WotInputNumber> {
  late final TextEditingController _c;
  late num _value;

  @override
  void initState() {
    super.initState();
    _value = (widget.modelValue).clamp(widget.min, widget.max);
    _c = TextEditingController(text: _value.toInt() == _value ? _value.toInt().toString() : _value.toString());
  }

  @override
  void didUpdateWidget(WotInputNumber old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) {
      _value = (widget.modelValue).clamp(widget.min, widget.max).toDouble();
      _syncText();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _fmt(num v) => v.toInt() == v ? v.toInt().toString() : v.toString();

  void _syncText() {
    _c.value = _c.value.copyWith(text: _fmt(_value));
  }

  void _emit(num v) {
    _value = v;
    widget.onChange?.call(v);
  }

  void _step(double delta) {
    if (widget.disabled || widget.readonly) return;
    final next = (_value + delta * widget.step).clamp(widget.min, widget.max).toDouble();
    if (next == _value) return;
    setState(() {
      _value = next;
      _syncText();
      _emit(next);
    });
  }

  void _parseAndEmit(String s) {
    if (s.isEmpty) return;
    final v = double.tryParse(s);
    if (v == null) {
      _syncText();
      return;
    }
    final clamped = v.clamp(widget.min, widget.max).toDouble();
    setState(() {
      _value = clamped;
      _syncText();
      _emit(clamped);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final btnColor = widget.disabled ? scheme.textDisabled : scheme.primaryOf(6);
    final disableMinus = _value <= widget.min;
    final disablePlus = _value >= widget.max;

    final minus = _button(Icons.remove, disableMinus, () => _step(-1), btnColor);
    final plus = _button(Icons.add, disablePlus, () => _step(1), btnColor);

    final field = SizedBox(
      width: widget.inputWidth,
      child: TextField(
        controller: _c,
        enabled: !widget.disabled && !widget.readonly,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(fontSize: 14, color: scheme.textMain),
        onSubmitted: _parseAndEmit,
        onChanged: (s) => setState(() {}),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: scheme.borderLight)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: scheme.primaryOf(6))),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: scheme.borderLight)),
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

  Widget _button(IconData icon, bool disabled, VoidCallback onTap, Color color) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : onTap,
      child: Container(
        width: widget.buttonSize,
        height: widget.buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: disabled ? kDisabledBorder : kActiveBorder),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: disabled ? kDisabledBorder : color),
      ),
    );
  }
}

const Color kActiveBorder = Color(0xFFE5E6EC);
const Color kDisabledBorder = Color(0xFFC8C9CC);