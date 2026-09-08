import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotVideoPreview 视频预览示例页（网络视频，失败由冒烟测试容错）。
class WotVideoPreviewPage extends StatelessWidget {
  const WotVideoPreviewPage({super.key});

  static const String _url = "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotVideoPreview 视频预览',
      children: [
        demoSection('命令式全屏（WotVideoPreview.show）'),
        demoBlock('点击全屏预览视频',
            WotButton(
              text: '预览视频',
              size: WotButtonSize.small,
              type: WotButtonType.primary,
              onClick: () => WotVideoPreview.show(context, _url, title: '示例视频'),
            )),
        demoSection('内嵌播放器'),
        demoBlock('内嵌视频播放',
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: WotVideoPreview(src: _url, title: '内嵌视频示例'),
              ),
            )),
      ],
    );
  }
}