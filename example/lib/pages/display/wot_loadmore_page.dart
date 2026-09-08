import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotLoadmore 加载更多示例页。
class WotLoadmorePage extends StatelessWidget {
  const WotLoadmorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotLoadmore 加载更多',
      children: [
        demoSection('状态（state: loading / noMore / loadingFailed）'),
        demoBlock('加载中',
            const WotLoadmore(state: WotLoadmoreState.loading)),
        demoBlock('没有更多',
            const WotLoadmore(state: WotLoadmoreState.noMore)),
        demoBlock('加载失败可点击重试',
            WotLoadmore(state: WotLoadmoreState.loadingFailed, onLoadmore: () => demoToast(context, '点击重试'))),
      ],
    );
  }
}