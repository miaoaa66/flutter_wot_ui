import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';
import 'package:flutter_wot_ui_example/pages/feedback/feedback_page.dart';

void main() {
  testWidgets('feedback 页逐个触发 toast/notify/dialog 无溢出', (tester) async {
    await tester.pumpWidget(WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: const MaterialApp(home: WotFeedbackPage(), debugShowCheckedModeBanner: false),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    final labels = ['文本', '成功', '失败', '加载中', '顶部', '居中', '底部', '自定义图标', '警告(便捷)', '信息(便捷)'];
    for (final label in labels) {
      final btn = find.text(label);
      if (btn.evaluate().isEmpty) {
        // 可能需要滚动到可见
        await tester.scrollUntilVisible(btn, 200, scrollable: find.byType(Scrollable).first);
      }
      await tester.tap(btn, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      final ex = tester.takeException();
      if (ex != null) {
        fail('点击[$label]触发 overflow/异常: $ex');
      }
      // toast 自动关闭计时器走完，避免 pending timer。
      await tester.pump(const Duration(seconds: 3));
    }
  });
}