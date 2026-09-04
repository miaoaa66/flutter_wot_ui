// 批次 E 冒烟：逐页渲染 + 滚动，捕获 RenderFlex 溢出 / 布局异常（非布局的插件/网络异常仅记录不 fail）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import 'package:flutter_wot_ui_example/pages/basic/basic_page.dart';
import 'package:flutter_wot_ui_example/pages/nav/nav_page.dart';
import 'package:flutter_wot_ui_example/pages/form/form_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/feedback_page.dart';
import 'package:flutter_wot_ui_example/pages/display/display_page.dart';

Widget _app(Widget home) => WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: MaterialApp(home: home, debugShowCheckedModeBanner: false),
    );

Future<void> _smoke(WidgetTester tester, String name, Widget home) async {
  await tester.pumpWidget(_app(home));
  await tester.pump(const Duration(milliseconds: 500));

  // 向下滚动触发 ListView 懒加载项渲染。
  final scroll = find.byType(Scrollable).first;
  for (var i = 0; i < 8; i++) {
    await tester.drag(scroll, const Offset(0, -350));
    await tester.pump(const Duration(milliseconds: 180));
  }
  // 滚动回顶。
  for (var i = 0; i < 8; i++) {
    await tester.drag(scroll, const Offset(0, 350));
    await tester.pump(const Duration(milliseconds: 120));
  }
  await tester.pump(const Duration(seconds: 1));

  // 消费所有异常，仅对布局溢出 fail；插件/网络异常记录不 fail。
  bool overflow = false;
  var other = 0;
  Object? ex;
  while ((ex = tester.takeException()) != null) {
    final s = ex.toString();
    if (s.contains('overflowed') || s.contains('RenderFlex')) {
      overflow = true;
      debugPrint('[$name] 布局溢出: $s');
    } else {
      other++;
    }
  }
  debugPrint('[$name] 渲染完成：overflow=$overflow, 非布局异常数=$other');
  if (overflow) {
    fail('$name 出现布局溢出');
  }
}

void main() {
  testWidgets('基础页渲染 + 滚动无溢出', (t) => _smoke(t, 'basic', const WotBasicPage()));
  testWidgets('导航页渲染 + 滚动无溢出', (t) => _smoke(t, 'nav', const WotNavPage()));
  testWidgets('录入页渲染 + 滚动无溢出', (t) => _smoke(t, 'form', const WotFormPage()));
  testWidgets('反馈页渲染 + 滚动无溢出', (t) => _smoke(t, 'feedback', const WotFeedbackPage()));
  testWidgets('展示页渲染 + 滚动无溢出', (t) => _smoke(t, 'display', const WotDisplayPage()));
}