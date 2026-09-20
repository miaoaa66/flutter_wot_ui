import 'package:flutter/material.dart';

import '../../theme/wot_state.dart';
import '../../locale/wot_messages.dart';
import '../../theme/wot_theme.dart';
import '../picker_view/wot_picker_view.dart';

/// 弹出选择器（弹层），对应 wot `wd-picker`。
///
/// 自建底部弹层（确定/取消工具栏 + 多列 [WotPickerView]）。典型用法：
/// 调用 [WotPicker.show] 命令式弹出，Future 返回选中的各列值。
class WotPicker extends StatefulWidget {
  const WotPicker({
    super.key,
    required this.columns,
    required this.values,
    this.onConfirm,
    this.onCancel,
    this.onChange,
    this.title,
    this.confirmText,
    this.cancelText,
    this.color,
    this.disabled = false,
    this.readonly = false,
    this.loading = false,
    this.showCancel = true,
  });

  /// 每列的选项列表（二维数组）。
  final List<List<WotColumnOption>> columns;

  /// 当前选中值列表（每列一个值），作为 `modelValue` 做值回显。
  final List<Object?> values;

  /// 点击确定（确认）时回调，参数为选中的各列值。
  final ValueChanged<List<Object?>>? onConfirm;

  /// 点击取消（或蒙层关闭）时回调。
  final VoidCallback? onCancel;

  /// 滚动出现选中值变化时回调，参数为当前各列值。
  final ValueChanged<List<Object?>>? onChange;

  /// 顶部大标题；不传则不显示标题。
  final String? title;

  /// 右侧确认按钮文案；默认「确定」。
  final String? confirmText;

  /// 左侧取消按钮文案；默认「取消」。
  final String? cancelText;

  /// 选中高亮/确认按钮颜色；不传时用主题主色。
  final Color? color;

  /// 是否禁用全部滚轮交互，并整体淡化。
  final bool disabled;

  /// 是否只读：锁滚轮交互但保持正常配色（仅供查看当前值），默认 false。
  final bool readonly;

  /// 是否显示加载中状态（覆盖选项区域并禁用交互）。
  final bool loading;

  /// 是否显示左侧取消按钮；默认 true。
  final bool showCancel;

  /// 命令式弹出并返回选中值列表；取消返回 null。
  static Future<List<Object?>?> show(
    BuildContext context, {
    required List<List<WotColumnOption>> columns,
    List<Object?> values = const [],
    String? title,
    Color? color,
    bool loading = false,
    bool showCancel = true,
    bool disabled = false,
    bool readonly = false,
    ValueChanged<List<Object?>>? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet<List<Object?>>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => WotPicker(
        columns: columns,
        values: values,
        title: title,
        color: color,
        loading: loading,
        showCancel: showCancel,
        disabled: disabled,
        readonly: readonly,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<WotPicker> createState() => _WotPickerState();
}

class _WotPickerState extends State<WotPicker> {
  late List<Object?> _values;

  @override
  void initState() {
    super.initState();
    _values = _clamp(widget.values, widget.columns);
  }

  @override
  void didUpdateWidget(WotPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部改变 values / columns 后需重新钳制，否则受控失效。
    // columns 是 List，未重写 ==，此处按引用比较即可。
    if (!_sameValues(oldWidget.values, widget.values) ||
        oldWidget.columns != widget.columns) {
      _values = _clamp(widget.values, widget.columns);
    }
  }

  static bool _sameValues(List<Object?> a, List<Object?> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// 保证每列值合法，非法时回退到列首项。
  static List<Object?> _clamp(List<Object?> v, List<List<WotColumnOption>> cols) {
    final out = <Object?>[];
    for (var i = 0; i < cols.length; i++) {
      if (cols[i].isEmpty) {
        out.add(null);
        continue;
      }
      final opt = i < v.length ? v[i] : null;
      out.add(cols[i].any((o) => o.value == opt) ? opt : cols[i].first.value);
    }
    return out;
  }

  void _confirm() {
    widget.onChange?.call(_values);
    widget.onConfirm?.call(_values);
    Navigator.of(context).pop(_values);
  }

  void _cancel() {
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = widget.color ?? scheme.primaryOf(6);
    // 弹层形态三态：readonly 锁滚轮交互、配色不变；disabled 额外整体淡化。
    final fieldScope = WotFieldScope.of(context);
    final disabled = widget.disabled || (fieldScope?.state == WotFieldState.disabled);
    final readonly = widget.readonly || (fieldScope?.state == WotFieldState.readonly);
    final locked = disabled || readonly;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (widget.showCancel)
                InkWell(
                  onTap: _cancel,
                  child: Text(widget.cancelText ?? tr(context, 'wot.common.cancel'),
                      style: TextStyle(fontSize: 14, color: scheme.textSecondary)),
                ),
              Expanded(
                child: Center(
                  child: Text(
                    widget.title ?? '',
                    style: TextStyle(fontSize: 16, color: scheme.textMain, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              InkWell(
                onTap: _confirm,
                child: Text(widget.confirmText ?? tr(context, 'wot.common.confirm'),
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
            disabled: locked,
            loading: widget.loading,
            onChange: (v) => setState(() => _values = v),
          ),
        ),
        Container(height: MediaQuery.of(context).padding.bottom, color: scheme.filledContent),
      ],
    );
    return disabled ? Opacity(opacity: 0.5, child: content) : content;
  }
}

/// 便捷：文本列表转单列选项。
List<List<WotColumnOption>> wotSingleColumn(List<String> texts) =>
    [if (texts.isNotEmpty) [for (final t in texts) WotColumnOption(text: t, value: t)]];