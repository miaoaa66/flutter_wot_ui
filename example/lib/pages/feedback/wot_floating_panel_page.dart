import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotFloatingPanel 底部浮动面板示例页。
class WotFloatingPanelPage extends StatelessWidget {
  const WotFloatingPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotFloatingPanel 底部浮动面板',
      children: [
        demoSection('基础（header / child / 拖动把手）'),
        demoBlock('拖动调整高度',
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Container(color: context.wotScheme.filledStrong),
                  WotFloatingPanel(
                    header: const Text('浮动面板'),
                    child: const Center(child: WotText('向上拖动展开，可调整高度')),
                  ),
                ],
              ),
            )),
        demoSection('吸附点（anchor / minHeight）'),
        demoBlock('minHeight=80',
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Container(color: context.wotScheme.filledStrong),
                  WotFloatingPanel(
                    minHeight: 80,
                    header: const Text('面板 (min=80)'),
                    child: const Center(child: WotText('内容区')),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}