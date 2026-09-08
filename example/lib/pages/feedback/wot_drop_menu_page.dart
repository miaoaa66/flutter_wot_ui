import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotDropMenu 下拉菜单示例页。
class WotDropMenuPage extends StatefulWidget {
  const WotDropMenuPage({super.key});

  @override
  State<WotDropMenuPage> createState() => _WotDropMenuPageState();
}

class _WotDropMenuPageState extends State<WotDropMenuPage> {
  String _sort = '综合';
  String _price = '不限';

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotDropMenu 下拉菜单',
      children: [
        demoSection('panel 自定义面板'),
        demoBlock('自定义 panel',
            WotDropMenu(menus: [
              WotDropMenuItem(
                title: '综合排序',
                panel: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    for (final t in ['综合', '销量', '价格'])
                      InkWell(
                        onTap: () => demoToast(context, '选择：$t'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.centerLeft,
                          child: Text(t),
                        ),
                      ),
                  ]),
                ),
              ),
            ])),
        demoSection('options 驱动（modelValue / onChange / closeOnClick）'),
        demoBlock('受控选项联动',
            WotDropMenu(menus: [
              WotDropMenuItem(
                modelValue: _sort,
                onChange: (v) => setState(() => _sort = v as String),
                options: const [
                  WotDropMenuOption(label: '综合', value: '综合'),
                  WotDropMenuOption(label: '销量', value: '销量'),
                  WotDropMenuOption(label: '价格', value: '价格'),
                ],
              ),
              WotDropMenuItem(
                title: '价格',
                modelValue: _price,
                closeOnClick: false,
                onChange: (v) => setState(() => _price = v as String),
                options: const [
                  WotDropMenuOption(label: '不限', value: '不限'),
                  WotDropMenuOption(label: '10-50元', value: '10-50'),
                  WotDropMenuOption(label: '50-100元', value: '50-100'),
                  WotDropMenuOption(label: '100元以上', value: '100+'),
                ],
              ),
            ])),
      ],
    );
  }
}