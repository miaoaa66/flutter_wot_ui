import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotDivider 分割线示例页。
class WotDividerPage extends StatelessWidget {
  const WotDividerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotDivider 分割线',
      children: [
        demoSection('基础（type: horizontal / vertical）'),
        demoBlock('水平分割线', const Column(children: [
          Text('上方内容'),
          WotDivider(distance: 12),
          Text('下方内容'),
        ])),
        demoBlock('垂直分割线',
            SizedBox(
              height: 40,
              child: Row(children: const [
                Text('左'),
                WotDivider(type: WotDividerType.vertical, distance: 12),
                Text('中'),
                WotDivider(type: WotDividerType.vertical, distance: 12),
                Text('右'),
              ]),
            )),
        demoSection('文字分割线（text / textPosition）'),
        demoBlock('默认居中文字', const WotDivider(text: '文本分割')),
        demoSection('样式（lineColor / dashed / hairline）'),
        demoBlock('虚线 dashed', const WotDivider(dashed: true, text: '虚线')),
        demoBlock('颜色 lineColor', const Column(children: [
          WotDivider(lineColor: Color(0xFFF14646)),
          WotDivider(lineColor: Color(0xFF12B886), text: '绿色分割'),
        ])),
      ],
    );
  }
}