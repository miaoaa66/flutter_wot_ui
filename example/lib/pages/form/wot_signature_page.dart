import 'dart:typed_data';

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

  // 图片导出回显（基础用法里的确认导出）。
  Uint8List? _exportedBytes;
  String _exportInfo = '';

  // 导出参数（清晰度）。
  double _exportScale = 2;

  void _onExport(WotSignatureResult r) {
    if (r.success && r.bytes != null) {
      setState(() {
        _exportedBytes = r.bytes;
        _exportInfo = '已导出 ${(r.bytes!.length / 1024).toStringAsFixed(1)} KB';
      });
      demoToast(context, _exportInfo);
    } else {
      demoToast(context, '画板为空，无法导出');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSignature 手写签名',
      children: [
        demoSection('基础用法（onUpdate 回调 + 清空图标）'),
        demoBlock(
            '书写，右上角删除图标清空',
            WotSignature(
              height: 160,
              onUpdate: (has) => demoToast(context, has ? '开始签名' : '已清空'),
            )),
        demoSection('图片导出（onConfirm 回显，exportScale=2）'),
        demoBlock('点击「确认」导出 PNG 并在下方预览',
            WotSignature(height: 160, exportScale: 2, onConfirm: _onExport)),
        if (_exportedBytes != null)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_exportInfo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Image.memory(_exportedBytes!, height: 80),
              ],
            ),
          ),
        demoSection('历史记录（enableHistory：撤销 / 恢复）'),
        demoBlock('开历史后，底部出现「撤销 / 恢复」按钮',
            const WotSignature(height: 160, enableHistory: true)),
        demoSection('导出参数（exportScale 提高清晰度）'),
        demoBlock('exportScale=${_exportScale.toInt()}（值越大像素越高、越清晰）',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: _exportScale,
                  min: 1,
                  max: 4,
                  divisions: 3,
                  label: _exportScale.toInt().toString(),
                  onChanged: (v) => setState(() => _exportScale = v),
                ),
                WotSignature(
                  height: 140,
                  exportScale: _exportScale,
                  onConfirm: _onExport,
                ),
                const SizedBox(height: 6),
                const Text(
                  'fileType / quality（JPG）需引擎支持 ImageByteFormat.jpeg'
                  '（Flutter ≥ 3.22），当前环境回退 PNG，quality 不生效。',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            )),
        demoSection('属性（penColor / lineWidth / bgColor）'),
        demoBlock('lineWidth=6 粗笔 + penColor 蓝色',
            WotSignature(height: 160, lineWidth: 6, penColor: Colors.blue)),
        demoBlock('bgColor 浅蓝底', WotSignature(height: 120, bgColor: const Color(0xFFE9F4FF))),
        demoSection('状态（disabled）'),
        Row(children: [
          Flexible(
              child: FilledButton.tonal(
                  onPressed: () => setState(() => _disabled = !_disabled),
                  child: Text('disabled: $_disabled'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用书写', WotSignature(height: 160, disabled: _disabled)),
      ],
    );
  }
}
