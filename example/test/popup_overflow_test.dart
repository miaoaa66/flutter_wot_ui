import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';
import 'package:flutter_wot_ui_example/pages/feedback/feedback_page.dart';

void main() {
  testWidgets('打开 WotPopup 不再触发 infinite height', (tester) async {
    await tester.pumpWidget(WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: const MaterialApp(home: WotFeedbackPage(), debugShowCheckedModeBanner: false),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(find.text('打开弹出层'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('打开弹出层'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final ex = tester.takeException();
    expect(ex, isNull, reason: '打开弹出层不应有布局异常，实际: $ex');

    // 关闭弹层
    await tester.tapAt(const Offset(20, 200)); // 点遮罩区域关闭
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });
}