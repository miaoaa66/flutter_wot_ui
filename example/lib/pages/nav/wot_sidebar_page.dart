import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSidebar 侧边导航示例页。
class WotSidebarPage extends StatefulWidget {
  const WotSidebarPage({super.key});

  @override
  State<WotSidebarPage> createState() => _WotSidebarPageState();
}

class _WotSidebarPageState extends State<WotSidebarPage> {
  Object? _sel = 'a';

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSidebar 侧边导航',
      children: [
        demoSection('基础（modelValue / onChange / 右侧内容联动）'),
        demoBlock('侧边导航 + 内容区',
            SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WotSidebar(
                    modelValue: _sel,
                    onChange: (v) => setState(() => _sel = v),
                    children: const [
                      WotSidebarItem(title: '标签名', name: 'a'),
                      WotSidebarItem(title: '标签名', name: 'b'),
                      WotSidebarItem(title: '标签名', name: 'c'),
                      WotSidebarItem(title: '标签名', name: 'd', badge: '399'),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      color: context.wotScheme.filledStrong,
                      alignment: Alignment.center,
                      child: WotText('当前：$_sel'),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}