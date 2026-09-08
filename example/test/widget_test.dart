// 示例 App 冒烟测试：验证用 WotConfigProvider 包裹后能正常构建三件套。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_wot_ui/flutter_wot_ui.dart';
import 'package:flutter_wot_ui_example/pages/basic/wot_button_page.dart';
import 'package:flutter_wot_ui_example/pages/index_page.dart';

Widget wrap(Widget child) =>
    WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('Button 示例页可渲染', (tester) async {
    await tester.pumpWidget(wrap(const WotButtonPage()));
    expect(find.text('主要'), findsOneWidget);
  });

  testWidgets('索引页可渲染分组入口', (tester) async {
    await tester.pumpWidget(wrap(const WotIndexPage(
      dark: false,
      onToggleDark: _noop,
    )));
    expect(find.text('Wot UI Flutter'), findsOneWidget);
    expect(find.text('Button'), findsOneWidget);
  });
}

void _noop() {}