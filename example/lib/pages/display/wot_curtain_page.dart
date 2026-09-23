import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCurtain 幕布示例页。
class WotCurtainPage extends StatefulWidget {
  const WotCurtainPage({super.key});

  @override
  State<WotCurtainPage> createState() => _WotCurtainPageState();
}

class _WotCurtainPageState extends State<WotCurtainPage> {
  bool _show = false;
  bool _showSrc = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCurtain 幕布',
      children: [
        demoSection('基础（modelValue / onModelUpdate）'),
        demoBlock('点击开启幕布',
            Column(children: [
              WotButton(text: '开启幕布', size: WotButtonSize.small, onClick: () => setState(() => _show = true)),
              const SizedBox(height: 8),
              if (_show)
                WotCurtain(
                  modelValue: _show,
                  onModelUpdate: (v) => setState(() => _show = v),
                  child: Container(
                    width: 260,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        WotText('活动公告', bold: true, size: 16),
                        SizedBox(height: 12),
                        WotText('这是一则全屏幕布活动公告内容。', type: WotTextType.wotDefault),
                      ],
                    ),
                  ),
                ),
            ])),
        demoSection('新增（D 类 P1）：src 图片幕布 + closePosition'),
        demoBlock(
            'src 图片幕布（width/height 自定义尺寸）',
            FilledButton(
                onPressed: () => setState(() => _showSrc = true),
                child: const Text('打开图片幕布'))),
        WotCurtain(
          modelValue: _showSrc,
          src: 'https://picsum.photos/300/360',
          width: 300,
          height: 360,
          maskClose: true,
          closePosition: WotCurtainClosePosition.inside,
          onModelUpdate: (v) => setState(() => _showSrc = v),
        ),
      ],
    );
  }
}