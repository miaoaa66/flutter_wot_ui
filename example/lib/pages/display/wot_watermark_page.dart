import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotWatermark 水印示例页。
class WotWatermarkPage extends StatelessWidget {
  const WotWatermarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotWatermark 水印',
      children: [
        demoSection('基础（content / fontSize）'),
        demoBlock('文字水印铺满内容区',
            WotWatermark(
              content: 'Wot UI Flutter',
              fontSize: 14,
              child: Container(
                height: 120,
                color: context.wotScheme.filledContent,
                alignment: Alignment.center,
                child: const WotText('水印底层内容'),
              ),
            )),
        demoSection('属性（rotate / opacity / fullScreen）'),
        demoBlock('自定义旋转与透明度',
            WotWatermark(
              content: '机密资料',
              fontSize: 12,
              rotate: -30,
              opacity: 0.4,
              child: Container(
                height: 100,
                color: context.wotScheme.filledContent,
                alignment: Alignment.center,
                child: const WotText('水印底层内容'),
              ),
            )),
      ],
    );
  }
}