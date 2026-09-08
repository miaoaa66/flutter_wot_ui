import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCellGroup 单元格分组示例页。
class WotCellGroupPage extends StatelessWidget {
  const WotCellGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCellGroup 单元格分组',
      children: [
        demoSection('基础分组（inset / bordered）'),
        demoBlock('普通分组',
            WotCellGroup(children: const [
              WotCell(title: '分组第一项', value: '内容'),
              WotCell(title: '分组第二项', value: '内容'),
              WotCell(title: '分组第三项', value: '内容'),
            ])),
        demoSection('内嵌卡片（inset=true / rounded / space）'),
        demoBlock('inset 卡片',
            WotCellGroup(inset: true, bordered: true, space: 12, children: const [
              WotCell(title: '卡片项一', value: '内容'),
              WotCell(title: '卡片项二', value: '内容'),
            ])),
      ],
    );
  }
}