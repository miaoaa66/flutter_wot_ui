import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotBarcode 条形码示例页。
class WotBarcodePage extends StatelessWidget {
  const WotBarcodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotBarcode 条形码',
      children: [
        demoSection('基础（Code128 / color / showValue）'),
        demoBlock('订单号条码', const WotBarcode(value: '20260807120001', type: WotBarcodeType.code128)),
        demoSection('类型（type）'),
        demoBlock('Code39', const WotBarcode(value: 'HELLO-123', type: WotBarcodeType.code39, width: 220)),
        demoBlock('EAN-13', const WotBarcode(value: '6901234567892', type: WotBarcodeType.ean13)),
        demoBlock('EAN-8', const WotBarcode(value: '96385074', type: WotBarcodeType.ean8)),
        demoBlock('UPC-A（11 位数据，校验位库自动补）',
            const WotBarcode(value: '01234567890', type: WotBarcodeType.upcA)),
        demoBlock('ITF-14', const WotBarcode(value: '15400141288763', type: WotBarcodeType.itf14)),
        demoSection('样式（color / backgroundColor / height / showValue）'),
        demoBlock('自定义颜色 + 更高条区 + 隐藏文本',
            WotBarcode(value: 'C128', height: 90, color: const Color(0xFF12B886), backgroundColor: const Color(0xFFF0FBF6), showValue: false)),
        demoBlock('自定义文本样式', WotBarcode(value: '2026-SEP', valueStyle: const TextStyle(fontSize: 12, color: Color(0xFF4480FF), fontWeight: FontWeight.bold))),
      ],
    );
  }
}