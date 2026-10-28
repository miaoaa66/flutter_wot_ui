// cascader 弹层溢出待实测项（COMPONENT_AUDIT E 类）的自动化关闭：
// _CascaderSheet 在 showModalBottomSheet 的有界高度内承载 Column(min) + Expanded，
// 用小屏尺寸 + 多级深选项验证不抛 RenderFlex 溢出异常。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

const _deepOptions = [
  WotCascadeOption(text: '浙江', value: 'zj', children: [
    WotCascadeOption(text: '杭州', value: 'hz'),
    WotCascadeOption(text: '宁波', value: 'nb'),
    WotCascadeOption(text: '温州', value: 'wz'),
    WotCascadeOption(text: '嘉兴', value: 'jx'),
    WotCascadeOption(text: '湖州', value: 'huz'),
    WotCascadeOption(text: '绍兴', value: 'sx'),
    WotCascadeOption(text: '金华', value: 'jh'),
    WotCascadeOption(text: '衢州', value: 'qz'),
  ]),
  WotCascadeOption(text: '广东', value: 'gd', children: [
    WotCascadeOption(text: '广州', value: 'gz'),
    WotCascadeOption(text: '深圳', value: 'sz'),
    WotCascadeOption(text: '东莞', value: 'dg'),
    WotCascadeOption(text: '佛山', value: 'fs'),
    WotCascadeOption(text: '珠海', value: 'zh'),
  ]),
];

void main() {
  testWidgets('cascader 弹层在小屏 + 深选项列表下不溢出', (tester) async {
    tester.view.physicalSize = const Size(375, 500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: WotCascader(
            options: _deepOptions,
            placeholder: '请选择所在地区',
            onChange: (_) {},
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // 打开弹层。
    await tester.tap(find.text('请选择所在地区'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // 下钻到有 8 个子项的省份，滚轮区内容最多时同样不溢出。
    await tester.tap(find.text('浙江'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
