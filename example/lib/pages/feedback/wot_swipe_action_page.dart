import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSwipeAction 滑动操作示例页。
class WotSwipeActionPage extends StatelessWidget {
  const WotSwipeActionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return WotDemoScaffold(
      title: 'WotSwipeAction 滑动操作',
      children: [
        demoSection('左滑显示右侧操作（actions 声明配置）'),
        demoBlock('shouldShow / disabled / onClick 等',
            WotSwipeAction(
              actions: [
                WotSwipeActionItem(text: '收藏', bgColor: scheme.primaryOf(6), onClick: () => demoToast(context, '收藏')),
                WotSwipeActionItem(text: '隐藏', bgColor: scheme.warningMain, shouldShow: false, onClick: () => demoToast(context, '不可见')),
                WotSwipeActionItem(text: '禁用', bgColor: scheme.filledContent, color: scheme.textSecondary, disabled: true),
                WotSwipeActionItem(text: '删除', bgColor: scheme.dangerMain, onClick: () => demoToast(context, '已删除')),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: scheme.filledOppo,
                child: const Row(
                  children: [WotIcon(name: 'user', size: 16), SizedBox(width: 8), WotText('左滑显示右侧操作')],
                ),
              ),
            )),
        demoSection('右滑显示左侧操作（side: left）'),
        demoBlock('side=left',
            WotSwipeAction(
              side: WotSwipeActionSide.left,
              actions: [
                WotSwipeActionItem(text: '标记', bgColor: scheme.successMain, onClick: () => demoToast(context, '已标记')),
                WotSwipeActionItem(text: '已读', bgColor: scheme.primaryOf(6), onClick: () => demoToast(context, '标为已读')),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: scheme.filledOppo,
                child: const Row(
                  children: [WotIcon(name: 'star', size: 16), SizedBox(width: 8), WotText('右滑显示左侧操作')],
                ),
              ),
            )),
        demoSection('禁止滑动（disabled）'),
        demoBlock('disabled 完全禁止',
            WotSwipeAction(
              disabled: true,
              actions: const [WotSwipeActionItem(text: '禁用滑动', bgColor: Color(0xFFC9CBD4), color: Color(0xFFFFFFFF), disabled: true)],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: scheme.filledOppo,
                child: const Row(
                  children: [WotIcon(name: 'lock', size: 16), SizedBox(width: 8), WotText('该条禁止滑动')],
                ),
              ),
            )),
      ],
    );
  }
}