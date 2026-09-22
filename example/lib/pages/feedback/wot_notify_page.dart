import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotNotify 顶部通知（命令式）示例页。
class WotNotifyPage extends StatelessWidget {
  const WotNotifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotNotify 顶部通知',
      children: [
        demoSection('类型（success / warning / error / 自定义 type）'),
        demoBlock('各类型',
            Wrap(spacing: 8, runSpacing: 8, children: [
              WotButton(text: '通知', size: WotButtonSize.small, onClick: () => WotNotify.success(context, '这是顶部通知')),
              WotButton(text: '警告', size: WotButtonSize.small, type: WotButtonType.warning, onClick: () => WotNotify.warning(context, '请注意')),
              WotButton(text: '错误', size: WotButtonSize.small, type: WotButtonType.danger, onClick: () => WotNotify.error(context, '出错了')),
              WotButton(text: 'primary', size: WotButtonSize.small, type: WotButtonType.info, onClick: () => WotNotify.show(context, message: 'primary 类型通知', type: WotNotifyType.primary)),
            ])),
        demoSection('事件（onClose / 时长）'),
        demoBlock('3 秒后自动关闭并触发 onClose',
            Wrap(spacing: 8, runSpacing: 8, children: [
              WotButton(
                text: 'onClose 回调查看',
                size: WotButtonSize.small,
                type: WotButtonType.warning,
                onClick: () => WotNotify.show(context, message: '3 秒后关闭', type: WotNotifyType.info, onClose: () => demoToast(context, 'onClose 已触发')),
              ),
            ])),
        demoSection('新增（D 类 P1）：closable / position / onClick / onClosed'),
        demoBlock(
            'closable 关闭按钮 + onClick 点击回调',
            FilledButton(
                onPressed: () => WotNotify.show(context,
                    message: '点击右侧 × 可关闭，点条体触发 onClick',
                    type: WotNotifyType.primary,
                    closable: true,
                    onClick: () => WotNotify.show(context,
                        message: '通知条被点击了', type: WotNotifyType.success)),
                child: const Text('可关闭通知'))),
        demoBlock(
            'position 底部显示',
            FilledButton.tonal(
                onPressed: () => WotNotify.show(context,
                    message: '底部通知（关闭后触发 onClosed）',
                    type: WotNotifyType.warning,
                    position: WotNotifyPosition.bottom,
                    onClosed: () {}),
                child: const Text('底部通知'))),
      ],
    );
  }
}