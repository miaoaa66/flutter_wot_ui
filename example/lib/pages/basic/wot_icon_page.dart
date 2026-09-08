import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotIcon 图标示例页。
class WotIconPage extends StatelessWidget {
  const WotIconPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotIcon 图标',
      children: [
        demoSection('基础图标（name / size / color）'),
        demoBlock('常用图标集合',
            Wrap(spacing: 12, runSpacing: 12, children: const [
              WotIcon(name: 'add', size: 24),
              WotIcon(name: 'close', size: 24),
              WotIcon(name: 'star', size: 24, color: Color(0xFFFAAD14)),
              WotIcon(name: 'heart', size: 24, color: Color(0xFFFF357C)),
              WotIcon(name: 'search', size: 24),
              WotIcon(name: 'arrow-left', size: 24),
              WotIcon(name: 'arrow-right', size: 24),
              WotIcon(name: 'arrow-down', size: 24),
              WotIcon(name: 'success', size: 24, color: Color(0xFF12B886)),
              WotIcon(name: 'info', size: 24, color: Color(0xFF2683F0)),
            ])),
        demoSection('颜色'),
        demoBlock('默认 / 自定义颜色',
            Wrap(spacing: 12, runSpacing: 12, children: const [
              WotIcon(name: 'settings', size: 24),
              WotIcon(name: 'user', size: 24, color: Color(0xFFF14646)),
              WotIcon(name: 'warning', size: 24, color: Color(0xFFFAAD14)),
            ])),
        demoSection('尺寸'),
        demoBlock('不同 size（16 / 24 / 32 / 48）',
            Wrap(spacing: 16, runSpacing: 12, children: const [
              WotIcon(name: 'add', size: 16),
              WotIcon(name: 'add', size: 24),
              WotIcon(name: 'add', size: 32),
              WotIcon(name: 'add', size: 48, color: Color(0xFF12B886)),
            ])),
        demoSection('事件（onClick）'),
        demoBlock('点击图标', const WotIcon(name: 'star', size: 32)),
      ],
    );
  }
}