import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

/// i18n en_US 全链路验证（T2.4）。
///
/// 覆盖 tr 管道的五个层面：locale 取值、占位符替换、别名归一、
/// 自定义语言包优先级、组件级文案随语言切换。
/// 文案表（zh_CN / en_US）内置并已随组件接入（T2.2 / T2.3 / 批次 6）。
Widget _wrap(
  Widget child, {
  String locale = 'zh_CN',
  Map<String, String>? messages,
}) {
  return WotConfigProvider(
    locale: locale,
    localeMessages: messages,
    wotTheme: WotThemeData.light,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('tr 管道：en_US 取英文、zh_CN 取中文', (tester) async {
    String? en;
    await tester.pumpWidget(_wrap(
      Builder(
        builder: (context) {
          en = tr(context, 'wot.common.confirm');
          return const SizedBox.shrink();
        },
      ),
      locale: 'en_US',
    ));
    expect(en, 'Confirm');

    String? zh;
    await tester.pumpWidget(_wrap(
      Builder(
        builder: (context) {
          zh = tr(context, 'wot.common.confirm');
          return const SizedBox.shrink();
        },
      ),
      locale: 'zh_CN',
    ));
    expect(zh, '确定');
  });

  testWidgets('占位符替换：pagination.total 英文模板', (tester) async {
    String? out;
    await tester.pumpWidget(_wrap(
      Builder(
        builder: (context) {
          out = tr(context, 'wot.pagination.total',
              params: {'total': 120, 'pages': 6});
          return const SizedBox.shrink();
        },
      ),
      locale: 'en_US',
    ));
    expect(out, 'Total 120 items in 6 pages');
  });

  testWidgets('normalize：en / en-US / en_US 均命中英文表', (tester) async {
    expect(WotMessages.normalize('en_US'), 'en_US');
    expect(WotMessages.normalize('en-US'), 'en_US');
    expect(WotMessages.normalize('en'), 'en_US');
    expect(WotMessages.normalize(null), 'zh_CN');
    expect(WotMessages.builtinValue('en', 'wot.table.empty'), 'No Data');
  });

  testWidgets('自定义语言包优先于内置表', (tester) async {
    String? out;
    await tester.pumpWidget(_wrap(
      Builder(
        builder: (context) {
          out = tr(context, 'wot.common.confirm');
          return const SizedBox.shrink();
        },
      ),
      locale: 'en_US',
      messages: {'wot.common.confirm': 'OK!'},
    ));
    expect(out, 'OK!');
  });

  testWidgets('组件级：WotSlideVerify 默认文案随语言切换', (tester) async {
    await tester.pumpWidget(
      _wrap(const WotSlideVerify(), locale: 'en_US'),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Slide to verify'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(const WotSlideVerify(), locale: 'zh_CN'),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('向右滑动完成验证'), findsOneWidget);
  });
}
