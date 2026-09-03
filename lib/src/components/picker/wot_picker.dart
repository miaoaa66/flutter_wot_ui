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
    this.onChange,
    this.title,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.color,
    this.disabled = false,
  });

  final List<List<WotColumnOption>> columns;
  final List<Object?> values;
  final ValueChanged<List<Object?>>? onConfirm;
  final ValueChanged<List<Object?>>? onChange;
  final String? title;
  final String confirmText;
  final String cancelText;
  final Color? color;
  final bool disabled;

  /// 命令式弹出并返回选中值列表；取消返回 null。
  static Future<List<Object?>?> show(
    BuildContext context, {
    required List<List<WotColumnOption>> columns,
    List<Object?> values = const [],
    String? title,
    Color? color,
  }) {
    return showModalBottomSheet<List<Object?>>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => WotPicker(columns: columns, values: values, title: title, color: color),
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
              InkWell(
                onTap: () => Navigator.of(context).pop(),
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
            onChange: (v) => setState(() => _values = v),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}

/// 便捷：文本列表转单列选项。
List<List<WotColumnOption>> wotSingleColumn(List<String> texts) =>
    [if (texts.isNotEmpty) [for (final t in texts) WotColumnOption(text: t, value: t)]];