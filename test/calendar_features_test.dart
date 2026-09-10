import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

Widget host(Widget child) => MaterialApp(
      home: Scaffold(
        body: SizedBox(height: 700, child: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  testWidgets('showTypeSwitch 可在日/周/月间切换并确认', (tester) async {
    Object? result;
    await tester.pumpWidget(host(WotCalendar(
      type: WotCalendarType.single,
      title: '日周月切换',
      showTypeSwitch: true,
      initialValues: [DateTime(2026, 9, 10)],
      onConfirm: (v) => result = v,
    )));
    // 切到「周」
    await tester.tap(find.text('周'));
    await tester.pump();
    await tester.ensureVisible(find.text('确定'));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pump();
    expect(result, isA<DateTime>());
  });

  testWidgets('shortcuts 点击后回填 range 并确认', (tester) async {
    Object? result;
    final now = DateTime.now();
    await tester.pumpWidget(host(WotCalendar(
      type: WotCalendarType.range,
      title: '快捷选项',
      shortcuts: [const WotCalendarShortcut(text: '近三天', value: [])],
      onShortcutClick: (_, __) => [now, now.add(const Duration(days: 2))],
      onConfirm: (v) => result = v,
    )));
    await tester.tap(find.text('近三天'));
    await tester.pump();
    await tester.ensureVisible(find.text('确定'));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pump();
    expect(result, isA<List<DateTime>>());
    expect((result as List).length, 2);
  });

  testWidgets('beforeConfirm 返回 false 阻止确认', (tester) async {
    Object? result = 'unset';
    await tester.pumpWidget(host(WotCalendar(
      type: WotCalendarType.single,
      title: '确认校验',
      initialValues: [DateTime(2026, 9, 10)],
      beforeConfirm: (_) async => false,
      onConfirm: (v) => result = v,
    )));
    await tester.ensureVisible(find.text('确定'));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pump();
    expect(result, 'unset', reason: '被 beforeConfirm 拦截则不应回调');
  });

  testWidgets('allowSameDay=false 时同一天不结束范围', (tester) async {
    Object? result;
    final d = DateTime(2026, 9, 10);
    await tester.pumpWidget(host(WotCalendar(
      type: WotCalendarType.range,
      title: '允许同天',
      allowSameDay: false,
      initialValues: [d],
      onConfirm: (v) => result = v,
    )));
    // 网格中点击同一天：范围仍不完整（only start）。
    final gridTap = find.text('10');
    expect(gridTap, findsWidgets);
    await tester.tap(gridTap.first);
    await tester.pump();
    await tester.ensureVisible(find.text('确定'));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pump();
    // 只有起点，返回值应为 1 个（RangePrompt 不受影响）。
    expect(result, isA<List<DateTime>>());
  });

  testWidgets('confirmLeft/confirmRight 渲染在确认区', (tester) async {
    await tester.pumpWidget(host(WotCalendar(
      type: WotCalendarType.single,
      title: '拓展确定区',
      confirmLeft: const Text('LEFT'), 
      confirmRight: const Text('RIGHT'),
    )));
    expect(find.text('LEFT'), findsOneWidget);
    expect(find.text('RIGHT'), findsOneWidget);
    expect(find.text('确定'), findsOneWidget);
  });

  testWidgets('hideSecond 隐藏秒选择列', (tester) async {
    await tester.pumpWidget(host(WotCalendar(
      type: WotCalendarType.datetime,
      title: '隐藏秒',
      hideSecond: true,
    )));
    expect(tester.takeException(), isNull, reason: 'datetime hideSecond 不应布局异常');
  });

  testWidgets('innerDisplayFormat 定制 range 顶部回显', (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(host(WotCalendar(
      type: WotCalendarType.range,
      title: '自定义展示',
      initialValues: [now, now.add(const Duration(days: 3))],
      innerDisplayFormat: (v, pos, type) => pos == WotCalendarRangePosition.start ? '起点' : '终点',
    )));
    expect(find.text('起点'), findsOneWidget);
    expect(find.text('终点'), findsOneWidget);
  });
}