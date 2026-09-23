import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSlideVerify 滑动验证示例页。
///
/// 覆盖：text / successText / **errorText（A 类死参数 #13）** /
/// height / color / disabled / modelValue 受控复位 / onChange。
class WotSlideVerifyPage extends StatefulWidget {
  const WotSlideVerifyPage({super.key});

  @override
  State<WotSlideVerifyPage> createState() => _WotSlideVerifyPageState();
}

class _WotSlideVerifyPageState extends State<WotSlideVerifyPage> {
  bool _ok2 = false;
  bool _disabled = false;
  String _log = '—';

  /// 失败态演示：拖到中途松手 → onChange(false)，组件内展示 errorText。
  void _onVerify(bool ok) {
    setState(() {
      _log = ok ? 'onChange(true) 已通过' : 'onChange(false) 未到终点';
    });
    demoToast(context, ok ? '验证通过' : '未到终点');
  }

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSlideVerify 滑动验证',
      children: [
        demoSection('基础用法（onChange 判定）'),
        demoBlock(
          '滑到底松手 = 通过；中途松手 = 不通过。'
          '下面这条会把 onChange 的布尔值回写到页面，方便确认判定逻辑。',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WotSlideVerify(onChange: _onVerify),
              const SizedBox(height: 6),
              Text('回调：$_log', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),

        demoSection('文案（text / successText / errorText）'),
        demoBlock(
          'errorText（A 类死参数 #13）：拖到中途松手，'
          '轨道中央会显示 errorText，1.2 秒后自动复原；'
          '重新拖动会立即清除失败态。',
          WotSlideVerify(
            text: '按住滑块拖动到最右侧',
            successText: '校验成功',
            errorText: '未成功，请重试',
            onChange: (v) => setState(() => _log = v ? '已通过' : '未到终点'),
          ),
        ),
        demoBlock(
          '同一组文案下「滑到底」与「中途松手」的两种终态对比：'
          '绿底 + successText，或灰底 + errorText。',
          WotSlideVerify(
            text: '请完成滑动验证',
            successText: '✅ 通过',
            errorText: '❌ 请滑到最右侧',
            onChange: (v) => setState(() => _log = v ? '已通过' : '未到终点'),
          ),
        ),

        demoSection('受控（modelValue）与程序复位'),
        demoBlock(
          'modelValue 由外部持有。点「重置」把它置回 false，'
          '滑块会退回可拖动状态——用于表单提交后需要重新验证的场景。',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WotSlideVerify(
                modelValue: _ok2,
                successText: '已验证',
                onChange: (v) => setState(() => _ok2 = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  WotButton(
                    text: '重置为未验证',
                    size: WotButtonSize.small,
                    onClick: () => setState(() => _ok2 = false),
                  ),
                  const SizedBox(width: 8),
                  Text('modelValue: $_ok2',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),

        demoSection('高度（height）与颜色（color）'),
        demoBlock('height=56 + 自定义主色滑块',
            WotSlideVerify(height: 56, color: const Color(0xFF12B886), onChange: (v) {})),
        demoBlock('height=36（紧凑）',
            WotSlideVerify(height: 36, onChange: (v) {})),

        demoSection('状态（disabled）'),
        demoBlock(
          'disabled 时轨道整体变灰、拖动无效，onChange 不再触发。'
          '注意与「验证通过后不可再拖动」区分——后者是成功态，轨道是绿的。',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: WotButton(
                    text: 'disabled: $_disabled',
                    size: WotButtonSize.small,
                    onClick: () => setState(() => _disabled = !_disabled),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              WotSlideVerify(disabled: _disabled, onChange: (v) {}),
            ],
          ),
        ),
      ],
    );
  }
}
