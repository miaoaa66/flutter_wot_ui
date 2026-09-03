import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../calendar_view/wot_calendar_view.dart';

/// 日历选择器（底部弹层），对应 wot `wd-calendar`。
///
/// 通过 [WotCalendar.show] 弹出月历选择单日。返回选中 [DateTime]；取消返回 null。
class WotCalendar extends StatelessWidget {
  const WotCalendar({
    super.key,
    this.modelValue,
    this.onChange,
    this.title = '选择日期',
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.minDate,
    this.maxDate,
    this.color,
  });

  final DateTime? modelValue;
  final ValueChanged<DateTime>? onChange;
  final String title;
  final String confirmText;
  final String cancelText;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Color? color;

  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? modelValue,
    String? title,
    DateTime? minDate,
    DateTime? maxDate,
    Color? color,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => _CalendarSheet(
        modelValue: modelValue,
        title: title ?? '选择日期',
        minDate: minDate,
        maxDate: maxDate,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CalendarSheet(
      modelValue: modelValue,
      title: title,
      confirmText: confirmText,
      cancelText: cancelText,
      minDate: minDate,
      maxDate: maxDate,
      color: color,
      onChange: onChange,
    );
  }
}

class _CalendarSheet extends StatefulWidget {
  const _CalendarSheet({
    this.modelValue,
    this.onChange,
    this.title = '选择日期',
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.minDate,
    this.maxDate,
    this.color,
  });
  final DateTime? modelValue;
  final ValueChanged<DateTime>? onChange;
  final String title;
  final String confirmText;
  final String cancelText;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Color? color;

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  DateTime? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.modelValue ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = widget.color ?? scheme.primaryOf(6);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
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
                    child: Text(widget.title,
                        style: TextStyle(fontSize: 16, color: scheme.textMain, fontWeight: FontWeight.w600)),
                  ),
                ),
                InkWell(
                  onTap: () {
                    widget.onChange?.call(_value!);
                    Navigator.of(context).pop(_value);
                  },
                  child: Text(widget.confirmText,
                      style: TextStyle(fontSize: 14, color: primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: WotCalendarView(
              modelValue: _value,
              minDate: widget.minDate,
              maxDate: widget.maxDate,
              color: primary,
              onDayClick: (d) => setState(() => _value = d),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}