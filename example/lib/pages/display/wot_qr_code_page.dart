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
      ],
    );
  }
}