import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_state.dart';
import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

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
/// 输入一棵层次树，点击后弹出底部「Tabs + 列表」逐级选择器（对齐 wot 形态）：
/// 顶部一排 tab 对应每级已选路径，点 tab 可回看该级；主体为当前级选项的列表，
/// 点选非叶节点自动下钻到下一级，点选叶节点即确认关闭。右上角「确定」提交当前路径。
class WotCascader extends StatelessWidget {
  const WotCascader({
    super.key,
    this.modelValue = const [],
    this.onChange,
    this.placeholder = '请选择',
    this.disabled = false,
    this.readonly = false,
    this.error = false,
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

  /// 是否禁用，禁用后不可点击，默认 false。禁用时触发区灰化。
  final bool disabled;

  /// 是否只读：不可弹出选择，但触发区保持正常配色（只读展示当前值），默认 false。
  final bool readonly;

  /// 是否处于校验失败态（error 态）。命中时触发区描红边。
  final bool error;

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

    // 触发区是框类形态，套用框类三态规则：显式传参 > WotFieldScope 下发 > 默认。
    final fieldScope = WotFieldScope.of(context);
    final isDisabled = disabled || (fieldScope?.state == WotFieldState.disabled);
    final isReadonly = readonly || (fieldScope?.state == WotFieldState.readonly);
    final hasError = error || (fieldScope?.error ?? false);
    final state = isDisabled
        ? WotFieldState.disabled
        : isReadonly
            ? WotFieldState.readonly
            : WotFieldState.editable;
    final style = wotFieldStyle(
      scheme,
      state,
      error: hasError,
      baseBorder: scheme.borderMain,
    );
    // 禁用给浅灰底；只读 / 可编辑透明（只读额外去掉边框）。
    final bg = isDisabled ? style.background : scheme.borderZero;
    final auxIconColor = isDisabled ? scheme.iconDisabled : scheme.iconAuxiliary;

    return InkWell(
      onTap: (isDisabled || isReadonly) ? null : () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: style.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                display.isEmpty ? placeholder : display,
                style: TextStyle(
                  fontSize: 14,
                  color: display.isEmpty ? style.placeholder : style.text,
                ),
              ),
            ),
            WotIcon(name: 'arrow-down', size: 14, color: auxIconColor),
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
  /// 各层级节点集合（自动下钻到叶节点后收敛）。
  late List<List<WotCascadeOption>> _levels;

  /// 每级当前选中值。
  late List<Object?> _path;

  /// 当前激活的层级 tab（展示哪一级的列表）。
  late int _active;

  WotCascadeOption? _find(List<WotCascadeOption> nodes, Object? value) {
    for (final n in nodes) {
      if (n.value == value) return n;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _path = [];
    _levels = [];
    _active = 0;
    if (widget.options.isEmpty) return;
    if (widget.values.isEmpty) {
      // 空值：从顶层开始，不预选。
      _levels = [widget.options];
      return;
    }
    // 有回显值：尽量恢复选中路径（非法值回退到该层首项）。
    var nodes = widget.options;
    var i = 0;
    while (true) {
      _levels.add(nodes);
      final n = _find(nodes, widget.values[i]) ?? nodes.first;
      _path.add(n.value);
      i++;
      if (n.children.isEmpty || i >= widget.values.length) break;
      nodes = n.children;
    }
    _active = _path.length - 1;
  }

  /// 点选第 [d] 级选项 [v]；若为非叶节点则下钻到下一级，返回是否为叶节点。
  bool _onSelect(int d, Object? v) {
    final node = _find(_levels[d], v);
    final isLeaf = node == null || node.children.isEmpty;
    setState(() {
      while (_path.length <= d) {
        _path.add(null);
      }
      _path[d] = v;
      while (_path.length > d + 1) {
        _path.removeLast();
      }
      if (isLeaf) {
        if (_levels.length > d + 1) _levels = _levels.sublist(0, d + 1);
        _active = d;
      } else {
        final nxt = d + 1;
        while (_levels.length <= nxt) {
          _levels.add(<WotCascadeOption>[]);
        }
        _levels[nxt] = node.children;
        while (_path.length <= nxt) {
          _path.add(null);
        }
        _active = nxt;
      }
    });
    return isLeaf;
  }

  void _confirm() => Navigator.of(context).pop([..._path]);

  void _cancel() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = scheme.primaryOf(6);
    final current = _levels.isEmpty ? const <WotCascadeOption>[] : _levels[_active];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              InkWell(onTap: _cancel, child: Text('取消', style: TextStyle(fontSize: 14, color: scheme.textSecondary))),
              Expanded(
                child: Center(
                  child: Text('选择地区',
                      style: TextStyle(fontSize: 16, color: scheme.textMain, fontWeight: FontWeight.w600)),
                ),
              ),
              InkWell(onTap: _confirm, child: Text('确定', style: TextStyle(fontSize: 14, color: primary, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
        _buildTabs(scheme, primary),
        Container(height: 1, color: scheme.dividerLight),
        Expanded(
          child: _levels.isEmpty
              ? Center(child: Text('暂无数据', style: TextStyle(color: scheme.textAuxiliary)))
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: current.length,
                  separatorBuilder: (_, i) => Container(height: 1, color: scheme.dividerLight),
                  itemBuilder: (_, i) => _buildRow(scheme, primary, current[i]),
                ),
        ),
        Container(height: MediaQuery.of(context).padding.bottom, color: scheme.filledContent),
      ],
    );
  }

  Widget _buildTabs(WotScheme scheme, Color primary) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          for (var i = 0; i < _levels.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: InkWell(
                onTap: () => setState(() => _active = i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _labelOf(i),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        color: i == _active ? primary : scheme.textSecondary,
                        fontWeight: i == _active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2,
                      width: 24,
                      decoration: BoxDecoration(
                        color: i == _active ? primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _labelOf(int i) {
    if (i >= _path.length) return '请选择';
    final opt = _find(_levels[i], _path[i]);
    return opt?.text ?? '请选择';
  }

  Widget _buildRow(WotScheme scheme, Color primary, WotCascadeOption node) {
    final selected = _active < _path.length && _path[_active] == node.value;
    return InkWell(
      onTap: () {
        final isLeaf = _onSelect(_active, node.value);
        if (isLeaf) _confirm();
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: selected ? scheme.filledContent : Colors.transparent,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                node.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: selected ? primary : scheme.textMain,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (node.children.isNotEmpty)
              Icon(Icons.chevron_right, size: 16, color: scheme.iconAuxiliary),
          ],
        ),
      ),
    );
  }
}