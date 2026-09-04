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

  /// 选项显示文案。
  final String label;

  /// 选项值，用于与选中值（v-model:value）匹配。
  final Object? value;

  /// 是否禁用该选项，默认 false。
  final bool disabled;

  /// 选中时的主题色，默认使用主题主色。
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
  const _RadioGroupData({this.value, this.onChange, this.groupDisabled = false, this.shape});
  final Object? value;
  final ValueChanged<Object?>? onChange;
  final bool groupDisabled;
  final String? shape;
}

/// 单选组，对应 wot `wd-radio-group`。受控（v-model:value）。
class WotRadioGroup extends StatelessWidget {
  const WotRadioGroup({
    super.key,
    this.modelValue,
    this.onChange,
    this.shape = 'circle',
    this.disabled = false,
    this.name,
    this.children,
    this.options = const [],
  });

  /// 当前选中的值（受控）。
  final Object? modelValue;

  /// 选中值变化回调。
  final ValueChanged<Object?>? onChange;

  /// 单选框形状：`circle`（圆形）或 `square`（方形），默认 `circle`，
  /// 仅对 [options] 自动生成的选项生效。
  final String shape;

  /// 是否禁用整组单选框，默认 false。
  final bool disabled;

  /// 表单字段名（用于原生表单提交示例）。
  final String? name;

  /// 自定义子项（[WotRadio] 列表），与 [options] 二选一。
  final List<Widget>? children;

  /// 选项数据列表，为空时使用 [children]。
  final List<WotRadioOption> options;

  @override
  Widget build(BuildContext context) {
    return _WotRadioScope(
      control: _RadioGroupData(
        value: modelValue,
        onChange: onChange,
        groupDisabled: disabled,
        shape: shape,
      ),
      child: options.isEmpty
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: children ?? [])
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final o in options)
                  WotRadio(
                    label: o.label,
                    value: o.value,
                    disabled: o.disabled,
                    color: o.color,
                    shape: shape,
                  ),
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
    this.shape = 'circle',
    this.name,
  });

  /// 初始是否选中（独立模式），默认 false。
  final bool modelValue;

  /// 选中状态变化回调。
  final ValueChanged<bool>? onChange;

  /// 选项显示文案。
  final String? label;

  /// 选项值，用于组模式（[WotRadioGroup]）下的选中匹配。
  final Object? value;

  /// 是否禁用，默认 false。
  final bool disabled;

  /// 选中时的主题色，默认使用主题主色。
  final Color? color;

  /// 单选框形状：`circle`（圆形）或 `square`（方形），默认 `circle`；
  /// 作为 [WotRadioGroup] 成员时默认取组配置。
  final String shape;

  /// 表单字段名（用于原生表单提交示例）。
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
      if (group.groupDisabled) return;
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
    final shape = group?.shape ?? widget.shape;
    final disabled = widget.disabled || (group?.groupDisabled ?? false);

    final icon = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: shape == 'circle' ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: shape == 'circle' ? null : BorderRadius.circular(3),
          color: Colors.transparent,
          border: Border.all(
            color: selected ? color : (disabled ? scheme.textDisabled : scheme.borderStrong),
            width: 1,
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: shape == 'circle' ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: shape == 'circle' ? null : BorderRadius.circular(2),
                  ),
                ),
              )
            : null,
      ),
    );

    if (widget.label == null) return icon;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : _toggle,
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
