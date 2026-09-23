import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotTabs 标签页示例页。
class WotTabsPage extends StatefulWidget {
  const WotTabsPage({super.key});

  @override
  State<WotTabsPage> createState() => _WotTabsPageState();
}

class _WotTabsPageState extends State<WotTabsPage>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  // 「指示器全套」段只有 4 个 tab，单独索引避免被 5-tab demo 顶到越界。
  int _indIdx = 0;
  late final TabController _ctl = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

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
                type: WotTabsType.card,
                children: [
                  for (var i = 0; i < 5; i++)
                    WotTab(title: '选项${i + 1}', width: 80, child: _panel(context, '内容${i + 1}')),
                ],
              ),
            )),
        demoSection('可滑动（swipeable + onPageChanged）'),
        demoBlock('swipeable 左右滑动切换',
            SizedBox(
              height: 160,
              child: WotTabs(
                modelValue: _index,
                onChange: (i) => setState(() => _index = i),
                onPageChanged: (i) => demoToast(context, '滑动到页 ${i + 1}'),
                swipeable: true,
                children: [
                  for (var i = 0; i < 5; i++)
                    WotTab(title: '页${i + 1}', child: _panel(context, '滑动内容 ${i + 1}')),
                ],
              ),
            )),
        demoSection('TabController 注入（外部受控 + 双向联动）'),
        demoBlock('下方按钮与标签互相驱动（共用一个 TabController）',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: OutlinedButton(
                          onPressed: () => _ctl.animateTo(i),
                          child: Text('切到 ${i + 1}'),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                AnimatedBuilder(
                  animation: _ctl,
                  builder: (c, _) => Text('当前索引：${_ctl.index}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 150,
                  child: WotTabs(
                    controller: _ctl,
                    onChange: (i) => demoToast(context, 'controller 切到 $i'),
                    children: [
                      for (var i = 0; i < 3; i++)
                        WotTab(title: '标签${i + 1}', child: _panel(context, '联动内容 ${i + 1}')),
                    ],
                  ),
                ),
              ],
            )),
        demoSection('指示器全套（indicatorWeight / indicatorSize / indicatorPadding / lineColor）'),
        demoBlock('indicatorSize=label + 线宽贴合文字 + 橙色',
            SizedBox(
              height: 110,
              child: WotTabs(
                modelValue: _indIdx,
                onChange: (i) => setState(() => _indIdx = i),
                lineColor: const Color(0xFFFF7D00),
                indicatorWeight: 4,
                indicatorSize: WotTabsIndicatorSize.label,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                children: [
                  for (var i = 0; i < 4; i++)
                    WotTab(title: '选项${i + 1}', width: 90, child: _panel(context, '内容${i + 1}')),
                ],
              ),
            )),
      ],
    );
  }
}
