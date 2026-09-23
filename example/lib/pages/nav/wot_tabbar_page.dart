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
  String _log = '（暂无）';

  void _push(String msg) => setState(() => _log = msg);

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
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

        demoSection('单项点击（WotTabbarItem.onClick，F 类缺陷 #3 已修复）'),
        demoBlock(
            '原先 clone item 时丢掉了 onClick，导致单项点击回调永不触发。'
            '点击任一标签应触发 onClick 并回写到下面日志（onChange 也会同时触发）',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WotTabbar(
                modelValue: _v,
                onChange: (v) => setState(() => _v = v),
                children: [
                  WotTabbarItem(
                      name: 1,
                      icon: 'home',
                      label: '首页',
                      onClick: () => _push('onClick：首页')),
                  WotTabbarItem(
                      name: 2,
                      icon: 'search',
                      label: '搜索',
                      onClick: () => _push('onClick：搜索')),
                  WotTabbarItem(
                      name: 3,
                      icon: 'user',
                      label: '我的',
                      onClick: () => _push('onClick：我的')),
                ],
              ),
              const SizedBox(height: 6),
              WotText('日志：$_log', type: WotTextType.wotDefault),
            ])),

        demoSection('激活/未激活色（activeColor / inactiveColor）'),
        demoBlock('自定义主色 + 灰色未激活',
            WotTabbar(
              modelValue: _v,
              activeColor: scheme.successMain,
              inactiveColor: scheme.textSecondary,
              onChange: (v) => setState(() => _v = v),
              children: [
                WotTabbarItem(name: 1, icon: 'star', label: '收藏'),
                WotTabbarItem(name: 2, icon: 'heart', label: '喜欢'),
                WotTabbarItem(name: 3, icon: 'user', label: '我的'),
              ],
            )),

        demoSection('图标态切换（icon / activeIcon）'),
        demoBlock('选中项使用 activeIcon',
            WotTabbar(
              modelValue: _v,
              onChange: (v) => setState(() => _v = v),
              children: [
                WotTabbarItem(name: 1, icon: 'star-o', activeIcon: 'star', label: '收藏'),
                WotTabbarItem(name: 2, icon: 'heart-o', activeIcon: 'heart', label: '喜欢'),
              ],
            )),

        demoSection('角标（badge / value+max / isDot）'),
        demoBlock('badge 文案｜value 数字 + max 上限｜isDot 红点',
            WotTabbar(
              modelValue: _v,
              onChange: (v) => setState(() => _v = v),
              children: [
                WotTabbarItem(name: 1, icon: 'home', label: 'badge', badge: 'new'),
                WotTabbarItem(name: 2, icon: 'search', label: 'value', value: 128, max: 99),
                WotTabbarItem(name: 3, icon: 'user', label: 'isDot', isDot: true),
              ],
            )),

        demoSection('样式（bordered / iconSize）'),
        demoBlock('bordered: true（顶部 1px 分割线）',
            WotTabbar(
              modelValue: _v,
              bordered: true,
              onChange: (v) => setState(() => _v = v),
              children: [
                WotTabbarItem(name: 1, icon: 'home', label: '有边框'),
                WotTabbarItem(name: 2, icon: 'search', label: '搜索'),
              ],
            )),
        demoBlock('bordered: false（默认）+ iconSize 26',
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

        demoSection('自定义内容（child 插槽）'),
        demoBlock('用 child 完全自定义某项渲染',
            WotTabbar(
              modelValue: _v,
              onChange: (v) => setState(() => _v = v),
              children: [
                const WotTabbarItem(name: 1, child: Text('自定义 A')),
                const WotTabbarItem(name: 2, child: Text('自定义 B')),
              ],
            )),

        demoSection('已废弃参数'),
        demoBlock(
            'fixed 已 @Deprecated：wot 的 fixed 是 CSS position:fixed 语义，'
            'Flutter 里组件无法把自己浮出父容器（强行用 Overlay 会破坏与 PageView 的联动）。'
            '吸底请直接放进 Scaffold.bottomNavigationBar。此处不演示。',
            const WotIcon(name: 'info', size: 20)),
      ],
    );
  }
}
