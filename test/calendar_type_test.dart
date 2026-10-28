import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

/// 每个类型单独渲染，用滚动外层给足高度，避免内联布局挤压导致的测试伪溢出。
Widget host(Widget child) => MaterialApp(
      home: Scaffold(
        body: SizedBox(height: 700, child: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  testWidgets('month 确认返回当月初', (tester) async {
    Object? result;
    await tester.pumpWidget(host(WotCalendar(type: WotCalendarType.month, title: '月选择', onConfirm: (v) => result = v)));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('确定'));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pump();
    expect(result, isA<DateTime>());
    expect((result as DateTime).day, 1);
  });

  testWidgets('week 确认返回日期类型', (tester) async {
    Object result = 'unset';
    await tester.pumpWidget(host(WotCalendar(
      type: WotCalendarType.week,
      title: '周选择',
      initialValues: [DateTime(2026, 9, 10)],
      onConfirm: (v) => result = v,
    )));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('确定'));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pump();
    expect(result, isA<DateTime>());
  });

  testWidgets('datetimeRange 在受限高度内不溢出且返回起止值', (tester) async {
    Object? result;
    final now = DateTime.now();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            height: 480, // 受限高度，此前会 RenderFlex 溢出 9.7px
            child: WotCalendar(
              type: WotCalendarType.datetimeRange,
              title: '日期时间区间',
              initialValues: [now, now.add(const Duration(days: 2))],
              // 显式指定 month 模式：本用例的语义是「受限高度下不溢出」，
              // 而 switchMode 默认值已改为 none（平铺全部月份），平铺 12 个月无法塞进 480px。
              switchMode: WotCalendarSwitchMode.month,
              onConfirm: (v) => result = v,
            ),
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull, reason: 'datetimeRange 受限高度不应溢出');
    await tester.ensureVisible(find.text('确定'));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pump();
    expect(result, isA<List<DateTime>>());
    expect((result as List<DateTime>).length, greaterThanOrEqualTo(1));
  });

  testWidgets('week 跨月补位日可渲染且确认正常', (tester) async {
    Object result = 'unset';
    // 2026-08-31 是周一，其所在周跨到 9 月。
    await tester.pumpWidget(host(WotCalendar(
      type: WotCalendarType.week,
      title: '周选择',
      initialValues: [DateTime(2026, 8, 31)],
      onConfirm: (v) => result = v,
    )));
    expect(tester.takeException(), isNull, reason: '跨月周网格不应有布局异常');
    await tester.ensureVisible(find.text('确定'));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pump();
    expect(result, isA<DateTime>());
  });

  testWidgets('none 平铺渲染范围内全部月份且可在受限高度内滚动', (tester) async {
    final now = DateTime.now();
    final min = DateTime(now.year, now.month - 2, 1);
    final max = DateTime(now.year, now.month + 2, 1);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            height: 480, // 有界高度：平铺月份列表应内部滚动而非溢出
            child: WotCalendar(
              type: WotCalendarType.single,
              title: '平铺',
              minDate: min,
              maxDate: max,
              onConfirm: (v) {},
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle(); // 等待首帧自动定位当前月的滚动动画结束
    expect(tester.takeException(), isNull, reason: '平铺 5 个月在受限高度内不应溢出');
    // 范围内首尾月份标题均应被渲染
    expect(find.text('${min.year} 年 ${min.month} 月'), findsOneWidget);
    expect(find.text('${max.year} 年 ${max.month} 月'), findsOneWidget);
    // none 模式不展示 ‹ › 月份切换按钮
    expect(find.text('‹'), findsNothing);
    expect(find.text('›'), findsNothing);
    // 中部月份列表可滚动到最后一个月
    await tester.scrollUntilVisible(
      find.text('${max.year} 年 ${max.month} 月'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(tester.takeException(), isNull);
  });
}