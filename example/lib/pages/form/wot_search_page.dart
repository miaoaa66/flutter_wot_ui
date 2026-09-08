import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSearch 搜索框示例页。
class WotSearchPage extends StatefulWidget {
  const WotSearchPage({super.key});

  @override
  State<WotSearchPage> createState() => _WotSearchPageState();
}

class _WotSearchPageState extends State<WotSearchPage> {
  String? _v1;
  String? _v2;
  String? _v3 = '预设搜索词';
  bool _disabled = false;
  bool _readonly = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSearch 搜索框',
      children: [
        demoSection('基础用法'),
        demoBlock('基础（placeholder / onChange）',
            WotSearch(modelValue: _v1, onChange: (v) => setState(() => _v1 = v))),
        demoBlock('预设值', WotSearch(modelValue: _v3, onChange: (v) => setState(() => _v3 = v))),
        demoSection('形状与清除'),
        demoBlock('shape=round 胶囊', WotSearch(modelValue: _v1, onChange: (v) => setState(() => _v1 = v), shape: 'round')),
        demoSection('action 按钮（showAction / actionText）'),
        demoBlock(
            'showAction + onSearch',
            WotSearch(
              modelValue: _v2,
              showAction: true,
              actionText: '搜一下',
              onChange: (v) => setState(() => _v2 = v),
              onSearch: () => demoToast(context, '搜索：$_v2'),
            )),
        demoBlock('onClear 清除回调',
            WotSearch(modelValue: _v3, onClear: () => demoToast(context, '已清空'), onChange: (v) => setState(() => _v3 = v))),
        demoSection('状态与回调'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled'))),
          const SizedBox(width: 8),
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _readonly = !_readonly), child: Text('readonly: $_readonly'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用', WotSearch(disabled: _disabled)),
        demoBlock('readonly 只读', WotSearch(readonly: _readonly)),
        demoBlock('聚焦 / 失焦回调',
            WotSearch(onFocus: () => demoToast(context, '聚焦'), onBlur: () => demoToast(context, '失焦'))),
      ],
    );
  }
}