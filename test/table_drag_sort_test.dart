import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

/// WotTable 拖拽重排回归测试。
///
/// 背景：Flutter 3.41 起 `SliverReorderableList.onReorder` 弃用，改由
/// `onReorderItem` 回调，且新回调的 `newIndex` 已扣除被移除项的位移
/// （旧回调语义是「移除前插入位」，需调用方自减修正）。本测试锁定两条不变式：
/// 1. 组件内部数据顺序按拖拽结果正确更新；
/// 2. 对外 `onReorder(oldIndex, newIndex)` 的 `newIndex` 等于数据的最终落位索引，
///    与视觉顺序一致。
void main() {
  const rowHeight = 44.0;

  Widget build({
    required void Function(int oldIndex, int newIndex) onReorder,
  }) =>
      WotConfigProvider(
        wotTheme: WotThemeData.light,
        child: MaterialApp(
          home: Scaffold(
            body: WotTable(
              dragSort: true,
              rowHeight: rowHeight,
              columns: const [WotTableColumn(prop: 'name', label: '名称')],
              data: const [
                {'name': 'A'},
                {'name': 'B'},
                {'name': 'C'},
              ],
              onReorder: onReorder,
            ),
          ),
        ),
      );

  /// 长按 [label] 行并按 [dy] 像素纵向拖动；分步移动保证 ReorderableList 能跟上。
  Future<void> dragRow(WidgetTester tester, String label, double dy) async {
    final gesture = await tester.startGesture(tester.getCenter(find.text(label)));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(Offset(0, dy / 10));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  double yOf(WidgetTester tester, String label) =>
      tester.getCenter(find.text(label)).dy;

  testWidgets('向下拖拽：数据顺序更新，newIndex 为最终落位索引', (tester) async {
    final calls = <List<int>>[];
    await tester.pumpWidget(build(onReorder: (o, n) => calls.add([o, n])));

    expect(yOf(tester, 'A'), lessThan(yOf(tester, 'B')), reason: '初始顺序 A 在 B 之上');

    await dragRow(tester, 'A', rowHeight * 2.4);

    expect(calls.length, 1, reason: '一次拖拽只应回调一次');
    expect(calls.single[0], 0, reason: 'oldIndex 为被拖拽行原索引');
    expect(calls.single[1], 2, reason: 'newIndex 为最终落位索引（旧语义会给 3）');

    expect(yOf(tester, 'A'), greaterThan(yOf(tester, 'C')), reason: 'A 已移到最末行');
    expect(yOf(tester, 'B'), lessThan(yOf(tester, 'C')), reason: 'B/C 相对顺序不变');
  });

  testWidgets('向上拖拽：newIndex 小于 oldIndex 时同样正确落位', (tester) async {
    final calls = <List<int>>[];
    await tester.pumpWidget(build(onReorder: (o, n) => calls.add([o, n])));

    await dragRow(tester, 'C', -rowHeight * 2.4);

    expect(calls.length, 1);
    expect(calls.single[0], 2, reason: 'oldIndex 为末行');
    expect(calls.single[1], 0, reason: 'newIndex 为首行');
    expect(yOf(tester, 'C'), lessThan(yOf(tester, 'A')), reason: 'C 已移到首行');
  });
}
