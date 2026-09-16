import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCalendar 日历示例页（9 种选择类型 + 年/年范围滚轮）。
class WotCalendarPage extends StatefulWidget {
  const WotCalendarPage({super.key});

  @override
  State<WotCalendarPage> createState() => _WotCalendarPageState();
}

class _WotCalendarPageState extends State<WotCalendarPage> {
  DateTime? _date;
  DateTime? _scoped;
  final List<DateTime> _calMulti = [];
  final List<DateTime> _calRange = [];

  // 新增 6 种类型。
  DateTime? _datetime;
  final List<DateTime> _dtRange = [];
  DateTime? _week;
  final List<DateTime> _weekRange = [];
  DateTime? _month;
  final List<DateTime> _monthRange = [];

  // 年 / 年范围（滚轮）。
  String? _year;
  String _yearRange = '';

  String _d(DateTime d) => d.toIso8601String().split('T').first;
  String _dt(DateTime d) => '${_d(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  String _m(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
  String _days(List<DateTime> l) => l.map(_d).join('  →  ');
  String _dts(List<DateTime> l) => l.map(_dt).join('  →  ');
  String _ms(List<DateTime> l) => l.map(_m).join('  →  ');

  Future<Object?> _open(WotCalendarType type, List<DateTime> initial, String title) {
    return showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => WotCalendar(
        type: type,
        title: title,
        initialValues: initial,
        onConfirm: (v) => demoToast(context, '已选择'),
      ),
    );
  }

  // 高级能力对齐 wot wd-calendar。
  DateTime? _fmtDate;
  dynamic _shortcutResult;
  dynamic _beforeConfirmResult;

  /// 打开一个带高级属性的日历弹层。
  Future<void> _openAdvanced(WotCalendar advanced) async {
    await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => advanced,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCalendar 日历',
      children: [
        demoSection('单选（WotCalendar.show + modelValue 回显）'),
        demoBlock(
            '点击选择单日',
            WotButton(
              text: _date == null ? '选择日期' : '日期：${_d(_date!)}',
              size: WotButtonSize.small,
              onClick: () async {
                final d = await WotCalendar.show(context, modelValue: _date);
                if (d != null) setState(() => _date = d);
              },
            )),
        demoSection('受限范围（minDate / maxDate）'),
        demoBlock(
            '仅可选中当年',
            WotButton(
              text: _scoped == null ? '选择当年日期' : '已选：${_d(_scoped!)}',
              size: WotButtonSize.small,
              onClick: () async {
                final now = DateTime.now();
                final d = await WotCalendar.show(
                  context,
                  modelValue: _scoped,
                  minDate: DateTime(now.year, 1, 1),
                  maxDate: DateTime(now.year, 12, 31),
                );
                if (d != null) setState(() => _scoped = d);
              },
            )),
        demoSection('多选 / 区间（type + onConfirm）'),
        demoBlock(
            '多选 multiple',
            WotButton(
              text: _calMulti.isEmpty ? '多选日期' : '多选：${_days(_calMulti)}',
              size: WotButtonSize.small,
              onClick: () async {
                final r = await _open(WotCalendarType.multiple, _calMulti, '多选日期');
                if (r != null && mounted) setState(() => _calMulti..clear()..addAll((r as List).cast<DateTime>()));
              },
            )),
        demoBlock(
            '区间 range',
            WotButton(
              text: _calRange.isEmpty ? '选择起止' : '区间：${_days(_calRange)}',
              size: WotButtonSize.small,
              onClick: () async {
                final r = await _open(WotCalendarType.range, _calRange, '选择区间');
                if (r != null && mounted) setState(() => _calRange..clear()..addAll((r as List).cast<DateTime>()));
              },
            )),
        demoSection('新增类型（date/daterange 之外）'),
        demoBlock(
            '日期时间 datetime',
            WotButton(
              text: _datetime == null ? '选择日期时间' : '已选：${_dt(_datetime!)}',
              size: WotButtonSize.small,
              onClick: () async {
                final r = await _open(WotCalendarType.datetime, _datetime == null ? const [] : [_datetime!], '选择日期时间');
                if (r != null && mounted) setState(() => _datetime = r as DateTime);
              },
            )),
        demoBlock(
            '日期时间区间 datetimerange',
            WotButton(
              text: _dtRange.isEmpty ? '选择起止日期时间' : '区间：${_dts(_dtRange)}',
              size: WotButtonSize.small,
              onClick: () async {
                final r = await _open(WotCalendarType.datetimeRange, _dtRange, '选择日期时间区间');
                if (r != null && mounted) setState(() => _dtRange..clear()..addAll((r as List).cast<DateTime>()));
              },
            )),
        demoBlock(
            '周 week',
            WotButton(
              text: _week == null ? '选择周' : '选中日：${_d(_week!)}',
              size: WotButtonSize.small,
              onClick: () async {
                final r = await _open(WotCalendarType.week, _week == null ? const [] : [_week!], '选择周');
                if (r != null && mounted) setState(() => _week = r as DateTime);
              },
            )),
        demoBlock(
            '周范围 weekrange',
            WotButton(
              text: _weekRange.isEmpty ? '选择起止周' : '周区间：${_days(_weekRange)}',
              size: WotButtonSize.small,
              onClick: () async {
                final r = await _open(WotCalendarType.weekRange, _weekRange, '选择周范围');
                if (r != null && mounted) setState(() => _weekRange..clear()..addAll((r as List).cast<DateTime>()));
              },
            )),
        demoBlock(
            '月 month',
            WotButton(
              text: _month == null ? '选择月份' : '已选：${_m(_month!)}',
              size: WotButtonSize.small,
              onClick: () async {
                final r = await _open(WotCalendarType.month, _month == null ? const [] : [_month!], '选择月份');
                if (r != null && mounted) setState(() => _month = r as DateTime);
              },
            )),
        demoBlock(
            '月范围 monthrange',
            WotButton(
              text: _monthRange.isEmpty ? '选择起止月' : '月区间：${_ms(_monthRange)}',
              size: WotButtonSize.small,
              onClick: () async {
                final r = await _open(WotCalendarType.monthRange, _monthRange, '选择月范围');
                if (r != null && mounted) setState(() => _monthRange..clear()..addAll((r as List).cast<DateTime>()));
              },
            )),
        demoSection('年 / 年范围（滚轮 wd-picker 实现，非日历类型）'),
        demoBlock(
            '年选择（WotPicker 单列年份轮）',
            WotButton(
              text: _year ?? '选择年份',
              size: WotButtonSize.small,
              onClick: () async {
                final y = await WotPicker.show(
                  context,
                  columns: wotSingleColumn([for (var y2 = 2020; y2 <= 2030; y2++) '$y2年']),
                  title: '选择年份',
                );
                if (y != null && y.isNotEmpty && mounted) setState(() => _year = y.first.toString());
              },
            )),
        demoBlock(
            '年范围（WotPicker 双列 起始/结束）',
            WotButton(
              text: _yearRange.isEmpty ? '选择年份范围' : '范围：$_yearRange',
              size: WotButtonSize.small,
              onClick: () async {
                final yrs = [for (var y2 = 2020; y2 <= 2030; y2++) '$y2年'];
                final y = await WotPicker.show(
                  context,
                  columns: [wotOptions(yrs), wotOptions(yrs)],
                  title: '选择年份范围',
                );
                if (y != null && y.length >= 2 && mounted) {
                  setState(() => _yearRange = '${y[0]}  →  ${y[1]}');
                }
              },
            )),
        demoSection('高级能力对齐 wot wd-calendar'),
        demoBlock(
            '切换模式 switch-mode',
            Wrap(
              spacing: 8,
              children: [
                WotButton(
                  text: 'month（按月切换）',
                  size: WotButtonSize.small,
                  onClick: () => _openAdvanced(WotCalendar(
                    type: WotCalendarType.single,
                    title: '按月切换',
                    switchMode: WotCalendarSwitchMode.month,
                    onConfirm: (v) => demoToast(context, '按月切换确认'),
                  )),
                ),
                WotButton(
                  text: 'year-month（年+月切换）',
                  size: WotButtonSize.small,
                  onClick: () => _openAdvanced(WotCalendar(
                    type: WotCalendarType.single,
                    title: '年+月切换',
                    switchMode: WotCalendarSwitchMode.yearMonth,
                    onConfirm: (v) => demoToast(context, '年+月切换确认'),
                  )),
                ),
              ],
            )),
        demoBlock(
            '日周月切换 show-type-switch',
            WotButton(
              text: '日/周/月自由切换',
              size: WotButtonSize.small,
              onClick: () => _openAdvanced(WotCalendar(
                type: WotCalendarType.single,
                title: '日周月切换',
                showTypeSwitch: true,
                onConfirm: (v) => demoToast(context, '日周月切换确认'),
              )),
            )),
        demoBlock(
            '快捷选项 shortcuts + on-shortcuts-click',
            WotButton(
              text: _shortcutResult == null ? '近一周 / 近一月' : '已选：$_shortcutResult',
              size: WotButtonSize.small,
              onClick: () => _openAdvanced(WotCalendar(
                type: WotCalendarType.range,
                title: '快捷选项',
                shortcuts: const [
                  WotCalendarShortcut(text: '近一周', value: []),
                  WotCalendarShortcut(text: '近一月', value: []),
                ],
                onShortcutClick: (s, _) {
                  final now = DateTime.now();
                  return [now.subtract(const Duration(days: 7)), now];
                },
                onConfirm: (v) {
                  setState(() => _shortcutResult = _days((v as List).cast<DateTime>()));
                  demoToast(context, '快捷确认');
                },
              )),
            )),
        demoBlock(
            '拓展确定区域 confirm-left / confirm-right',
            WotButton(
              text: '确定按钮两侧插槽',
              size: WotButtonSize.small,
              onClick: () => _openAdvanced(WotCalendar(
                type: WotCalendarType.single,
                title: '拓展确定区',
                confirmLeft: WotButton(
                  text: '今天', size: WotButtonSize.small, variant: WotButtonVariant.plain,
                  onClick: () => demoToast(context, '点了左侧'),
                ),
                confirmRight: WotButton(
                  text: '下月', size: WotButtonSize.small, variant: WotButtonVariant.plain,
                  onClick: () => demoToast(context, '点了右侧'),
                ),
                onConfirm: (v) => demoToast(context, '扩展区确认'),
              )),
            )),
        demoBlock(
            '日期格式化 formatter',
            WotButton(
              text: _fmtDate == null ? '自定义单元格（今天标圆点）' : '已选：${_d(_fmtDate!)}',
              size: WotButtonSize.small,
              onClick: () async {
                await showModalBottomSheet<Object>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  builder: (_) => WotCalendar(
                    type: WotCalendarType.single,
                    title: '日期格式化',
                    // 仅当月第一天展示底部提示，演示自定义渲染。
                    formatter: (d) {
                      final today = DateTime.now();
                      if (d.year == today.year && d.month == today.month && d.day == today.day) {
                        return const WotCalendarDayItem(text: '今', bottomInfo: '今日');
                      }
                      return WotCalendarDayItem(text: '${d.day}');
                    },
                    onConfirm: (v) {
                      if (mounted) setState(() => _fmtDate = v as DateTime);
                    },
                  ),
                );
              },
            )),
        demoBlock(
            '自定义展示 inner-display-format',
            WotButton(
              text: '范围顶部起止文案自定义',
              size: WotButtonSize.small,
              onClick: () => _openAdvanced(WotCalendar(
                type: WotCalendarType.range,
                title: '自定义展示',
                innerDisplayFormat: (v, pos, type) =>
                    pos == WotCalendarRangePosition.start ? '自 ${_d(v)}' : '至 ${_d(v)}',
                onConfirm: (v) => demoToast(context, '自定义展示确认'),
              )),
            )),
        demoBlock(
            '范围约束 max-range / range-prompt',
            WotButton(
              text: '跨度超 7 天提示',
              size: WotButtonSize.small,
              onClick: () => _openAdvanced(WotCalendar(
                type: WotCalendarType.range,
                title: '范围约束',
                maxRange: 7,
                rangePrompt: '最多只能选择 7 天哦',
                onConfirm: (v) => demoToast(context, '范围约束确认'),
              )),
            )),
        demoBlock(
            '隐藏秒 hide-second / 默认时刻 default-time',
            WotButton(
              text: 'datetime 隐藏秒 + 默认 08:30',
              size: WotButtonSize.small,
              onClick: () => _openAdvanced(WotCalendar(
                type: WotCalendarType.datetime,
                title: '隐藏秒',
                hideSecond: true,
                defaultTime: '08:30',
                onConfirm: (v) => demoToast(context, 'datetime 确认'),
              )),
            )),
        demoBlock(
            '确认前校验 before-confirm',
            WotButton(
              text: _beforeConfirmResult == null ? '先校验再确认' : '结果：$_beforeConfirmResult',
              size: WotButtonSize.small,
              onClick: () => _openAdvanced(WotCalendar(
                type: WotCalendarType.single,
                title: '确认前校验',
                beforeConfirm: (v) async => (v as DateTime).weekday != 6, // 周六不允许确认
                onConfirm: (v) {
                  final d = v as DateTime;
                  setState(() => _beforeConfirmResult = '${_d(d)}（${d.weekday}）');
                  demoToast(context, '校验通过并确认');
                },
              )),
            )),
        demoSection('内嵌日历（组件式 + 点击年月快速跳转）'),
        demoBlock(
            '内嵌单选日历',
            WotCalendar(
              type: WotCalendarType.single,
              modelValue: _date,
              switchMode: WotCalendarSwitchMode.month,
              onChange: (d) => setState(() => _date = d),
            )),
      ],
    );
  }
}