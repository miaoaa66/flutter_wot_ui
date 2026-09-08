import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_popup_page.dart';

void main() {
  testWidgets('打开 WotPopup 不再触发 infinite height', (tester) async {
    await tester.pumpWidget(WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: const MaterialApp(home: WotPopupPage(), debugShowCheckedModeBanner: false),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('底部弹层'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final ex = tester.takeException();
    expect(ex, isNull, reason: '打开弹出层不应有布局异常，实际: $ex');

    // 关闭弹层（点遮罩区域）。
    await tester.tapAt(const Offset(20, 60));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });
}