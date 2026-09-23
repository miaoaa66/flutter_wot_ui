import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotQrCode 二维码示例页。
class WotQrCodePage extends StatelessWidget {
  const WotQrCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotQrCode 二维码',
      children: [
        demoSection('基础（value / size）'),
        demoBlock('160px 二维码',
            const WotQrCode(value: 'https://wot-design-uni.cn', size: 160)),
        demoSection('其余尺寸'),
        demoBlock('100px', const WotQrCode(value: 'https://flutter.dev', size: 100)),
        demoSection('新增（D 类 P1）：dotType / margin / gapless'),
        demoBlock('dotType=circle 圆点码', WotQrCode(value: 'https://example.com', size: 120, dotType: WotQrCodeDotType.circle)),
        demoBlock('margin 内边距', WotQrCode(value: 'https://example.com', size: 120, margin: const EdgeInsets.all(12), border: 1)),
      ],
    );
  }
}