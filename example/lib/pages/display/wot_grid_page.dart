import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotGrid 宫格示例页。
class WotGridPage extends StatelessWidget {
  const WotGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotGrid 宫格',
      children: [
        demoSection('基础（columnNum / WotGridItem / onClick）'),
        demoBlock('3 列宫格',
            WotGrid(
              columnNum: 3,
              children: [
                for (final (name, label) in [
                  ('home', '首页'),
                  ('category', '分类'),
                  ('user', '我的'),
                  ('cart', '购物车'),
                  ('star', '收藏'),
                  ('service', '客服'),
                ])
                  WotGridItem(iconName: name, text: label, onClick: () => demoToast(context, '点击 $label')),
              ],
            )),
        demoSection('样式（border / square / gap / badge）'),
        demoBlock('4 列 + 边框',
            WotGrid(
              columnNum: 4,
              border: true,
              children: [
                WotGridItem(iconName: 'star', text: '收藏', onClick: () {}),
                WotGridItem(iconName: 'user', text: '我的', badge: 99, onClick: () {}),
                WotGridItem(iconName: 'cart', text: '购物车', dot: true, onClick: () {}),
                WotGridItem(iconName: 'home', text: '首页', onClick: () {}),
              ],
            )),
      ],
    );
  }
}