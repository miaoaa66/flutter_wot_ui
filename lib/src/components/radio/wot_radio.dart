import 'package:flutter/material.dart';

import '../../theme/wot_state.dart';
import '../../theme/wot_theme.dart';
import '../form/wot_form.dart';

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
        onChange: (v) {
          // 按组 name 把选中值登记到表单（原先漏登记，name 是死参数）。
          wotFormPushValue(context, name, v);
          onChange?.call(v);
        },
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
    this.readonly = false,
    this.color,
    this.shape = 'circle',
    this.error = false,
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

  /// 是否禁用，默认 false。禁用时选中 / 未选中均灰化且不可交互。
  final bool disabled;

  /// 是否只读：不可切换，但保持正常配色（内容有效可读），默认 false。
  final bool readonly;

  /// 选中时的主题色，默认使用主题主色。
  final Color? color;

  /// 单选框形状：`circle`（圆形）或 `square`（方形），默认 `circle`；
  /// 作为 [WotRadioGroup] 成员时默认取组配置。
  final String shape;

  /// 是否处于校验失败态（error 态）。未显式传入时取父级 [WotFieldScope] 下发的值。
  final bool error;

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
    if (widget.disabled || widget.readonly) return;
    final group = _WotRadioScope.of(context);
    if (group != null) {
      if (group.groupDisabled) return;
      // 组模式：由 [WotRadioGroup] 负责登记选中值（组名）。
      group.onChange?.call(widget.value);
      return;
    }
    if (_selected) return;
    setState(() => _selected = true);
    // 独立模式：按自身 name 登记到表单（原先漏登记，name 是死参数）。
    wotFormPushValue(context, widget.name, true);
    widget.onChange?.call(true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final group = _WotRadioScope.of(context);
    final selected = group != null ? group.value == widget.value : _selected;
    final shape = group?.shape ?? widget.shape;
    // 三态：显式 disabled / 组合禁用优先，其次取父级 WotFieldScope 下发。
    final fieldScope = WotFieldScope.of(context);
    final disabled = widget.disabled ||
        (group?.groupDisabled ?? false) ||
        (fieldScope?.state == WotFieldState.disabled);
    final hasError = widget.error || (fieldScope?.error ?? false);
    final style = wotFieldStyle(
      scheme,
      disabled ? WotFieldState.disabled : WotFieldState.editable,
      error: hasError,
      baseBorder: scheme.borderStrong,
    );
    // 选中色：禁用转灰；其余用自定义色 / 主色（错误只体现在未选中描边与标签）。
    final color =
        disabled ? scheme.filledExtraStrong : (widget.color ?? scheme.primaryOf(6));

    final icon = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled || widget.readonly ? null : _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: shape == 'circle' ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: shape == 'circle' ? null : BorderRadius.circular(3),
          color: Colors.transparent,
          border: Border.all(
            color: selected ? color : style.border,
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
      onTap: disabled || widget.readonly ? null : _toggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            widget.label!,
            style: TextStyle(fontSize: 14, color: style.label),
          ),
        ],
      ),
    );
  }
}
