import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';
import '../picker_view/wot_picker_view.dart';

/// 日历切换模式，对应 wot `switch-mode`。
enum WotCalendarSwitchMode {
  /// 平铺展示所有月份，不展示切换按钮（对应 wot `none`）。
  none,

  /// 支持按月切换，展示上个月/下个月按钮（对应 wot `month`）。
  month,

  /// 支持按年与按月切换，展示上一年/下一年、上个月/下个月（对应 wot `year-month`）。
  yearMonth,
}

/// 日历选择类型，对应 wot `wd-calendar` 的 type。
enum WotCalendarType {
  /// 单选某一天（wot `date`）。
  single,

  /// 多选，可高亮多个日期（wot `dates`）。
  multiple,

  /// 日期区间，选择起止日期（wot `daterange`）。
  range,

  /// 日期时间：选某一天并附带时分秒（wot `datetime`）。
  datetime,

  /// 日期时间区间：起止日期各带时分秒（wot `datetimerange`）。
  datetimeRange,

  /// 周选择：点选一周中的任一天即选中整周（wot `week`）。
  week,

  /// 月选择：在 12 个月格里选一月（wot `month`）。
  month,

  /// 周范围：选择起止周（wot `weekrange`）。
  weekRange,

  /// 月范围：选择起止月（wot `monthrange`）。
  monthRange,
}

/// 日历单元格格式化结果，对应 wot `CalendarDayItem`。
class WotCalendarDayItem {
  const WotCalendarDayItem({
    required this.text,
    this.topInfo,
    this.bottomInfo,
    this.disabled = false,
  });

  /// 日期主文本。
  final String text;

  /// 上方提示信息。
  final String? topInfo;

  /// 下方提示信息。
  final String? bottomInfo;

  /// 是否禁用。
  final bool disabled;
}

/// 日历格式化函数签名，对应 wot `CalendarFormatter`。
/// 接收 date 返回自定义单元格展示信息。
typedef WotCalendarFormatter = WotCalendarDayItem Function(DateTime date);

/// 范围选择内部显示格式化函数签名，对应 wot `CalendarInnerDisplayFormat`。
/// 返回要展示的字符串，null 使用默认格式。
typedef WotCalendarInnerDisplayFormat = String? Function(
  DateTime value,
  WotCalendarRangePosition rangePosition,
  WotCalendarType type,
);

/// 范围选择位置（开始/结束）。
enum WotCalendarRangePosition {
  /// 开始。
  start,

  /// 结束。
  end,
}

/// 快捷选项，对应 wot `shortcuts`。
class WotCalendarShortcut {
  const WotCalendarShortcut({
    required this.text,
    required this.value,
  });

  /// 展示文案。
  final String text;

  /// 对应值（单选返回 DateTime，范围返回 List<DateTime>）。
  final Object value;
}

/// 快捷选项点击回调，返回用户选择的值。
typedef WotCalendarOnShortcutClick = Object Function(WotCalendarShortcut shortcut, int index);

/// 确认前校验回调，返回 false 则阻止确认。
typedef WotCalendarBeforeConfirm = FutureOr<bool> Function(Object value);


/// 日历选择器（底部弹层），对应 wot `wd-calendar`。
///
/// 支持 9 种选择类型 [WotCalendarType]。单选（[WotCalendarType.single]）通过
/// [modelValue]/[onChange]（返回 [DateTime]）交互；其余类型通过 [onConfirm] 回调
/// 获取结果（多选/区间/周范围/月范围为 `List<DateTime>`，周/月/日期时间为 [DateTime]）。
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
    this.firstDayOfWeek = 1,
    this.formatter,
    this.innerDisplayFormat,
    this.maxRange,
    this.rangePrompt,
    this.allowSameDay = false,
    this.defaultTime,
    this.hideSecond = false,
    this.showConfirm = true,
    this.showTypeSwitch = false,
    this.shortcuts = const [],
    this.onShortcutClick,
    this.beforeConfirm,
    this.confirmLeft,
    this.confirmRight,
    this.switchMode = WotCalendarSwitchMode.month,
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

  /// 选择类型：默认单选。
  final WotCalendarType type;

  /// 多选/区间/周/月等模式的初始选中（可选）。
  final List<DateTime>? initialValues;

  /// 点击确认时触发的回调。单选为 [DateTime]，其余为 [List]&lt;[DateTime]&gt; 或 [DateTime]。
  final ValueChanged<Object>? onConfirm;

  /// 点击取消（或关闭且未确认）时触发的回调。
  final VoidCallback? onCancel;

  /// 周起始日：0=周日，1=周一（默认周一，对应 wot `first-day-of-week`）。
  final int firstDayOfWeek;

  /// 日期单元格格式化回调（对应 wot `formatter`）。
  final WotCalendarFormatter? formatter;

  /// 范围选择面板顶部起止文案自定义（对应 wot `inner-display-format`）。
  final WotCalendarInnerDisplayFormat? innerDisplayFormat;

  /// 范围类型最大可跨度天数（对应 wot `max-range`）。
  final int? maxRange;

  /// 超出最大跨度时的提示文案（对应 wot `range-prompt`）。
  final String? rangePrompt;

  /// 范围类型是否允许起止为同一天/周/月（对应 wot `allow-same-day`）。
  final bool allowSameDay;

  /// datetime / datetimeRange 的默认时分秒，如 '12:30' 或 ['12:30','12:30']（对应 wot `default-time`）。
  final Object? defaultTime;

  /// datetime 是否隐藏秒（对应 wot `hide-second`）。
  final bool hideSecond;

  /// 是否显示确认按钮（为 false 时选中即确认，对应 wot `show-confirm`）。
  final bool showConfirm;

  /// 是否显示日/周/月类型切换（对应 wot `show-type-switch`）。
  final bool showTypeSwitch;

  /// 快捷选项列表（对应 wot `shortcuts`）。
  final List<WotCalendarShortcut> shortcuts;

  /// 快捷选项点击回调（对应 wot `on-shortcuts-click`）。
  final WotCalendarOnShortcutClick? onShortcutClick;

  /// 确认前校验回调，返回 false 阻止确认（对应 wot `before-confirm`）。
  final WotCalendarBeforeConfirm? beforeConfirm;

  /// 确定按钮区域左侧拓展组件（对应 wot `confirm-left` 插槽）。
  final Widget? confirmLeft;

  /// 确定按钮区域右侧拓展组件（对应 wot `confirm-right` 插槽）。
  final Widget? confirmRight;

  /// 月份面板切换模式（对应 wot `switch-mode`）。
  final WotCalendarSwitchMode switchMode;

  /// 便捷静态方法：单选弹窗。等同于打开一个仅单选类型的日历。
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
      type: type,
      initialValues: initialValues,
      onChange: onChange,
      onConfirm: onConfirm,
      onCancel: onCancel,
      firstDayOfWeek: firstDayOfWeek,
      formatter: formatter,
      innerDisplayFormat: innerDisplayFormat,
      maxRange: maxRange,
      rangePrompt: rangePrompt,
      allowSameDay: allowSameDay,
      defaultTime: defaultTime,
      hideSecond: hideSecond,
      showConfirm: showConfirm,
      showTypeSwitch: showTypeSwitch,
      shortcuts: shortcuts,
      onShortcutClick: onShortcutClick,
      beforeConfirm: beforeConfirm,
      confirmLeft: confirmLeft,
      confirmRight: confirmRight,
      switchMode: switchMode,
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
    this.firstDayOfWeek = 1,
    this.formatter,
    this.innerDisplayFormat,
    this.maxRange,
    this.rangePrompt,
    this.allowSameDay = false,
    this.defaultTime,
    this.hideSecond = false,
    this.showConfirm = true,
    this.showTypeSwitch = false,
    this.shortcuts = const [],
    this.onShortcutClick,
    this.beforeConfirm,
    this.confirmLeft,
    this.confirmRight,
    this.switchMode = WotCalendarSwitchMode.month,
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
  final int firstDayOfWeek;
  final WotCalendarFormatter? formatter;
  final WotCalendarInnerDisplayFormat? innerDisplayFormat;
  final int? maxRange;
  final String? rangePrompt;
  final bool allowSameDay;
  final Object? defaultTime;
  final bool hideSecond;
  final bool showConfirm;
  final bool showTypeSwitch;
  final List<WotCalendarShortcut> shortcuts;
  final WotCalendarOnShortcutClick? onShortcutClick;
  final WotCalendarBeforeConfirm? beforeConfirm;
  final Widget? confirmLeft;
  final Widget? confirmRight;
  final WotCalendarSwitchMode switchMode;

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  DateTime? _value; // single / datetime / week 的选中日。
  final Set<DateTime> _multi = {}; // multiple 选中集合（按日归一化）。
  DateTime? _rangeStart; // range / datetimeRange / weekRange 起点。
  DateTime? _rangeEnd; // range / datetimeRange / weekRange 终点。
  DateTime? _mon; // month 选中月（当月初）。
  DateTime? _monStart; // monthRange 起始月。
  DateTime? _monEnd; // monthRange 结束月。
  late DateTime _time1; // datetime 时间分量。
  late DateTime _time2; // datetimeRange 结束时间分量。

  /// 当前生效类型：showTypeSwitch 时随 tab 切换，否则恒等于 widget.type。
  late WotCalendarType _activeType;

  /// 当前选中的 tab（仅 showTypeSwitch 时使用）。
  int _tab = 0;

  bool get _isTime => _activeType == WotCalendarType.datetime || _activeType == WotCalendarType.datetimeRange;

  bool get _isMonthType => _activeType == WotCalendarType.month || _activeType == WotCalendarType.monthRange;

  bool get _isRangeType =>
      _activeType == WotCalendarType.range ||
      _activeType == WotCalendarType.datetimeRange ||
      _activeType == WotCalendarType.weekRange ||
      _activeType == WotCalendarType.monthRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _activeType = widget.type;
    _time1 = now;
    _time2 = now;
    _parseDefaultTime();
    final seeds = widget.initialValues ?? const <DateTime>[];
    switch (widget.type) {
      case WotCalendarType.single:
      case WotCalendarType.week:
        _value = widget.modelValue ?? (seeds.isNotEmpty ? seeds.first : now);
        break;
      case WotCalendarType.datetime:
        _value = seeds.isNotEmpty ? seeds.first : now;
        break;
      case WotCalendarType.multiple:
        for (final d in seeds) {
          _addDay(_multi, d);
        }
        break;
      case WotCalendarType.range:
      case WotCalendarType.datetimeRange:
      case WotCalendarType.weekRange:
        if (seeds.isNotEmpty) _rangeStart = _day(seeds.first);
        if (seeds.length > 1) _rangeEnd = _day(seeds[1]);
        break;
      case WotCalendarType.month:
        _mon = seeds.isNotEmpty ? DateTime(seeds.first.year, seeds.first.month) : DateTime(now.year, now.month);
        break;
      case WotCalendarType.monthRange:
        if (seeds.isNotEmpty) _monStart = DateTime(seeds.first.year, seeds.first.month);
        if (seeds.length > 1) _monEnd = DateTime(seeds[1].year, seeds[1].month);
        break;
    }
  }

  /// 解析 default-time（'HH:mm' 或 'HH:mm:ss'），用于 datetime 初始时刻。
  void _parseDefaultTime() {
    final t = widget.defaultTime;
    DateTime? apply(String s, {bool isStart = true}) {
      final parts = s.split(':').map((e) => int.tryParse(e) ?? 0).toList();
      if (parts.isEmpty) return null;
      final h = parts.isNotEmpty ? parts[0].clamp(0, 23) : 0;
      final m = parts.length > 1 ? parts[1].clamp(0, 59) : 0;
      final sec = parts.length > 2 ? parts[2].clamp(0, 59) : 0;
      return DateTime(1, 1, 1, h, m, sec);
    }

    DateTime? t1, t2;
    if (t is String) {
      t1 = apply(t);
      t2 = apply(t);
    } else if (t is List) {
      if (t.isNotEmpty) t1 = apply(t[0].toString());
      if (t.length > 1) t2 = apply(t[1].toString());
    }
    if (t1 != null) _time1 = DateTime(1, 1, 1, t1.hour, t1.minute, t1.second);
    if (t2 != null) _time2 = DateTime(1, 1, 1, t2.hour, t2.minute, t2.second);
  }

  /// showTypeSwitch 的 tab 文案与类型映射（非 range 版本）。
  static const List<(String, WotCalendarType)> _plainTabs = [
    ('日', WotCalendarType.single),
    ('周', WotCalendarType.week),
    ('月', WotCalendarType.month),
  ];

  /// showTypeSwitch 的 tab 文案与类型映射（range 版本）。
  static const List<(String, WotCalendarType)> _rangeTabs = [
    ('日', WotCalendarType.range),
    ('周', WotCalendarType.weekRange),
    ('月', WotCalendarType.monthRange),
  ];

  List<(String, WotCalendarType)> get _tabs {
    final isBaseRange =
        widget.type == WotCalendarType.range ||
        widget.type == WotCalendarType.weekRange ||
        widget.type == WotCalendarType.monthRange ||
        widget.type == WotCalendarType.datetimeRange;
    return isBaseRange ? _rangeTabs : _plainTabs;
  }

  void _selectTab(int index) {
    final tabs = _tabs;
    if (index < 0 || index >= tabs.length) return;
    setState(() {
      _tab = index;
      _activeType = tabs[index].$2;
    });
  }

  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  void _addDay(Set<DateTime> s, DateTime d) {
    final k = _day(d);
    s.removeWhere((e) => e.isAtSameMomentAs(k));
    s.add(k);
  }

  /// 按 firstDayOfWeek 计算一周起点（firstDayOfWeek: 0=周日 … 6=周六）。
  DateTime _weekStart(DateTime d) {
    final first = widget.firstDayOfWeek;
    final offset = (d.weekday - first) % 7 == 0 ? 0 : ((d.weekday - first) % 7 + 7) % 7;
    return _day(d).subtract(Duration(days: offset));
  }

  DateTime _weekEnd(DateTime d) => _weekStart(d).add(const Duration(days: 6));

  /// 生成 [a]~[b]（含）连续日期集合。
  Set<DateTime> _daySpan(DateTime a, DateTime b) {
    final out = <DateTime>{};
    var cur = _day(a);
    final end = _day(b);
    while (!cur.isAfter(end)) {
      out.add(cur);
      cur = cur.add(const Duration(days: 1));
    }
    return out;
  }

  /// 生成 (a, b) 之间（不含两端）的连续日期集合。
  Set<DateTime> _daySpanBetween(DateTime a, DateTime b) {
    final out = <DateTime>{};
    var cur = _day(a).add(const Duration(days: 1));
    final end = _day(b);
    while (cur.isBefore(end)) {
      out.add(cur);
      cur = cur.add(const Duration(days: 1));
    }
    return out;
  }

  // ---------------- 选择行为 ----------------

  void _onDayClick(DateTime date) {
    if (!widget.allowSameDay && _isRangeType && _rangeStart != null && _rangeEnd == null && _isSameForType(date, _rangeStart!)) return;
    setState(() {
      switch (_activeType) {
        case WotCalendarType.multiple:
          final k = _day(date);
          final hit = _multi.any((e) => e.isAtSameMomentAs(k));
          if (hit) {
            _multi.removeWhere((e) => e.isAtSameMomentAs(k));
          } else {
            _addDay(_multi, k);
          }
          break;
        case WotCalendarType.range:
        case WotCalendarType.datetimeRange:
        case WotCalendarType.weekRange:
          _tapRange(date);
          break;
        case WotCalendarType.single:
        case WotCalendarType.week:
        case WotCalendarType.datetime:
          _value = _day(date);
          break;
        case WotCalendarType.month:
        case WotCalendarType.monthRange:
          break;
      }
    });
    _maybeAutoConfirm();
  }

  /// 判断两个日期是否在同一粒度（天/周）上相等，用于 allowSameDay 校验。
  bool _isSameForType(DateTime a, DateTime b) {
    switch (_activeType) {
      case WotCalendarType.weekRange:
        return _weekStart(a) == _weekStart(b);
      case WotCalendarType.monthRange:
        return a.year == b.year && a.month == b.month;
      default:
        return _day(a) == _day(b);
    }
  }

  void _tapRange(DateTime date) {
    if (_rangeStart == null) {
      _rangeStart = _day(date);
      _rangeEnd = null;
    } else if (_rangeEnd == null) {
      if (date.isBefore(_rangeStart!)) {
        _rangeStart = _day(date);
      } else {
        // maxRange 约束：跨度超过限制给出提示。
        final span = _rangeSpanDays(date, _rangeStart!);
        if (widget.maxRange != null && span > widget.maxRange!) {
          final prompt = widget.rangePrompt ?? '选择的天数不能超过 ${widget.maxRange} 天';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prompt), duration: const Duration(milliseconds: 1200)));
          return;
        }
        _rangeEnd = _day(date);
      }
    } else {
      _rangeStart = _day(date);
      _rangeEnd = null;
    }
  }

  /// 计算范围跨度（天），同一粒度为最小单位。
  int _rangeSpanDays(DateTime a, DateTime b) {
    switch (widget.type) {
      case WotCalendarType.weekRange:
        return _weekEnd(a).difference(_weekStart(b)).inDays + 1;
      case WotCalendarType.monthRange:
        return _weekEnd(a).difference(_weekStart(b)).inDays + 1;
      default:
        return _day(a).difference(_day(b)).inDays + 1;
    }
  }

  void _onMonthClick(DateTime m) {
    final k = DateTime(m.year, m.month);
    if (!widget.allowSameDay && _monStart != null && _monEnd == null && k.year == _monStart!.year && k.month == _monStart!.month) return;
    setState(() {
      switch (_activeType) {
        case WotCalendarType.month:
          _mon = k;
          break;
        case WotCalendarType.monthRange:
          if (_monStart == null) {
            _monStart = k;
            _monEnd = null;
          } else if (_monEnd == null) {
            if (k.isBefore(_monStart!)) {
              _monStart = k;
            } else {
              _monEnd = k;
            }
          } else {
            _monStart = k;
            _monEnd = null;
          }
          break;
        default:
          break;
      }
    });
    _maybeAutoConfirm();
  }

  /// 非确认模式（showConfirm=false）下，选择完成后自动确认。
  void _maybeAutoConfirm() {
    if (widget.showConfirm) return;
    final complete = _selectionComplete();
    if (complete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _confirm();
      });
    }
  }

  bool _selectionComplete() {
    switch (_activeType) {
      case WotCalendarType.single:
      case WotCalendarType.week:
      case WotCalendarType.datetime:
      case WotCalendarType.month:
        return _value != null || _mon != null;
      case WotCalendarType.multiple:
        return _multi.isNotEmpty;
      case WotCalendarType.range:
      case WotCalendarType.datetimeRange:
      case WotCalendarType.weekRange:
        return _rangeStart != null && _rangeEnd != null;
      case WotCalendarType.monthRange:
        return _monStart != null && _monEnd != null;
    }
  }

  // ---------------- 高亮与结果 ----------------

  /// full：选区（填充圆），light：中间带（淡色填充）。
  ({Set<DateTime> full, Set<DateTime> light}) _highlight() {
    final full = <DateTime>{};
    final light = <DateTime>{};
    switch (_activeType) {
      case WotCalendarType.single:
      case WotCalendarType.datetime:
        if (_value != null) full.add(_day(_value!));
        break;
      case WotCalendarType.multiple:
        full.addAll(_multi);
        break;
      case WotCalendarType.range:
      case WotCalendarType.datetimeRange:
        if (_rangeStart != null) full.add(_day(_rangeStart!));
        if (_rangeEnd != null) full.add(_day(_rangeEnd!));
        if (_rangeStart != null && _rangeEnd != null) {
          light.addAll(_daySpanBetween(_rangeStart!, _rangeEnd!));
        }
        break;
      case WotCalendarType.week:
        if (_value != null) full.addAll(_daySpan(_weekStart(_value!), _weekEnd(_value!)));
        break;
      case WotCalendarType.weekRange:
        if (_rangeStart != null) full.addAll(_daySpan(_weekStart(_rangeStart!), _weekEnd(_rangeStart!)));
        if (_rangeEnd != null) full.addAll(_daySpan(_weekStart(_rangeEnd!), _weekEnd(_rangeEnd!)));
        if (_rangeStart != null && _rangeEnd != null) {
          final a = _weekEnd(_rangeStart!);
          final b = _weekStart(_rangeEnd!);
          if (b.isAfter(a)) light.addAll(_daySpanBetween(a, b));
        }
        break;
      case WotCalendarType.month:
      case WotCalendarType.monthRange:
        break;
    }
    return (full: full, light: light);
  }

  Object _result() {
    switch (_activeType) {
      case WotCalendarType.single:
      case WotCalendarType.week:
        return _value ?? DateTime.now();
      case WotCalendarType.multiple:
        final list = _multi.toList()..sort();
        return list;
      case WotCalendarType.range:
      case WotCalendarType.weekRange:
        final list = <DateTime>[];
        if (_rangeStart != null) list.add(_rangeStart!);
        if (_rangeEnd != null) list.add(_rangeEnd!);
        list.sort();
        return list;
      case WotCalendarType.month:
        return _mon ?? DateTime.now();
      case WotCalendarType.monthRange:
        final list = <DateTime>[];
        if (_monStart != null) list.add(_monStart!);
        if (_monEnd != null) list.add(_monEnd!);
        list.sort();
        return list;
      case WotCalendarType.datetime:
        final d = _value ?? DateTime.now();
        return DateTime(d.year, d.month, d.day, _time1.hour, _time1.minute, _time1.second);
      case WotCalendarType.datetimeRange:
        final out = <DateTime>[];
        if (_rangeStart != null) {
          final d = _rangeStart!;
          out.add(DateTime(d.year, d.month, d.day, _time1.hour, _time1.minute, _time1.second));
        }
        if (_rangeEnd != null) {
          final d = _rangeEnd!;
          out.add(DateTime(d.year, d.month, d.day, _time2.hour, _time2.minute, _time2.second));
        }
        out.sort();
        return out;
    }
  }

  void _confirm() async {
    final result = _result();
    if (widget.beforeConfirm != null) {
      final ok = await widget.beforeConfirm!(result);
      if (!ok) return;
    }
    if (_activeType == WotCalendarType.single) {
      widget.onChange?.call(_value!);
    }
    widget.onConfirm?.call(result);
    if (mounted) Navigator.of(context).pop(result);
  }

  void _cancel() {
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  Widget _buildHeader(WotScheme scheme, Color primary) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          InkWell(onTap: _cancel, child: Text(widget.cancelText, style: TextStyle(fontSize: 14, color: scheme.textSecondary))),
          Expanded(
            child: Center(
              child: Text(widget.title, style: TextStyle(fontSize: 16, color: scheme.textMain, fontWeight: FontWeight.w600)),
            ),
          ),
          const Text('    '),
        ],
      ),
    );
  }

  /// 范围类型顶部起止回显（对应 wot 的 range 栏 + inner-display-format）。
  Widget? _buildRangeBar(WotScheme scheme) {
    if (!_isRangeType) return null;
    String textFor(DateTime? v, WotCalendarRangePosition pos) {
      if (v == null) return pos == WotCalendarRangePosition.start ? '开始' : '结束';
      final custom = widget.innerDisplayFormat?.call(v, pos, _activeType);
      if (custom != null) return custom;
      switch (_activeType) {
        case WotCalendarType.week:
        case WotCalendarType.weekRange:
          final week = (v.difference(DateTime(v.year, 1, 1)).inDays / 7).floor() + 1;
          return '${v.year}-W$week';
        case WotCalendarType.month:
        case WotCalendarType.monthRange:
          return '${v.year}-${v.month.toString().padLeft(2, '0')}';
        default:
          return '${v.year}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}';
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              textFor(_rangeStart, WotCalendarRangePosition.start),
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 13, color: _rangeStart == null ? scheme.textDisabled : scheme.textMain),
            ),
          ),
          Text('至', style: TextStyle(fontSize: 13, color: scheme.textAuxiliary)),
          Expanded(
            child: Text(
              textFor(_rangeEnd, WotCalendarRangePosition.end),
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 13, color: _rangeEnd == null ? scheme.textDisabled : scheme.textMain),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildTypeSwitch(WotScheme scheme, Color primary) {
    if (!widget.showTypeSwitch) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _tabs.length; i++)
            GestureDetector(
              onTap: () => _selectTab(i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: i == _tab ? BoxDecoration(color: primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)) : null,
                child: Text(
                  _tabs[i].$1,
                  style: TextStyle(fontSize: 13, color: i == _tab ? primary : scheme.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 快捷选项横向排布（对应 wot shortcuts）。
  Widget? _buildShortcuts(WotScheme scheme, Color primary) {
    if (widget.shortcuts.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SizedBox(
        height: 28,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: widget.shortcuts.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final s = widget.shortcuts[index];
            return GestureDetector(
              onTap: () => _handleShortcutClick(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Text(s.text, style: TextStyle(fontSize: 12, color: primary)),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 点击快捷项：调用 onShortcutClick（若提供）得到值并回填，否则直接用 shortcut.value。
  void _handleShortcutClick(int index) {
    final s = widget.shortcuts[index];
    final value = widget.onShortcutClick?.call(s, index) ?? s.value;
    if (value is DateTime) {
      setState(() => _value = _day(value));
    } else if (value is List) {
      final list = value.cast<DateTime>();
      setState(() {
        _rangeStart = list.isNotEmpty ? _day(list.first) : null;
        _rangeEnd = list.length > 1 ? _day(list[1]) : null;
      });
    }
    _maybeAutoConfirm();
  }

  Widget _buildConfirmArea(WotScheme scheme, Color primary) {
    if (!widget.showConfirm) {
      return widget.confirmLeft != null || widget.confirmRight != null
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(children: [if (widget.confirmLeft != null) widget.confirmLeft!, if (widget.confirmRight != null) widget.confirmRight!]),
            )
          : const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          if (widget.confirmLeft != null) widget.confirmLeft!,
          Expanded(
            child: InkWell(
              onTap: _confirm,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(8)),
                child: Text(widget.confirmText, style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          if (widget.confirmRight != null) widget.confirmRight!,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = widget.color ?? scheme.primaryOf(6);

    final list = <Widget>[
      _buildHeader(scheme, primary),
      if (_buildTypeSwitch(scheme, primary) case final w?) w,
      if (_buildShortcuts(scheme, primary) case final w2?) w2,
      if (_buildRangeBar(scheme) case final w3?) w3,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: _isMonthType ? _buildMonthBody(primary) : _buildDayBody(scheme, primary),
      ),
      _buildConfirmArea(scheme, primary),
    ];

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: list,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      // 外层弹层/窄屏下高度受限时改为内部滚动，避免 RenderFlex 溢出。
      child: LayoutBuilder(
        builder: (context, cons) {
          final availH = cons.maxHeight;
          if (availH.isFinite && availH > 0) {
            return SingleChildScrollView(child: content);
          }
          return content;
        },
      ),
    );
  }

  Widget _buildDayBody(WotScheme scheme, Color primary) {
    final h = _highlight();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MonthGrid(
          full: h.full,
          light: h.light,
          color: primary,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          firstDayOfWeek: widget.firstDayOfWeek,
          formatter: widget.formatter,
          switchMode: widget.switchMode,
          onDay: _onDayClick,
        ),
        if (_isTime) ...[
          const SizedBox(height: 8),
          _TimeRow(label: '开始时间', value: _time1, hideSecond: widget.hideSecond, color: primary, onChanged: (t) => setState(() => _time1 = t)),
          if (_activeType == WotCalendarType.datetimeRange) ...[
            const SizedBox(height: 4),
            _TimeRow(label: '结束时间', value: _time2, hideSecond: widget.hideSecond, color: primary, onChanged: (t) => setState(() => _time2 = t)),
          ],
        ],
      ],
    );
  }

  Widget _buildMonthBody(Color primary) {
    final isRange = _activeType == WotCalendarType.monthRange;
    return _MonthPickerGrid(
      value: _mon,
      start: _monStart,
      end: _monEnd,
      rangeMode: isRange,
      color: primary,
      onMonth: _onMonthClick,
    );
  }
}

/// 月历网格（自绘），跨月连续渲染，按 full（填充圆）/ light（中间带）高亮。
class _MonthGrid extends StatefulWidget {
  const _MonthGrid({
    required this.full,
    required this.light,
    required this.color,
    this.minDate,
    this.maxDate,
    this.firstDayOfWeek = 1,
    this.formatter,
    this.switchMode = WotCalendarSwitchMode.month,
    required this.onDay,
  });

  final Set<DateTime> full;
  final Set<DateTime> light;
  final Color color;
  final DateTime? minDate;
  final DateTime? maxDate;
  final int firstDayOfWeek;
  final WotCalendarFormatter? formatter;
  final WotCalendarSwitchMode switchMode;
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
    final seed = widget.full.isEmpty ? DateTime.now() : widget.full.first;
    _year = seed.year;
    _month = seed.month;
  }

  /// 按 firstDayOfWeek 计算某个日期在周内的偏移（firstDayOfWeek: 0=周日 … 6=周六）。
  int _weekdayIndex(DateTime d) {
    final first = widget.firstDayOfWeek;
    return (d.weekday - first) % 7 == 0 ? 0 : ((d.weekday - first) % 7 + 7) % 7;
  }

  /// 周表头文案，按 firstDayOfWeek 排列：'日','一',...,'六'（firstDayOfWeek=0）或 '一',...,'日'（=1）。
  List<String> get _weekLabels {
    const base = ['一', '二', '三', '四', '五', '六', '日'];
    if (widget.firstDayOfWeek == 0) {
      return ['日', ...base.take(6)];
    }
    return base;
  }

  bool _same(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDisabled(DateTime d) {
    if (widget.minDate != null && d.isBefore(widget.minDate!)) return true;
    if (widget.maxDate != null && d.isAfter(widget.maxDate!)) return true;
    final fmt = widget.formatter;
    if (fmt != null && fmt(d).disabled) return true;
    return false;
  }

  void _shift(int delta) {
    final d = DateTime(_year, _month + delta, 1);
    setState(() {
      _year = d.year;
      _month = d.month;
    });
  }

  /// switch-mode==yearMonth 时支持按年切换。
  void _shiftYear(int delta) {
    setState(() {
      _year += delta;
    });
  }

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
      builder: (_) => _YearMonthPicker(year: _year, month: _month, years: years, months: months, color: widget.color),
    );
    if (res == null || res.length < 2 || !mounted) return;
    final picked = DateTime((res[0] as num).toInt(), (res[1] as num).toInt(), 1);
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
    final firstDay = DateTime(_year, _month, 1);
    final leading = _weekdayIndex(firstDay);
    const totalCells = 42;

    // 头部左侧：month 模式显示上个月 ‹；year-month 模式下可显示上一年 ‹‹ + 上个月 ‹。
    final left = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.switchMode == WotCalendarSwitchMode.yearMonth)
          InkWell(onTap: () => _shiftYear(-1), child: const Text('‹‹', style: TextStyle(fontSize: 16))),
        if (widget.switchMode != WotCalendarSwitchMode.none)
          InkWell(onTap: () => _shift(-1), child: const Text('‹', style: TextStyle(fontSize: 20))),
      ],
    );
    final right = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.switchMode != WotCalendarSwitchMode.none)
          InkWell(onTap: () => _shift(1), child: const Text('›', style: TextStyle(fontSize: 20))),
        if (widget.switchMode == WotCalendarSwitchMode.yearMonth)
          InkWell(onTap: () => _shiftYear(1), child: const Text('››', style: TextStyle(fontSize: 16))),
      ],
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            left,
            InkWell(
              onTap: widget.switchMode == WotCalendarSwitchMode.none ? null : () => _openYearMonthPicker(context),
              child: Text('$_year 年 $_month 月', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: scheme.textMain, fontWeight: FontWeight.w600)),
            ),
            right,
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final w in _weekLabels)
              Expanded(child: Center(child: Text(w, style: TextStyle(fontSize: 12, color: scheme.textAuxiliary)))),
          ],
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.2),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            // 跨月连续：用 DateTime 归一化生成前一月/后一个月的补位日。
            final date = DateTime(_year, _month, index - leading + 1);
            final inMonth = date.year == _year && date.month == _month;
            final disabled = _isDisabled(date);
            return _cell(context, scheme, date, disabled, inMonth);
          },
        ),
      ],
    );
  }

  Widget _cell(BuildContext context, WotScheme scheme, DateTime date, bool disabled, bool inMonth) {
    final isFull = widget.full.any((e) => _same(e, date));
    final isLight = widget.light.any((e) => _same(e, date));
    final dim = disabled || !inMonth;

    // formatter 自定义展示：主文本 + 上下提示。未设置时默认显示日号。
    final fmt = widget.formatter?.call(date);
    final dayText = fmt?.text ?? '${date.day}';

    final body = isLight
        ? Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.18)),
            child: _dayTextContent(scheme, dayText, fmt, isFull: false, dim: dim),
          )
        : Container(
            alignment: Alignment.center,
            decoration: isFull ? BoxDecoration(color: widget.color, shape: BoxShape.circle) : null,
            child: _dayTextContent(scheme, dayText, fmt, isFull: isFull, dim: dim),
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (disabled || (fmt?.disabled ?? false)) ? null : () => _handleTap(date),
      child: body,
    );
  }

  /// 组合日号文本 + topInfo/bottomInfo。
  Widget _dayTextContent(WotScheme scheme, String dayText, WotCalendarDayItem? fmt, {required bool isFull, required bool dim}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (fmt?.topInfo != null)
          Text(fmt!.topInfo!, style: TextStyle(fontSize: 8, color: isFull ? Colors.white : scheme.textAuxiliary)),
        Text(
          dayText,
          style: TextStyle(
            fontSize: 14,
            color: isFull ? Colors.white : (dim ? scheme.textDisabled : scheme.textMain),
          ),
        ),
        if (fmt?.bottomInfo != null) Text(fmt!.bottomInfo!, style: TextStyle(fontSize: 8, color: isFull ? Colors.white : scheme.textAuxiliary)),
      ],
    );
  }

  /// 点击补位日时先切页到该日所在月，再回调选中。
  void _handleTap(DateTime date) {
    if (date.year != _year || date.month != _month) {
      setState(() {
        _year = date.year;
        _month = date.month;
      });
    }
    widget.onDay(date);
  }
}

/// 月选择网格（12 个月），支持单选/区间高亮。
class _MonthPickerGrid extends StatefulWidget {
  const _MonthPickerGrid({required this.value, required this.start, required this.end, required this.rangeMode, required this.color, required this.onMonth});
  final DateTime? value;
  final DateTime? start;
  final DateTime? end;
  final bool rangeMode;
  final Color color;
  final ValueChanged<DateTime> onMonth;

  @override
  State<_MonthPickerGrid> createState() => _MonthPickerGridState();
}

class _MonthPickerGridState extends State<_MonthPickerGrid> {
  late int _year;

  @override
  void initState() {
    super.initState();
    final seed = widget.value ?? widget.start ?? DateTime.now();
    _year = seed.year;
  }

  bool _same(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(onTap: () => setState(() => _year--), child: const Text('‹', style: TextStyle(fontSize: 20))),
            Text('$_year 年', style: TextStyle(fontSize: 16, color: scheme.textMain, fontWeight: FontWeight.w600)),
            InkWell(onTap: () => setState(() => _year++), child: const Text('›', style: TextStyle(fontSize: 20))),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.6),
          itemCount: 12,
          itemBuilder: (context, i) {
            final m = DateTime(_year, i + 1);
            final isStart = widget.rangeMode && widget.start != null && _same(widget.start!, m);
            final isEnd = widget.rangeMode && widget.end != null && _same(widget.end!, m);
            final isSel = !widget.rangeMode && widget.value != null && _same(widget.value!, m);
            final isBetween = widget.rangeMode && widget.start != null && widget.end != null && m.isAfter(widget.start!) && m.isBefore(widget.end!);
            if (isBetween) {
              return InkWell(
                onTap: () => widget.onMonth(m),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.18)),
                  child: Text('${i + 1}月', style: TextStyle(fontSize: 13, color: scheme.textMain)),
                ),
              );
            }
            final selected = isStart || isEnd || isSel;
            return InkWell(
              onTap: () => widget.onMonth(m),
              child: Container(
                alignment: Alignment.center,
                decoration: selected ? BoxDecoration(color: widget.color, shape: BoxShape.circle) : null,
                child: Text('${i + 1}月', style: TextStyle(fontSize: 13, color: selected ? Colors.white : scheme.textMain)),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// 时分秒滚轮行，用于 datetime / datetimeRange。
class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.label, required this.value, this.hideSecond = false, required this.color, required this.onChanged});
  final String label;
  final DateTime value;
  final bool hideSecond;
  final Color color;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final hours = [for (var i = 0; i < 24; i++) WotColumnOption(text: '$i', value: i)];
    final mins = [for (var i = 0; i < 60; i++) WotColumnOption(text: '$i', value: i)];
    final seconds = [for (var i = 0; i < 60; i++) WotColumnOption(text: '$i', value: i)];
    final columns = hideSecond ? [hours, mins] : [hours, mins, seconds];
    final values = hideSecond ? [value.hour, value.minute] : [value.hour, value.minute, value.second];
    return Row(
      children: [
        SizedBox(width: 56, child: Text(label, style: TextStyle(fontSize: 12, color: scheme.textAuxiliary))),
        Expanded(
          child: SizedBox(
            height: 120,
            child: WotPickerView(
              columns: columns,
              values: values,
              color: color,
              height: 120,
              onChange: (v) {
                final h = (v[0] as num).toInt();
                final m = (v[1] as num).toInt();
                final s = v.length > 2 ? (v[2] as num).toInt() : 0;
                onChanged(DateTime(1, 1, 1, h, m, s));
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// 年份/月份双列滚轮选择弹层，用于日历快速跳转。
class _YearMonthPicker extends StatefulWidget {
  const _YearMonthPicker({required this.year, required this.month, required this.years, required this.months, this.color});
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
              InkWell(onTap: () => Navigator.of(context).pop(), child: Text('取消', style: TextStyle(fontSize: 14, color: scheme.textSecondary))),
              Expanded(child: Center(child: Text('选择年月', style: TextStyle(fontSize: 16, color: scheme.textMain, fontWeight: FontWeight.w600)))),
              InkWell(onTap: () => Navigator.of(context).pop(_values), child: Text('确定', style: TextStyle(fontSize: 14, color: primary, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: WotPickerView(columns: _columns, values: _values, color: primary, onChange: (v) => setState(() => _values = [...v])),
        ),
        Container(height: MediaQuery.of(context).padding.bottom, color: scheme.filledContent),
      ],
    );
  }
}