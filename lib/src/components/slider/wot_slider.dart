import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 滑块，对应 wot `wd-slider`。受控（v-model:value）。
class WotSlider extends StatefulWidget {
  const WotSlider({
    super.key,
    this.modelValue = 0,
    this.onChange,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.disabled = false,
    this.activeColor,
    this.inactiveColor,
    this.showTip = false,
    this.tipFormatter,
    this.name,
  });

  final num modelValue;
  final ValueChanged<num>? onChange;
  final num min;
  final num max;
  final num step;
  final bool disabled;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showTip;
  final String Function(num)? tipFormatter;
  final String? name;

  @override
  State<WotSlider> createState() => _WotSliderState();
}

class _WotSliderState extends State<WotSlider> {
  double _value = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.modelValue.toDouble();
  }

  @override
  void didUpdateWidget(WotSlider old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) _value = widget.modelValue.toDouble();
  }

  double _fraction(double v) {
    if (widget.max <= widget.min) return 0;
    return ((v - widget.min.toDouble()) / (widget.max - widget.min).toDouble()).clamp(0.0, 1.0);
  }

  void _set(double fraction) {
    if (widget.disabled) return;
    final range = (widget.max - widget.min).toDouble();
    final v = widget.min.toDouble() + fraction * range;
    final stepped = (v / widget.step.toDouble()).round() * widget.step.toDouble();
    final clamped = stepped.clamp(widget.min.toDouble(), widget.max.toDouble()).toDouble();
    if (clamped == _value) return;
    setState(() => _value = clamped);
    widget.onChange?.call(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final active = widget.activeColor ?? scheme.primaryOf(6);
    final inactive = widget.inactiveColor ?? scheme.borderLight;
    final frac = _fraction(_value);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _set(d.localPosition.dx / width),
          onHorizontalDragUpdate: (d) => _set(d.localPosition.dx / width),
          child: SizedBox(
            height: 32,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // 轨道。
                Container(
                  height: 3,
                  decoration: BoxDecoration(color: inactive, borderRadius: BorderRadius.circular(2)),
                ),
                // 已激活段。
                Container(
                  width: width * frac,
                  height: 3,
                  decoration: BoxDecoration(color: active, borderRadius: BorderRadius.circular(2)),
                ),
                // 滑块.
                Positioned(
                  left: width * frac - 14,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: active, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}