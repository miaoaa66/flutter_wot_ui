import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() {
  const area = [
    WotCascadeOption(text: '浙江', value: 'zhejiang', children: [
      WotCascadeOption(text: '杭州', value: 'hangzhou', children: [
        WotCascadeOption(text: '西湖区', value: 'xihu'),
      ]),
      WotCascadeOption(text: '宁波', value: 'ningbo'),
    ]),
    WotCascadeOption(text: '广东', value: 'guangdong', children: [
      WotCascadeOption(text: '广州', value: 'guangzhou'),
    ]),
  ];

  testWidgets('Cascader 弹出 Tabs+列表，逐级下钻并回填', (tester) async {
    List<Object?>? result;
    Widget host() => MaterialApp(
          home: Scaffold(
            body: Center(
              child: WotCascader(
                options: area,
                onChange: (v) => result = v,
              ),
            ),
          ),
        );

    await tester.pumpWidget(host());

    // 打开弹层（触发 trigger）。
    await tester.tap(find.byType(WotCascader));
    await tester.pumpAndSettle();

    // 第一级列表出现「浙江 / 广东」。
    expect(find.text('浙江'), findsWidgets);
    // 点选「浙江」→ 下钻到第二级。
    await tester.tap(find.text('浙江').last);
    await tester.pumpAndSettle();
    // 第二级出现「杭州 / 宁波」。
    expect(find.text('杭州'), findsOneWidget);
    // 点选「杭州」→ 下钻到第三级。
    await tester.tap(find.text('杭州'));
    await tester.pumpAndSettle();
    // 第三级叶子「西湖区」，点它即确认关闭。
    await tester.tap(find.text('西湖区'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result, ['zhejiang', 'hangzhou', 'xihu']);
    // 弹层已关闭。
    expect(find.text('西湖区'), findsNothing);
  });
}