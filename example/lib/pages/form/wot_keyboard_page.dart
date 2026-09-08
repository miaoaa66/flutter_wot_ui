import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotKeyboard 数字键盘示例页（联动密码输入）。
class WotKeyboardPage extends StatefulWidget {
  const WotKeyboardPage({super.key});

  @override
  State<WotKeyboardPage> createState() => _WotKeyboardPageState();
}

class _WotKeyboardPageState extends State<WotKeyboardPage> {
  String _pw = '';
  bool _random = false;

  void _keypress(String k) {
    if (_pw.length >= 6) return;
    setState(() => _pw += k);
  }

  void _delete() => setState(() => _pw = _pw.isEmpty ? _pw : _pw.substring(0, _pw.length - 1));

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotKeyboard 键盘',
      children: [
        demoSection('联动密码输入（onKeypress / onDelete）'),
        demoBlock('已输入 $_pw',
            WotPasswordInput(modelValue: _pw, maxLength: 6, onChange: (v) {})),
        demoSection('键盘模式（mode / showTitle）'),
        demoBlock('number 数字键盘（含小数点）',
            WotKeyboard(
              title: '安全键盘',
              showTitle: true,
              mode: WotKeyboardMode.number,
              onKeypress: _keypress,
              onDelete: _delete,
            )),
        demoSection('随机布局与完成键（randomOrder / onPressEnsure）'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _random = !_random), child: Text('randomOrder: $_random'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('随机布局 + 完成回调',
            WotKeyboard(
              mode: WotKeyboardMode.number,
              randomOrder: _random,
              showTitle: true,
              title: '安全键盘',
              onKeypress: _keypress,
              onDelete: _delete,
              onPressEnsure: () => demoToast(context, '完成'),
            )),
        demoSection('身份证键盘'),
        demoBlock('mode=idcard（. 替换为 X）',
            WotKeyboard(
              mode: WotKeyboardMode.idcard,
              showTitle: true,
              onKeypress: (k) => demoToast(context, '按键：$k'),
              onDelete: () {},
            )),
      ],
    );
  }
}