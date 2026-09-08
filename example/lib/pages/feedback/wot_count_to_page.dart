import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCountTo 数字滚动示例页。
class WotCountToPage extends StatelessWidget {
  const WotCountToPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCountTo 数字滚动',
      children: [
        demoSection('基础（modelValue / prefix / suffix）'),
        demoBlock('金额滚动',
            const WotCountTo(modelValue: 1234567, prefix: '¥ ', suffix: ' 元')),
        demoSection('时长（duration）'),
        demoBlock('5 秒缓动',
            WotCountTo(modelValue: 9999, duration: const Duration(seconds: 5), textStyle: const TextStyle(fontSize: 24))),
      ],
    );
  }
}