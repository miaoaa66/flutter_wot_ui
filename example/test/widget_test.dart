// 示例 App 冒烟测试：验证用 WotConfigProvider 包裹后能正常构建三件套。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_wot_ui/flutter_wot_ui.dart';
import 'package:flutter_wot_ui_example/pages/basic/basic_page.dart';
import 'package:flutter_wot_ui_example/pages/index_page.dart';

Widget wrap(Widget child) =>
    WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('基础组件演示页可渲染 Button/Icon/Text', (tester) async {
    await tester.pumpWidget(wrap(const WotBasicPage()));
    expect(find.text('基础组件'), findsOneWidget);
    expect(find.text('主要'), findsOneWidget);
  });

  testWidgets('索引页可渲染分组入口', (tester) async {
    await tester.pumpWidget(wrap(const WotIndexPage(
      dark: false,
      variant: WotThemeVariant.shadcn,
      onToggleDark: _noop,
      onSelectVariant: _noopVariant,
    )));
    expect(find.text('Wot UI Flutter'), findsOneWidget);
    expect(find.text('Button'), findsOneWidget);
  });
}

void _noop() {}
void _noopVariant(WotThemeVariant _) {}