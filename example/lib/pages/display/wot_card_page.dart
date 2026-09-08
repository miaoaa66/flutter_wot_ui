import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCard 卡片示例页。
class WotCardPage extends StatelessWidget {
  const WotCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCard 卡片',
      children: [
        demoSection('标准卡片（title / description / price / image / footer）'),
        demoBlock('商品卡片',
            WotCard(
              title: '商品标题',
              description: '这是一段商品描述，用于展示卡片的内容区域。',
              price: '99.00',
              image: 'https://picsum.photos/seed/card/90',
              showFooter: true,
              footer: WotButton(text: '加入购物车', size: WotButtonSize.small, onClick: () => demoToast(context, '已加入')),
            )),
        demoSection('自定义内容（children 任意布局 + onClick）'),
        demoBlock('自定义活动卡片',
            WotCard(
              onClick: () => demoToast(context, '点击卡片'),
              children: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      WotText('活动标题', bold: true, size: 16),
                      SizedBox(height: 4),
                      WotText('活动副标题', type: WotTextType.wotDefault),
                    ])),
                    WotTag(text: 'NEW', type: WotTagType.danger, size: WotTagSize.mini),
                  ]),
                  const SizedBox(height: 8),
                  const WotText('标题下方描述：这里通过 children 自定义卡片内容，点击整卡可触发回调。', type: WotTextType.wotDefault),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    WotButton(text: '查看详情', size: WotButtonSize.small, variant: WotButtonVariant.text),
                    const SizedBox(width: 8),
                    WotButton(text: '立即参加', size: WotButtonSize.small, onClick: () => demoToast(context, '参加活动')),
                  ]),
                ],
              ),
            )),
      ],
    );
  }
}