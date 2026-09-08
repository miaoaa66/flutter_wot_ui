import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSlideVerify 滑动验证示例页。
class WotSlideVerifyPage extends StatefulWidget {
  const WotSlideVerifyPage({super.key});

  @override
  State<WotSlideVerifyPage> createState() => _WotSlideVerifyPageState();
}

class _WotSlideVerifyPageState extends State<WotSlideVerifyPage> {
  bool _ok2 = false;
  bool _disabled = false;

  void _onVerify(bool ok) => demoToast(context, ok ? '验证通过' : '未到终点');

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSlideVerify 滑动验证',
      children: [
        demoSection('基础用法（onChange 判定）'),
        demoBlock('向右滑动完成验证',
            WotSlideVerify(onChange: _onVerify)),
        demoSection('文案（text / successText / errorText）'),
        demoBlock(
            '自定义文案',
            WotSlideVerify(
              text: '按住滑块拖动到最右侧',
              successText: '校验成功',
              errorText: '未成功，请重试',
              modelValue: _ok2,
              onChange: (v) => setState(() => _ok2 = v),
            )),
        demoSection('高度（height）与颜色（color）'),
        demoBlock('height=56 + 主色滑块', WotSlideVerify(height: 56, color: const Color(0xFF12B886), onChange: (v) {})),
        demoSection('状态（disabled）'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用', WotSlideVerify(disabled: _disabled, onChange: (v) {})),
      ],
    );
  }
}