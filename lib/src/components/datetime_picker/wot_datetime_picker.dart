import 'package:flutter/material.dart';

import '../../theme/wot_state.dart';
import '../../locale/wot_messages.dart';
import '../../theme/wot_theme.dart';
import '../picker_view/wot_picker_view.dart';

/// 日期时间选择类型（对齐 wot `WotDatetimePickerType`）。
enum WotDatetimePickerType {
  date,

  /// 年月（year-month）。
  yearMonth,

  time,
  datetime,

  /// 月日（month-day）。
  monthDay,

  /// 仅年份（year）。
  year,
}

/// 日期时间选择器视图（内嵌滚轮，可选列），作为 picker 的日期特化。
class WotDatetimePickerView extends StatelessWidget {
  const WotDatetimePickerView({
    super.key,
    required this.modelValue,
    required this.onChange,
    this.type = WotDatetimePickerType.datetime,
    this.minYear = 1900,
    this.maxYear = 2100,
    this.color,
    this.height = 220,
    this.minDate,
    this.maxDate,
    this.minHour = 0,
    this.maxHour = 23,
    this.minMinute = 0,
    this.maxMinute = 59,
  });

  /// 当前选中值。
  final DateTime modelValue;

  /// 选中值变化回调（每次滚轮变化即触发）。
  final ValueChanged<DateTime> onChange;

  /// 选择器类型，可选 [WotDatetimePickerType]，默认 datetime（对齐 wot）。
  final WotDatetimePickerType type;

  /// 最小可选择年份，默认 1900。
  final int minYear;

  /// 最大可选择年份，默认 2100。
  final int maxYear;

  /// 选中项高亮颜色；为空时取主题主色。
  final Color? color;

  /// 滚轮区域高度（逻辑像素），默认 220。
  final double height;

  /// 受限可选范围的最小日期/时间；早于该值的选项将被置灰不可选。
  final DateTime? minDate;

  /// 受限可选范围的最大日期/时间；晚于该值的选项将被置灰不可选。
  final DateTime? maxDate;

  /// type 为 time 时生效，可选的最小小时，默认 0。
  final int minHour;

  /// type 为 time 时生效，可选的最大小时，默认 23。
  final int maxHour;

  /// type 为 time 时生效，可选的最小分钟，默认 0。
  final int minMinute;

  /// type 为 time 时生效，可选的最大分钟，默认 59。
  final int maxMinute;

  /// 生成 [minYear, maxYear] 区间内的年份选项。
  List<WotColumnOption> _years() {
    final minY = minDate != null && minDate!.year < maxYear ? minDate!.year : minYear;
    final maxY = maxDate != null && maxDate!.year > minYear ? maxDate!.year : maxYear;
    final from = minY;
    final to = maxY;
    return [
      for (var y = to; y >= from; y--)
        WotColumnOption(text: '$y 年', value: '$y', disabled: _yearDisabled(y)),
    ];
  }

  bool _yearDisabled(int y) {
    if (minDate == null && maxDate == null) return false;
    final minAct = minDate != null && DateTime(y, 12, 31).isBefore(minDate!);
    final maxAct = maxDate != null && DateTime(y, 1, 1).isAfter(maxDate!);
    return minAct || maxAct;
  }

  List<WotColumnOption> _months() {
    final selectedYear = modelValue.year;
    return [
      for (var m = 1; m <= 12; m++)
        WotColumnOption(text: '$m 月', value: '$m', disabled: _monthDisabled(selectedYear, m)),
    ];
  }

  bool _monthDisabled(int y, int m) {
    if (minDate == null && maxDate == null) return false;
    final lo = DateTime(y, m, _daysIn(y, m));
    final hi = DateTime(y, m, 1);
    if (minDate != null && lo.isBefore(minDate!)) return true;
    if (maxDate != null && hi.isAfter(maxDate!)) return true;
    return false;
  }

  int _daysIn(int y, int m) => DateTime(y, m + 1, 0).day;

  List<WotColumnOption> _days() {
    final maxDay = DateTime(modelValue.year, modelValue.month + 1, 0).day;
    return [
      for (var d = 1; d <= maxDay; d++)
        WotColumnOption(text: '$d 日', value: '$d', disabled: _dayDisabled(d)),
    ];
  }

  bool _dayDisabled(int d) {
    final sel = DateTime.utc(modelValue.year, modelValue.month, d);
    if (minDate != null && minDate!.isAfter(sel)) return true;
    if (maxDate != null && maxDate!.isBefore(sel)) return true;
    return false;
  }

  List<WotColumnOption> _hours() {
    final lo = minDate != null && type == WotDatetimePickerType.time && minDate!.hour > minHour
        ? minDate!.hour
        : minHour;
    final hi = maxDate != null && type == WotDatetimePickerType.time && maxDate!.hour < maxHour
        ? maxDate!.hour
        : maxHour;
    final lowBound = lo.clamp(minHour, maxHour).toInt();
    final highBound = hi.clamp(minHour, maxHour).toInt();
    return [for (var h = lowBound; h <= highBound; h++) WotColumnOption(text: _pad(h), value: '$h')];
  }

  List<WotColumnOption> _minutes() {
    final lo = minDate != null && type == WotDatetimePickerType.time && minDate!.minute > minMinute
        ? minDate!.minute
        : minMinute;
    final hi = maxDate != null && type == WotDatetimePickerType.time && maxDate!.minute < maxMinute
        ? maxDate!.minute
        : maxMinute;
    final lowBound = lo.clamp(minMinute, maxMinute).toInt();
    final highBound = hi.clamp(minMinute, maxMinute).toInt();
    return [for (var m = lowBound; m <= highBound; m++) WotColumnOption(text: _pad(m), value: '$m')];
  }

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
    } else if (type == WotDatetimePickerType.year) {
      columns.add(_years());
      values.add('${modelValue.year}');
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
    if (type == WotDatetimePickerType.year) {
      maybe(0, (s) => y = int.parse(s));
      // 跨年时受 min-month 约束，保留现有月份与日期。
      return DateTime(y, mo, d, h, mi);
    }
    maybe(0, (s) => y = int.parse(s));
    maybe(1, (s) => mo = int.parse(s));
    maybe(2, (s) => d = int.parse(s));
    // 修正：目标月天数可能少于当前选中日（如 3-31 切到 2 月），
    // 需钳制到该月最后一天，避免 DateTime 静默进位成下个月导致错位。
    final maxDay = DateTime(y, mo + 1, 0).day;
    if (d > maxDay) d = maxDay;
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
    this.confirmText,
    this.cancelText,
    this.type = WotDatetimePickerType.datetime,
    this.color,
    this.minDate,
    this.maxDate,
    this.minHour = 0,
    this.maxHour = 23,
    this.minMinute = 0,
    this.maxMinute = 59,
    this.minYear = 1900,
    this.maxYear = 2100,
    this.onConfirm,
    this.onCancel,
    this.disabled = false,
    this.readonly = false,
  });

  /// 初始选中时间；为空时取当前时间。
  final DateTime? modelValue;

  /// 选中值变化回调（每次滚轮变化即触发）。
  final ValueChanged<DateTime>? onChange;

  /// 弹出层标题。
  final String? title;

  /// 确认按钮文案，默认“确定”。
  final String? confirmText;

  /// 取消按钮文案，默认“取消”。
  final String? cancelText;

  /// 选择器类型，可选 [WotDatetimePickerType]，默认 datetime（对齐 wot）。
  final WotDatetimePickerType type;

  /// 是否禁用（锁滚轮交互并整体淡化），默认 false。
  final bool disabled;

  /// 是否只读：锁滚轮交互但保持正常配色（仅供查看当前值），默认 false。
  final bool readonly;

  /// 确认按钮高亮颜色；为空时取主题主色。
  final Color? color;

  /// 可选范围的最小日期/时间；早于该值的选项被置灰。
  final DateTime? minDate;

  /// 可选范围的最大日期/时间；晚于该值的选项被置灰。
  final DateTime? maxDate;

  /// type 为 time 时生效，可选的最小小时，默认 0。
  final int minHour;

  /// type 为 time 时生效，可选的最大小时，默认 23。
  final int maxHour;

  /// type 为 time 时生效，可选的最小分钟，默认 0。
  final int minMinute;

  /// type 为 time 时生效，可选的最大分钟，默认 59。
  final int maxMinute;

  /// 年份列的最小可选年份，默认 1900。
  final int minYear;

  /// 年份列的最大可选年份，默认 2100。
  final int maxYear;

  /// 点击确认按钮时触发的回调，参数为确认时的当前值。
  final ValueChanged<DateTime>? onConfirm;

  /// 点击取消（或关闭且未确认）时触发的回调。
  final VoidCallback? onCancel;

  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? modelValue,
    String? title,
    WotDatetimePickerType type = WotDatetimePickerType.datetime,
    Color? color,
    DateTime? minDate,
    DateTime? maxDate,
    int minHour = 0,
    int maxHour = 23,
    int minMinute = 0,
    int maxMinute = 59,
    bool disabled = false,
    bool readonly = false,
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
        minDate: minDate,
        maxDate: maxDate,
        minHour: minHour,
        maxHour: maxHour,
        minMinute: minMinute,
        maxMinute: maxMinute,
        disabled: disabled,
        readonly: readonly,
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
    // 弹层形态三态：readonly 锁滚轮交互、配色不变；disabled 额外整体淡化。
    final fieldScope = WotFieldScope.of(context);
    final disabled = widget.disabled || (fieldScope?.state == WotFieldState.disabled);
    final readonly = widget.readonly || (fieldScope?.state == WotFieldState.readonly);
    final locked = disabled || readonly;

    final view = WotDatetimePickerView(
      modelValue: _value,
      type: widget.type,
      color: primary,
      minYear: widget.minYear,
      maxYear: widget.maxYear,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      minHour: widget.minHour,
      maxHour: widget.maxHour,
      minMinute: widget.minMinute,
      maxMinute: widget.maxMinute,
      onChange: (v) {
        setState(() => _value = v);
        widget.onChange?.call(v);
      },
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  widget.onCancel?.call();
                  Navigator.of(context).pop();
                },
                child: Text(widget.cancelText ?? tr(context, 'wot.common.cancel'),
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
                  widget.onConfirm?.call(_value);
                  widget.onChange?.call(_value);
                  Navigator.of(context).pop(_value);
                },
                child: Text(widget.confirmText ?? tr(context, 'wot.common.confirm'),
                    style: TextStyle(fontSize: 14, color: primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        locked ? IgnorePointer(child: view) : view,
        Container(height: MediaQuery.of(context).padding.bottom, color: scheme.filledContent),
      ],
    );
    return disabled ? Opacity(opacity: 0.5, child: content) : content;
  }
}