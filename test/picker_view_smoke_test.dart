import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: SizedBox(height: 240, child: child)));

  testWidgets('单列含 loading 渲染无 infinite width', (tester) async {
    await tester.pumpWidget(host(WotPickerViewColumn(
      options: [
        for (var i = 0; i < 5; i++) WotColumnOption(text: '选项$i', value: 'v$i'),
      ],
      value: 'v2',
      onChange: (_) {},
      loading: true,
    )));
    final ex = tester.takeException();
    expect(ex, isNull, reason: '不应有布局异常，实际: $ex');
  });

  testWidgets('多列 WotPickerView 渲染无 infinite width', (tester) async {
    final options = [
      [for (var i = 0; i < 5; i++) WotColumnOption(text: '省$i', value: 'p$i')],
      [for (var i = 0; i < 4; i++) WotColumnOption(text: '市$i', value: 'c$i')],
    ];
    await tester.pumpWidget(host(WotPickerView(
      columns: options,
      values: ['p1', 'c2'],
      onChange: (_) {},
      loading: true,
    )));
    final ex = tester.takeException();
    expect(ex, isNull, reason: '多列不应有布局异常，实际: $ex');
  });
}