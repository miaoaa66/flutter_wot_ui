import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCheckbox / WotCheckboxGroup 示例页。
class WotCheckboxPage extends StatefulWidget {
  const WotCheckboxPage({super.key});

  @override
  State<WotCheckboxPage> createState() => _WotCheckboxPageState();
}

class _WotCheckboxPageState extends State<WotCheckboxPage> {
  bool _single = false;
  List<Object?> _group = const [1];
  List<Object?> _square = const [];
  List<Object?> _limited = const [];
  List<Object?> _disabled = const [];

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCheckbox 复选框',
      children: [
        demoSection('单个复选框（modelValue / onChange / label）'),
        demoBlock('基础单个',
            WotCheckbox(label: '同意协议', modelValue: _single, onChange: (v) => setState(() => _single = v))),
        demoBlock('自定义颜色 checkColor + size',
            WotCheckbox(label: '主色方块', modelValue: _single, size: 20, checkColor: Colors.orange, onChange: (v) => setState(() => _single = v))),
        demoSection('Group（options 驱动 option / shape / max / min）'),
        demoBlock(
            '基础多选（shape=square 方形）',
            WotCheckboxGroup(
              modelValue: _group,
              shape: 'square',
              options: const [
                WotCheckboxOption(label: '图书', value: 1),
                WotCheckboxOption(label: '音乐', value: 2),
                WotCheckboxOption(label: '旅行', value: 3),
              ],
              onChange: (v) => setState(() => _group = v),
            )),
        demoBlock(
            'shape=circle 圆形',
            WotCheckboxGroup(
              modelValue: _square,
              shape: 'circle',
              options: const [
                WotCheckboxOption(label: '圆形一', value: 1),
                WotCheckboxOption(label: '圆形二', value: 2),
              ],
              onChange: (v) => setState(() => _square = v),
            )),
        demoBlock(
            'min=1 / max=2 限制选中数量',
            WotCheckboxGroup(
              modelValue: _limited,
              min: 1,
              max: 2,
              options: const [
                WotCheckboxOption(label: '最少 1', value: 1),
                WotCheckboxOption(label: '中间', value: 2),
                WotCheckboxOption(label: '最多 2', value: 3),
              ],
              onChange: (v) => setState(() => _limited = v),
            )),
        demoBlock(
            'disabled 单选项禁用',
            WotCheckboxGroup(
              modelValue: _disabled,
              options: const [
                WotCheckboxOption(label: '可选', value: 1),
                WotCheckboxOption(label: '禁用', value: 2, disabled: true),
              ],
              onChange: (v) => setState(() => _disabled = v),
            )),
      ],
    );
  }
}