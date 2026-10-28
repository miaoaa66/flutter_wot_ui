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
  Object? _v4 = 'a';
  Object? _v5 = '1';

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
              size: WotSegmentedSize.small,
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
        demoSection('边界（长文案 / 超多选项，非 block 自适应）'),
        demoBlock(
            '非 block 长文案：每项最小 88、超长自然撑开不再截断；'
            '整体超宽时水平滚动（此前 options.length×88 定宽必溢出）',
            WotSegmented(
              modelValue: _v4,
              onChange: (v) => setState(() => _v4 = v),
              options: const [
                WotSegmentedOption(label: '超长的选项文案一', value: 'a'),
                WotSegmentedOption(label: '更长的选项文案二号', value: 'b'),
                WotSegmentedOption(label: '短', value: 'c'),
              ],
            )),
        demoBlock(
            '非 block 八个选项：窄屏整体超宽 → 水平滑动查看（不溢出崩溃）',
            WotSegmented(
              modelValue: _v5,
              onChange: (v) => setState(() => _v5 = v),
              options: const [
                WotSegmentedOption(label: '一', value: '1'),
                WotSegmentedOption(label: '二', value: '2'),
                WotSegmentedOption(label: '三', value: '3'),
                WotSegmentedOption(label: '四', value: '4'),
                WotSegmentedOption(label: '五', value: '5'),
                WotSegmentedOption(label: '六', value: '6'),
                WotSegmentedOption(label: '七', value: '7'),
                WotSegmentedOption(label: '八', value: '8'),
              ],
            )),
      ],
    );
  }
}