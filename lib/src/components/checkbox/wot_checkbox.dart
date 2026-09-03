import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 复选框选项数据，对齐 wot `WotCheckboxOption`。
class WotCheckboxOption {
  const WotCheckboxOption({
    required this.label,
    this.value,
    this.disabled = false,
    this.checkColor,
  });

  final String label;
  final Object? value;
  final bool disabled;
  final Color? checkColor;
}

/// 复选框组配置（经 InheritedWidget 下发）。
class _CheckGroupData {
  const _CheckGroupData({this.values, this.onChange, this.max});
  final List<Object?>? values;
  final ValueChanged<Object?>? onChange;
  final int? max;
}

/// 复选框组配置作用域。
class _WotCheckboxScope extends InheritedWidget {
  const _WotCheckboxScope({required this.control, required super.child});
  final _CheckGroupData? control;

  static _CheckGroupData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_WotCheckboxScope>()?.control;
  }

  @override
  bool updateShouldNotify(_WotCheckboxScope old) => old.control != control;
}

/// 复选框组，对应 wot `wd-checkbox-group`。受控（v-model:value）。
class WotCheckboxGroup extends StatelessWidget {
  const WotCheckboxGroup({
    super.key,
    this.modelValue = const [],
    this.onChange,
    this.max,
    this.name,
    this.children,
    this.options = const [],
  });

  final List<Object?> modelValue;
  final ValueChanged<List<Object?>>? onChange;
  final int? max;
  final String? name;
  final List<Widget>? children;
  final List<WotCheckboxOption> options;

  @override
  Widget build(BuildContext context) {
    return _WotCheckboxScope(
      control: _CheckGroupData(
        values: modelValue,
        max: max,
        onChange: (v) {
          final list = [...modelValue];
          if (list.contains(v)) {
            list.remove(v);
          } else {
            if (max != null && list.length >= max!) return;
            list.add(v);
          }
          onChange?.call(list);
        },
      ),
      child: options.isEmpty
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: children ?? [])
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final o in options)
                  WotCheckbox(label: o.label, value: o.value, disabled: o.disabled),
              ],
            ),
    );
  }
}

/// 复选框，对应 wot `wd-checkbox`。
///
/// 单独使用时受控（[modelValue]/[onChange]）；作为 [WotCheckboxGroup] 成员时
/// 选中值由组统一管理。
class WotCheckbox extends StatefulWidget {
  const WotCheckbox({
    super.key,
    this.modelValue = false,
    this.onChange,
    this.label,
    this.value,
    this.disabled = false,
    this.checkColor,
    this.size = 18,
    this.readonly = false,
    this.name,
  });

  final bool modelValue;
  final ValueChanged<bool>? onChange;
  final String? label;
  final Object? value;
  final bool disabled;
  final Color? checkColor;
  final double size;
  final bool readonly;
  final String? name;

  @override
  State<WotCheckbox> createState() => _WotCheckboxState();
}

class _WotCheckboxState extends State<WotCheckbox> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.modelValue;
  }

  @override
  void didUpdateWidget(WotCheckbox old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) _checked = widget.modelValue;
  }

  void _toggle() {
    if (widget.disabled || widget.readonly) return;
    final group = _WotCheckboxScope.of(context);
    if (group != null) {
      group.onChange?.call(widget.value);
      return;
    }
    setState(() => _checked = !_checked);
    widget.onChange?.call(_checked);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final group = _WotCheckboxScope.of(context);
    final checked = group != null
        ? (group.values ?? []).any((e) => e == widget.value)
        : _checked;
    final disabled = widget.disabled;
    final boxColor = widget.checkColor ?? scheme.primaryOf(6);

    final icon = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled || widget.readonly ? null : _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: checked ? boxColor : Colors.transparent,
          borderRadius: BorderRadius.circular(widget.size * 0.2),
          border: Border.all(
            color: checked ? boxColor : (disabled ? scheme.textDisabled : scheme.borderStrong),
          ),
        ),
        child: checked
            ? Icon(Icons.check, size: widget.size * 0.7, color: Colors.white)
            : null,
      ),
    );

    if (widget.label == null) return icon;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled || widget.readonly ? null : _toggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              color: disabled ? scheme.textDisabled : scheme.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
