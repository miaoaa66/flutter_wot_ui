import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotUpload 上传示例页。
///
/// 上传依赖 file_picker 选文件；本页展示常用属性配置（maxCount / multiple /
/// autoUpload / preview / size / gutter / 受限大小）。
class WotUploadPage extends StatefulWidget {
  const WotUploadPage({super.key});

  @override
  State<WotUploadPage> createState() => _WotUploadPageState();
}

class _WotUploadPageState extends State<WotUploadPage> {
  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotUpload 上传',
      children: [
        demoSection('基础上传（maxCount / multiple / autoUpload）'),
        demoBlock(
            '最多 3 个、可多选、选后自动上传',
            WotUpload(
              maxCount: 3,
              onChange: (_) => demoToast(context, '文件列表已更新'),
              onUpload: (f) => demoToast(context, '上传：${f.name ?? "文件"}'),
            )),
        demoSection('限制大小（maxSize / onOverSize）'),
        demoBlock(
            '单文件不超过 1MB ',
            WotUpload(
              maxSize: 1024 * 1024,
              onOverSize: (f) => demoToast(context, '超限：${f.name}'),
              onChange: (_) => demoToast(context, '已加入'),
            )),
        demoSection('尺寸与间距（size / gutter / addText）'),
        demoBlock('size=60 gutter=8 addText=上传',
            WotUpload(size: 60, gutter: 8, addText: '上传', onChange: (_) {})),
        demoSection('受控列表 + 状态'),
        demoBlock(
            '自定义初始文件（受控 files）',
            WotUpload(
              files: const [
                WotUploadFile(name: '示例文档.pdf', url: '', type: 'pdf'),
              ],
              onChange: (_) => demoToast(context, '列表变化'),
            )),
        demoSection('状态（disabled）'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用', WotUpload(disabled: _disabled, onChange: (_) {})),
      ],
    );
  }
}