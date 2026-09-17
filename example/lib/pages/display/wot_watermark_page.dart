import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotWatermark 水印示例页。
///
/// 覆盖：内嵌模式（fullScreen: false）、**全屏模式（fullScreen，A 类死参数 #19）**、
/// image 图片水印、rotate / opacity / fontSize / lineHeight / gap / repeat /
/// color·fontColor，以及已废弃的 zIndex。
class WotWatermarkPage extends StatefulWidget {
  const WotWatermarkPage({super.key});

  @override
  State<WotWatermarkPage> createState() => _WotWatermarkPageState();
}

class _WotWatermarkPageState extends State<WotWatermarkPage> {
  bool _fullScreen = true;
  bool _repeat = true;
  int _rotate = -25;
  double _opacity = 0.15;
  double _lineHeight = 80;

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
        demoBlock(
          '水印仅在 child 区域内平铺，不越界。'
          '适合给单个卡片、图片加印。',
          WotWatermark(
            content: 'Wot UI Flutter',
            fontSize: 14,
            fullScreen: false,
            child: _box(text: '水印底层内容'),
          ),
        ),

        demoSection('全屏模式（fullScreen，A 类死参数 #19，默认 true）'),
        demoBlock(
          'fullScreen 原先声明了但 build 完全不读——'
          '传 true 和 false 渲染一模一样，是个彻底的死参数。'
          '现已用 Overlay 实现：开启时水印脱离容器布局、覆盖整个屏幕。'
          '⚠️ 默认值也一并从 false 改为 true（对齐 wot），'
          '不传参就是全屏——需要局部水印必须显式写 fullScreen: false。',
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

        demoSection('图片水印（image / imageWidth / imageHeight）'),
        demoBlock(
          '传入 image（网络图地址）后优先渲染图片，content 不再生效。'
          '默认尺寸 100 × 40（原为 40，已对齐 wot）。'
          '图片加载失败时会静默不显示——注意不是报错。',
          WotWatermark(
            image: 'https://flutter.dev/images/flutter-logo-sharing.png',
            imageWidth: 60,
            imageHeight: 60,
            fullScreen: false,
            child: _box(height: 120, text: '图片水印底层'),
          ),
        ),

        demoSection('排版（rotate / opacity / fontSize / lineHeight / gap / repeat）'),
        demoBlock(
          'repeat: false 时只画一个水印，不平铺；'
          'lineHeight 控制两行水印的垂直间距，gap 控制水平间距。'
          '下面全部用内嵌模式，方便并排对比。',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('角度 '),
                  Expanded(
                    child: Slider(
                      value: _rotate.toDouble(),
                      min: -90,
                      max: 0,
                      divisions: 9,
                      label: '$_rotate',
                      onChanged: (v) => setState(() => _rotate = v.round()),
                    ),
                  ),
                  Text('$_rotate°'),
                ],
              ),
              Row(
                children: [
                  const Text('透明 '),
                  Expanded(
                    child: Slider(
                      value: _opacity,
                      min: 0.05,
                      max: 0.8,
                      divisions: 15,
                      label: _opacity.toStringAsFixed(2),
                      onChanged: (v) => setState(() => _opacity = v),
                    ),
                  ),
                  Text(_opacity.toStringAsFixed(2)),
                ],
              ),
              Row(
                children: [
                  const Text('行距 '),
                  Expanded(
                    child: Slider(
                      value: _lineHeight,
                      min: 40,
                      max: 160,
                      divisions: 12,
                      label: _lineHeight.toStringAsFixed(0),
                      onChanged: (v) => setState(() => _lineHeight = v),
                    ),
                  ),
                  Text(_lineHeight.toStringAsFixed(0)),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('repeat（平铺）'),
                value: _repeat,
                onChanged: (v) => setState(() => _repeat = v),
              ),
              WotWatermark(
                content: '机密资料',
                fontSize: 12,
                rotate: _rotate.toDouble(),
                opacity: _opacity,
                lineHeight: _lineHeight,
                repeat: _repeat,
                fullScreen: false,
                child: _box(height: 130, text: '水印底层内容'),
              ),
            ],
          ),
        ),

        demoSection('颜色（color / fontColor）与多行文案'),
        demoBlock(
          'content 支持 \\n 换行。color 优先级高于 fontColor（后者为兼容保留）。',
          WotWatermark(
            content: '第一行\n第二行',
            fontSize: 13,
            color: const Color(0xFFF14646),
            opacity: 0.35,
            fullScreen: false,
            child: _box(height: 120, text: '红色多行水印'),
          ),
        ),

        demoSection('已废弃参数（zIndex）'),
        demoBlock(
          'zIndex 已 @Deprecated：Flutter 没有 CSS 的 z-index 语义，'
          '层叠顺序由 Overlay / Stack 的插入顺序决定，该参数从未生效。'
          '传任何值都不影响渲染，编译期会有删除线提示。',
          WotWatermark(
            content: 'zIndex 无效',
            fontSize: 12,
            // ignore: deprecated_member_use
            zIndex: 999,
            fullScreen: false,
            child: _box(height: 100, text: '底层内容'),
          ),
        ),
      ],
    );
  }
}
