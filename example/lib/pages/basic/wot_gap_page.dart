import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotGap 间距示例页。
class WotGapPage extends StatelessWidget {
  const WotGapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotGap 间距',
      children: [
        demoSection('横向/纵向间距（gap / flex）'),
        demoBlock('gap=12 纵向空隙',
            Column(children: [
              Container(height: 28, color: Colors.red.withValues(alpha: 0.4), alignment: Alignment.center, child: const Text('上')),
              const WotGap(flex: true, gap: 16),
              Container(height: 28, color: Colors.blue.withValues(alpha: 0.4), alignment: Alignment.center, child: const Text('下')),
            ])),
        demoBlock('水平空隙（flex=false）',
            Row(children: [
              Container(width: 60, height: 30, color: Colors.red.withValues(alpha: 0.4)),
              const WotGap(gap: 16),
              Container(width: 60, height: 30, color: Colors.blue.withValues(alpha: 0.4)),
            ])),
        demoSection('背景色（bgColor）'),
        demoBlock('bgColor 留白底色', const WotGap(flex: true, gap: 24, bgColor: Color(0xFFF5F5F5))),
        demoSection('覆盖尺寸（width）'),
        demoBlock('width 覆盖', const WotGap(flex: true, gap: 12, width: 60, bgColor: Color(0xFFE7F1FF))),
      ],
    );
  }
}