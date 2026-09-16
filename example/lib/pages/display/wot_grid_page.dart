import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// 演示用宫格数据（图标名, 文案）。
const List<(String, String)> _items = [
  ('home', '首页'),
  ('category', '分类'),
  ('cart', '购物车'),
  ('user', '我的'),
  ('star', '收藏'),
  ('service', '客服'),
];

/// WotGrid 宫格示例页。
///
/// 覆盖：columnNum / border / gap / square / 徽标（badge·dot·max）/
/// 自定义颜色 / iconSize / 自绘图标 / 自定义内容 / 点击事件。
class WotGridPage extends StatefulWidget {
  const WotGridPage({super.key});

  @override
  State<WotGridPage> createState() => _WotGridPageState();
}

class _WotGridPageState extends State<WotGridPage> {
  int _columnNum = 4;
  bool _border = false;
  bool _square = false;
  double _gap = 0;

  List<WotGridItem> _cells(BuildContext context) => [
        for (final (name, label) in _items)
          WotGridItem(
            iconName: name,
            text: label,
            onClick: () => demoToast(context, '点击 $label'),
          ),
      ];

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;

    return WotDemoScaffold(
      title: 'WotGrid 宫格',
      children: [
        demoSection('列数（columnNum）'),
        demoBlock('columnNum: 3', WotGrid(columnNum: 3, children: _cells(context))),
        demoBlock('columnNum: 4（默认）', WotGrid(columnNum: 4, children: _cells(context))),
        demoBlock('columnNum: 5', WotGrid(columnNum: 5, children: _cells(context))),

        demoSection('可切换属性（现场切换验证受控响应）'),
        demoBlock(
          'columnNum / border / square / gap 实时调整',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('列数 '),
                  Expanded(
                    child: Slider(
                      value: _columnNum.toDouble(),
                      min: 2,
                      max: 6,
                      divisions: 4,
                      label: '$_columnNum',
                      onChanged: (v) => setState(() => _columnNum = v.round()),
                    ),
                  ),
                  Text('$_columnNum'),
                ],
              ),
              Row(
                children: [
                  const Text('间距 '),
                  Expanded(
                    child: Slider(
                      value: _gap,
                      min: 0,
                      max: 16,
                      divisions: 8,
                      label: _gap.toStringAsFixed(0),
                      onChanged: (v) => setState(() => _gap = v),
                    ),
                  ),
                  Text(_gap.toStringAsFixed(0)),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('border（边框）'),
                value: _border,
                onChanged: (v) => setState(() => _border = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('square（正方形格子）'),
                value: _square,
                onChanged: (v) => setState(() => _square = v),
              ),
              WotGrid(
                columnNum: _columnNum,
                border: _border,
                gap: _gap,
                square: _square,
                children: _cells(context),
              ),
            ],
          ),
        ),

        demoSection('边框（border）'),
        demoBlock('border: true 全量边框', WotGrid(columnNum: 3, border: true, children: _cells(context))),
        demoBlock('子项单独覆盖 border（GridItem.border 优先于 Grid.border）',
            WotGrid(
              columnNum: 3,
              border: false,
              children: [
                WotGridItem(iconName: 'home', text: '有边框', border: true, onClick: () {}),
                WotGridItem(iconName: 'star', text: '无边框', border: false, onClick: () {}),
                WotGridItem(iconName: 'user', text: '继承', onClick: () {}),
              ],
            )),

        demoSection('徽标（badge / dot / max）'),
        demoBlock('badge 数字、dot 红点、超 max 显示 99+',
            WotGrid(
              columnNum: 3,
              children: [
                WotGridItem(iconName: 'cart', text: '购物车', badge: 5, onClick: () {}),
                WotGridItem(iconName: 'service', text: '客服', dot: true, onClick: () {}),
                WotGridItem(iconName: 'star', text: '收藏', badge: 120, max: 99, onClick: () {}),
              ],
            )),

        demoSection('颜色与图标尺寸（color / iconColor / iconSize）'),
        demoBlock('自定义文字色与图标色',
            WotGrid(
              columnNum: 3,
              children: [
                WotGridItem(
                  iconName: 'home',
                  text: '主色',
                  color: scheme.primaryOf(6),
                  iconColor: scheme.primaryOf(6),
                  onClick: () {},
                ),
                WotGridItem(
                  iconName: 'category',
                  text: '危险色',
                  color: scheme.dangerMain,
                  iconColor: scheme.dangerMain,
                  onClick: () {},
                ),
                WotGridItem(
                  iconName: 'star',
                  text: '成功色',
                  color: scheme.successMain,
                  iconColor: scheme.successMain,
                  onClick: () {},
                ),
              ],
            )),
        demoBlock('iconSize: 16 / 26（默认）/ 36',
            WotGrid(
              columnNum: 3,
              children: [
                WotGridItem(iconName: 'star', text: '16', iconSize: 16, onClick: () {}),
                WotGridItem(iconName: 'star', text: '26', iconSize: 26, onClick: () {}),
                WotGridItem(iconName: 'star', text: '36', iconSize: 36, onClick: () {}),
              ],
            )),

        demoSection('自绘图标（icon）与自定义内容（children）'),
        demoBlock('icon 传入任意 Widget（优先级高于 iconName）',
            WotGrid(
              columnNum: 3,
              children: [
                WotGridItem(
                  icon: const Icon(Icons.flight, size: 26),
                  text: '飞机',
                  onClick: () {},
                ),
                WotGridItem(
                  icon: const CircleAvatar(radius: 13, child: Icon(Icons.person, size: 16)),
                  text: '头像',
                  onClick: () {},
                ),
                WotGridItem(
                  icon: const Icon(Icons.favorite, size: 26, color: Colors.pink),
                  text: '喜欢',
                  onClick: () {},
                ),
              ],
            )),
        demoBlock('children 完全自定义内容（覆盖默认图标+文字布局）',
            WotGrid(
              columnNum: 2,
              square: false,
              children: [
                WotGridItem(
                  children: Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('自定义卡片', style: TextStyle(fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Text('可放任意 Widget', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  onClick: () => demoToast(context, '自定义内容 1'),
                ),
                WotGridItem(
                  children: Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: const Text('第二个'),
                  ),
                  onClick: () => demoToast(context, '自定义内容 2'),
                ),
              ],
            )),

        demoSection('点击事件（onClick）'),
        demoBlock('点击任意格子弹 toast', WotGrid(columnNum: 3, children: _cells(context))),

        // TODO: reverse（内容反向）当前为死参数——WotGrid 声明于 wot_grid.dart:17 但
        // build 未消费，切换无效果。待组件实现后补此演示，见 COMPONENT_AUDIT.md。
      ],
    );
  }
}
