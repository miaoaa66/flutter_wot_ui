import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSwitch 开关示例页。
class WotSwitchPage extends StatefulWidget {
  const WotSwitchPage({super.key});

  @override
  State<WotSwitchPage> createState() => _WotSwitchPageState();
}

class _WotSwitchPageState extends State<WotSwitchPage> {
  bool _on1 = false;
  bool _on2 = true;
  bool _on3 = false;
  bool _on4 = false;
  bool _on5 = false;
  bool _loading = false;
  bool _disabled = false;
  bool _readonly = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSwitch 开关',
      children: [
        demoSection('基础用法（modelValue / onChange）'),
        demoBlock('基础开关', Row(children: [const Expanded(child: Text('开关')), WotSwitch(modelValue: _on1, onChange: (v) => setState(() => _on1 = v))])),
        demoSection('文本与颜色（activeText / inactiveText / activeColor）'),
        demoBlock(
            '文字开关（开/关）',
            Row(children: [const Expanded(child: Text('消息通知')), WotSwitch(modelValue: _on2, activeText: '开', inactiveText: '关', onChange: (v) => setState(() => _on2 = v))])),
        demoBlock(
            '自定义 activeColor 开启色',
            Row(children: [const Expanded(child: Text('主色开关')), WotSwitch(modelValue: _on3, activeColor: const Color(0xFF12B886), activeText: 'ON', inactiveText: 'OFF', onChange: (v) => setState(() => _on3 = v))])),
        demoSection('尺寸（size）'),
        demoBlock(
            'size=24 与 size=40',
            Row(children: [
              WotSwitch(modelValue: _on4, size: 24, onChange: (v) => setState(() => _on4 = v)),
              const SizedBox(width: 16),
              WotSwitch(modelValue: _on5, size: 40, onChange: (v) => setState(() => _on5 = v)),
            ])),
        demoSection('状态（disabled / readonly / loading）'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled')),
          FilledButton.tonal(onPressed: () => setState(() => _readonly = !_readonly), child: Text('readonly: $_readonly')),
          FilledButton.tonal(onPressed: () => setState(() => _loading = !_loading), child: Text('loading: $_loading')),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用（轨道整体灰化，不可切换）',
            Row(children: [const Expanded(child: Text('禁用')), WotSwitch(modelValue: _on1, disabled: _disabled, onChange: (v) => setState(() => _on1 = v))])),
        demoBlock('readonly 只读（锁切换、保持正常配色 —— 区别于 disabled 的灰化）',
            Row(children: [const Expanded(child: Text('只读')), WotSwitch(modelValue: _on1, readonly: _readonly, onChange: (v) => setState(() => _on1 = v))])),
        demoBlock('loading 异步加载',
            Row(children: [
              const Expanded(child: Text('确认切换')), WotSwitch(modelValue: _on2, loading: _loading, onChange: (v) {}),
            ])),
      ],
    );
  }
}