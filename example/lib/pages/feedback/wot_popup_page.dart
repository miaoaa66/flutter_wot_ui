import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotPopup 弹出层示例页（弹层作为全屏覆盖层叠在列表上方）。
class WotPopupPage extends StatefulWidget {
  const WotPopupPage({super.key});

  @override
  State<WotPopupPage> createState() => _WotPopupPageState();
}

class _WotPopupPageState extends State<WotPopupPage> {
  bool _bottom = false;
  bool _center = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WotPopup 弹出层')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              demoSection('底部弹出（position: bottom / round）'),
              demoBlock('点击底部出现',
                  WotButton(text: '底部弹层', size: WotButtonSize.small, onClick: () => setState(() => _bottom = true))),
              demoSection('居中弹出（position: center）'),
              demoBlock('点击居中出现',
                  WotButton(text: '居中弹层', size: WotButtonSize.small, type: WotButtonType.primary, onClick: () => setState(() => _center = true))),
            ],
          ),
          // 全屏弹层覆盖层（Positioned.fill 提供有界约束，避免 Stack expand 崩溃）。
          if (_bottom)
            Positioned.fill(
              child: WotPopup(
                visible: _bottom,
                onClose: () => setState(() => _bottom = false),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: const Center(child: WotText('底部弹出内容')),
                ),
              ),
            ),
          if (_center)
            Positioned.fill(
              child: WotPopup(
                visible: _center,
                position: WotPopupPosition.center,
                onClose: () => setState(() => _center = false),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('居中弹出内容'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}