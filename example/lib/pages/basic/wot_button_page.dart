import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotButton 按钮示例页。
class WotButtonPage extends StatefulWidget {
  const WotButtonPage({super.key});

  @override
  State<WotButtonPage> createState() => _WotButtonPageState();
}

class _WotButtonPageState extends State<WotButtonPage> {
  bool _disabled = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotButton 按钮',
      children: [
        demoSection('类型（type）'),
        demoBlock('type 六态',
            Wrap(spacing: 8, runSpacing: 8, children: const [
              WotButton(text: '主要', type: WotButtonType.primary),
              WotButton(text: '成功', type: WotButtonType.success),
              WotButton(text: '信息', type: WotButtonType.info),
              WotButton(text: '警告', type: WotButtonType.warning),
              WotButton(text: '危险', type: WotButtonType.danger),
            ])),
        demoSection('尺寸（size）'),
        demoBlock('mini / small / medium / large',
            Wrap(spacing: 8, runSpacing: 8, children: const [
              WotButton(text: 'mini', size: WotButtonSize.mini),
              WotButton(text: 'small', size: WotButtonSize.small),
              WotButton(text: 'medium', size: WotButtonSize.medium),
              WotButton(text: 'large', size: WotButtonSize.large),
            ])),
        demoSection('变体（variant）'),
        demoBlock('base / plain / dashed / soft / subtle / text',
            Wrap(spacing: 8, runSpacing: 8, children: [
              WotButton(text: '实心', variant: WotButtonVariant.base),
              WotButton(text: '线框', variant: WotButtonVariant.plain),
              WotButton(text: '虚线', variant: WotButtonVariant.dashed),
              WotButton(text: '柔和', variant: WotButtonVariant.soft),
              WotButton(text: '浅淡', variant: WotButtonVariant.subtle),
              WotButton(text: '文字', variant: WotButtonVariant.text),
            ])),
        demoSection('圆角/块状/hairline（round / block / hairline）'),
        demoBlock('round 圆角 + block 块状',
            WotButton(text: '块状圆角', block: true, round: true, variant: WotButtonVariant.plain, onClick: () => demoToast(context, '块状按钮'))),
        demoBlock('hairline 细边', WotButton(text: 'hairline 描边', variant: WotButtonVariant.plain, hairline: true)),
        demoSection('颜色与图标（color / icon / textColor）'),
        demoBlock('自定义 color',
            Wrap(spacing: 8, runSpacing: 8, children: [
              WotButton(text: '薄荷绿', color: const Color(0xFF12B886)),
              WotButton(text: '带图标', icon: 'star', type: WotButtonType.warning),
            ])),
        demoSection('状态（disabled / loading）'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled'))),
          const SizedBox(width: 8),
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _loading = !_loading), child: Text('loading: $_loading'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用', WotButton(text: '禁用按钮', disabled: _disabled, onClick: () {})),
        demoBlock('loading 加载中', WotButton(text: '加载中', loading: _loading, onClick: () {})),
        demoSection('自定义内容（child）'),
        demoBlock('child 插槽', WotButton(type: WotButtonType.success, child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, size: 18), SizedBox(width: 4), Text('自定义内容')]))),
      ],
    );
  }
}