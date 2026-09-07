import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() {
  testWidgets('closeable 关闭后不再占位', (tester) async {
    await tester.pumpWidget(WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: const MaterialApp(home: Scaffold(body: WotNoticeBar(text: '公告', closeable: true))),
    ));
    // 关闭前：可找到图标与容器高度。
    expect(find.byType(WotNoticeBar), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close).first); // 关闭按钮
    await tester.pump();
    // 过渡动画
    await tester.pump(const Duration(milliseconds: 250));
    // 关闭后：不再占位（WotNoticeBar build 返回空）
    expect(tester.takeException(), isNull);
    final pos = tester.getSize(find.byType(WotNoticeBar, skipOffstage: true));
    // 若仍在树中则应为 0 尺寸（空），否则 notify removed。
    expect(pos.height, 0, reason: '关闭后应不占高度');
  });
}