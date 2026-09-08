import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotActionSheet 操作菜单（命令式）示例页。
class WotActionSheetPage extends StatelessWidget {
  const WotActionSheetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotActionSheet 操作菜单',
      children: [
        demoSection('基础（actions / title）'),
        demoBlock('弹出选项并返回选择',
            WotButton(
              text: '弹出选项',
              size: WotButtonSize.small,
              onClick: () async {
                final r = await WotActionSheet.show(context, actions: const [
                  WotActionSheetItem(name: '分享'),
                  WotActionSheetItem(name: '编辑', color: Color(0xFF4480FF)),
                  WotActionSheetItem(name: '删除', color: Color(0xFFF14646)),
                ], title: '请选择操作');
                if (!context.mounted) return;
                if (r != null) demoToast(context, '选择：${r.name}');
              },
            )),
        demoSection('showCancel / 事件（onSelect / onCancel）'),
        demoBlock('无取消按钮 + 回调',
            WotButton(
              text: 'showCancel=false',
              size: WotButtonSize.small,
              type: WotButtonType.primary,
              onClick: () async {
                final r = await WotActionSheet.show(
                  context,
                  actions: const [
                    WotActionSheetItem(name: '拍照'),
                    WotActionSheetItem(name: '相册'),
                  ],
                  title: '选择图片来源',
                  showCancel: false,
                  onSelect: (item) => demoToast(context, '选中：${item.name}'),
                  onCancel: () => demoToast(context, '已取消'),
                );
                if (!context.mounted) return;
                if (r != null) demoToast(context, '选择返回：${r.name}');
              },
            )),
        demoSection('禁用项（disabled）'),
        demoBlock('含禁用与 loading 动作',
            WotButton(
              text: '禁用动作',
              size: WotButtonSize.small,
              type: WotButtonType.danger,
              onClick: () async {
                final r = await WotActionSheet.show(context, actions: const [
                  WotActionSheetItem(name: '可点'),
                  WotActionSheetItem(name: '禁用', disabled: true),
                ], title: '动作列表');
                if (!context.mounted) return;
                if (r != null) demoToast(context, '选择：${r.name}');
              },
            )),
      ],
    );
  }
}