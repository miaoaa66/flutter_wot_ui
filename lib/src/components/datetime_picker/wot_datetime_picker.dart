import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../picker_view/wot_picker_view.dart';

/// 日期时间选择类型（对齐 wot `WotDatetimePickerType`）。
enum WotDatetimePickerType {
  date,
  yearMonth,
  time,
  datetime,
  monthDay,
}

/// 日期时间选择器视图（内嵌滚轮，可选列），作为 picker 的日期特化。
class WotDatetimePickerView extends StatelessWidget {
  const WotDatetimePickerView({
    super.key,
    required this.modelValue,
    required this.onChange,
    this.type = WotDatetimePickerType.date,
    this.minYear = 1900,
    this.maxYear = 2100,
    this.color,
    this.height = 220,
  });

  final DateTime modelValue;
  final ValueChanged<DateTime> onChange;
  final WotDatetimePickerType type;
  final int minYear;
  final int maxYear;
  final Color? color;
  final double height;

  List<WotColumnOption> _years() => [
        for (var y = maxYear; y >= minYear; y--)
          WotColumnOption(text: '$y 年', value: '$y'),
      ];

  List<WotColumnOption> _months() =>
      [for (var m = 1; m <= 12; m++) WotColumnOption(text: '$m 月', value: '$m')];

  List<WotColumnOption> _days() {
    final maxDay = DateTime(modelValue.year, modelValue.month + 1, 0).day;
    return [for (var d = 1; d <= maxDay; d++) WotColumnOption(text: '$d 日', value: '$d')];
  }

  List<WotColumnOption> _hours() =>
      [for (var h = 0; h < 24; h++) WotColumnOption(text: _pad(h), value: '$h')];

  List<WotColumnOption> _minutes() =>
      [for (var m = 0; m < 60; m++) WotColumnOption(text: _pad(m), value: '$m')];

  String _pad(int n) => n.toString().padLeft(2, '0');

  bool _hasHours() => type == WotDatetimePickerType.time ||
      type == WotDatetimePickerType.datetime;

  bool _hasMinutes() => _hasHours();

  @override
  Widget build(BuildContext context) {
    final columns = <List<WotColumnOption>>[];
    final values = <Object?>[];

    if (type == WotDatetimePickerType.time) {
      columns.add(_hours());
      columns.add(_minutes());
      values.add('${modelValue.hour}');
      values.add('${modelValue.minute}');
    } else if (type == WotDatetimePickerType.yearMonth) {
      columns.add(_years());
      columns.add(_months());
      values.add('${modelValue.year}');
      values.add('${modelValue.month}');
    } else if (type == WotDatetimePickerType.monthDay) {
      columns.add(_months());
      columns.add(_days());
      values.add('${modelValue.month}');
      values.add('${modelValue.day}');
    } else {
      // date / datetime
      columns.add(_years());
      columns.add(_months());
      columns.add(_days());
      values.add('${modelValue.year}');
      values.add('${modelValue.month}');
      values.add('${modelValue.day}');
      if (_hasHours()) {
        columns.add(_hours());
        columns.add(_minutes());
        values.add('${modelValue.hour}');
        values.add('${modelValue.minute}');
      }
    }

    return WotPickerView(
      columns: columns,
      values: values,
      color: color,
      height: height,
      onChange: (v) => onChange(_apply(modelValue, v)),
    );
  }

  DateTime _apply(DateTime base, List<Object?> v) {
    var y = base.year;
    var mo = base.month;
    var d = base.day;
    var h = base.hour;
    var mi = base.minute;
    void maybe(int i, void Function(String) f) {
      if (i < v.length && v[i] != null) f(v[i].toString());
    }

    if (type == WotDatetimePickerType.time) {
      maybe(0, (s) => h = int.parse(s));
      maybe(1, (s) => mi = int.parse(s));
      return DateTime(y, mo, d, h, mi);
    }
    if (type == WotDatetimePickerType.yearMonth) {
      maybe(0, (s) => y = int.parse(s));
      maybe(1, (s) => mo = int.parse(s));
      return DateTime(y, mo, 1);
    }
    if (type == WotDatetimePickerType.monthDay) {
      maybe(0, (s) => mo = int.parse(s));
      maybe(1, (s) => d = int.parse(s));
      return DateTime(y, mo, d);
    }
    maybe(0, (s) => y = int.parse(s));
    maybe(1, (s) => mo = int.parse(s));
    maybe(2, (s) => d = int.parse(s));
    if (_hasHours()) maybe(3, (s) => h = int.parse(s));
    if (_hasMinutes()) maybe(4, (s) => mi = int.parse(s));
    return DateTime(y, mo, d, h, mi);
  }
}

/// 日期时间选择器（底部弹层），对应 wot `wd-datetime-picker`。
class WotDatetimePicker extends StatefulWidget {
  const WotDatetimePicker({
    super.key,
    this.modelValue,
    this.onChange,
    this.title,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.type = WotDatetimePickerType.date,
    this.color,
  });

  final DateTime? modelValue;
  final ValueChanged<DateTime>? onChange;
  final String? title;
  final String confirmText;
  final String cancelText;
  final WotDatetimePickerType type;
  final Color? color;

  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? modelValue,
    String? title,
    WotDatetimePickerType type = WotDatetimePickerType.date,
    Color? color,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => WotDatetimePicker(
        modelValue: modelValue,
        title: title,
        type: type,
        color: color,
      ),
    );
  }

  @override
  State<WotDatetimePicker> createState() => _WotDatetimePickerState();
}

class _WotDatetimePickerState extends State<WotDatetimePicker> {
  late DateTime _value;

  @override
  void initState() {
    super.initState();
    _value = widget.modelValue ?? DateTime.now();
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
                  child: Text(widget.title ?? '',
                      style: TextStyle(fontSize: 16, color: scheme.textMain, fontWeight: FontWeight.w600)),
                ),
              ),
              InkWell(
                onTap: () {
                  widget.onChange?.call(_value);
                  Navigator.of(context).pop(_value);
                },
                child: Text(widget.confirmText,
                    style: TextStyle(fontSize: 14, color: primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        WotDatetimePickerView(
          modelValue: _value,
          type: widget.type,
          color: primary,
          onChange: (v) {
            setState(() => _value = v);
            widget.onChange?.call(v);
          },
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}