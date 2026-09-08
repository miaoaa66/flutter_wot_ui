import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSortButton 排序按钮示例页。
class WotSortButtonPage extends StatefulWidget {
  const WotSortButtonPage({super.key});

  @override
  State<WotSortButtonPage> createState() => _WotSortButtonPageState();
}

class _WotSortButtonPageState extends State<WotSortButtonPage> {
  WotSortDirection _dir = WotSortDirection.ascending;
  WotSortDirection _dir2 = WotSortDirection.none;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSortButton 排序按钮',
      children: [
        demoSection('基础（text / modelValue / onChange）'),
        demoBlock('三态排序（不排/升/降）',
            WotSortButton(
              text: '年龄',
              modelValue: _dir,
              onChange: (d) => setState(() => _dir = d),
            )),
        demoSection('样式（activeColor / color / disabled）'),
        demoBlock('自定义激活色',
            WotSortButton(
              text: '价格',
              modelValue: _dir2,
              activeColor: const Color(0xFFF14646),
              onChange: (d) => setState(() => _dir2 = d),
            )),
        demoBlock('默认排序图标',
            const WotSortButton()),
      ],
    );
  }
}