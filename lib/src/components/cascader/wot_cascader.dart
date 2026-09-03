import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';
import '../picker_view/wot_picker_view.dart';

/// 级联选项节点。
class WotCascadeOption {
  const WotCascadeOption({required this.text, this.value, this.children = const []});
  final String text;
  final Object? value;
  final List<WotCascadeOption> children;
}

/// 级联选择器，对应 wot `wd-cascader`。
///
/// 输入一棵层次树，点击后弹出底部级联滚轮；每列切换会重置后续列到子级首项。
class WotCascader extends StatelessWidget {
  const WotCascader({
    super.key,
    this.modelValue = const [],
    this.onChange,
    this.placeholder = '请选择',
    this.disabled = false,
    this.color,
    this.name,
    this.options = const [],
  });

  /// 当前选中路径值数组。
  final List<Object?> modelValue;
  final ValueChanged<List<Object?>>? onChange;
  final String placeholder;
  final bool disabled;
  final Color? color;
  final String? name;

  /// 根级选项。
  final List<WotCascadeOption> options;

  List<List<WotColumnOption>> _resolveLevels() {
    final levels = <List<WotColumnOption>>[];
    var nodes = options;
    for (var i = 0; i < _maxDepth(options); i++) {
      if (nodes.isEmpty) break;
      levels.add([for (final n in nodes) WotColumnOption(text: n.text, value: n.value)]);
      // 依据 modelValue 定位当前层节点以确定子级。
      nodes = i < modelValue.length
          ? (_find(nodes, modelValue[i])?.children ?? const [])
          : (nodes.first.children);
    }
    return levels;
  }

  WotCascadeOption? _find(List<WotCascadeOption> nodes, Object? value) {
    for (final n in nodes) {
      if (n.value == value) return n;
    }
    return null;
  }

  int _maxDepth(List<WotCascadeOption> nodes) {
    var d = 1;
    for (final n in nodes) {
      if (n.children.isNotEmpty) d = d > 1 + _maxDepth(n.children) ? d : 1 + _maxDepth(n.children);
    }
    return d;
  }

  List<Object?> _defaultPath() {
    final path = <Object?>[];
    var nodes = options;
    while (nodes.isNotEmpty) {
      final first = nodes.first;
      path.add(first.value);
      nodes = first.children;
    }
    return path;
  }

  String _display() {
    final parts = <String>[];
    var nodes = options;
    for (final v in modelValue) {
      final n = _find(nodes, v);
      if (n == null) break;
      parts.add(n.text);
      nodes = n.children;
    }
    return parts.join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final display = _display();
    return InkWell(
      onTap: disabled
          ? null
          : () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: disabled ? scheme.borderLight : scheme.borderMain),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                display.isEmpty ? placeholder : display,
                style: TextStyle(
                  fontSize: 14,
                  color: display.isEmpty ? scheme.textPlaceholder : scheme.textMain,
                ),
              ),
            ),
            WotIcon(name: 'arrow-down', size: 14, color: scheme.iconAuxiliary),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) async {
    final levels = _resolveLevels();
    final res = await showModalBottomSheet<List<Object?>>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => _CascaderSheet(
        columns: levels,
        values: modelValue.isEmpty ? _defaultPath() : modelValue,
      ),
    );
    if (res != null) onChange?.call(res);
  }
}

class _CascaderSheet extends StatefulWidget {
  const _CascaderSheet({required this.columns, required this.values});
  final List<List<WotColumnOption>> columns;
  final List<Object?> values;

  @override
  State<_CascaderSheet> createState() => _CascaderSheetState();
}

class _CascaderSheetState extends State<_CascaderSheet> {
  late List<Object?> _values;

  @override
  void initState() {
    super.initState();
    _values = [...widget.values];
    for (var i = 0; i < widget.columns.length; i++) {
      if (widget.columns[i].isEmpty) {
        while (_values.length <= i) {
          _values.add(null);
        }
        _values[i] = null;
      } else if (i >= _values.length || !widget.columns[i].any((o) => o.value == _values[i])) {
        while (_values.length <= i) {
          _values.add(null);
        }
        _values[i] = widget.columns[i].first.value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = scheme.primaryOf(6);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Text('取消',
                    style: TextStyle(fontSize: 14, color: scheme.textSecondary)),
              ),
              Expanded(
                child: Center(
                  child: Text('选择地区',
                      style: TextStyle(fontSize: 16, color: scheme.textMain, fontWeight: FontWeight.w600)),
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(_values),
                child: Text('确定',
                    style: TextStyle(fontSize: 14, color: primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: WotPickerView(
            columns: widget.columns,
            values: _values,
            color: primary,
            onChange: (v) => setState(() => _values = v),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}