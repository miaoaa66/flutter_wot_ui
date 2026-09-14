import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';
import '../empty/wot_empty.dart';
import '../icon/wot_icon.dart';
import '../search/wot_search.dart';

/// 列表选择器选项，对应 wot `wd-select-picker` 的选项。
///
/// 既可用本结构体，也可直接传 `String` 或 `Map`（配合 [WotSelectPicker.valueKey]
/// /[WotSelectPicker.labelKey]/[WotSelectPicker.disabledKey] 取值），保持与 wot
/// `columns`（简单值数组或对象数组）一致。
class WotSelectPickerOption {
  const WotSelectPickerOption({
    required this.label,
    this.value,
    this.disabled = false,
  });

  /// 选项显示文案。
  final String label;

  /// 选项值，用于与选中值（v-model）匹配。
  final Object? value;

  /// 是否禁用该选项，默认 false。
  final bool disabled;
}

/// 列表选择器（弹层），对应 wot `wd-select-picker`。
///
/// 区别于滚轮 [WotPicker]（对应 `wd-picker`）：本组件渲染一个可点击的展示框，
/// 点击后弹出「扁平列表」选择面板，支持单选(type=radio)/多选(type=checkbox)、
/// 本地搜索(filterable)、选择数量限制(min/max)、确认前校验(before-confirm)、
/// 单选自动回填(show-confirm=false)、清除(clearable) 等。
///
/// 值统一为 [modelValue]：radio 模式存单个值，checkbox 模式存 `List<Object?>`。
class WotSelectPicker extends StatefulWidget {
  const WotSelectPicker({
    super.key,
    this.columns = const [],
    this.type = 'radio',
    this.modelValue,
    this.modelVisible,
    this.onChange,
    this.onConfirm,
    this.onCancel,
    this.onUpdateVisible,
    this.filterable = false,
    this.min,
    this.max,
    this.showConfirm = true,
    this.clearable = true,
    this.beforeConfirm,
    this.valueKey = 'value',
    this.labelKey = 'label',
    this.disabledKey = 'disabled',
    this.title,
    this.placeholder = '请选择',
    this.disabled = false,
    this.loading = false,
    this.color,
    this.name,
    this.emptyText = '暂无数据',
  });

  /// 扁平选项列表（对应 wot `columns`）。每项可为 [WotSelectPickerOption]、
  /// `String`、`Map`（配合 valueKey/labelKey/disabledKey 提取）。
  final List<Object> columns;

  /// 选择类型：`radio`（单选，默认）或 `checkbox`（多选）。
  final String type;

  /// 当前选中值（受控 v-model）。radio 存单个值；checkbox 存 `List<Object?>`。
  final Object? modelValue;

  /// 是否受控显示弹层（v-model:visible）。非空时由外部接管显隐。
  final bool? modelVisible;

  /// 值变化回调（radio 回传单值，checkbox 回传 `List<Object?>`）。
  final ValueChanged<Object?>? onChange;

  /// 确认（有效变更）回调，参数与 [onChange] 一致。
  final ValueChanged<Object?>? onConfirm;

  /// 点击取消（或蒙层关闭）时回调。
  final VoidCallback? onCancel;

  /// 显隐变化回调（v-model:visible 双向绑定）。
  final ValueChanged<bool>? onUpdateVisible;

  /// 是否显示顶部搜索框并支持本地过滤，默认 false。
  final bool filterable;

  /// 最少可选数量（多选时生效），达到后已选项不可取消。
  final int? min;

  /// 最多可选数量（多选时生效），达到后禁选新项。
  final int? max;

  /// 是否显示确认按钮；默认 true。`false` 时单选点击即自动回填关闭。
  final bool showConfirm;

  /// 已选中后是否提供清除按钮，默认 true。
  final bool clearable;

  /// 确认前校验钩子；返回 `bool` 或 `Future<bool>`，`false` 则不关闭弹层。
  final FutureOr<bool> Function(Object? value)? beforeConfirm;

  /// 选项为 `Map` 时提取 value 的字段名，默认 `value`。
  final String valueKey;

  /// 选项为 `Map` 时提取 label 的字段名，默认 `label`。
  final String labelKey;

  /// 选项为 `Map` 时提取 disabled 的字段名，默认 `disabled`。
  final String disabledKey;

  /// 弹层顶部标题；不传则不显示。
  final String? title;

  /// 未选择任何项时的占位文本，默认「请选择」。
  final String placeholder;

  /// 是否禁用整组件（不可点击弹出），默认 false。
  final bool disabled;

  /// 弹层内是否显示加载中状态（覆盖选项区域并禁用交互）。
  final bool loading;

  /// 选中高亮/确认颜色；不传时用主题主色。
  final Color? color;

  /// 表单字段名（原生表单提交示例用，可选）。
  final String? name;

  /// 空列表/搜索无结果时的提示文案，默认「暂无数据」。
  final String emptyText;

  /// 解析单个选项为内部统一结构。
  ({String label, Object? value, bool disabled}) _resolveOne(Object item) {
    if (item is WotSelectPickerOption) {
      return (label: item.label, value: item.value, disabled: item.disabled);
    }
    if (item is Map) {
      final m = item;
      final disabled = m[disabledKey] is bool && m[disabledKey] as bool;
      if (m[labelKey] is String) {
        return (
          label: m[labelKey] as String,
          value: m.containsKey(valueKey) ? m[valueKey] : item,
          disabled: disabled,
        );
      }
      return (label: item.toString(), value: item, disabled: disabled);
    }
    return (label: item.toString(), value: item, disabled: false);
  }

  List<({String label, Object? value, bool disabled})> get _options =>
      [for (final o in columns) _resolveOne(o)];

  /// 计算展示框的文本（把当前选中值还原为 label 拼接）。
  String _display(Object? mv) {
    if (mv == null) return '';
    final opts = _options;
    if (mv is List) {
      final labels = <String>[
        for (final o in opts)
          if (mv.contains(o.value)) o.label,
      ];
      return labels.join('，');
    }
    for (final o in opts) {
      if (o.value == mv) return o.label;
    }
    return '';
  }

  bool get _hasValue {
    final mv = modelValue;
    if (mv == null) return false;
    if (mv is List) return mv.isNotEmpty;
    return mv.toString().isNotEmpty;
  }

  /// 命令式弹出列表选择器并返回选中的值。
  ///
  /// radio 返回选中的单值，checkbox 返回 `List<Object?>`；取消返回 null。
  static Future<T?> show<T>(
    BuildContext context, {
    List<Object> columns = const [],
    String type = 'radio',
    Object? initialValue,
    String? title,
    bool filterable = false,
    int? min,
    int? max,
    bool showConfirm = true,
    FutureOr<bool> Function(Object? value)? beforeConfirm,
    String valueKey = 'value',
    String labelKey = 'label',
    String disabledKey = 'disabled',
    bool loading = false,
    Color? color,
    String emptyText = '暂无数据',
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => _WotSelectPickerSheet(
        columns: columns,
        type: type,
        initialValue: initialValue,
        title: title,
        filterable: filterable,
        min: min,
        max: max,
        showConfirm: showConfirm,
        beforeConfirm: beforeConfirm,
        valueKey: valueKey,
        labelKey: labelKey,
        disabledKey: disabledKey,
        loading: loading,
        color: color,
        emptyText: emptyText,
      ),
    );
  }

  @override
  State<WotSelectPicker> createState() => _WotSelectPickerState();
}

class _WotSelectPickerState extends State<WotSelectPicker> {
  bool _opening = false;

  void _setVisible(bool v) {
    if (widget.modelVisible != null) widget.onUpdateVisible?.call(v);
  }

  Future<void> _present() async {
    if (widget.disabled || _opening) return;
    _opening = true;
    _setVisible(true);
    final result = await WotSelectPicker.show<Object?>(
      context,
      columns: widget.columns,
      type: widget.type,
      initialValue: widget.modelValue,
      title: widget.title,
      filterable: widget.filterable,
      min: widget.min,
      max: widget.max,
      showConfirm: widget.showConfirm,
      beforeConfirm: widget.beforeConfirm,
      valueKey: widget.valueKey,
      labelKey: widget.labelKey,
      disabledKey: widget.disabledKey,
      loading: widget.loading,
      color: widget.color,
      emptyText: widget.emptyText,
    );
    _opening = false;
    if (!mounted) return;
    _setVisible(false);
    if (result != null) {
      widget.onConfirm?.call(result);
      widget.onChange?.call(result);
    } else {
      widget.onCancel?.call();
    }
  }

  void _clear() {
    final empty = widget.type == 'checkbox' ? <Object?>[] : null;
    widget.onConfirm?.call(empty);
    widget.onChange?.call(empty);
  }

  @override
  void didUpdateWidget(WotSelectPicker old) {
    super.didUpdateWidget(old);
    final nowOpen = widget.modelVisible ?? false;
    if (nowOpen && !(old.modelVisible ?? false) && !_opening) {
      _present();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final display = widget._display(widget.modelValue);
    final hasValue = widget._hasValue;

    return InkWell(
      onTap: widget.disabled ? null : _present,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.disabled ? scheme.borderLight : scheme.borderMain,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                display.isEmpty ? widget.placeholder : display,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: display.isEmpty
                      ? scheme.textPlaceholder
                      : scheme.textMain,
                ),
              ),
            ),
            if (hasValue && widget.clearable && !widget.disabled)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _clear,
                child: WotIcon(
                  name: 'close-circle',
                  size: 14,
                  color: scheme.iconAuxiliary,
                ),
              ),
            const SizedBox(width: 8),
            WotIcon(
              name: 'arrow-down',
              size: 14,
              color: scheme.iconAuxiliary,
            ),
          ],
        ),
      ),
    );
  }
}

/// 列表选择弹层面板（单选/多选 + 搜索 + 校验）。
class _WotSelectPickerSheet extends StatefulWidget {
  const _WotSelectPickerSheet({
    required this.columns,
    required this.type,
    this.initialValue,
    this.title,
    this.filterable = false,
    this.min,
    this.max,
    this.showConfirm = true,
    this.beforeConfirm,
    this.valueKey = 'value',
    this.labelKey = 'label',
    this.disabledKey = 'disabled',
    this.loading = false,
    this.color,
    this.emptyText = '暂无数据',
  });

  final List<Object> columns;
  final String type;
  final Object? initialValue;
  final String? title;
  final bool filterable;
  final int? min;
  final int? max;
  final bool showConfirm;
  final FutureOr<bool> Function(Object? value)? beforeConfirm;
  final String valueKey;
  final String labelKey;
  final String disabledKey;
  final bool loading;
  final Color? color;
  final String emptyText;

  @override
  State<_WotSelectPickerSheet> createState() => _WotSelectPickerSheetState();
}

class _WotSelectPickerSheetState extends State<_WotSelectPickerSheet> {
  late Object? _value;
  String _keyword = '';

  List<({String label, Object? value, bool disabled})> get _all =>
      [
        for (final o in widget.columns)
          _resolveOne(o),
      ];

  ({String label, Object? value, bool disabled}) _resolveOne(Object item) {
    if (item is WotSelectPickerOption) {
      return (label: item.label, value: item.value, disabled: item.disabled);
    }
    if (item is Map) {
      final m = item;
      final disabled = m[widget.disabledKey] is bool && m[widget.disabledKey] as bool;
      if (m[widget.labelKey] is String) {
        return (
          label: m[widget.labelKey] as String,
          value: m.containsKey(widget.valueKey) ? m[widget.valueKey] : item,
          disabled: disabled,
        );
      }
      return (label: item.toString(), value: item, disabled: disabled);
    }
    return (label: item.toString(), value: item, disabled: false);
  }

  List<({String label, Object? value, bool disabled})> get _filtered {
    final all = _all;
    if (_keyword.isEmpty) return all;
    final kw = _keyword.toLowerCase();
    return [
      for (final o in all)
        if (o.label.toLowerCase().contains(kw)) o,
    ];
  }

  bool get _isCheckbox => widget.type == 'checkbox';

  List<Object?> get _checkedList => (_value is List) ? (_value! as List<Object?>) : [];

  bool _selected(Object? v) {
    if (_isCheckbox) return _checkedList.contains(v);
    return _value == v;
  }

  bool _locked(Object? v) {
    if (!_isCheckbox) return false;
    final list = _checkedList;
    final includes = list.contains(v);
    return (widget.max != null && !includes && list.length >= widget.max!) ||
        (widget.min != null && includes && list.length <= widget.min!);
  }

  void _onTap(Object? v) {
    if (_isCheckbox) {
      final list = [..._checkedList];
      if (list.contains(v)) {
        if (widget.min != null && list.length <= widget.min!) return;
        list.remove(v);
      } else {
        if (widget.max != null && list.length >= widget.max!) return;
        list.add(v);
      }
      setState(() => _value = list);
    } else {
      setState(() => _value = v);
      if (!widget.showConfirm) _confirm();
    }
  }

  Future<bool> _before() async {
    final bc = widget.beforeConfirm;
    if (bc == null) return true;
    final r = await bc(_value);
    return r;
  }

  Future<void> _confirm() async {
    if (widget.loading) return;
    final ok = await _before();
    if (!ok || !mounted) return;
    Navigator.of(context).pop(_value);
  }

  void _cancel() => Navigator.of(context).pop();

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? (_isCheckbox ? <Object?>[] : null);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = widget.color ?? scheme.primaryOf(6);
    final options = _filtered;

    return SizedBox(
      height: 430,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                InkWell(
                  onTap: _cancel,
                  child: Text('取消', style: TextStyle(fontSize: 14, color: scheme.textSecondary)),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: scheme.textMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (widget.showConfirm)
                  InkWell(
                    onTap: _confirm,
                    child: Text('确定', style: TextStyle(fontSize: 14, color: primary, fontWeight: FontWeight.w600)),
                  )
                else
                  const SizedBox(width: 28),
              ],
            ),
          ),
          if (widget.filterable)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: WotSearch(
                modelValue: _keyword.isEmpty ? null : _keyword,
                placeholder: '搜索',
                onChange: (v) => setState(() => _keyword = v),
              ),
            ),
          Container(height: 1, color: scheme.dividerLight),
          Expanded(child: _buildBody(scheme, primary, options)),
          Container(height: MediaQuery.of(context).padding.bottom, color: scheme.filledContent),
        ],
      ),
    );
  }

  Widget _buildBody(
    WotScheme scheme,
    Color primary,
    List<({String label, Object? value, bool disabled})> options,
  ) {
    final body = options.isEmpty
        ? WotEmpty(description: widget.emptyText)
        : ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: options.length,
            separatorBuilder: (_, i) => Container(height: 1, color: scheme.dividerLight),
            itemBuilder: (_, i) => _buildRow(scheme, primary, options[i]),
          );

    if (!widget.loading) return body;
    return Stack(
      children: [
        Positioned.fill(child: IgnorePointer(child: body)),
        Positioned.fill(
          child: ColoredBox(
            color: scheme.filledBottom.withValues(alpha: 0.5),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    WotScheme scheme,
    Color primary,
    ({String label, Object? value, bool disabled}) o,
  ) {
    final selected = _selected(o.value);
    final disabled = o.disabled || _locked(o.value);
    final textColor = disabled
        ? scheme.textDisabled
        : (selected ? scheme.textMain : scheme.textMain);

    return InkWell(
      onTap: (disabled || widget.loading) ? null : () => _onTap(o.value),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: selected ? scheme.filledContent : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Text(
                o.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: textColor),
              ),
            ),
            const SizedBox(width: 16),
            if (_isCheckbox)
              _checkbox(scheme, primary, selected, disabled)
            else
              _radio(scheme, primary, selected, disabled),
          ],
        ),
      ),
    );
  }

  Widget _radio(WotScheme scheme, Color primary, bool selected, bool disabled) {
    final dotColor = disabled ? scheme.textDisabled : primary;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? dotColor : (disabled ? scheme.borderLight : scheme.borderStrong),
          width: 1.4,
        ),
      ),
      child: selected
          ? Padding(
              padding: const EdgeInsets.all(4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
            )
          : null,
    );
  }

  Widget _checkbox(WotScheme scheme, Color primary, bool selected, bool disabled) {
    final boxColor = disabled ? scheme.textDisabled : primary;
    final check = selected
        ? const Padding(
            padding: EdgeInsets.all(3),
            child: Icon(Icons.check, size: 14, color: Colors.white),
          )
        : null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: selected ? boxColor : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: selected ? boxColor : (disabled ? scheme.borderLight : scheme.borderStrong),
          width: 1.4,
        ),
      ),
      child: check,
    );
  }
}