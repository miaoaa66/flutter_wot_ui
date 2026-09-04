import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 月历面板（自绘，不引日期库），作为 WotCalendar 的公共底座。
///
/// 周一为每周首日，默认展示当前月。支持单选某一天。
class WotCalendarView extends StatefulWidget {
  const WotCalendarView({
    super.key,
    this.year,
    this.month,
    this.modelValue,
    this.onDayClick,
    this.onMonthChange,
    this.minDate,
    this.maxDate,
    this.color,
    this.weekdays = const ['一', '二', '三', '四', '五', '六', '日'],
  });

  /// 初始年份，缺省取当前年。
  final int? year;

  /// 初始月份（1-12），缺省取当前月。
  final int? month;

  /// 当前选中日期（v-model）。
  final DateTime? modelValue;

  /// 点击某一天时触发的回调，参数为点击的日期。
  final ValueChanged<DateTime>? onDayClick;

  /// 切换年/月时触发的回调。
  final ValueChanged<DateTime>? onMonthChange;

  /// 可选日期范围的最小日期，早于该日期的日期不可选。
  final DateTime? minDate;

  /// 可选日期范围的最大日期，晚于该日期的日期不可选。
  final DateTime? maxDate;

  /// 主题色，覆盖默认主色。
  final Color? color;

  /// 周首行展示的星期文案，默认「一」~「日」。
  final List<String> weekdays;

  @override
  State<WotCalendarView> createState() => _WotCalendarViewState();
}

class _WotCalendarViewState extends State<WotCalendarView> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = widget.modelValue ?? DateTime.now();
    _year = widget.year ?? now.year;
    _month = widget.month ?? now.month;
  }

  @override
  void didUpdateWidget(WotCalendarView old) {
    super.didUpdateWidget(old);
    if (widget.year != null) _year = widget.year!;
    if (widget.month != null) _month = widget.month!;
  }

  /// 以周一起始的一周索引（周一=0 ... 周日=6）。
  int _weekdayIndex(DateTime d) => d.weekday - 1;

  void _shift(int delta) {
    final d = DateTime(_year, _month + delta, 1);
    setState(() {
      _year = d.year;
      _month = d.month;
    });
    widget.onMonthChange?.call(DateTime(_year, _month, 1));
  }

  int _daysInMonth(int y, int m) => DateTime(y, m + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = widget.color ?? scheme.primaryOf(6);

    // 当月第一天与开始时偏移。
    final firstDay = DateTime(_year, _month, 1);
    final leading = _weekdayIndex(firstDay);
    final daysInMonth = _daysInMonth(_year, _month);
    const totalCells = 42; // 固定 6 行 × 7 列。

    return Column(
      children: [
        // 标题：切换年/月。
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(onTap: () => _shift(-1), child: const WotIcon(name: 'arrow-left', size: 16)),
            Text('$_year 年 $_month 月',
                style: TextStyle(fontSize: 16, color: scheme.textMain, fontWeight: FontWeight.w600)),
            InkWell(onTap: () => _shift(1), child: const WotIcon(name: 'arrow-right', size: 16)),
          ],
        ),
        const SizedBox(height: 8),
        // 周首行。
        Row(
          children: [
            for (final w in widget.weekdays)
              Expanded(
                child: Center(
                  child: Text(w,
                      style: TextStyle(fontSize: 12, color: scheme.textAuxiliary)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // 日期网格（6 行 × 7 列）。
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
            final selected = widget.modelValue != null &&
                _isSameDay(widget.modelValue!, date);
            final disabled = _isDisabled(date);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: disabled ? null : () => widget.onDayClick?.call(date),
              child: Container(
                alignment: Alignment.center,
                decoration: selected
                    ? BoxDecoration(color: primary, shape: BoxShape.circle)
                    : null,
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
          },
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDisabled(DateTime d) {
    if (widget.minDate != null && d.isBefore(widget.minDate!)) return true;
    if (widget.maxDate != null && d.isAfter(widget.maxDate!)) return true;
    return false;
  }
}