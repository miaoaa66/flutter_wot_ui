import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotPopover 气泡弹层示例页。
class WotPopoverPage extends StatelessWidget {
  const WotPopoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotPopover 气泡弹层',
      children: [
        demoSection('基础（content / child / onClick）'),
        demoBlock('点击弹出选项',
            WotPopover(
              content: const [Text('选项一'), Text('选项二')],
              child: WotButton(text: '弹出气泡', size: WotButtonSize.small),
              onClick: (i) => demoToast(context, '点击 $i'),
            )),
        demoSection('位置（placement）'),
        demoBlock('placement: top',
            WotPopover(
              placement: WotPopoverPlacement.top,
              content: const [Text('顶部气泡')],
              child: WotButton(text: '顶部', size: WotButtonSize.small),
            )),
      ],
    );
  }
}