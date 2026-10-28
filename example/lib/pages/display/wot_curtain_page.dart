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
  bool _showOutside = false;

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
        demoSection('位置（position）与关闭按钮在外（closePosition: outside）'),
        demoBlock(
            'position: bottom（幕布贴底展示）+ closePosition: outside'
            '（关闭按钮在幕布外 18px，命中区有预留；默认 inside 在幕布内）',
            FilledButton(
                onPressed: () => setState(() => _showOutside = true),
                child: const Text('打开底部幕布'))),
        WotCurtain(
          modelValue: _showOutside,
          position: WotCurtainPosition.bottom,
          closePosition: WotCurtainClosePosition.outside,
          onModelUpdate: (v) => setState(() => _showOutside = v),
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WotText('贴底幕布', bold: true, size: 16),
                SizedBox(height: 12),
                WotText('关闭按钮显示在幕布外侧。', type: WotTextType.wotDefault),
              ],
            ),
          ),
        ),
      ],
    );
  }
}