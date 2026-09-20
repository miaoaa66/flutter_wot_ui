import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotRadio / WotRadioGroup 示例页。
class WotRadioPage extends StatefulWidget {
  const WotRadioPage({super.key});

  @override
  State<WotRadioPage> createState() => _WotRadioPageState();
}

class _WotRadioPageState extends State<WotRadioPage> {
  Object? _v1 = 1;
  Object? _v2 = 'a';
  bool _tDisabled = false;
  bool _tReadonly = false;
  bool _tError = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotRadio 单选框',
      children: [
        demoSection('Group（options 驱动 / shape）'),
        demoBlock('基础单选（shape=circle）',
            WotRadioGroup(
              modelValue: _v1,
              shape: 'circle',
              options: const [
                WotRadioOption(label: '选项一', value: 1),
                WotRadioOption(label: '选项二', value: 2),
                WotRadioOption(label: '禁用', value: 3, disabled: true),
              ],
              onChange: (v) => setState(() => _v1 = v),
            )),
        demoBlock('shape=square 方形',
            WotRadioGroup(
              modelValue: _v2,
              shape: 'square',
              options: const [
                WotRadioOption(label: '方案 A', value: 'a', color: Colors.teal),
                WotRadioOption(label: '方案 B', value: 'b'),
              ],
              onChange: (v) => setState(() => _v2 = v),
            )),
        demoSection('custom children（使用 WotRadio 子项）'),
        demoBlock('自定义 color 单选项',
            WotRadioGroup(
              modelValue: _v1,
              options: const [
                WotRadioOption(label: '红色', value: 1, color: Colors.red),
                WotRadioOption(label: '蓝色', value: 2, color: Colors.blue),
              ],
              onChange: (v) => setState(() => _v1 = v),
            )),
        demoSection('三态（disabled / readonly / error）'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.tonal(onPressed: () => setState(() => _tDisabled = !_tDisabled), child: Text('disabled: $_tDisabled')),
          FilledButton.tonal(onPressed: () => setState(() => _tReadonly = !_tReadonly), child: Text('readonly: $_tReadonly')),
          FilledButton.tonal(onPressed: () => setState(() => _tError = !_tError), child: Text('error: $_tError')),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 整项灰化（圆点 / 边框 / 标签一并变灰）',
            WotRadio(label: '禁用单选', modelValue: true, disabled: _tDisabled)),
        demoBlock('readonly 只读（锁切换、保持正常配色 —— 区别于 disabled 的灰化）',
            WotRadio(label: '只读单选', modelValue: true, readonly: _tReadonly)),
        demoBlock('error 校验失败（未选中描边与标签转红）',
            WotRadio(label: '校验失败', modelValue: false, error: _tError)),
      ],
    );
  }
}