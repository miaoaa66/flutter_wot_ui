import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() {
  Widget wrap() => WotConfigProvider(
        wotTheme: WotThemeData.light,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => WotToast.show(ctx,
                          '这是一段用于测试的成功提示文字，内容稍长一些，看看是否会出现溢出黄条', type: WotToastType.success),
                      child: const Text('图标成功'),
                    ),
                    ElevatedButton(
                      onPressed: () => WotToast.text(ctx, '纯文字提示'),
                      child: const Text('纯文字'),
                    ),
                    ElevatedButton(
                      onPressed: () => WotToast.loading(ctx, '加载中……'),
                      child: const Text('loading'),
                    ),
                    ElevatedButton(
                      onPressed: () => WotToast.warning(ctx, '底部警告提示', position: 'bottom'),
                      child: const Text('底部'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  for (final label in ['图标成功', '纯文字', 'loading', '底部']) {
    testWidgets('toast $label 渲染无溢出黄条', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final ex = tester.takeException();
      expect(ex, isNull, reason: '$label toast 不应有溢出，实际: $ex');
      // 等自动关闭计时器走完，避免 pending timer 报错。
      await tester.pump(const Duration(seconds: 3));
    });
  }
}