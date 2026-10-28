import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCalendarView 月历视图示例页（WotCalendar 的公共底座，可单独使用）。
class WotCalendarViewPage extends StatefulWidget {
  const WotCalendarViewPage({super.key});

  @override
  State<WotCalendarViewPage> createState() => _WotCalendarViewPageState();
}

class _WotCalendarViewPageState extends State<WotCalendarViewPage> {
  DateTime? _selected;
  String _lastMonth = '—';

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCalendarView 月历视图',
      children: [
        demoSection('基础用法（默认当前月，单选某一天）'),
        demoBlock(
            'modelValue 受控选中 + onDayClick 点选回调 + onMonthChange 翻月回调'
            '（当前选中：${_selected == null ? '未选' : _selected.toString().substring(0, 10)}，'
            '最近翻月：$_lastMonth）',
            WotCalendarView(
              modelValue: _selected,
              onDayClick: (d) => setState(() => _selected = d),
              onMonthChange: (m) =>
                  setState(() => _lastMonth = m.toString().substring(0, 7)),
            )),
        demoSection('指定年月（year / month）'),
        demoBlock('固定展示 2026 年 10 月（不传时默认当前年月）',
            const WotCalendarView(year: 2026, month: 10)),
        demoSection('日期范围限制（minDate / maxDate）'),
        demoBlock(
            '只允许 2026-10-10 ~ 2026-10-20 之间的日期可选，'
            '范围外日期置灰不可点',
            WotCalendarView(
              year: 2026,
              month: 10,
              minDate: DateTime(2026, 10, 10),
              maxDate: DateTime(2026, 10, 20),
              onDayClick: (d) => demoToast(context, '选中：${d.toString().substring(0, 10)}'),
            )),
        demoSection('主题色（color）'),
        demoBlock('color: 选中态与今日标识改用主题色渲染',
            WotCalendarView(
              color: Colors.purple,
              modelValue: _selected,
              onDayClick: (d) => setState(() => _selected = d),
            )),
        demoSection('自定义星期表头（weekdays）'),
        demoBlock('weekdays 换成英文缩写（默认 [一, 二, 三, 四, 五, 六, 日]，周一为首日）',
            const WotCalendarView(
              weekdays: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
            )),
      ],
    );
  }
}
