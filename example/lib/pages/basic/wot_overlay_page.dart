import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotOverlay 遮罩层示例页。
class WotOverlayPage extends StatefulWidget {
  const WotOverlayPage({super.key});

  @override
  State<WotOverlayPage> createState() => _WotOverlayPageState();
}

class _WotOverlayPageState extends State<WotOverlayPage> {
  bool _show1 = false;
  bool _show2 = false;
  bool _show3 = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotOverlay 遮罩层',
      children: [
        demoSection('基础（visible / color / opacity / clickToClose）'),
        demoBlock('淡色遮罩 + 点击关闭',
            SizedBox(
              height: 160,
              child: Stack(children: [
                const Center(child: Text('下层内容')),
                WotOverlay(visible: _show1, opacity: 0.4, clickToClose: true, onClick: () => setState(() => _show1 = false)),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: WotButton(text: _show1 ? '关闭遮罩' : '显示遮罩', size: WotButtonSize.small,
                      onClick: () => setState(() => _show1 = !_show1)),
                ),
              ]),
            )),
        demoBlock('自定义 color 遮罩 + 覆盖内容',
            SizedBox(
              height: 160,
              child: Stack(children: [
                const Center(child: Text('下层内容')),
                WotOverlay(visible: _show2, color: Colors.black.withValues(alpha: 0.6), clickToClose: true, onClick: () => setState(() => _show2 = false)),
                if (_show2) const Center(child: Text('遮罩上的内容', style: TextStyle(color: Colors.white))),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: WotButton(text: _show2 ? '关闭' : '深色遮罩', size: WotButtonSize.small, type: WotButtonType.warning,
                      onClick: () => setState(() => _show2 = !_show2)),
                ),
              ]),
            )),
        demoBlock('自定义 opacity（0.7）',
            SizedBox(
              height: 160,
              child: Stack(children: [
                const Center(child: Text('下层内容')),
                WotOverlay(visible: _show3, opacity: 0.7),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: WotButton(text: _show3 ? '隐藏遮罩' : '高透明度遮罩', size: WotButtonSize.small, type: WotButtonType.success,
                      onClick: () => setState(() => _show3 = !_show3)),
                ),
              ]),
            )),
      ],
    );
  }
}