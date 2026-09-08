import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotEmpty 空状态示例页。
class WotEmptyPage extends StatelessWidget {
  const WotEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotEmpty 空状态',
      children: [
        demoSection('基础（description / icon）'),
        demoBlock('暂无数据',
            const WotEmpty(description: '暂无数据')),
        demoSection('内容（footer 插槽）'),
        demoBlock('自定义底部按钮',
            WotEmpty(
              description: '当前列表为空',
              footer: WotButton(text: '去添加', size: WotButtonSize.small, type: WotButtonType.primary, onClick: () => demoToast(context, '去添加')),
            )),
      ],
    );
  }
}