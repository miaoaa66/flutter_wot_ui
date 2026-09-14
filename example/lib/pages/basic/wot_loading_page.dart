import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotLoading 加载指示器示例页。
class WotLoadingPage extends StatelessWidget {
  const WotLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotLoading 加载',
      children: [
        demoSection('基础（text / size）'),
        demoBlock('无文字 + 带文字',
            Row(children: const [
              WotLoading(),
              SizedBox(width: 16),
              WotLoading(text: '加载中...', size: 24),
            ])),
        demoSection('排列方向（vertical）'),
        demoBlock('vertical 上下排列', WotLoading(vertical: true, size: 24)),
        demoSection('颜色（color / textColor / strokeWidth）'),
        demoBlock('自定义指示器与文字颜色',
            WotLoading(text: '主色加载', size: 24, color: const Color(0xFF12B886), textColor: const Color(0xFF12B886))),
        demoBlock('strokeWidth 描边宽度',
            WotLoading(size: 32, color: const Color(0xFF2683F0), strokeWidth: 2)),
        demoSection('动画类型（animationType）'),
        demoBlock('breathing（旋转+弧长呼吸，默认）',
            WotLoading(size: 32, color: const Color(0xFF2683F0), animationType: WotLoadingAnimationType.breathing)),
        demoBlock('uniform（匀速旋转半圆）',
            WotLoading(size: 32, color: const Color(0xFF12B886), animationType: WotLoadingAnimationType.uniform)),
        demoBlock('pulse（圆环缩放脉动）',
            WotLoading(size: 32, color: const Color(0xFFE67E22), animationType: WotLoadingAnimationType.pulse)),
      ],
    );
  }
}
