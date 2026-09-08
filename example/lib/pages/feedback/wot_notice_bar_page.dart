import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotNoticeBar 公告栏示例页。
class WotNoticeBarPage extends StatelessWidget {
  const WotNoticeBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotNoticeBar 公告栏',
      children: [
        demoSection('基础（text / leftIcon）'),
        demoBlock('单条公告', const WotNoticeBar(text: '这是一条公告消息，用于提示用户重要信息。')),
        demoSection('可关闭（closeable / onClose）'),
        demoBlock('closeable 可关闭',
            WotNoticeBar(text: '点击右侧关闭按钮隐藏本条公告', closeable: true, leftIcon: false, onClose: () => demoToast(context, '公告已关闭'))),
        demoSection('多文本轮播（texts / onNext）'),
        demoBlock('多条轮播',
            const WotNoticeBar(
              texts: ['第一条公告内容', '第二条公告内容', '第三条公告内容'],
              leftIcon: false,
            )),
        demoSection('样式（scrollable / speed / wrapable）'),
        demoBlock('scrollable=false 静态显示',
            const WotNoticeBar(text: '静态公告条（不可滚动）', scrollable: false)),
      ],
    );
  }
}