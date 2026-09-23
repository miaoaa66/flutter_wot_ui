import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCountDown 倒计时示例页。
class WotCountDownPage extends StatelessWidget {
  const WotCountDownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCountDown 倒计时',
      children: [
        demoSection('基础（value 毫秒）'),
        demoBlock('1 小时倒计时（value: 3600*1000）', const WotCountDown(value: 3600 * 1000)),
        demoSection('格式（format）'),
        demoBlock('自定义格式',
            const WotCountDown(value: 12 * 3600 * 1000 + 34 * 60 * 1000 + 56 * 1000, format: 'HH 时 MM 分 SS 秒')),
        demoSection('样式（textStyle）'),
        demoBlock('自定义字号颜色',
            WotCountDown(value: 90 * 1000, textStyle: const TextStyle(fontSize: 20, color: Color(0xFFF14646), fontWeight: FontWeight.bold))),
        demoSection('新增（D 类 P1）：millisecond 毫秒级刷新'),
        demoBlock(
            'millisecond=true + SS 百分秒实时显示',
            WotCountDown(
              value: 60000,
              format: 'mm:ss:SS',
              millisecond: true,
            )),
        demoBlock('默认（每秒一跳，SS 恒 00 属预期）', WotCountDown(value: 60000, format: 'mm:ss:SS')),
      ],
    );
  }
}