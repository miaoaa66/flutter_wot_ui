import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() {
  Widget build() => WotConfigProvider(
        wotTheme: WotThemeData.light,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WotCollapse(
                accordion: false,
                children: const [
                  WotCollapseItem(data: WotCollapseItemData(name: 'a', title: '标题A', content: '内容A')),
                  WotCollapseItem(data: WotCollapseItemData(name: 'b', title: '标题B', content: '内容B')),
                ],
              ),
            ),
          ),
        ),
      );

  bool expanded(WidgetTester tester, int i) =>
      tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade).at(i)).crossFadeState ==
      CrossFadeState.showSecond;

  testWidgets('点击可展开，多选可同时展开、再点收起', (tester) async {
    await tester.pumpWidget(build());
    expect(expanded(tester, 0), isFalse, reason: '初始全部收起');
    expect(expanded(tester, 1), isFalse);

    await tester.tap(find.text('标题A'));
    await tester.pump(const Duration(milliseconds: 320));
    expect(expanded(tester, 0), isTrue, reason: '点A应展开');

    await tester.tap(find.text('标题B'));
    await tester.pump(const Duration(milliseconds: 320));
    expect(expanded(tester, 0), isTrue, reason: 'A 保持展开');
    expect(expanded(tester, 1), isTrue, reason: '多选：B 也应展开');

    await tester.tap(find.text('标题A'));
    await tester.pump(const Duration(milliseconds: 320));
    expect(expanded(tester, 0), isFalse, reason: '再点A应收起');
    expect(expanded(tester, 1), isTrue, reason: 'B 不受影响');
  });
}