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
        demoSection('类型 type（A 类死参数 #7 已实现：左侧 4px 辅助色条）'),
        demoBlock('success 绿 / warning 黄 / error 红 / info 主色——色条贴在弹窗左边缘，'
            '加了 clipBehavior 所以不会顶出圆角',
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final e in <(WotDialogType, String, WotButtonType)>[
                  (WotDialogType.success, 'success', WotButtonType.success),
                  (WotDialogType.warning, 'warning', WotButtonType.warning),
                  (WotDialogType.error, 'error', WotButtonType.danger),
                  (WotDialogType.info, 'info', WotButtonType.primary),
                ])
                  WotButton(
                    text: e.$2,
                    size: WotButtonSize.small,
                    type: e.$3,
                    onClick: () => WotDialog.alert(
                      context,
                      title: '提示',
                      message: 'type: ${e.$2}，左侧色条应为对应语义色',
                      type: e.$1,
                    ),
                  ),
              ],
            )),
        demoBlock('confirm 同样支持 type（showCancelButton=false 时更易看清色条）',
            WotButton(
                text: 'confirm + error',
                size: WotButtonSize.small,
                type: WotButtonType.danger,
                onClick: () => WotDialog.confirm(
                      context,
                      title: '危险操作',
                      message: '此操作不可撤销',
                      type: WotDialogType.error,
                      confirmButtonText: '仍要删除',
                    ))),
        demoSection('新增（D 类 P1）：beforeConfirm / actionLayout / actions'),
        demoBlock(
            'beforeConfirm 确认拦截（返回 false 取消弹窗）',
            FilledButton(
                onPressed: () async {
                  final ok = await WotDialog.confirm(context,
                      title: '删除确认',
                      message: '确定删除该项吗？',
                      beforeConfirm: () async {
                        // 这里可弹二次确认或做前置校验。
                        return true;
                      });
                  if (!ok || !context.mounted) return;
                  WotDialog.alert(context, message: '已删除');
                },
                child: const Text('beforeConfirm 拦截'))),
        demoBlock(
            'actions 自定义按钮组 + vertical 纵排',
            FilledButton.tonal(
                onPressed: () => WotDialog.show(
                    context,
                    WotDialogView(
                      title: '选择操作',
                      message: '自定义按钮组示例',
                      actions: [
                        WotDialogAction(text: '收藏', onClick: () {}),
                        WotDialogAction(text: '分享', onClick: () {}),
                        WotDialogAction(text: '取消', onClick: () {}),
                      ],
                      actionLayout: WotDialogActionLayout.vertical,
                    )),
                child: const Text('actions + vertical'))),
      ],
    );
  }
}