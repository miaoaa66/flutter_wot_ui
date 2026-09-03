import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 单选选项数据，对齐 wot `WotRadioOption`。
class WotRadioOption {
  const WotRadioOption({
    required this.label,
    this.value,
    this.disabled = false,
    this.color,
  });

  final String label;
  final Object? value;
  final bool disabled;
  final Color? color;
}

/// 单选组配置。
class _WotRadioScope extends InheritedWidget {
  const _WotRadioScope({required this.control, required super.child});
  final _RadioGroupData? control;

  static _RadioGroupData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_WotRadioScope>()?.control;
  }

  @override
  bool updateShouldNotify(_WotRadioScope old) => old.control != control;
}

class _RadioGroupData {
  const _RadioGroupData({this.value, this.onChange});
  final Object? value;
  final ValueChanged<Object?>? onChange;
}

/// 单选组，对应 wot `wd-radio-group`。受控（v-model:value）。
class WotRadioGroup extends StatelessWidget {
  const WotRadioGroup({
    super.key,
    this.modelValue,
    this.onChange,
    this.name,
    this.children,
    this.options = const [],
  });

  final Object? modelValue;
  final ValueChanged<Object?>? onChange;
  final String? name;
  final List<Widget>? children;
  final List<WotRadioOption> options;

  @override
  Widget build(BuildContext context) {
    return _WotRadioScope(
      control: _RadioGroupData(value: modelValue, onChange: onChange),
      child: options.isEmpty
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: children ?? [])
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final o in options)
                  WotRadio(label: o.label, value: o.value, disabled: o.disabled),
              ],
            ),
    );
  }
}

/// 单选，对应 wot `wd-radio`。
class WotRadio extends StatefulWidget {
  const WotRadio({
    super.key,
    this.modelValue = false,
    this.onChange,
    this.label,
    this.value,
    this.disabled = false,
    this.color,
    this.name,
  });

  final bool modelValue;
  final ValueChanged<bool>? onChange;
  final String? label;
  final Object? value;
  final bool disabled;
  final Color? color;
  final String? name;

  @override
  State<WotRadio> createState() => _WotRadioState();
}

class _WotRadioState extends State<WotRadio> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.modelValue;
  }

  @override
  void didUpdateWidget(WotRadio old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) _selected = widget.modelValue;
  }

  void _toggle() {
    if (widget.disabled) return;
    final group = _WotRadioScope.of(context);
    if (group != null) {
      group.onChange?.call(widget.value);
      return;
    }
    if (_selected) return;
    setState(() => _selected = true);
    widget.onChange?.call(true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final group = _WotRadioScope.of(context);
    final selected = group != null ? group.value == widget.value : _selected;
    final color = widget.color ?? scheme.primaryOf(6);

    final icon = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.disabled ? null : _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(
            color: selected ? color : (widget.disabled ? scheme.textDisabled : scheme.borderStrong),
            width: 1,
          ),
        ),
        child: selected
            ? Center(
                child: Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              )
            : null,
      ),
    );

    if (widget.label == null) return icon;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.disabled ? null : _toggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              color: widget.disabled ? scheme.textDisabled : scheme.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
