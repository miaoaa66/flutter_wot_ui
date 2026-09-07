import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() {
  Widget build(Future<void> Function() onSub) => WotConfigProvider(
        wotTheme: WotThemeData.light,
        child: MaterialApp(
          home: Scaffold(
            body: WotForm(
              showSubmitButton: true,
              submitButtonText: '提交',
              rules: {
                'username': (v) => v != null && v.isNotEmpty,
              },
              onSubmit: (_) => onSub(),
              children: [
                WotFormItem(
                  label: '用户名',
                  name: 'username',
                  required: true,
                  child: WotInput(name: 'username', placeholder: '请输入用户名'),
                ),
              ],
            ),
          ),
        ),
      );

  testWidgets('空表单点提交：显示校验错误且不触发 onSubmit', (tester) async {
    var submitted = 0;
    await tester.pumpWidget(build(() async => submitted++));
    await tester.tap(find.text('提交'));
    await tester.pump();
    expect(find.textContaining('校验未通过'), findsOneWidget, reason: '应显示校验错误');
    expect(submitted, 0, reason: '校验失败不应触发 onSubmit');
  });

  testWidgets('填写后点提交：通过并触发 onSubmit', (tester) async {
    var submitted = 0;
    await tester.pumpWidget(build(() async => submitted++));
    await tester.enterText(find.byType(TextField), 'alice');
    await tester.tap(find.text('提交'));
    await tester.pump();
    expect(find.textContaining('校验未通过'), findsNothing);
    expect(submitted, 1, reason: '校验通过应触发 onSubmit');
  });

  testWidgets('多字段都失败：所有错误都显示，且 onSubmit 不触发', (tester) async {
    var submitted = 0;
    await tester.pumpWidget(WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: MaterialApp(
        home: Scaffold(
          body: WotForm(
            showSubmitButton: true,
            submitButtonText: '提交',
            rules: {
              'username': (v) => v != null && v.isNotEmpty,
              'email': (v) => v != null && v.contains('@'),
              'code': (v) => v != null && v.isNotEmpty,
            },
            onSubmit: (_) async => submitted++,
            children: [
              WotFormItem(label: '用户名', name: 'username', child: WotInput(name: 'username')),
              WotFormItem(label: '邮箱', name: 'email', child: WotInput(name: 'email')),
              WotFormItem(label: '验证码', name: 'code', child: WotInput(name: 'code')),
            ],
          ),
        ),
      ),
    ));
    await tester.tap(find.text('提交'));
    await tester.pump();
    expect(find.text('用户名校验未通过'), findsOneWidget);
    expect(find.text('邮箱校验未通过'), findsOneWidget);
    expect(find.text('验证码校验未通过'), findsOneWidget);
    expect(submitted, 0, reason: '任一眼校验失败都不应提交');
  });
}