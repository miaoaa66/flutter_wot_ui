import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotImgCropper 图片裁剪示例页（对话框内拖动/缩放，GlobalKey 命令式 crop）。
class WotImgCropperPage extends StatelessWidget {
  const WotImgCropperPage({super.key});

  Future<void> _openCropper(BuildContext context) async {
    final key = GlobalKey<WotImgCropperState>();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          height: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: WotImgCropper(key: key, src: 'https://picsum.photos/800', showButtons: false),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                      FilledButton(
                        onPressed: () async {
                          final r = await key.currentState?.crop();
                          if (!ctx.mounted) return;
                          demoToast(ctx, r == null ? '裁剪失败' : '已裁剪 ${r.width}x${r.height}，共 ${r.bytes.length} 字节');
                          Navigator.pop(ctx);
                        },
                        child: const Text('完成'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotImgCropper 图片裁剪',
      children: [
        demoSection('命令式裁剪（showButtons / GlobalKey<WotImgCropperState>.crop）'),
        demoBlock(
            '点击后在对话框内拖动/缩放图片，确认后导出裁剪结果',
            WotButton(
              text: '打开裁剪',
              size: WotButtonSize.small,
              type: WotButtonType.primary,
              onClick: () => _openCropper(context),
            )),
      ],
    );
  }
}