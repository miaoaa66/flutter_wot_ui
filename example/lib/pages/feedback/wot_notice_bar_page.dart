import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotNoticeBar 公告栏示例页。
class WotNoticeBarPage extends StatefulWidget {
  const WotNoticeBarPage({super.key});

  @override
  State<WotNoticeBarPage> createState() => _WotNoticeBarPageState();
}

class _WotNoticeBarPageState extends State<WotNoticeBarPage> {
  int _carouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotNoticeBar 公告栏',
      children: [
        demoSection('基础（text / leftIcon）'),
        demoBlock('单条公告', const WotNoticeBar(text: '这是一条公告消息，用于提示用户重要信息，用于提示用户重要信息，用于提示用户重要信息。')),
        demoSection('可关闭（closeable / onClose）'),
        demoBlock('closeable 可关闭',
            WotNoticeBar(text: '点击右侧关闭按钮隐藏本条公告', closeable: true, leftIcon: false, onClose: () => demoToast(context, '公告已关闭'))),
        demoSection('多文本轮播（texts / onNext）'),
        demoBlock(
          '多条轮播（onNext 回传当前索引）',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WotNoticeBar(
                texts: const ['第一条公告内容', '第二条公告内容，用于提示用户重要信息，用于提示用户重要信息', '第三条公告内容'],
                direction: WotNoticeDirection.vertical,
                leftIcon: false,
                onNext: (i) => setState(() => _carouselIndex = i),
              ),
              const SizedBox(height: 6),
              Text('当前轮播到第 $_carouselIndex 条',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        demoSection('轮播节奏（delay 停留 / duration 动画）'),
        demoBlock(
          '自定义：停留 2s、滑动 400ms',
          WotNoticeBar(
            texts: const ['停留 2 秒再滑', '切换动画 400 毫秒', '节奏可调'],
            direction: WotNoticeDirection.vertical,
            leftIcon: false,
            delay: 2,
            duration: 400,
          ),
        ),
        demoSection('样式（scrollable / speed / wrapable）'),
        demoBlock('scrollable=false 静态显示',
            const WotNoticeBar(text: '静态公告条（不可滚动）', scrollable: false)),
      ],
    );
  }
}
