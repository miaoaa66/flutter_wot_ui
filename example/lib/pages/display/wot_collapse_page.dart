import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCollapse 折叠面板示例页。
class WotCollapsePage extends StatefulWidget {
  const WotCollapsePage({super.key});

  @override
  State<WotCollapsePage> createState() => _WotCollapsePageState();
}

class _WotCollapsePageState extends State<WotCollapsePage> {
  final List<String> _collapsed = ['1'];
  int _multiCount = 0;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCollapse 折叠面板',
      children: [
        demoSection('手风琴（accordion / 受控 modelValue）'),
        demoBlock('同时仅一项展开',
            WotCollapse(
              modelValue: _collapsed,
              accordion: true,
              onChange: (v) => setState(() => _collapsed
                ..clear()
                ..addAll(v)),
              children: [
                WotCollapseItem(data: WotCollapseItemData(name: '1', title: '标题一', content: '内容一：这里是折叠面板的内容。')),
                WotCollapseItem(data: WotCollapseItemData(name: '2', title: '标题二', content: '内容二：这里是折叠面板的内容。')),
                WotCollapseItem(data: WotCollapseItemData(name: '3', title: '标题三（禁用）', disabled: true, content: '内容三：禁用项无法展开')),
              ],
            )),
        demoSection('多选（accordion=false / 自定义 children）'),
        demoBlock('多选展开 + 自定义内容',
            WotCollapse(
              accordion: false,
              onChange: (v) => setState(() => _multiCount = v.length),
              children: [
                WotCollapseItem(
                  data: const WotCollapseItemData(name: 'm1', title: '收货地址'),
                  children: [
                    const WotText('四川省成都市高新区天府大道 1000 号', type: WotTextType.wotDefault),
                    const SizedBox(height: 8),
                    WotButton(text: '修改地址', size: WotButtonSize.small),
                  ],
                ),
                WotCollapseItem(
                  data: const WotCollapseItemData(name: 'm2', title: '发票信息'),
                  children: const [WotText('企业增值税普通发票', type: WotTextType.wotDefault)],
                ),
                WotCollapseItem(data: const WotCollapseItemData(name: 'm3', title: '备注', content: '可同时展开多个面板')),
              ],
            )),
        const SizedBox(height: 6),
        Row(children: [
          const WotText('当前展开 ', type: WotTextType.wotDefault),
          WotText('$_multiCount', type: WotTextType.primary, bold: true),
          const WotText(' 项（非手风琴）', type: WotTextType.wotDefault),
        ]),
      ],
    );
  }
}