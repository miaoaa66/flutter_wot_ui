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

  // 边界 / 步进演示用值。
  num _lo1 = 1;
  num _lo2 = 1;
  num _lo3 = 1;
  num _step = 0;

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
        demoSection('边界（min / max）——含破坏性变更提醒'),
        demoBlock(
          '⚠️ min 默认值曾从 0 改为 1（对齐 wot）。'
          '不传 min 时最小值是 1 而不是 0——需要允许 0 的业务必须显式写 min: 0。'
          '下面两个都减到底，观察下限分别是 0 还是 1。',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('不传 min（下限 = 1）',
                            style: TextStyle(fontSize: 12)),
                        WotInputNumber(
                          modelValue: _lo1,
                          max: 5,
                          onChange: (v) => setState(() => _lo1 = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('min: 0（显式放开下限）',
                            style: TextStyle(fontSize: 12)),
                        WotInputNumber(
                          modelValue: _lo2,
                          min: 0,
                          max: 5,
                          onChange: (v) => setState(() => _lo2 = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('当前值：$_lo1 / $_lo2', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        demoBlock(
          'max 默认值已改为极大值（不再默认 100）。'
          '下面不传 max，一路加到 999 验证不会被静默截断。',
          WotInputNumber(
            modelValue: _lo3,
            onChange: (v) => setState(() => _lo3 = v),
          ),
        ),
        demoBlock(
          'step × precision 组合：step=0.3、precision=1。'
          '浮点步进若不做 precision 修正会累积出 0.30000000000000004 这类值。',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WotInputNumber(
                modelValue: _step,
                min: 0,
                max: 3,
                step: 0.3,
                precision: 1,
                onChange: (v) => setState(() => _step = v),
              ),
              const SizedBox(height: 4),
              Text('当前值：$_step（应为一位小数）',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),

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