import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';
import 'package:flutter_wot_ui_example/pages/feedback/feedback_page.dart';

void main() {
  testWidgets('触发 WotTour 后气泡可交互、可退出', (tester) async {
    await tester.pumpWidget(WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: const MaterialApp(home: WotFeedbackPage(), debugShowCheckedModeBanner: false),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(find.text('开始引导'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('开始引导'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final ex = tester.takeException();
    if (ex != null) fail('触发引导异常: $ex');

    // 关键：气泡必须出现（否则只剩灰蒙层无法操作）。
    final hasNext = find.text('下一步').evaluate().isNotEmpty;
    final hasSkip = find.text('跳过').evaluate().isNotEmpty;
    debugPrint('气泡按钮：下一步=$hasNext 跳过=$hasSkip');
    expect(hasNext || hasSkip, isTrue, reason: '引导应有可交互按钮，否则用户无法退出');

    // 点击跳过退出。
    if (hasSkip) {
      await tester.tap(find.text('跳过'));
    } else {
      await tester.tap(find.text('下一步'));
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('沿步骤前进：onEnter 在第三步打开弹出层并圈住目标', (tester) async {
    await tester.pumpWidget(WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: const MaterialApp(home: WotFeedbackPage(), debugShowCheckedModeBanner: false),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(find.text('开始引导'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('开始引导'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // step0 onEnter/scroll
    expect(tester.takeException(), isNull);

    // 走到第三步：onEnter(setState 打开 popup) → 弹出内容出现且被圈住。
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('下一步'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull, reason: '第${i + 2}步无异常');
    }
    // 第三步：popup 已被 onEnter 打开，弹出内容可见。
    expect(find.text('弹出内容'), findsOneWidget, reason: 'onEnter 应已打开弹出层');
    // 仍有可退出按钮。
    expect(find.text('完成').evaluate().isNotEmpty || find.text('跳过').evaluate().isNotEmpty, isTrue);

    // 点完成退出，popup 由 onLeave 关闭。
    if (find.text('完成').evaluate().isNotEmpty) {
      await tester.tap(find.text('完成'));
    } else {
      await tester.tap(find.text('跳过'));
    }
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    expect(find.text('弹出内容'), findsNothing, reason: '退出后 onLeave/onClose 应关闭弹出层');
  });
}