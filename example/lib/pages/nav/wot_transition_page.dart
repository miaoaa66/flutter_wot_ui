import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotTransition 过渡动画示例页。
class WotTransitionPage extends StatefulWidget {
  const WotTransitionPage({super.key});

  @override
  State<WotTransitionPage> createState() => _WotTransitionPageState();
}

class _WotTransitionPageState extends State<WotTransitionPage> {
  bool _show = true;

  Widget _box(BuildContext c, String text) => Container(
        width: 140,
        height: 60,
        color: c.wotScheme.primaryOf(6),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      );

  void _toggle() => setState(() => _show = !_show);

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotTransition 过渡动画',
      children: [
        demoSection('name 动画类型（fade / slideUp / zoom / slideLeft 等）'),
        demoBlock('淡入淡出 fade',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WotButton(text: _show ? '隐藏' : '显示', size: WotButtonSize.small, onClick: _toggle),
              const SizedBox(height: 8),
              WotTransition(inShow: _show, name: WotTransitionName.fade, child: _box(context, 'fade')),
            ])),
        demoSection('上滑进入（slideUp）'),
        demoBlock('slideUp',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WotButton(text: _show ? '隐藏' : '显示', size: WotButtonSize.small, onClick: _toggle),
              const SizedBox(height: 8),
              WotTransition(inShow: _show, name: WotTransitionName.slideUp, child: _box(context, 'slideUp')),
            ])),
        demoSection('缩放（zoom）'),
        demoBlock('zoom',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WotButton(text: _show ? '隐藏' : '显示', size: WotButtonSize.small, onClick: _toggle),
              const SizedBox(height: 8),
              WotTransition(inShow: _show, name: WotTransitionName.zoom, child: _box(context, 'zoom')),
            ])),
      ],
    );
  }
}