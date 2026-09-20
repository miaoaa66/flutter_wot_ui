import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotDatetimePicker 日期时间选择器示例页。
class WotDatetimePickerPage extends StatefulWidget {
  const WotDatetimePickerPage({super.key});

  @override
  State<WotDatetimePickerPage> createState() => _WotDatetimePickerPageState();
}

class _WotDatetimePickerPageState extends State<WotDatetimePickerPage> {
  DateTime? _date;
  DateTime? _datetime;
  DateTime? _time;
  DateTime? _yearMonth;
  DateTime? _scoped;

  String _fmt(DateTime? d) => d == null ? '未选择' : d.toIso8601String().substring(0, 16);

  String _dateOnly(DateTime? d) => d == null ? '未选择' : d.toIso8601String().split('T').first;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotDatetimePicker 日期时间',
      children: [
        demoSection('日期（date）'),
        demoBlock(
            '选择日期',
            WotButton(
              text: _fmt(_date) == '未选择' ? '选择日期' : '日期：${_dateOnly(_date)}',
              size: WotButtonSize.small,
              onClick: () async {
                final d = await WotDatetimePicker.show(context, type: WotDatetimePickerType.date, modelValue: _date);
                if (d != null) setState(() => _date = d);
              },
            )),
        demoSection('日期时间（datetime）'),
        demoBlock(
            '选择日期+时间',
            WotButton(
              text: _fmt(_datetime),
              size: WotButtonSize.small,
              onClick: () async {
                final d = await WotDatetimePicker.show(context, type: WotDatetimePickerType.datetime, modelValue: _datetime);
                if (d != null) setState(() => _datetime = d);
              },
            )),
        demoSection('时间（time / minHour / maxHour / minMinute / maxMinute）'),
        demoBlock(
            '选择时间（9:00-18:00）',
            WotButton(
              text: _fmt(_time),
              size: WotButtonSize.small,
              onClick: () async {
                final d = await WotDatetimePicker.show(context, type: WotDatetimePickerType.time, modelValue: _time, minHour: 9, maxHour: 18, minMinute: 0, maxMinute: 45);
                if (d != null) setState(() => _time = d);
              },
            )),
        demoSection('年月（yearMonth）'),
        demoBlock(
            '选择年月',
            WotButton(
              text: _yearMonth == null ? '选择年月' : '年月：${_yearMonth!.year}年${_yearMonth!.month}月',
              size: WotButtonSize.small,
              onClick: () async {
                final d = await WotDatetimePicker.show(context, type: WotDatetimePickerType.yearMonth, modelValue: _yearMonth);
                if (d != null) setState(() => _yearMonth = d);
              },
            )),
        demoSection('受限范围（minDate / maxDate）'),
        demoBlock(
            '仅可选中当年（date）',
            WotButton(
              text: _fmt(_scoped),
              size: WotButtonSize.small,
              onClick: () async {
                final now = DateTime.now();
                final d = await WotDatetimePicker.show(context, type: WotDatetimePickerType.date, modelValue: _scoped, minDate: DateTime(now.year, 1, 1), maxDate: DateTime(now.year, 12, 31));
                if (d != null) setState(() => _scoped = d);
              },
            )),
        demoSection('三态（disabled / readonly —— 作用于弹层内部交互）'),
        demoBlock(
            '弹层没有「显示区」，三态应施加在调用方的触发区；这里演示弹层内部的锁交互差异：'
            'disabled = 锁滚轮 + 整体淡化；readonly = 锁滚轮 + 配色不变',
            Wrap(spacing: 8, runSpacing: 8, children: [
              WotButton(
                text: '打开 disabled 弹层',
                size: WotButtonSize.small,
                onClick: () => WotDatetimePicker.show(context, type: WotDatetimePickerType.date, modelValue: _date, disabled: true),
              ),
              WotButton(
                text: '打开 readonly 弹层',
                size: WotButtonSize.small,
                onClick: () => WotDatetimePicker.show(context, type: WotDatetimePickerType.date, modelValue: _date, readonly: true),
              ),
            ])),
      ],
    );
  }
}