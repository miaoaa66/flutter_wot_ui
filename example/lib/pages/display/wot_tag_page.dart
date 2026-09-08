import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotTag 标签示例页。
class WotTagPage extends StatefulWidget {
  const WotTagPage({super.key});

  @override
  State<WotTagPage> createState() => _WotTagPageState();
}

class _WotTagPageState extends State<WotTagPage> {
  final Set<String> _closed = {};

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotTag 标签',
      children: [
        demoSection('类型（type）'),
        demoBlock('五种主题',
            Wrap(spacing: 8, runSpacing: 8, children: const [
              WotTag(text: '默认'),
              WotTag(text: '成功', type: WotTagType.success),
              WotTag(text: '警告', type: WotTagType.warning),
              WotTag(text: '危险', type: WotTagType.danger),
              WotTag(text: '信息', type: WotTagType.info),
            ])),
        demoSection('变体（variant）'),
        demoBlock('plain / dark / light',
            Wrap(spacing: 8, runSpacing: 8, children: const [
              WotTag(text: '默认'),
              WotTag(text: '描边', variant: WotTagVariant.plain),
              WotTag(text: '实心', variant: WotTagVariant.dark),
              WotTag(text: '浅色', variant: WotTagVariant.light),
            ])),
        demoSection('尺寸与圆角（size / round）'),
        demoBlock('尺寸',
            Wrap(spacing: 8, runSpacing: 8, children: const [
              WotTag(text: '大号', size: WotTagSize.large),
              WotTag(text: '小号', size: WotTagSize.small),
              WotTag(text: '迷你', size: WotTagSize.mini, variant: WotTagVariant.plain),
            ])),
        demoBlock('圆角 / 方角',
            Wrap(spacing: 8, runSpacing: 8, children: const [
              WotTag(text: '圆角', round: true, type: WotTagType.success),
              WotTag(text: '方角', round: false, type: WotTagType.warning),
            ])),
        demoSection('自定义色（color）与交互'),
        demoBlock('自定义颜色',
            WotTag(text: '自定义色', color: const Color(0xFF8B5CF6), variant: WotTagVariant.plain)),
        demoBlock('可点击 onClick',
            WotTag(text: '可点击', onClick: () => demoToast(context, '点击标签'))),
        demoBlock('closable 可关闭',
            !_closed.contains('c1')
                ? WotTag(text: '可关闭', closable: true, onClose: () => setState(() => _closed.add('c1')))
                : const WotTag(text: '已关闭')),
      ],
    );
  }
}