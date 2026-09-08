import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSwiper 轮播示例页。
class WotSwiperPage extends StatefulWidget {
  const WotSwiperPage({super.key});

  @override
  State<WotSwiperPage> createState() => _WotSwiperPageState();
}

class _WotSwiperPageState extends State<WotSwiperPage> {
  int _index = 0;

  Widget _slide(int i, Color c) => Container(
        color: c,
        alignment: Alignment.center,
        child: Text('第${i + 1}页', style: const TextStyle(color: Colors.white, fontSize: 18)),
      );

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSwiper 轮播',
      children: [
        demoSection('自动播放（autoplay / interval / onChange）'),
        demoBlock('当前页：${_index + 1} / 4',
            SizedBox(
              height: 150,
              child: WotSwiper(
                autoplay: true,
                interval: 2500,
                onChange: (i) => setState(() => _index = i),
                children: [
                  for (var i = 0; i < 4; i++)
                    WotSwiperItem(child: _slide(i, [Colors.teal, Colors.indigo, Colors.deepOrange, Colors.brown][i % 4])),
                ],
              ),
            )),
        demoSection('指示点位置 + 循环（indicatorPosition / loop）'),
        demoBlock('居中指示点 + 循环',
            SizedBox(
              height: 150,
              child: WotSwiper(
                loop: true,
                indicatorPosition: WotSwiperIndicatorPosition.middleCenter,
                children: const [
                  WotSwiperItem(child: ColoredBox(color: Color(0xFF4DB6AC), child: Center(child: Text('第 1 页', style: TextStyle(color: Colors.white))))),
                  WotSwiperItem(child: ColoredBox(color: Color(0xFF7986CB), child: Center(child: Text('第 2 页', style: TextStyle(color: Colors.white))))),
                  WotSwiperItem(child: ColoredBox(color: Color(0xFFF06292), child: Center(child: Text('第 3 页', style: TextStyle(color: Colors.white))))),
                ],
              ),
            )),
      ],
    );
  }
}