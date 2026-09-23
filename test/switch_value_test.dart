import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

/// WotSwitch 自定义值域 + beforeChange（D 类 P1）。
///
/// 值域泛型化：默认 bool（activeValue/inactiveValue 不传）；
/// 对接后端 `'1'/'0'` 协议时使用 `WotSwitch<String>`。
Widget _wrap(Widget child) {
  return WotConfigProvider(
    wotTheme: WotThemeData.light,
    child: MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('默认 bool 值域：切换触发 onChange(true/false)', (tester) async {
    final values = <bool?>[];
    await tester.pumpWidget(_wrap(WotSwitch<bool>(
      modelValue: false,
      onChange: values.add,
    )));
    await tester.tap(find.byType(WotSwitch<bool>));
    expect(values, [true]);

    await tester.pumpWidget(_wrap(WotSwitch<bool>(
      modelValue: true,
      onChange: values.add,
    )));
    await tester.tap(find.byType(WotSwitch<bool>));
    expect(values, [true, false]);
  });

  testWidgets('自定义值域：1/0 协议切换', (tester) async {
    final values = <String?>[];
    await tester.pumpWidget(_wrap(WotSwitch<String>(
      modelValue: '1',
      activeValue: '1',
      inactiveValue: '0',
      onChange: values.add,
    )));
    // '1' 为开态：开关轨道呈激活色、文案切换后回调返回 '0'。
    await tester.tap(find.byType(WotSwitch<String>));
    expect(values, ['0']);
  });

  testWidgets('beforeChange 返回 false 阻止切换', (tester) async {
    final values = <bool?>[];
    await tester.pumpWidget(_wrap(WotSwitch<bool>(
      modelValue: false,
      beforeChange: (_) async => false,
      onChange: values.add,
    )));
    await tester.tap(find.byType(WotSwitch<bool>));
    await tester.pumpAndSettle();
    expect(values, isEmpty);
  });

  testWidgets('beforeChange 返回 true 放行切换', (tester) async {
    final values = <bool?>[];
    await tester.pumpWidget(_wrap(WotSwitch<bool>(
      modelValue: false,
      beforeChange: (_) async => true,
      onChange: values.add,
    )));
    await tester.tap(find.byType(WotSwitch<bool>));
    await tester.pumpAndSettle();
    expect(values, [true]);
  });
}
