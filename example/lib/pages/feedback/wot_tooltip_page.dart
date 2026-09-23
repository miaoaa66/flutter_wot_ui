import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotTooltip 气泡提示示例页。
class WotTooltipPage extends StatelessWidget {
  const WotTooltipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotTooltip 气泡提示',
      children: [
        demoSection('触发方式（trigger: hover / click）'),
        demoBlock('hover 悬停触发',
            WotTooltip(content: '悬停出现的提示', child: WotButton(text: '悬停我', size: WotButtonSize.small))),
        demoBlock('click 点击触发',
            WotTooltip(content: '点击出现的提示', trigger: WotTriggerMode.click, child: WotButton(text: '点击我', size: WotButtonSize.small))),
        demoSection('位置（placement）'),
        demoBlock('placement: top',
            WotTooltip(content: '顶部提示', placement: WotTooltipPlacement.top, trigger: WotTriggerMode.click, child: WotButton(text: '顶部', size: WotButtonSize.small))),
        demoBlock('placement: bottom',
            WotTooltip(content: '底部提示', placement: WotTooltipPlacement.bottom, trigger: WotTriggerMode.click, child: WotButton(text: '底部', size: WotButtonSize.small))),
      ],
    );
  }
}