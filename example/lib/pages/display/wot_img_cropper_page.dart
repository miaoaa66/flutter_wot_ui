import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotImgCropper 图片裁剪示例页（对话框内拖动/缩放，GlobalKey 命令式 crop）。
class WotImgCropperPage extends StatelessWidget {
  const WotImgCropperPage({super.key});

  Future<void> _openCropper(
    BuildContext context, {
    WotCropType outputType = WotCropType.png,
    double quality = 1,
  }) async {
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
                child: WotImgCropper(
                  key: key,
                  src: 'https://picsum.photos/800',
                  outputType: outputType,
                  quality: quality,
                  showButtons: false,
                ),
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
                          demoToast(
                              ctx,
                              r == null
                                  ? '裁剪失败'
                                  : '实际输出 ${r.outputType.name}，${r.width}x${r.height}，共 ${r.bytes.length} 字节');
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
        demoSection('导出格式（outputType / quality）'),
        demoBlock(
            'outputType: WotCropType.jpg + quality: 0.8——引擎支持 JPEG 编码时按 JPEG 输出'
            '（有损、quality 生效）；老引擎仅内置 PNG 时自动回退，实际格式以结果 outputType 如实上报',
            WotButton(
              text: '裁剪为 JPG（quality 0.8）',
              size: WotButtonSize.small,
              type: WotButtonType.primary,
              onClick: () => _openCropper(
                context,
                outputType: WotCropType.jpg,
                quality: 0.8,
              ),
            )),
        demoSection('内置操作栏（showButtons 默认 true）'),
        demoBlock(
            'showButtons: true：组件自带「取消 / 完成」栏；cancelText/confirmText 自定义文案，'
            'onCancelled / onCrop 回调（操作栏不自动关弹层，示例在回调里关闭）',
            WotButton(
              text: '内置操作栏裁剪',
              size: WotButtonSize.small,
              onClick: () => _openBuiltIn(context),
            )),
        demoSection('视口与缩放（aspectRatio / cropSize / minScale / maxScale）'),
        demoBlock(
            'aspectRatio: 16/9（裁剪框宽高比）+ cropSize: 280（框宽）+ '
            'minScale: 1 / maxScale: 5（双指缩放边界）',
            WotButton(
              text: '16:9 裁剪',
              size: WotButtonSize.small,
              onClick: () => _openWithRatio(context),
            )),
        demoSection('图片来源（imageProvider / srcIsAsset）'),
        demoBlock(
            'imageProvider 直接传 ImageProvider（与 src 二选一、优先级更高）；'
            'srcIsAsset: true 时 src 按 asset 解析（示例工程未配置 assets，此处用 NetworkImage 演示）',
            WotButton(
              text: 'imageProvider 传图',
              size: WotButtonSize.small,
              onClick: () => _openProvider(context),
            )),
      ],
    );
  }

  void _popWithResult(BuildContext ctx, WotCropResult? r) {
    demoToast(ctx, r == null ? '裁剪失败' : '实际输出 ${r.outputType.name}，${r.width}x${r.height}');
  }

  /// 内置操作栏路径：取消 / 完成由组件渲染，回调里关闭对话框。
  Future<void> _openBuiltIn(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          height: 420,
          child: WotImgCropper(
            src: 'https://picsum.photos/800',
            showButtons: true,
            cancelText: '放弃',
            confirmText: '就这张',
            onCancelled: () {
              demoToast(ctx, 'onCancelled：已取消');
              Navigator.pop(ctx);
            },
            onCrop: (r) {
              _popWithResult(ctx, r);
              Navigator.pop(ctx);
            },
          ),
        ),
      ),
    );
  }

  /// 视口与缩放参数。
  Future<void> _openWithRatio(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          height: 420,
          child: WotImgCropper(
            src: 'https://picsum.photos/800',
            aspectRatio: 16 / 9,
            cropSize: 280,
            minScale: 1,
            maxScale: 5,
            showButtons: true,
            onCrop: (r) {
              _popWithResult(ctx, r);
              Navigator.pop(ctx);
            },
            onCancelled: () => Navigator.pop(ctx),
          ),
        ),
      ),
    );
  }

  /// imageProvider 传图。
  Future<void> _openProvider(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          height: 420,
          child: WotImgCropper(
            imageProvider: const NetworkImage('https://picsum.photos/800'),
            showButtons: true,
            onCrop: (r) {
              _popWithResult(ctx, r);
              Navigator.pop(ctx);
            },
            onCancelled: () => Navigator.pop(ctx),
          ),
        ),
      ),
    );
  }
}