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

  /// 选项显示文案。
  final String label;

  /// 选项值。
  final Object? value;

  /// 是否禁用该项，默认 false。
  final bool disabled;

  /// 勾选颜色，缺省取主题主色。
  final Color? checkColor;
}

/// 复选框组配置（经 InheritedWidget 下发）。
class _CheckGroupData {
  const _CheckGroupData({
    this.values,
    this.onChange,
    this.max,
    this.min,
    this.groupDisabled = false,
    this.shape,
  });
  final List<Object?>? values;
  final ValueChanged<Object?>? onChange;
  final int? max;
  final int? min;
  final bool groupDisabled;
  final String? shape;
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
    this.min,
    this.shape = 'square',
    this.disabled = false,
    this.name,
    this.children,
    this.options = const [],
  });

  /// 当前选中值数组（v-model）。
  final List<Object?> modelValue;

  /// 选中值变化时触发的回调，参数为最新的选中值数组。
  final ValueChanged<List<Object?>>? onChange;

  /// 最多可选中数量，超过后新选项不可选中（`null` 表示不限制）。
  final int? max;

  /// 最少可选中数量，低于后已选中的选项不可取消（`null` 表示不限制）。
  final int? min;

  /// 复选框形状：`circle`（圆形）或 `square`（方形），默认 `square`，
  /// 仅对 [options] 自动生成的选项生效。
  final String shape;

  /// 是否禁用整组复选框，默认 false。
  final bool disabled;

  /// 组件名称（表单标识，可选）。
  final String? name;

  /// 自定义子项列表，提供时替代 [options] 渲染。
  final List<Widget>? children;

  /// 选项数据列表，将自动生成为 [WotCheckbox]。
  final List<WotCheckboxOption> options;

  @override
  Widget build(BuildContext context) {
    return _WotCheckboxScope(
      control: _CheckGroupData(
        values: modelValue,
        max: max,
        min: min,
        groupDisabled: disabled,
        shape: shape,
        onChange: (v) {
          final list = [...modelValue];
          if (list.contains(v)) {
            if (min != null && list.length <= min!) return;
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
                  WotCheckbox(
                    label: o.label,
                    value: o.value,
                    disabled: o.disabled,
                    checkColor: o.checkColor,
                    shape: shape,
                  ),
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
    this.shape = 'square',
    this.readonly = false,
    this.name,
  });

  /// 是否选中（单独使用时受控，v-model）。
  final bool modelValue;

  /// 选中状态变化时触发的回调。
  final ValueChanged<bool>? onChange;

  /// 选项文案。
  final String? label;

  /// 选项值（作为 [WotCheckboxGroup] 成员时用于标识选中项）。
  final Object? value;

  /// 是否禁用，默认 false。
  final bool disabled;

  /// 勾选颜色，缺省取主题主色。
  final Color? checkColor;

  /// 复选框边长，单位 px，默认 18。
  final double size;

  /// 复选框形状：`circle`（圆形）或 `square`（方形），默认 `square`；
  /// 作为 [WotCheckboxGroup] 成员时默认取组配置。
  final String shape;

  /// 是否只读（展示但不可点击切换），默认 false。
  final bool readonly;

  /// 组件名称（表单标识，可选）。
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
    final shape = group?.shape ?? widget.shape;
    final disabled = widget.disabled || (group?.groupDisabled ?? false);
    // 在组中受 min/max 限制：已达上限且未选中、或已达下限且已选中时不可操作。
    final locked = group != null &&
        ((group.max != null && !checked && (group.values ?? []).length >= group.max!) ||
            (group.min != null && checked && (group.values ?? []).length <= group.min!));
    final boxColor = widget.checkColor ?? scheme.primaryOf(6);

    final icon = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled || widget.readonly || locked ? null : _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: checked ? boxColor : Colors.transparent,
          borderRadius: BorderRadius.circular(
            shape == 'circle' ? widget.size / 2 : widget.size * 0.2,
          ),
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
      onTap: disabled || widget.readonly || locked ? null : _toggle,
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
