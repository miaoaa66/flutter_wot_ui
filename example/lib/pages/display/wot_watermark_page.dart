import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotWatermark 水印示例页。
///
/// 覆盖：内嵌模式（fullScreen: false，仅覆盖 [child] 区域）、
/// 全屏模式（fullScreen 默认 true，通过 Overlay 覆盖整个屏幕）、
/// 以及 rotate / opacity 等属性。
class WotWatermarkPage extends StatefulWidget {
  const WotWatermarkPage({super.key});

  @override
  State<WotWatermarkPage> createState() => _WotWatermarkPageState();
}

class _WotWatermarkPageState extends State<WotWatermarkPage> {
  bool _fullScreen = true;

  Widget _box({double height = 110, required String text}) {
    return Container(
      height: height,
      color: context.wotScheme.filledContent,
      alignment: Alignment.center,
      child: WotText(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotWatermark 水印',
      children: [
        demoSection('内嵌模式（fullScreen: false）'),
        demoBlock('水印仅覆盖下方内容区',
            WotWatermark(
              content: 'Wot UI Flutter',
              fontSize: 14,
              fullScreen: false,
              child: _box(text: '水印底层内容'),
            )),

        demoSection('全屏模式（fullScreen，默认 true）'),
        demoBlock(
          '开启时水印脱离容器、覆盖整个屏幕；关闭可对比内嵌效果',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('fullScreen'),
                value: _fullScreen,
                onChanged: (v) => setState(() => _fullScreen = v),
              ),
              WotWatermark(
                content: '全屏水印',
                fontSize: 12,
                opacity: 0.25,
                fullScreen: _fullScreen,
                child: _box(height: 90, text: '该容器之外也会被覆盖'),
              ),
            ],
          ),
        ),

        demoSection('属性（rotate / opacity）'),
        demoBlock('自定义旋转与透明度（用内嵌模式便于对比）',
            WotWatermark(
              content: '机密资料',
              fontSize: 12,
              rotate: -45,
              opacity: 0.4,
              fullScreen: false,
              child: _box(height: 100, text: '水印底层内容'),
            )),
      ],
    );
  }
}
