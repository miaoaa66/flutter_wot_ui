import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSegmented 分段控制器示例页。
class WotSegmentedPage extends StatefulWidget {
  const WotSegmentedPage({super.key});

  @override
  State<WotSegmentedPage> createState() => _WotSegmentedPageState();
}

class _WotSegmentedPageState extends State<WotSegmentedPage> {
  Object? _v1 = 1;
  Object? _v2 = 'a';
  Object? _v3 = 'x';

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSegmented 分段控制器',
      children: [
        demoSection('基础（options / modelValue / onChange）'),
        demoBlock('五个选项',
            WotSegmented(
              modelValue: _v1,
              onChange: (v) => setState(() => _v1 = v),
              options: const [
                WotSegmentedOption(label: '选项一', value: 1),
                WotSegmentedOption(label: '选项二', value: 2),
                WotSegmentedOption(label: '选项三', value: 3),
                WotSegmentedOption(label: '选项四', value: 4),
              ],
            )),
        demoSection('形状与尺寸（shape / size）'),
        demoBlock('shape=pill + size=small',
            WotSegmented(
              modelValue: _v2,
              shape: WotSegmentedShape.pill,
              size: 'small',
              onChange: (v) => setState(() => _v2 = v),
              options: const [
                WotSegmentedOption(label: '小号', value: 'a'),
                WotSegmentedOption(label: '控件', value: 'b'),
              ],
            )),
        demoSection('样式（block / activeColor）'),
        demoBlock('activeColor + icon（含禁用项）',
            WotSegmented(
              modelValue: _v3,
              activeColor: const Color(0xFF12B886),
              onChange: (v) => setState(() => _v3 = v),
              options: const [
                WotSegmentedOption(label: '可点', value: 'x', icon: 'star'),
                WotSegmentedOption(label: '禁用', value: 'y', disabled: true, icon: 'close'),
                WotSegmentedOption(label: '三', value: 'z', icon: 'user'),
              ],
            )),
      ],
    );
  }
}