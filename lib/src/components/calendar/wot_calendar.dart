import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';
import '../picker_view/wot_picker_view.dart';

/// 日历选择类型，对应 wot `wd-calendar` 的 type。
enum WotCalendarType {
  /// 单选某一天。
  single,

  /// 多选，可高亮多个日期。
  multiple,

  /// 区间，选择起止日期。
  range,
}

/// 日历选择器（底部弹层），对应 wot `wd-calendar`。
///
/// 通过 [WotCalendar.show] 弹出月历选择单日。返回选中 [DateTime]；取消返回 null。
///
/// 单选时（[WotCalendarType.single]）通过 [modelValue]/[onChange]（返回 [DateTime]）交互；
/// 多选/区间时通过 [onConfirm] 回调获取结果（[List&lt;DateTime&gt;]）。
/// 兼容既有：单选模式不改变原有 [modelValue] 的 [DateTime]? 语义。
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
    this.type = WotCalendarType.single,
    this.initialValues,
    this.onConfirm,
    this.onCancel,
  });

  /// 当前选中日期（v-model，仅对单选 [WotCalendarType.single] 生效）。
  final DateTime? modelValue;

  /// 确定选中单日时触发的回调。
  final ValueChanged<DateTime>? onChange;

  /// 标题文案，默认「选择日期」。
  final String title;

  /// 确认按钮文案，默认「确定」。
  final String confirmText;

  /// 取消按钮文案，默认「取消」。
  final String cancelText;

  /// 可选日期范围的最小日期。
  final DateTime? minDate;

  /// 可选日期范围的最大日期。
  final DateTime? maxDate;

  /// 主题色，覆盖默认主色。
  final Color? color;

  /// 选择类型：单选/多选/区间，默认单选。
  final WotCalendarType type;

  /// 多选/区间模式的初始选中日期（可选），仅在该两种类型下生效。
  final List<DateTime>? initialValues;

  /// 点击确认时触发的回调。
  /// 参数为目标值：单选为 [DateTime]，多选/区间为 [List]&lt;[DateTime]&gt;。
  final ValueChanged<Object>? onConfirm;

  /// 点击取消（或关闭且未确认）时触发的回调。
  final VoidCallback? onCancel;

  static Future<DateTime?> show(
    BuildContext context, {
    /// 初始选中的日期（可选）。
    DateTime? modelValue,

    /// 标题文案，默认「选择日期」。
    String? title,

    /// 可选日期范围的最小日期。
    DateTime? minDate,

    /// 可选日期范围的最大日期。
    DateTime? maxDate,

    /// 主题色，覆盖默认主色。
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
      type: type,
      initialValues: initialValues,
      onChange: onChange,
      onConfirm: onConfirm,
      onCancel: onCancel,
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
    this.type = WotCalendarType.single,
    this.initialValues,
    this.onConfirm,
    this.onCancel,
  });
  final DateTime? modelValue;
  final ValueChanged<DateTime>? onChange;
  final String title;
  final String confirmText;
  final String cancelText;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Color? color;
  final WotCalendarType type;
  final List<DateTime>? initialValues;
  final ValueChanged<Object>? onConfirm;
  final VoidCallback? onCancel;

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  DateTime? _value; // single 选中值。
  final Set<DateTime> _multi = {}; // multiple 选中集合（按日归一化）。
  DateTime? _rangeStart; // range 区间起点。
  DateTime? _rangeEnd; // range 区间终点。

  @override
  void initState() {
    super.initState();
    _value = widget.modelValue ?? DateTime.now();
    for (final d in widget.initialValues ?? const <DateTime>[]) {
      _addDay(_multi, d);
    }
    if (widget.type == WotCalendarType.range && widget.initialValues != null) {
      if (widget.initialValues!.isNotEmpty) _rangeStart = _day(widget.initialValues!.first);
      if (widget.initialValues!.length > 1) _rangeEnd = _day(widget.initialValues![1]);
    }
  }

  /// 归一化为当日零点（用于集合比较与按日定位）。
  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  void _addDay(Set<DateTime> s, DateTime d) {
    final k = _day(d);
    // 去重按日，避免 time 分量导致 Set 误判。
    s.removeWhere((e) => e.isAtSameMomentAs(k));
    s.add(k);
  }

  void _onDayClick(DateTime date) {
    setState(() {
      switch (widget.type) {
        case WotCalendarType.multiple:
          final k = _day(date);
          // 已选中则取消，否则选中（去重按日）。
          final hit = _multi.any((e) => e.isAtSameMomentAs(k));
          if (hit) {
            _multi.removeWhere((e) => e.isAtSameMomentAs(k));
          } else {
            _addDay(_multi, k);
          }
        case WotCalendarType.range:
          if (_rangeStart == null) {
            _rangeStart = _day(date);
            _rangeEnd = null;
          } else if (_rangeEnd == null) {
            if (date.isBefore(_rangeStart!)) {
              _rangeStart = _day(date);
            } else {
              _rangeEnd = _day(date);
            }
          } else {
            // 已成组：重新开始一段区间。
            _rangeStart = _day(date);
            _rangeEnd = null;
          }
        case WotCalendarType.single:
          _value = date;
      }
    });
  }

  Object _result() {
    switch (widget.type) {
      case WotCalendarType.single:
        return _value!;
      case WotCalendarType.multiple:
        final list = _multi.toList()..sort();
        return list;
      case WotCalendarType.range:
        final list = <DateTime>[_rangeStart!];
        if (_rangeEnd != null) list.add(_rangeEnd!);
        list.sort();
        return list;
    }
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
                  onTap: () {
                    widget.onCancel?.call();
                    Navigator.of(context).pop();
                  },
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
                    final result = _result();
                    if (widget.type == WotCalendarType.single) {
                      widget.onChange?.call(_value!);
                    }
                    widget.onConfirm?.call(result);
                    Navigator.of(context).pop(result);
                  },
                  child: Text(widget.confirmText,
                      style: TextStyle(fontSize: 14, color: primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _MonthGrid(
              type: widget.type,
              value: _value,
              multi: _multi,
              rangeStart: _rangeStart,
              rangeEnd: _rangeEnd,
              minDate: widget.minDate,
              maxDate: widget.maxDate,
              color: primary,
              onDay: _onDayClick,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// 月历网格（自绘，不引日期库），支持单选/多选/区间高亮。
class _MonthGrid extends StatefulWidget {
  const _MonthGrid({
    required this.type,
    this.value,
    required this.multi,
    this.rangeStart,
    this.rangeEnd,
    this.minDate,
    this.maxDate,
    required this.color,
    required this.onDay,
  });

  final WotCalendarType type;
  final DateTime? value;
  final Set<DateTime> multi;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Color color;
  final ValueChanged<DateTime> onDay;

  @override
  State<_MonthGrid> createState() => _MonthGridState();
}

class _MonthGridState extends State<_MonthGrid> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    // 以「初始选中/起点/第一个选中」所在月作为初始展示月，否则取当前月。
    final seed = widget.value ??
        (widget.rangeStart ??
            (widget.multi.isNotEmpty ? widget.multi.first : DateTime.now()));
    _year = seed.year;
    _month = seed.month;
  }

  int _weekdayIndex(DateTime d) => d.weekday - 1;

  int _daysInMonth(int y, int m) => DateTime(y, m + 1, 0).day;

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDisabled(DateTime d) {
    if (widget.minDate != null && d.isBefore(widget.minDate!)) return true;
    if (widget.maxDate != null && d.isAfter(widget.maxDate!)) return true;
    return false;
  }

  void _shift(int delta) {
    final d = DateTime(_year, _month + delta, 1);
    setState(() {
      _year = d.year;
      _month = d.month;
    });
  }

  /// 点击「X 年 Y 月」弹出年份/月份选择，用于快速跳转。
  Future<void> _openYearMonthPicker(BuildContext context) async {
    final yMin = widget.minDate?.year ?? (_year - 20);
    final yMax = widget.maxDate?.year ?? (_year + 20);
    final years = <WotColumnOption>[
      for (var y = yMin; y <= yMax; y++) WotColumnOption(text: '$y', value: y),
    ];
    final months = <WotColumnOption>[
      for (var m = 1; m <= 12; m++) WotColumnOption(text: '$m 月', value: m),
    ];
    final res = await showModalBottomSheet<List<Object?>>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => _YearMonthPicker(
        year: _year,
        month: _month,
        years: years,
        months: months,
        color: widget.color,
      ),
    );
    if (res == null || res.length < 2 || !mounted) return;
    final picked = DateTime((res[0] as num).toInt(), (res[1] as num).toInt(), 1);
    // 若结果超出 min/max 范围，夹取到一个合法月。
    var year = picked.year, month = picked.month;
    if (widget.minDate != null && picked.isBefore(widget.minDate!)) {
      year = widget.minDate!.year;
      month = widget.minDate!.month;
    }
    if (widget.maxDate != null && picked.isAfter(widget.maxDate!)) {
      year = widget.maxDate!.year;
      month = widget.maxDate!.month;
    }
    setState(() {
      _year = year;
      _month = month;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = widget.color;

    final firstDay = DateTime(_year, _month, 1);
    final leading = _weekdayIndex(firstDay);
    final daysInMonth = _daysInMonth(_year, _month);
    const totalCells = 42;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(onTap: () => _shift(-1), child: const Text('‹', style: TextStyle(fontSize: 20))),
            InkWell(
              onTap: () => _openYearMonthPicker(context),
              child: Text('$_year 年 $_month 月',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: scheme.textMain, fontWeight: FontWeight.w600)),
            ),
            InkWell(onTap: () => _shift(1), child: const Text('›', style: TextStyle(fontSize: 20))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final w in const ['一', '二', '三', '四', '五', '六', '日'])
              Expanded(
                child: Center(
                  child: Text(w, style: TextStyle(fontSize: 12, color: scheme.textAuxiliary)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final dayNum = index - leading + 1;
            if (dayNum < 1 || dayNum > daysInMonth) {
              return const SizedBox.shrink();
            }
            final date = DateTime(_year, _month, dayNum);
            final disabled = _isDisabled(date);
            return _cell(scheme, primary, date, disabled, dayNum);
          },
        ),
      ],
    );
  }

  Widget _cell(WotScheme scheme, Color primary, DateTime date, bool disabled, int dayNum) {
    final bool selectedSingle =
        widget.type == WotCalendarType.single && widget.value != null && _same(widget.value!, date);
    final bool multiSel = widget.multi.any((e) => _same(e, date));
    final isStart = widget.rangeStart != null && _same(widget.rangeStart!, date);
    final isEnd = widget.rangeEnd != null && _same(widget.rangeEnd!, date);

    if (widget.type == WotCalendarType.range &&
        widget.rangeStart != null && widget.rangeEnd != null) {
      final between = date.isAfter(widget.rangeStart!) && date.isBefore(widget.rangeEnd!);
      if (between) {
        // 区间中间日：淡色填充。
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: disabled ? null : () => widget.onDay(date),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(color: primary.withValues(alpha: 0.18)),
            child: Text('$dayNum',
                style: TextStyle(fontSize: 14, color: disabled ? scheme.textDisabled : scheme.textMain)),
          ),
        );
      }
    }

    final selected = selectedSingle || multiSel || isStart || isEnd;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : () => widget.onDay(date),
      child: Container(
        alignment: Alignment.center,
        decoration: selected ? BoxDecoration(color: primary, shape: BoxShape.circle) : null,
        child: Text(
          '$dayNum',
          style: TextStyle(
            fontSize: 14,
            color: selected
                ? Colors.white
                : (disabled ? scheme.textDisabled : scheme.textMain),
          ),
        ),
      ),
    );
  }
}

/// 年份/月份双列滚轮选择弹层，用于日历快速跳转。
class _YearMonthPicker extends StatefulWidget {
  const _YearMonthPicker({
    required this.year,
    required this.month,
    required this.years,
    required this.months,
    this.color,
  });

  final int year;
  final int month;
  final List<WotColumnOption> years;
  final List<WotColumnOption> months;
  final Color? color;

  @override
  State<_YearMonthPicker> createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<_YearMonthPicker> {
  late List<Object?> _values;
  late List<List<WotColumnOption>> _columns;

  @override
  void initState() {
    super.initState();
    _values = [widget.year, widget.month];
    _columns = [widget.years, widget.months];
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
                child: Text('取消',
                    style: TextStyle(fontSize: 14, color: scheme.textSecondary)),
              ),
              Expanded(
                child: Center(
                  child: Text('选择年月',
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
          height: 200,
          child: WotPickerView(
            columns: _columns,
            values: _values,
            color: primary,
            onChange: (v) => setState(() => _values = [...v]),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}