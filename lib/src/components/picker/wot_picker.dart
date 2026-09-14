import 'package:flutter/material.dart';

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
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.color,
    this.disabled = false,
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
  final String confirmText;

  /// 左侧取消按钮文案；默认「取消」。
  final String cancelText;

  /// 选中高亮/确认按钮颜色；不传时用主题主色。
  final Color? color;

  /// 是否禁用全部滚轮交互。
  final bool disabled;

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
    return Column(
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
                  child: Text(widget.cancelText,
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
                child: Text(widget.confirmText,
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
            disabled: widget.disabled,
            loading: widget.loading,
            onChange: (v) => setState(() => _values = v),
          ),
        ),
        Container(height: MediaQuery.of(context).padding.bottom, color: scheme.filledContent),
      ],
    );
  }
}

/// 便捷：文本列表转单列选项。
List<List<WotColumnOption>> wotSingleColumn(List<String> texts) =>
    [if (texts.isNotEmpty) [for (final t in texts) WotColumnOption(text: t, value: t)]];