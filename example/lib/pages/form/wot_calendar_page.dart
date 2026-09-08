import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCalendar 日历示例页（单选 / 多选 / 区间 / 受限范围）。
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

  String _fmt(DateTime d) => d.toIso8601String().split('T').first;
  String _fmtDays(List<DateTime> l) => l.map(_fmt).join(', ');

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCalendar 日历',
      children: [
        demoSection('单选（WotCalendar.show + modelValue 回显）'),
        demoBlock(
            '点击选择单日',
            WotButton(
              text: _date == null ? '选择日期' : '日期：${_fmt(_date!)}',
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
              text: _scoped == null ? '选择当年日期' : '已选：${_fmt(_scoped!)}',
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
              text: _calMulti.isEmpty ? '多选日期' : '多选：${_fmtDays(_calMulti)}',
              size: WotButtonSize.small,
              onClick: () async {
                final r = await showModalBottomSheet<Object>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  builder: (_) => WotCalendar(
                    type: WotCalendarType.multiple,
                    title: '多选日期',
                    initialValues: _calMulti,
                    onConfirm: (v) => demoToast(context, '多选：${_fmtDays((v as List).cast<DateTime>())}'),
                  ),
                );
                if (r != null && mounted) setState(() => _calMulti..clear()..addAll((r as List).cast<DateTime>()));
              },
            )),
        demoBlock(
            '区间 range',
            WotButton(
              text: _calRange.isEmpty ? '选择起止' : '区间：${_fmtDays(_calRange)}',
              size: WotButtonSize.small,
              onClick: () async {
                final r = await showModalBottomSheet<Object>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  builder: (_) => WotCalendar(
                    type: WotCalendarType.range,
                    title: '选择区间',
                    initialValues: _calRange,
                    onConfirm: (v) => demoToast(context, '区间：${_fmtDays((v as List).cast<DateTime>())}'),
                  ),
                );
                if (r != null && mounted) setState(() => _calRange..clear()..addAll((r as List).cast<DateTime>()));
              },
            )),
        demoSection('内嵌日历（组件式 + 点击年月快速跳转）'),
        demoBlock(
            '内嵌单选日历',
            WotCalendar(
              type: WotCalendarType.single,
              modelValue: _date,
              onChange: (d) => setState(() => _date = d),
            )),
      ],
    );
  }
}