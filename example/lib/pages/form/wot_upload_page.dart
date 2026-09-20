import 'dart:async';

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
  bool _readonly = false;
  bool _failNext = true;

  /// 演示用的自定义上传：模拟分段上报进度。
  ///
  /// 真实项目里请在这里换成你的网络请求（`package:http` / `dio` 等），
  /// 按已发送字节数回调 onProgress，并回传 [WotUploadResponse]。
  Future<WotUploadResponse> _demoUpload(
    WotUploadFile file,
    void Function(double percent) onProgress,
  ) async {
    for (var p = 10; p <= 100; p += 15) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      onProgress(p.toDouble());
    }
    return WotUploadResponse(
      statusCode: 200,
      body: '{"url":"https://example.com/${file.name}"}',
      url: 'https://example.com/${file.name}',
    );
  }

  /// 演示失败态：返回一个非 2xx 结果，组件会切换到 fail 并可点击重试。
  Future<WotUploadResponse> _demoFail(
    WotUploadFile file,
    void Function(double percent) onProgress,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    onProgress(60);
    return const WotUploadResponse(statusCode: 500, error: '服务端返回 500');
  }

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
        demoSection('真实上传（uploadMethod）'),
        demoBlock(
            'uploadMethod 自定义上传 + 真实进度',
            WotUpload(
              uploadMethod: _demoUpload,
              onUpload: (f) => demoToast(context, '成功：${f.name}'),
              onFail: (f) => demoToast(context, '失败：${f.name}'),
            )),
        demoBlock(
            '失败态：点击文件可重试（onFail）',
            WotUpload(
              uploadMethod: _failNext ? _demoFail : _demoUpload,
              onFail: (f) => demoToast(context, '上传失败：${f.name}'),
              onUpload: (f) => demoToast(context, '重试成功：${f.name}'),
            )),
        Row(children: [
          Flexible(
            child: FilledButton.tonal(
              onPressed: () => setState(() => _failNext = !_failNext),
              child: Text('下一次上传：${_failNext ? "失败" : "成功"}'),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        demoBlock(
            'accept 限制文件类型（image/*）',
            WotUpload(
              accept: 'image/*',
              uploadMethod: _demoUpload,
              onChange: (_) => demoToast(context, '已选文件'),
            )),
        demoSection('三态（disabled / readonly）'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled')),
          FilledButton.tonal(onPressed: () => setState(() => _readonly = !_readonly), child: Text('readonly: $_readonly')),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用（锁增删 + 整体淡化）',
            WotUpload(disabled: _disabled, onChange: (_) {})),
        demoBlock('readonly 只读（锁增删、**预览仍可用** —— 配色不变）',
            WotUpload(readonly: _readonly, onChange: (_) {})),
      ],
    );
  }
}