import 'package:flutter/material.dart';

import '../../theme/wot_state.dart';
import '../../theme/wot_theme.dart';
import '../form/wot_form.dart';

/// 滑块，对应 wot `wd-slider`。受控（v-model:value）。
class WotSlider extends StatefulWidget {
  const WotSlider({
    super.key,
    this.modelValue = 0,
    this.onChange,
    this.onChangeEnd,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.range = false,
    this.valueStart,
    this.onChangeRange,
    this.disabled = false,
    this.readonly = false,
    this.error = false,
    this.activeColor,
    this.inactiveColor,
    this.showTip = false,
    this.tipFormatter,
    this.showMinMax = false,
    this.showValueInThumb = false,
    this.name,
  });

  /// 当前值，默认 0。单滑块模式下为选中的值；[range] 模式下作为区间上限值。
  final num modelValue;

  /// 值变化回调（单滑块模式，拖动/点击过程中触发）。
  final ValueChanged<num>? onChange;

  /// 拖动/点击结束回调（单滑块模式），参数为最终值。
  final ValueChanged<num>? onChangeEnd;

  /// 最小值，默认 0。
  final num min;

  /// 最大值，默认 100。
  final num max;

  /// 步进值，默认 1。
  final num step;

  /// 是否为双向滑块模式，开启后显示两个滑块以选择区间，默认 false。
  final bool range;

  /// 双向滑块模式下区间的起始值（下限），缺省取 [min]。
  final num? valueStart;

  /// 双向滑块模式下区间变化回调，参数为 `[低值, 高值]`。
  final ValueChanged<List<num>>? onChangeRange;

  /// 是否禁用，默认 false。禁用时轨道灰化且不可拖动。
  final bool disabled;

  /// 是否只读：不可拖动，但保持正常配色（内容有效可读），默认 false。
  final bool readonly;

  /// 是否处于校验失败态（error 态）。命中时激活段转危险色。
  final bool error;

  /// 已激活段颜色，默认使用主题主色。
  final Color? activeColor;

  /// 未激活轨道颜色，默认使用主题描边浅色。
  final Color? inactiveColor;

  /// 是否显示当前值提示气泡，默认 false。
  final bool showTip;

  /// 提示气泡文本格式化函数，入参为当前值。
  final String Function(num)? tipFormatter;

  /// 是否在滑动条下方两端显示最小值和最大值，默认 false。
  final bool showMinMax;

  /// 是否在当前值圆点内显示当前数值，默认 false。
  final bool showValueInThumb;

  /// 表单字段名（用于原生表单提交示例）。
  final String? name;

  @override
  State<WotSlider> createState() => _WotSliderState();
}

class _WotSliderState extends State<WotSlider> {
  double _value = 0;
  double _low = 0;
  double _high = 0;
  bool _dragging = false;
  bool _dragLow = false;

  double get _range => (widget.max - widget.min).toDouble();

  @override
  void initState() {
    super.initState();
    _value = widget.modelValue.toDouble();
    _low = (widget.valueStart ?? widget.min).toDouble();
    _high = widget.modelValue.toDouble();
  }

  @override
  void didUpdateWidget(WotSlider old) {
    super.didUpdateWidget(old);
    if (_dragging) return;
    if (old.modelValue != widget.modelValue) _value = widget.modelValue.toDouble();
    if (widget.range) {
      _low = (widget.valueStart ?? widget.min).toDouble();
      _high = widget.modelValue.toDouble();
    }
  }

  double _fraction(double v) {
    if (_range <= 0) return 0;
    return ((v - widget.min.toDouble()) / _range).clamp(0.0, 1.0);
  }

  double _fracToValue(double fraction) {
    if (_range <= 0) return widget.min.toDouble();
    final v = widget.min.toDouble() + fraction * _range;
    final stepped = (v / widget.step.toDouble()).round() * widget.step.toDouble();
    return stepped.clamp(widget.min.toDouble(), widget.max.toDouble()).toDouble();
  }

  void _setSingle(double fraction) {
    final v = _fracToValue(fraction);
    if (v == _value) return;
    setState(() => _value = v);
    wotFormPushValue(context, widget.name, v);
    widget.onChange?.call(v);
  }

  void _setRange(double fraction, {required bool low}) {
    final v = _fracToValue(fraction);
    if (low) {
      if (v >= _high) return;
      setState(() => _low = v);
    } else {
      if (v <= _low) return;
      setState(() => _high = v);
    }
    widget.onChangeRange?.call([_low, _high]);
  }

  /// 在拖拽开始时按指针与两端滑块的远近决定抓取哪一端；拖拽过程中保持不变。
  void _beginDrag(double fraction) {
    if (!widget.range) return;
    _dragLow = (fraction - _fraction(_low)).abs() <=
        (fraction - _fraction(_high)).abs();
  }

  /// 根据指针位置移动当前锁定的端点。
  void _dragMove(double fraction) {
    if (widget.range) {
      _setRange(fraction, low: _dragLow);
    } else {
      _setSingle(fraction);
    }
  }

  void _dragEnd() {
    if (!_dragging) return;
    setState(() => _dragging = false);
    if (!widget.range) widget.onChangeEnd?.call(_value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    // 三态：显式 disabled 优先，其次取父级 WotFieldScope 下发；
    // readonly 仅锁交互、保持正常配色（区别于 disabled 的灰化）。
    final fieldScope = WotFieldScope.of(context);
    final disabled = widget.disabled || (fieldScope?.state == WotFieldState.disabled);
    final hasError = widget.error || (fieldScope?.error ?? false);
    final locked = disabled || widget.readonly;
    final active = disabled
        ? scheme.filledExtraStrong
        : (hasError ? scheme.dangerMain : (widget.activeColor ?? scheme.primaryOf(6)));
    final inactive = widget.inactiveColor ?? scheme.borderLight;
    final lowFrac = widget.range ? _fraction(_low) : 0.0;
    // 区间模式渲染高值圆点要用 _high（区间逻辑只更新 _high）；单滑块才用 _value。
    final highFrac = _fraction(widget.range ? _high : _value);

    final sliderView = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        Widget thumb(double frac, {bool isLow = false, num? value}) {
          return Positioned(
            // 轨道线中心 y ≈ 27 + 1.5 = 28.5；圆点高 28，故 top=14.5 使其竖直居中于轨道。
            left: frac * width - 14,
            top: 14.5,
            child: SizedBox(
              width: 28,
              height: 28,
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: active, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1)),
                  ],
                ),
                child: (widget.showValueInThumb && value != null)
                    ? Text(
                        _label(value),
                        maxLines: 1,
                        style: TextStyle(
                          color: active,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
            ),
          );
        }

        /// 值提示气泡：悬浮在圆点正上方，借助整条宽度 Align 定位，不限制文字宽度避免折行。
        Widget tip(num value, double frac) {
          return Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: Align(
                alignment: Alignment(((frac * 2 - 1).clamp(-1.0, 1.0)), -1),
                child: _tipBubble(value),
              ),
            ),
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: locked
              ? null
              : (d) {
                  final f = d.localPosition.dx / width;
                  _dragging = true;
                  _beginDrag(f);
                  _dragMove(f);
                  _dragEnd();
                },
          onHorizontalDragStart: locked
              ? null
              : (d) {
                  final f = d.localPosition.dx / width;
                  _beginDrag(f);
                  setState(() => _dragging = true);
                  _dragMove(f);
                },
          onHorizontalDragUpdate: locked ? null : (d) => _dragMove(d.localPosition.dx / width),
          onHorizontalDragEnd: locked ? null : (_) => _dragEnd(),
          onHorizontalDragCancel: locked ? null : _dragEnd,
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 27,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(color: inactive, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                if (widget.range) ...[
                  Positioned(
                    top: 27,
                    left: width * lowFrac,
                    width: width * (highFrac - lowFrac),
                    height: 3,
                    child: Container(
                      decoration: BoxDecoration(color: active, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  thumb(lowFrac, isLow: true, value: _low),
                  thumb(highFrac, value: _high),
                  if (widget.showTip && _dragging && _dragLow)
                    tip(_low, lowFrac),
                  if (widget.showTip && _dragging && !_dragLow)
                    tip(_high, highFrac),
                ] else ...[
                  Positioned(
                    top: 27,
                    left: 0,
                    width: width * highFrac,
                    height: 3,
                    child: Container(
                      decoration: BoxDecoration(color: active, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  thumb(highFrac, value: _value),
                  if (widget.showTip && _dragging) tip(_value, highFrac),
                ],
                if (widget.showMinMax)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _scaleLabel(widget.min),
                          _scaleLabel(widget.max),
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

    // 无障碍：裸 GestureDetector 不产生语义节点，屏幕阅读器读不出当前值 / 可增减。
    // 增减复用内部拖动路径（_dragMove + _dragEnd），与手动拖动一样走对齐吸附和 onChange。
    void semanticStep(int dir) {
      final cur = widget.range ? _high : _value;
      num next = cur + dir * widget.step;
      final steps = ((next - widget.min) / widget.step).round();
      next = widget.min + steps * widget.step;
      if (next < widget.min) next = widget.min;
      if (next > widget.max) next = widget.max;
      _dragMove(((next - widget.min) / _range).toDouble());
      _dragEnd();
    }

    final cur = widget.range ? _high : _value;
    return Semantics(
      slider: true,
      value: widget.range ? '${_label(_low)} - ${_label(_high)}' : _label(cur),
      increasedValue: widget.range ? null : _label(cur + widget.step),
      decreasedValue: widget.range ? null : _label(cur - widget.step),
      onIncrease: locked ? null : () => semanticStep(1),
      onDecrease: locked ? null : () => semanticStep(-1),
      enabled: !locked,
      child: sliderView,
    );
  }

  /// 当前值提示气泡。
  Widget _tipBubble(num value) {
    final scheme = context.wotScheme;
    final text = widget.tipFormatter?.call(value) ?? _label(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.textMain,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  /// 把数值格式化为简洁文案：整数显示为整数，小数保留小数。
  String _label(num value) {
    final v = value.toDouble();
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
  }

  /// 滑动条下方两端的刻度标签（最小值 / 最大值）。
  Widget _scaleLabel(num value) {
    final scheme = context.wotScheme;
    return Text(
      _label(value),
      style: TextStyle(fontSize: 10, color: scheme.textSecondary),
    );
  }
}