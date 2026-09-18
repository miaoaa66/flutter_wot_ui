import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotProgress 进度条示例页。
class WotProgressPage extends StatelessWidget {
  const WotProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotProgress 进度条',
      children: [
        demoSection('基础（modelValue）'),
        demoBlock('默认（showText 默认开）', const WotProgress(modelValue: 60)),
        demoSection('文字位置（textInside / showText）'),
        demoBlock('textInside 内部文字', const WotProgress(modelValue: 45, textInside: true)),
        demoBlock('textInside 内部文字', const WotProgress(modelValue: 2, textInside: true)),
        demoBlock('showText=false 隐藏文字', const WotProgress(modelValue: 80, showText: false)),
        demoSection('样式（color / trackColor / strokeWidth）'),
        demoBlock('自定义颜色 + 粗细',
            WotProgress(modelValue: 70, strokeWidth: 20, color: const Color(0xFF12B886), trackColor: const Color(0xFFE9F7F1))),
        demoSection('格式化（format）'),
        demoBlock('自定义 format', WotProgress(modelValue: 33, format: (v) => '已用 ${v.toInt()}%')),
      ],
    );
  }
}