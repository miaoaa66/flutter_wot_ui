import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';
import '../picker/wot_picker.dart';
import '../picker_view/wot_picker_view.dart';

/// 选择器（含触发显示），对应 wot `wd-select-picker`。
///
/// 渲染一个可点击的展示框，点击后弹出底部滚轮选择器。受控（v-model:value）。
class WotSelectPicker extends StatelessWidget {
  const WotSelectPicker({
    super.key,
    required this.columns,
    this.modelValue = const [],
    this.onChange,
    this.onConfirm,
    this.onCancel,
    this.title,
    this.placeholder = '请选择',
    this.disabled = false,
    this.loading = false,
    this.showCancel = true,
    this.color,
    this.name,
  });

  /// 列定义数据，每列一组 [WotColumnOption]（级联多列则多组）。
  final List<List<WotColumnOption>> columns;

  /// 当前选中的值列表（每列一个值），受控。
  final List<Object?> modelValue;

  /// 选中值变化回调。
  final ValueChanged<List<Object?>>? onChange;

  /// 点击确定并确认值回调。
  final ValueChanged<List<Object?>>? onConfirm;

  /// 点击取消（或蒙层关闭）时回调。
  final VoidCallback? onCancel;

  /// 弹出层顶部标题；不传则不显示。
  final String? title;

  /// 未选择任何项时的占位文本，默认「请选择」。
  final String placeholder;

  /// 是否禁用（不可点击弹出），默认 false。
  final bool disabled;

  /// 弹出时是否显示加载中状态（覆盖选项区域并禁用交互）。
  final bool loading;

  /// 弹出层是否显示取消按钮，默认 true。
  final bool showCancel;

  /// 展开箭头/图标颜色，默认使用主题辅助图标色。
  final Color? color;

  /// 表单字段名（用于原生表单提交示例）。
  final String? name;

  String _display() {
    final texts = <String>[];
    for (var i = 0; i < columns.length; i++) {
      if (i >= modelValue.length) continue;
      for (final o in columns[i]) {
        if (o.value == modelValue[i]) {
          texts.add(o.text);
          break;
        }
      }
    }
    return texts.join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final display = _display();
    return InkWell(
      onTap: disabled
          ? null
          : () async {
              final res = await WotPicker.show(
                context,
                columns: columns,
                values: modelValue,
                title: title,
                loading: loading,
                showCancel: showCancel,
                onConfirm: onConfirm,
                onCancel: onCancel,
              );
              if (res != null) {
                onChange?.call(res);
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: disabled ? scheme.borderLight : scheme.borderMain,
          ),
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
}