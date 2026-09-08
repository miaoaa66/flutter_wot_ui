import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotToast 轻提示（命令式）示例页。
class WotToastPage extends StatelessWidget {
  const WotToastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotToast 轻提示',
      children: [
        demoSection('类型（text / success / error / warning / info / loading）'),
        demoBlock('各类型便捷方法',
            Wrap(spacing: 8, runSpacing: 8, children: [
              WotButton(text: '文本', size: WotButtonSize.small, onClick: () => WotToast.text(context, '轻提示')),
              WotButton(text: '成功', size: WotButtonSize.small, type: WotButtonType.success, onClick: () => WotToast.success(context, '操作成功')),
              WotButton(text: '失败', size: WotButtonSize.small, type: WotButtonType.danger, onClick: () => WotToast.error(context, '操作失败')),
              WotButton(text: '警告', size: WotButtonSize.small, type: WotButtonType.warning, onClick: () => WotToast.warning(context, '警告信息')),
              WotButton(text: '信息', size: WotButtonSize.small, type: WotButtonType.info, onClick: () => WotToast.info(context, '信息提示')),
              WotButton(text: '加载中', size: WotButtonSize.small, onClick: () => WotToast.loading(context, '加载中')),
            ])),
        demoSection('位置（position）'),
        demoBlock('top / center / bottom',
            Wrap(spacing: 8, runSpacing: 8, children: [
              WotButton(text: '顶部', size: WotButtonSize.small, onClick: () => WotToast.text(context, '顶部提示', position: 'top')),
              WotButton(text: '居中', size: WotButtonSize.small, onClick: () => WotToast.text(context, '居中提示', position: 'center')),
              WotButton(text: '底部', size: WotButtonSize.small, onClick: () => WotToast.text(context, '底部提示', position: 'bottom')),
            ])),
        demoSection('自定义（show / icon / duration）'),
        demoBlock('自定义图标 + 时长',
            Wrap(spacing: 8, runSpacing: 8, children: [
              WotButton(text: '自定义图标', size: WotButtonSize.small, type: WotButtonType.primary, onClick: () => WotToast.show(context, '自定义图标', icon: Icons.favorite)),
              WotButton(text: '3 秒时长', size: WotButtonSize.small, type: WotButtonType.info, onClick: () => WotToast.text(context, '长提示 3s', duration: const Duration(seconds: 3))),
            ])),
      ],
    );
  }
}