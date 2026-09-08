import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotTabbar 底部标签栏示例页。
class WotTabbarPage extends StatefulWidget {
  const WotTabbarPage({super.key});

  @override
  State<WotTabbarPage> createState() => _WotTabbarPageState();
}

class _WotTabbarPageState extends State<WotTabbarPage> {
  Object? _v = 1;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotTabbar 底部标签栏',
      children: [
        demoSection('基础（modelValue / onChange / icon / label / badge）'),
        demoBlock('三个标签 + 角标',
            WotTabbar(
              modelValue: _v,
              onChange: (v) => setState(() => _v = v),
              children: [
                WotTabbarItem(name: 1, icon: 'home', label: '首页'),
                WotTabbarItem(name: 2, icon: 'search', label: '搜索'),
                WotTabbarItem(name: 3, icon: 'user', label: '我的', badge: '99+'),
              ],
            )),
        demoSection('样式（fixed / bordered / iconSize）'),
        demoBlock('bordered=false + iconSize 26',
            WotTabbar(
              modelValue: _v,
              bordered: false,
              iconSize: 26,
              onChange: (v) => setState(() => _v = v),
              children: [
                WotTabbarItem(name: 1, icon: 'star', label: '收藏'),
                WotTabbarItem(name: 2, icon: 'heart', label: '喜欢'),
              ],
            )),
      ],
    );
  }
}