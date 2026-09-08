import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotBacktop 回到顶部示例页。
class WotBacktopPage extends StatefulWidget {
  const WotBacktopPage({super.key});

  @override
  State<WotBacktopPage> createState() => _WotBacktopPageState();
}

class _WotBacktopPageState extends State<WotBacktopPage> {
  final ScrollController _ctl = ScrollController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotBacktop 回到顶部',
      children: [
        demoSection('基础（scrollController 自动显隐 + 点击回顶）'),
        demoBlock('在滚动容器内监听并回顶',
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _ctl,
                    itemCount: 20,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.all(10),
                      child: WotCell(title: '第 $i 项', value: '内容'),
                    ),
                  ),
                  // 传入 scrollController：滚动超过 distance 自动显示，点击自动回顶。
                  WotBacktop(
                    scrollController: _ctl,
                    distance: 80,
                    tip: '回顶部',
                    right: 4,
                    bottom: 4,
                  ),
                ],
              ),
            )),
        demoSection('静态显示（show）'),
        demoBlock('手动 show + tip + 自定义颜色',
            SizedBox(
              height: 120,
              child: Stack(
                children: [
                  const Positioned(left: 12, top: 12, child: Text('静态悬浮按钮')),
                  WotBacktop(show: true, tip: 'TOP', color: const Color(0xFF12B886), right: 4, bottom: 4, onClick: () => demoToast(context, '点击回顶')),
                ],
              ),
            )),
      ],
    );
  }
}