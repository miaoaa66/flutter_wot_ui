import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotDialog 对话框（命令式 confirm / alert）示例页。
class WotDialogPage extends StatelessWidget {
  const WotDialogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotDialog 对话框',
      children: [
        demoSection('基础（confirm / alert）'),
        demoBlock('确认框返回结果',
            WotButton(text: '确认框', size: WotButtonSize.small, onClick: () async {
              final ok = await WotDialog.confirm(context, message: '确定要删除吗？', title: '提示');
              if (!context.mounted) return;
              demoToast(context, '结果：$ok');
            })),
        demoBlock('提示框', WotButton(
            text: '提示框', size: WotButtonSize.small, onClick: () => WotDialog.alert(context, message: '这是一个提示消息'))),
        demoSection('按钮（showClose / showConfirmButton / 自定义文案）'),
        demoBlock('右上角关闭按钮',
            WotButton(
              text: '显示关闭',
              size: WotButtonSize.small,
              onClick: () => WotDialog.alert(context, title: '提示', message: '右上角有关闭按钮', showClose: true, onClose: () => demoToast(context, '点击了关闭')),
            )),
        demoBlock('仅保留取消（showConfirmButton=false）',
            WotButton(
              text: '隐藏确定',
              size: WotButtonSize.small,
              type: WotButtonType.warning,
              onClick: () async {
                final ok = await WotDialog.confirm(context, title: '提示', message: '仅保留取消按钮', showConfirmButton: false);
                if (!context.mounted) return;
                demoToast(context, '结果：$ok');
              },
            )),
        demoSection('自定义文案与事件'),
        demoBlock('confirmButtonText / cancelButtonText / 各类回调',
            WotButton(
              text: '自定义按钮文案',
              size: WotButtonSize.small,
              type: WotButtonType.primary,
              onClick: () async {
                final ok = await WotDialog.confirm(
                  context,
                  title: '提示',
                  message: '自定义确定/取消文案',
                  showClose: true,
                  confirmButtonText: '保存',
                  cancelButtonText: '暂不',
                  onConfirm: () => demoToast(context, '点了保存'),
                  onCancel: () => demoToast(context, '点了暂不'),
                  onClose: () => demoToast(context, '点了关闭'),
                );
                if (!context.mounted) return;
                demoToast(context, '结果：$ok');
              },
            )),
      ],
    );
  }
}