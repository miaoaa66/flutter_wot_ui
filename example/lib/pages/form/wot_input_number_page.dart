import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotInputNumber 数字输入框示例页。
class WotInputNumberPage extends StatefulWidget {
  const WotInputNumberPage({super.key});

  @override
  State<WotInputNumberPage> createState() => _WotInputNumberPageState();
}

class _WotInputNumberPageState extends State<WotInputNumberPage> {
  num _n1 = 1;
  num _n2 = 0;
  num _n3 = 1;
  num _n4 = 5;
  bool _disabled = false;
  bool _readonly = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotInputNumber 数字输入框',
      children: [
        demoSection('基础用法（modelValue / onChange）'),
        demoBlock('基础=1', WotInputNumber(modelValue: _n1, onChange: (v) => setState(() => _n1 = v))),
        demoBlock('min=0 max=10 step=0.1 precision=2',
            WotInputNumber(modelValue: _n2, min: 0, max: 10, step: 0.1, precision: 2, onChange: (v) => setState(() => _n2 = v))),
        demoBlock('inputWidth=80 buttonSize=36 自定义尺寸',
            WotInputNumber(modelValue: _n3, inputWidth: 80, buttonSize: 36, onChange: (v) => setState(() => _n3 = v))),
        demoBlock('longPress 长按连续增减',
            WotInputNumber(modelValue: _n4, longPress: true, onChange: (v) => setState(() => _n4 = v))),
        demoSection('状态'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled'))),
          const SizedBox(width: 8),
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _readonly = !_readonly), child: Text('readonly: $_readonly'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用', WotInputNumber(modelValue: _n1, disabled: _disabled, onChange: (v) => setState(() => _n1 = v))),
        demoBlock('readonly 只读（仅按钮可操作）', WotInputNumber(modelValue: _n1, readonly: _readonly, onChange: (v) => setState(() => _n1 = v))),
        demoSection('表单集成（name）'),
        demoBlock('name 登记到 WotForm（提交时取值）',
            WotForm(
              submitButtonText: '提交',
              showSubmitButton: true,
              onSubmit: (c) => demoToast(context, '数量 = ${c.valueOf('qty')}'),
              children: [
                WotFormItem(name: 'qty', label: '数量', child: WotInputNumber(name: 'qty', modelValue: _n1, onChange: (v) => setState(() => _n1 = v))),
              ],
            )),
      ],
    );
  }
}