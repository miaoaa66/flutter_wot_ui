import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';
import '../picker_view/wot_picker_view.dart';

/// 级联选项节点。
class WotCascadeOption {
  const WotCascadeOption({required this.text, this.value, this.children = const []});

  /// 节点显示文案。
  final String text;

  /// 节点值。
  final Object? value;

  /// 子级选项。
  final List<WotCascadeOption> children;
}

/// 级联选择器，对应 wot `wd-cascader`。
///
/// 输入一棵层次树，点击后弹出底部级联滚轮；每列切换会实时刷新后续列为
/// 当前选中节点的子级，并在叶子提前时自动收敛列数。
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

  /// 选中路径值变化时触发的回调。
  final ValueChanged<List<Object?>>? onChange;

  /// 未选择时展示的占位文案，默认「请选择」。
  final String placeholder;

  /// 是否禁用，禁用后不可点击，默认 false。
  final bool disabled;

  /// 主题色。
  final Color? color;

  /// 组件名称（表单标识，可选）。
  final String? name;

  /// 根级选项。
  final List<WotCascadeOption> options;

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

  WotCascadeOption? _find(List<WotCascadeOption> nodes, Object? value) {
    for (final n in nodes) {
      if (n.value == value) return n;
    }
    return null;
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
    final res = await showModalBottomSheet<List<Object?>>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => _CascaderSheet(options: options, values: modelValue),
    );
    if (res != null) onChange?.call(res);
  }
}

class _CascaderSheet extends StatefulWidget {
  const _CascaderSheet({required this.options, required this.values});
  final List<WotCascadeOption> options;
  final List<Object?> values;

  @override
  State<_CascaderSheet> createState() => _CascaderSheetState();
}

class _CascaderSheetState extends State<_CascaderSheet> {
  late List<Object?> _values;
  late List<List<WotColumnOption>> _levels;

  @override
  void initState() {
    super.initState();
    _values = [...widget.values];
    _resolveAll();
  }

  WotCascadeOption? _find(List<WotCascadeOption> nodes, Object? value) {
    for (final n in nodes) {
      if (n.value == value) return n;
    }
    return null;
  }

  /// 依据当前 [widget.options] 与 [widget.values] 解析出各层级列与合法选中值。
  void _resolveAll() {
    _levels = [];
    var nodes = widget.options;
    var i = 0;
    while (nodes.isNotEmpty) {
      _levels.add([for (final n in nodes) WotColumnOption(text: n.text, value: n.value)]);
      if (i >= _values.length) {
        // 缺省：回退到当前层首项并下钻。
        while (_values.length <= i) {
          _values.add(null);
        }
        _values[i] = nodes.first.value;
        nodes = nodes.first.children;
      } else {
        final n = _find(nodes, _values[i]);
        if (n == null) {
          _values[i] = nodes.first.value;
          nodes = nodes.first.children;
        } else {
          nodes = n.children;
        }
      }
      i++;
    }
    if (_values.length > _levels.length) {
      _values = _values.sublist(0, _levels.length);
    }
  }

  /// 第 [c] 列选中 [v] 后，联动刷新第 c 层及之后所有层。
  void _onColumnChange(int c, Object? v) {
    setState(() {
      _values[c] = v;
      // 从 c 指向的节点重新向下钻取，重建后续列。
      var childNodes = _columnNodes(c, v);
      var k = 0;
      while (childNodes.isNotEmpty) {
        final target = c + 1 + k;
        if (target >= _levels.length) {
          _levels.add([]);
        }
        _levels[target] = [
          for (final n in childNodes) WotColumnOption(text: n.text, value: n.value),
        ];
        while (_values.length <= target) {
          _values.add(null);
        }
        _values[target] = childNodes.first.value;
        childNodes = childNodes.first.children;
        k++;
      }
      // 叶子提前时，收敛多余的列与值。
      if (c + 1 < _levels.length) {
        _levels = _levels.sublist(0, c + 1 + k);
      }
      if (_values.length > _levels.length) {
        _values = _values.sublist(0, _levels.length);
      }
    });
  }

  /// 第 [c] 层的节点列表。
  List<WotCascadeOption> _columnNodes(int c, Object? value) {
    if (c == 0) return _find(widget.options, value)?.children ?? const [];
    var nodes = widget.options;
    for (var i = 0; i < c; i++) {
      if (nodes.isEmpty) return const [];
      final cur = _find(nodes, _values[i]) ?? nodes.first;
      nodes = cur.children;
    }
    if (nodes.isEmpty) return const [];
    final cur = _find(nodes, value) ?? nodes.first;
    return cur.children;
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
            columns: _levels,
            values: _values,
            color: primary,
            onChange: (v) {
              // _values 由底层按列序给出；据此联动。
              var changed = false;
              for (var i = 0; i < _levels.length; i++) {
                final nv = i < v.length ? v[i] : null;
                if (nv != _values[i]) {
                  _onColumnChange(i, nv);
                  changed = true;
                  break;
                }
              }
              if (!changed) setState(() {});
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}