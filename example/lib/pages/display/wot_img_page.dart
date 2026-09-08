import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotImg 图片示例页（网络图，加载失败由冒烟测试容错）。
class WotImgPage extends StatelessWidget {
  const WotImgPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotImg 图片',
      children: [
        demoSection('基础（src / width / height / radius / preview）'),
        demoBlock('圆角 + 可点击预览',
            const WotImg(
              src: 'https://picsum.photos/seed/swiper/400/200',
              width: double.infinity,
              height: 120,
              radius: 8,
              preview: true,
            )),
        demoSection('加载失败占位'),
        demoBlock('bad src 占位',
            const WotImg(
              src: 'https://invalid.example.com/x.png',
              width: double.infinity,
              height: 80,
            )),
      ],
    );
  }
}