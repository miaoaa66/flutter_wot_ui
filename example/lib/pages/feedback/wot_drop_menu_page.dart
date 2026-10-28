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
  String _filter = '全部';
  bool _mask = true;
  String _delivery = '不限';

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
        demoSection('展开方向（direction）'),
        demoBlock(
          'direction: up——面板渲染在菜单栏上方，适合页面底部的筛选条；'
          '展开/收起动画时长由 duration 控制（默认 200ms）。',
          WotDropMenu(
            direction: WotDropMenuDirection.up,
            menus: [
              WotDropMenuItem(
                title: '筛选',
                modelValue: _filter,
                onChange: (v) => setState(() => _filter = v as String),
                options: const [
                  WotDropMenuOption(label: '全部', value: '全部'),
                  WotDropMenuOption(label: '今日', value: '今日'),
                  WotDropMenuOption(label: '本周', value: '本周'),
                ],
              ),
            ],
          )),
        demoSection('蒙层（closeOnClickOverlay，默认 true）'),
        demoBlock(
          'closeOnClickOverlay 现场切换：true 时展开后出现全屏蒙层，'
          '点击菜单栏/面板以外的区域关闭；false 时无蒙层，仅可再次点标题栏收起。'
          '（蒙层用主题令牌 opacMainCover，菜单栏与面板浮于蒙层之上，滚动实时跟随）',
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FilledButton.tonal(
              onPressed: () => setState(() => _mask = !_mask),
              child: Text('closeOnClickOverlay: $_mask'),
            ),
            const SizedBox(height: 8),
            WotDropMenu(
              closeOnClickOverlay: _mask,
              menus: [
                WotDropMenuItem(
                  title: '配送',
                  modelValue: _delivery,
                  onChange: (v) => setState(() => _delivery = v as String),
                  options: const [
                    WotDropMenuOption(label: '不限配送', value: '不限'),
                    WotDropMenuOption(label: '蜂鸟配送', value: '蜂鸟'),
                    WotDropMenuOption(label: '美团配送', value: '美团'),
                  ],
                ),
              ],
            ),
          ])),
          SizedBox(height: 160),
      ],
    );
  }
}