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
  int _loopIndex = 0;
  bool _loop = true;
  bool _indicator = true;
  int _duration = 300;

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
        demoBlock('默认自动轮播（autoplay 默认 true，interval 5000）',
            SizedBox(
              height: 120,
              child: WotSwiper(
                children: [
                  for (var i = 0; i < 3; i++)
                    WotSwiperItem(child: _slide(i, [Colors.blue, Colors.green, Colors.purple][i % 3])),
                ],
              ),
            )),

        demoSection('循环（loop，A 类死参数 #2 已实现）'),
        demoBlock(
            'loop: $_loop —— 打开后从最后一页继续右滑应回到第一页；关闭后滑到头就停住。'
            '现场切换这个开关同时验证 loop 变化时 PageController 的重建'
            '（原实现切换会崩溃，这点用 analyze 查不出来）',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('loop ', style: TextStyle(fontSize: 12)),
                WotSwitch(modelValue: _loop, onChange: (v) => setState(() => _loop = v)),
              ]),
              const SizedBox(height: 8),
              SizedBox(
                height: 130,
                child: WotSwiper(
                  loop: _loop,
                  autoplay: false,
                  onChange: (i) => setState(() => _loopIndex = i),
                  children: [
                    for (var i = 0; i < 3; i++)
                      WotSwiperItem(child: _slide(i, [Colors.red, Colors.orange, Colors.amber][i % 3])),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              WotText('对外索引：${_loopIndex + 1} / 3（loop 下仍报 0..n-1 的逻辑索引）',
                  type: WotTextType.wotDefault),
            ])),

        demoSection('指示点（indicator / indicatorPosition）'),
        demoBlock('indicator: $_indicator（关闭后下方指示点应消失）',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('indicator ', style: TextStyle(fontSize: 12)),
                WotSwitch(modelValue: _indicator, onChange: (v) => setState(() => _indicator = v)),
              ]),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: WotSwiper(
                  autoplay: false,
                  indicator: _indicator,
                  children: [
                    WotSwiperItem(child: _slide(0, Colors.cyan)),
                    WotSwiperItem(child: _slide(1, Colors.lime)),
                  ],
                ),
              ),
            ])),
        demoBlock('上排：topLeft / topCenter / topRight',
            Wrap(spacing: 12, runSpacing: 12, children: [
              for (final pos in [WotSwiperIndicatorPosition.topLeft, WotSwiperIndicatorPosition.topCenter, WotSwiperIndicatorPosition.topRight])
                SizedBox(
                  width: 120,
                  height: 100,
                  child: WotSwiper(
                    autoplay: false,
                    indicatorPosition: pos,
                    children: [
                      WotSwiperItem(child: ColoredBox(color: const Color(0xFF4DB6AC), child: const Center(child: Text('1', style: TextStyle(color: Colors.white))))),
                      WotSwiperItem(child: ColoredBox(color: const Color(0xFF7986CB), child: const Center(child: Text('2', style: TextStyle(color: Colors.white))))),
                    ],
                  ),
                ),
            ])),
        demoBlock('下排：bottomLeft / bottomCenter / bottomRight',
            Wrap(spacing: 12, runSpacing: 12, children: [
              for (final pos in [WotSwiperIndicatorPosition.bottomLeft, WotSwiperIndicatorPosition.bottomCenter, WotSwiperIndicatorPosition.bottomRight])
                SizedBox(
                  width: 120,
                  height: 100,
                  child: WotSwiper(
                    autoplay: false,
                    indicatorPosition: pos,
                    children: [
                      WotSwiperItem(child: ColoredBox(color: const Color(0xFFF06292), child: const Center(child: Text('1', style: TextStyle(color: Colors.white))))),
                      WotSwiperItem(child: ColoredBox(color: const Color(0xFFA1887F), child: const Center(child: Text('2', style: TextStyle(color: Colors.white))))),
                    ],
                  ),
                ),
            ])),

        demoSection('切换动画时长（duration）'),
        demoBlock('当前 ${_duration}ms —— 调到 1200 后手动滑动，能明显看到慢速过渡',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8, children: [
                for (final d in [300, 1200])
                  ChoiceChip(
                    label: Text('${d}ms'),
                    selected: _duration == d,
                    onSelected: (_) => setState(() => _duration = d),
                  ),
              ]),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: WotSwiper(
                  autoplay: false,
                  duration: _duration,
                  children: [
                    WotSwiperItem(child: _slide(0, Colors.indigo)),
                    WotSwiperItem(child: _slide(1, Colors.teal)),
                    WotSwiperItem(child: _slide(2, Colors.pink)),
                  ],
                ),
              ),
            ])),

        demoSection('数据驱动（itemCount + itemBuilder）'),
        demoBlock(
          'itemBuilder(context, index) 从数据批量生成页面，'
          '提供后忽略 children；适合轮播页数由接口数据决定的场景。',
          SizedBox(
            height: 120,
            child: WotSwiper(
              itemCount: 5,
              itemBuilder: (context, index) =>
                  WotSwiperItem(child: _slide(index, Colors.primaries[index % 18])),
            ),
          )),
      ],
    );
  }
}
