import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCircle 环形进度示例页。
class WotCirclePage extends StatelessWidget {
  const WotCirclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCircle 环形进度',
      children: [
        demoSection('基础（modelValue / size / strokeWidth）'),
        demoBlock('默认（size 100 + 文字）',
            const WotCircle(modelValue: 75, size: 120)),
        demoBlock('自定义粗细 + 颜色（color / trackColor）',
            Row(children: [
              WotCircle(modelValue: 60, size: 120, strokeWidth: 18, color: const Color(0xFF12B886), trackColor: const Color(0xFFE9F7F1)),
              const SizedBox(width: 20),
              WotCircle(modelValue: 40, size: 110, strokeWidth: 8, color: const Color(0xFFF14646)),
            ])),
        demoSection('文字（textFormat / showText）'),
        demoBlock('自定义文字',
            WotCircle(modelValue: 85, size: 120, textFormat: (v) => '${v.toInt()}% 完成')),
        demoBlock('showText=false',
            WotCircle(modelValue: 30, size: 100, showText: false)),
      ],
    );
  }
}