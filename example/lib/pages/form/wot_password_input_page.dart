import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotPasswordInput 密码输入框示例页。
class WotPasswordInputPage extends StatefulWidget {
  const WotPasswordInputPage({super.key});

  @override
  State<WotPasswordInputPage> createState() => _WotPasswordInputPageState();
}

class _WotPasswordInputPageState extends State<WotPasswordInputPage> {
  String _p1 = '';
  String _p2 = '';
  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotPasswordInput 密码输入',
      children: [
        demoSection('基础（maxLength / modelValue / onChange）'),
        demoBlock('6 位密码', WotPasswordInput(modelValue: _p1, onChange: (v) => setState(() => _p1 = v))),
        demoSection('位数与间距（maxLength / gutter）'),
        demoBlock('4 位 + gutter=12',
            WotPasswordInput(modelValue: _p2, maxLength: 4, gutter: 12, onChange: (v) => setState(() => _p2 = v))),
        demoSection('属性（focusColor / obscure / readonly / disabled）'),
        demoBlock('focusColor 聚焦色', WotPasswordInput(modelValue: _p1, focusColor: const Color(0xFF12B886), onChange: (v) => setState(() => _p1 = v))),
        demoBlock('obscure=false 明文点', WotPasswordInput(modelValue: _p2, obscure: false, onChange: (v) => setState(() => _p2 = v))),
        demoSection('状态与事件'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用', WotPasswordInput(modelValue: _p1, disabled: _disabled, onChange: (v) => setState(() => _p1 = v))),
        demoBlock('onInput / onFocus / onBlur 回调',
            WotPasswordInput(
              modelValue: _p1,
              onChange: (v) => setState(() => _p1 = v),
              onInput: (v) => demoToast(context, '输入：$v'),
              onFocus: () => demoToast(context, '聚焦'),
              onBlur: () => demoToast(context, '失焦'),
            )),
      ],
    );
  }
}