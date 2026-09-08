import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotTabs 标签页示例页。
class WotTabsPage extends StatefulWidget {
  const WotTabsPage({super.key});

  @override
  State<WotTabsPage> createState() => _WotTabsPageState();
}

class _WotTabsPageState extends State<WotTabsPage> {
  int _index = 0;

  Widget _panel(BuildContext c, String s) => Container(
        alignment: Alignment.center,
        color: c.wotScheme.filledStrong,
        child: WotText(s, type: WotTextType.wotDefault),
      );

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotTabs 标签页',
      children: [
        demoSection('line 样式（activeColor / badge / 回调）'),
        demoBlock('自定义激活色 + 角标',
            SizedBox(
              height: 190,
              child: WotTabs(
                modelValue: _index,
                activeColor: const Color(0xFF12B886),
                onChange: (i) => setState(() => _index = i),
                onChangeTab: (nav) => demoToast(context, '切到 Tab ${nav.index + 1}'),
                onDisabled: (_) => demoToast(context, '该标签已禁用'),
                children: [
                  for (var i = 0; i < 5; i++)
                    WotTab(
                      title: '选项${i + 1}',
                      width: 80,
                      badge: i == 0
                          ? const WotTabBadge(value: 12)
                          : (i == 1
                              ? const WotTabBadge(value: 128)
                              : (i == 2
                                  ? const WotTabBadge(isDot: true, color: Color(0xFF12B886))
                                  : null)),
                      child: _panel(context, '内容${i + 1}'),
                    ),
                  WotTab(title: '禁用', width: 80, disabled: true, child: _panel(context, '禁用')),
                ],
              ),
            )),
        demoSection('card 样式（type: card）'),
        demoBlock('card 样式标签',
            SizedBox(
              height: 90,
              child: WotTabs(
                modelValue: _index,
                onChange: (i) => setState(() => _index = i),
                type: 'card',
                children: [
                  for (var i = 0; i < 5; i++)
                    WotTab(title: '选项${i + 1}', width: 80, child: _panel(context, '内容${i + 1}')),
                ],
              ),
            )),
        demoSection('可滑动（swipeable）'),
        demoBlock('swipeable 左右滑动切换',
            SizedBox(
              height: 160,
              child: WotTabs(
                modelValue: _index,
                onChange: (i) => setState(() => _index = i),
                swipeable: true,
                children: [
                  for (var i = 0; i < 5; i++)
                    WotTab(title: '页${i + 1}', child: _panel(context, '滑动内容 ${i + 1}')),
                ],
              ),
            )),
      ],
    );
  }
}