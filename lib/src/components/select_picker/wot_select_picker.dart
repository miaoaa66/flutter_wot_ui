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
    this.placeholder = '请选择',
    this.disabled = false,
    this.showPickerView = false,
    this.color,
    this.name,
  });

  final List<List<WotColumnOption>> columns;
  final List<Object?> modelValue;
  final ValueChanged<List<Object?>>? onChange;
  final ValueChanged<List<Object?>>? onConfirm;
  final String placeholder;
  final bool disabled;
  final bool showPickerView;
  final Color? color;
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
              final res = await WotPicker.show(context, columns: columns, values: modelValue);
              if (res != null) {
                onChange?.call(res);
                onConfirm?.call(res);
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