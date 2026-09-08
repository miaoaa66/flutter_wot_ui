import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCascader 级联选择器示例页。
class WotCascaderPage extends StatefulWidget {
  const WotCascaderPage({super.key});

  @override
  State<WotCascaderPage> createState() => _WotCascaderPageState();
}

class _WotCascaderPageState extends State<WotCascaderPage> {
  List<Object?> _region = ['gd', 'gz'];
  List<Object?> _empty = [];
  bool _disabled = false;

  static const List<WotCascadeOption> _options = [
    WotCascadeOption(text: '浙江', value: 'zj', children: [
      WotCascadeOption(text: '杭州', value: 'hz'),
      WotCascadeOption(text: '宁波', value: 'nb'),
      WotCascadeOption(text: '温州', value: 'wz'),
    ]),
    WotCascadeOption(text: '广东', value: 'gd', children: [
      WotCascadeOption(text: '广州', value: 'gz'),
      WotCascadeOption(text: '深圳', value: 'sz'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCascader 级联',
      children: [
        demoSection('基础（options 树 / modelValue 回显）'),
        demoBlock('两级级联 + 受控回显',
            WotCascader(options: _options, modelValue: _region, onChange: (v) => setState(() => _region = v))),
        demoSection('占位与默认展开'),
        demoBlock(
            'placeholder 占位（未选择）',
            WotCascader(options: _options, modelValue: _empty, placeholder: '请选择所在地区', onChange: (v) => setState(() => _empty = v))),
        demoSection('状态（disabled）'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用', WotCascader(options: _options, modelValue: _region, disabled: _disabled, onChange: (v) => setState(() => _region = v))),
      ],
    );
  }
}