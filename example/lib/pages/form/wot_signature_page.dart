import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSignature 手写签名示例页。
class WotSignaturePage extends StatefulWidget {
  const WotSignaturePage({super.key});

  @override
  State<WotSignaturePage> createState() => _WotSignaturePageState();
}

class _WotSignaturePageState extends State<WotSignaturePage> {
  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSignature 手写签名',
      children: [
        demoSection('基础用法（onUpdate 回调）'),
        demoBlock(
            '书写，右上角删除图标清空',
            WotSignature(
              height: 160,
              onUpdate: (has) => demoToast(context, has ? '开始签名' : '已清空'),
            )),
        demoSection('属性（penColor / lineWidth / bgColor / height）'),
        demoBlock('lineWidth=6 粗笔 + penColor 蓝色',
            WotSignature(height: 160, lineWidth: 6, penColor: Colors.blue)),
        demoBlock('bgColor 浅蓝底', WotSignature(height: 120, bgColor: const Color(0xFFE9F4FF))),
        demoSection('状态（disabled）'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用书写', WotSignature(height: 160, disabled: _disabled)),
      ],
    );
  }
}