import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotThemeBtn 明暗主题切换按钮示例页。
class WotThemeBtnPage extends StatefulWidget {
  const WotThemeBtnPage({super.key});

  @override
  State<WotThemeBtnPage> createState() => _WotThemeBtnPageState();
}

class _WotThemeBtnPageState extends State<WotThemeBtnPage> {
  bool _night1 = false;
  bool _night2 = true;
  bool _disabled = false;
  double _size = 240;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotThemeBtn 主题切换',
      children: [
        demoSection('基础用法（value / onChanged）'),
        demoBlock(
          '点击在 明亮 ⇄ 夜间 间切换',
          Row(
            children: [
              WotThemeBtn(
                value: _night1,
                onChanged: (v) => setState(() => _night1 = v),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: WotText(
                  _night1 ? '当前：夜间' : '当前：明亮',
                  size: 14,
                ),
              ),
            ],
          ),
        ),
        demoSection('尺寸（size，高度按比例自适应）'),
        demoBlock(
          'size = 60 / 100 / 180 / 240 / 320',
          Column(
            children: [
              WotThemeBtn(value: _night2, onChanged: (v) => setState(() => _night2 = v), size: 60),
              const SizedBox(height: 12),
              WotThemeBtn(value: _night2, onChanged: (v) => setState(() => _night2 = v), size: 100),
              const SizedBox(height: 12),
              WotThemeBtn(value: _night2, onChanged: (v) => setState(() => _night2 = v), size: 180),
              const SizedBox(height: 12),
              WotThemeBtn(value: _night2, onChanged: (v) => setState(() => _night2 = v), size: 240),
              const SizedBox(height: 12),
              WotThemeBtn(value: _night2, onChanged: (v) => setState(() => _night2 = v), size: 320),
            ],
          ),
        ),
        demoSection('可调尺寸（Slider 实时调整 width）'),
        demoBlock(
          'size = ${_size.round()}',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: _size,
                min: 140,
                max: 360,
                divisions: 22,
                label: _size.round().toString(),
                onChanged: (v) => setState(() => _size = v),
              ),
              WotThemeBtn(value: _night1, onChanged: (v) => setState(() => _night1 = v), size: _size),
            ],
          ),
        ),
        demoSection('禁用（disabled）'),
        demoBlock(
          'disabled = $_disabled',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WotThemeBtn(value: _night2, onChanged: (v) => setState(() => _night2 = v), disabled: _disabled),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => setState(() => _disabled = !_disabled),
                child: const Text('切换 disabled'),
              ),
            ],
          ),
        ),
        demoSection('边缘阴影（shadow：none / dark / light）'),
        demoBlock(
          'dark 用于浅色背景；light 用于深色背景',
          Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: WotThemeBtn(
                  value: false,
                  shadow: WotThemeBtnShadow.dark,
                  size: 200,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.all(20),
                child: WotThemeBtn(
                  value: true,
                  shadow: WotThemeBtnShadow.light,
                  size: 200,
                ),
              ),
            ],
          ),
        ),
        demoSection('颜色固定，不跟随主题'),
        const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: WotText(
            '本组件所有颜色均为字面值硬编码（蓝天数 / 星空数 / 月亮灰），不读取 '
            'context.wotScheme，因此无论外层 WotConfigProvider 切换浅色或深色，'
            '按钮配色始终保持一致。',
            size: 13,
            type: WotTextType.wotDefault,
          ),
        ),
      ],
    );
  }
}
