import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotFloatingPanel 底部浮动面板示例页。
class WotFloatingPanelPage extends StatelessWidget {
  const WotFloatingPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotFloatingPanel 底部浮动面板',
      children: [
        demoSection('基础（header / child / 拖动把手）'),
        demoBlock('默认 anchors = [0.1H, 0.5H, 0.95H]，初始停在中间档',
            SizedBox(
              height: 220,
              child: Stack(
                children: [
                  Container(color: context.wotScheme.filledStrong),
                  const WotFloatingPanel(
                    header: Text('浮动面板'),
                    child: Center(child: WotText('向上拖动展开，松手吸附到最近档位')),
                  ),
                ],
              ),
            )),
        demoSection('多吸附点对照（像素 + 比例混排）'),
        demoBlock('anchors = [100px, 0.4H, 0.7H]', SizedBox(
          height: 220,
          child: Stack(
            children: [
              Container(color: context.wotScheme.filledStrong),
              const WotFloatingPanel(
                anchors: [
                  WotFloatingPanelAnchor.pixels(100),
                  WotFloatingPanelAnchor.fraction(0.4),
                  WotFloatingPanelAnchor.fraction(0.7),
                ],
                header: Text('面板 (100 / 40% / 70%)'),
                child: Center(child: WotText('最低档是固定 100px')),
              ),
            ],
          ),
        )),
        demoSection('受控高度（height + onHeightChange 双向同步）'),
        const _ControlledFloatingPanelDemo(),
      ],
    );
  }
}

/// 受控演示：滑块改 [WotFloatingPanel.height]，面板拖拽时通过
/// [WotFloatingPanel.onHeightChange] 回写，二者双向同步。
class _ControlledFloatingPanelDemo extends StatefulWidget {
  const _ControlledFloatingPanelDemo();

  @override
  State<_ControlledFloatingPanelDemo> createState() =>
      _ControlledFloatingPanelDemoState();
}

class _ControlledFloatingPanelDemoState extends State<_ControlledFloatingPanelDemo> {
  late double _h;

  @override
  void initState() {
    super.initState();
    _h = 120;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: _h,
          min: 56,
          max: 220,
          divisions: 164,
          label: _h.round().toString(),
          onChanged: (v) => setState(() => _h = v),
        ),
        Text('当前高度：${_h.round()} px（拖面板也会更新这里）',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(
          height: 220,
          child: Stack(
            children: [
              Container(color: context.wotScheme.filledStrong),
              WotFloatingPanel(
                height: _h,
                onHeightChange: (v) => setState(() => _h = v),
                header: const Text('受控面板'),
                child: const Center(child: WotText('拖动我，高度同步到上方滑块')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
