import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';

/// 裁剪结果数据。
///
/// 对应 wot `wd-img-cropper` 的 `confirm` 事件返回值，
/// 用 [bytes] 承载导出位图（PNG/JPEG），[width]/[height] 为导出像素尺寸。
class WotCropResult {
  const WotCropResult({
    required this.bytes,
    required this.width,
    required this.height,
    required this.outputType,
  });

  /// 导出图片字节（PNG 或 JPEG）。
  final Uint8List bytes;

  /// 导出图片像素宽。
  final int width;

  /// 导出图片像素高。
  final int height;

  /// 导出格式：`png` / `jpg`。
  final String outputType;
}

/// 裁剪完成回调。
typedef WotCropCallback = void Function(WotCropResult result);

/// 图片裁剪组件，对应 wot `wd-img-cropper`。
///
/// 支持双指缩放、拖动平移图片，居中固定裁剪框并带暗色遮罩；通过
/// `crop()`（或点击“完成”按钮）借助 `InteractiveViewer` +
/// `RepaintBoundary.toImage` 导出裁剪框区域的位图。
///
/// 通过 `imageProvider` 或 `src`（网络 / asset，见 [srcIsAsset]）传入原图，
/// 可在选择器（如 `WotImagePreview`、`showDialog`）内以全屏承载本组件。
class WotImgCropper extends StatefulWidget {
  const WotImgCropper({
    super.key,
    this.imageProvider,
    this.src,
    this.srcIsAsset = false,
    this.width,
    this.height,
    this.cropSize,
    this.aspectRatio,
    this.outputType = WotCropType.png,
    this.quality = 1,
    this.minScale = 1,
    this.maxScale = 3,
    this.showButtons = true,
    this.cancelText,
    this.confirmText,
    this.onCancelled,
    this.onCrop,
  }) : assert(
          imageProvider != null || src != null,
          '必须提供 imageProvider 或 src 中的至少一个',
        );

  /// 直接传入图片提供者（如 `AssetImage`、`NetworkImage`、`MemoryImage`）。
  ///
  /// 与 [src] 二选一；同时提供时优先使用 [imageProvider]。
  final ImageProvider? imageProvider;

  /// 图片资源地址（默认按网络链接 [Image.network] 加载；
  /// 若为 asset 资源请同时把 [srcIsAsset] 置为 true）。
  final String? src;

  /// [src] 是否为 `assets` 资源。为 true 时使用 [Image.asset]。
  ///
  /// 默认 `false`（网络链接）。
  final bool srcIsAsset;

  /// 裁剪视口宽度；空则撑满父容器约束。
  final double? width;

  /// 裁剪视口高度；空则撑满父容器约束。
  final double? height;

  /// 裁剪框边长（逻辑像素），默认取视口宽高中的较小者。
  ///
  /// 在 [aspectRatio] 非空时表示“宽度”。
  final double? cropSize;

  /// 裁剪框宽高比（`宽/高`）。为空时使用正方形裁剪框；对应 wot
  /// `aspect-ratio`（如 `3:2` → 1.5、`16:9` → 16/9）。
  final double? aspectRatio;

  /// 导出格式：`jpg` / `png`，对应 wot `file-type`。
  ///
  /// 默认 `png`。请使用预置常量 [WotCropType.jpg]/[WotCropType.png]。
  final String outputType;

  /// 导出图片质量（0~1），对应 wot `quality`，默认 `1`。
  ///
  /// 仅对 JPEG 格式有效，映射到导出压缩质量（0-100）。
  final double quality;

  /// 最小缩放倍数，默认 `1`。
  final double minScale;

  /// 最大缩放倍数，对应 wot `max-scale`，默认 `3`。
  final double maxScale;

  /// 是否显示底部“取消 / 完成”按钮，默认 `true`；
  /// 为 false 时由外层通过 `crop()` / 自行处理交互。
  final bool showButtons;

  /// 取消按钮文案，默认“取消”。
  final String? cancelText;

  /// 完成按钮文案，默认“完成”。
  final String? confirmText;

  /// 点击“取消”按钮回调（默认文案“取消”）。
  final VoidCallback? onCancelled;

  /// 导出成功回调，参数为 [WotCropResult]（bytes/尺寸/格式）。
  final WotCropCallback? onCrop;

  @override
  State<WotImgCropper> createState() => WotImgCropperState();
}

/// 导出格式常量，供 [outputType] 使用。
class WotCropType {
  WotCropType._();

  /// JPEG 格式。
  static const String jpg = 'jpg';

  /// PNG 格式。
  static const String png = 'png';
}

/// 图片裁剪组件的状态，暴露 `crop()` 导出裁剪框区域位图。
class WotImgCropperState extends State<WotImgCropper> {
  /// 包裹图片承载区的 [RepaintBoundary]，用于 `toImage` 导出裁剪像素。
  final GlobalKey _boundaryKey = GlobalKey();

  /// 裁剪框在视口内的矩形（由最近一次布局计算得出）。
  Rect _cropRect = Rect.zero;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewportW = constraints.maxWidth;
            final viewportH = constraints.maxHeight;
            _cropRect = _computeCropRect(viewportW, viewportH);

            final image = _buildImage();

            return Stack(
              fit: StackFit.expand,
              children: [
                // 图片承载区：仅在 InteractiveViewer 上包裹 RepaintBoundary，
                // 使 crop() 导出时不包含遮罩/裁剪框/按钮。
                RepaintBoundary(
                  key: _boundaryKey,
                  child: InteractiveViewer(
                    minScale: widget.minScale,
                    maxScale: widget.maxScale,
                    boundaryMargin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    panEnabled: true,
                    scaleEnabled: true,
                    child: SizedBox(
                      width: viewportW,
                      height: viewportH,
                      child: image,
                    ),
                  ),
                ),
                // 裁剪框 + 遮罩（不参与导出）。
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CropOverlayPainter(
                        cropRect: _cropRect,
                        maskColor: scheme.opacMainCover,
                        borderColor: scheme.borderWhite,
                        gridColor: scheme.borderWhite.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                if (widget.showButtons)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildFooter(scheme),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 计算裁剪框矩形：居中于视口，边长取 `cropSize` 或视口短边，并收缩到视口内。
  Rect _computeCropRect(double viewportW, double viewportH) {
    final base = widget.cropSize ?? math.min(viewportW, viewportH);
    final ratio = widget.aspectRatio ?? 1;
    double cw, ch;
    if (ratio > 0) {
      cw = base;
      ch = base / ratio;
    } else {
      cw = base;
      ch = base;
    }
    // 保证裁剪框不超出视口。
    final maxW = math.min(cw, viewportW);
    final maxH = math.min(ch, viewportH);
    cw = math.min(maxW, maxH * ratio); // 受高度限定
    ch = math.min(maxH, maxW / ratio); // 受宽度限定
    cw = math.min(cw, maxW);
    ch = math.min(ch, maxH);
    final center = Offset(viewportW / 2, viewportH / 2);
    return Rect.fromCenter(center: center, width: cw, height: ch);
  }

  /// 构建承载图片的 widget。
  Widget _buildImage() {
    final provider = widget.imageProvider;
    final fit = BoxFit.cover; // 填满裁剪视口，便于裁剪框中心取样。
    if (provider != null) {
      return Image(image: provider, fit: fit, gaplessPlayback: true);
    }
    if (widget.srcIsAsset) {
      return Image.asset(widget.src!, fit: fit, gaplessPlayback: true);
    }
    return Image.network(widget.src!, fit: fit, gaplessPlayback: true);
  }

  /// 底部“取消 / 完成”按钮栏。
  Widget _buildFooter(WotScheme scheme) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => widget.onCancelled?.call(),
              child: Text(
                widget.cancelText ?? '取消',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primaryOf(6),
                foregroundColor: scheme.textWhite,
              ),
              onPressed: _handleCrop,
              child: Text(widget.confirmText ?? '完成'),
            ),
          ],
        ),
      ),
    );
  }

  /// “完成”按钮处理：导出并回调。
  Future<void> _handleCrop() async {
    final result = await crop();
    if (result != null) widget.onCrop?.call(result);
  }

  /// 导出裁剪框区域位图。
  ///
  /// 通过 [RepaintBoundary.toImage] 截取图片承载区的全部像素，
  /// 再按裁剪框局部矩形 `_cropRect` 用 [Canvas.drawImageRect] 抠图生成
  /// 独立位图，最后按 [outputType]（png / jpg）编码为字节。
  ///
  /// 返回 [WotCropResult]；无图片或导出失败时返回 null。
  Future<WotCropResult?> crop() async {
    final renderObject =
        _boundaryKey.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderRepaintBoundary) {
      return null;
    }
    if (_cropRect.isEmpty) return null;

    final ratio = MediaQuery.of(context).devicePixelRatio;
    final source = await renderObject.toImage(pixelRatio: ratio);

    // 裁剪框在抓取位图中的像素矩形。
    final srcRect = Rect.fromLTWH(
      _cropRect.left * ratio,
      _cropRect.top * ratio,
      _cropRect.width * ratio,
      _cropRect.height * ratio,
    );
    final outW = srcRect.width.round().clamp(1, 1 << 14);
    final outH = srcRect.height.round().clamp(1, 1 << 14);

    // 离屏绘制：仅保留裁剪框内的像素。
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      source,
      srcRect,
      Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
      Paint()..filterQuality = FilterQuality.high,
    );
    final picture = recorder.endRecording();
    final cropped = await picture.toImage(outW, outH);
    source.dispose();
    picture.dispose();

    // 编码导出。说明：Flutter 的 `ui.Image.toByteData` 仅支持 PNG（无损），
    // 原生不支持 JPEG 编码，故无论 [outputType] 为 jpg 或 png 均输出 PNG 字节；
    // JPEG 输出需自行借助图像编码包（本项目约束不引入三方库），
    // 因此 [quality]（仅对 JPEG 有意义）当前不参与编码。
    final ByteData? data = await cropped.toByteData(
      format: ui.ImageByteFormat.png,
    );
    cropped.dispose();
    if (data == null) return null;

    return WotCropResult(
      bytes: data.buffer.asUint8List(),
      width: outW,
      height: outH,
      outputType: WotCropType.png,
    );
  }
}

/// 裁剪框遮罩绘制者。
///
/// 在裁剪框四周绘制暗色遮罩（含 3x3 明暗高亮效果），
/// 并绘制裁剪框边界线与九宫格辅助线。
class _CropOverlayPainter extends CustomPainter {
  _CropOverlayPainter({
    required this.cropRect,
    required this.maskColor,
    required this.borderColor,
    required this.gridColor,
  });

  final Rect cropRect;
  final Color maskColor;
  final Color borderColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    // —— 四周遮罩（保持裁剪框区域透明）。 ——
    final mask = Paint()..color = maskColor;
    final top = Offset(0, 0) & Size(size.width, cropRect.top);
    final bottom = Offset(0, cropRect.bottom) &
        Size(size.width, size.height - cropRect.bottom);
    final left = Offset(0, cropRect.top) &
        Size(cropRect.left, cropRect.height);
    final right = Offset(cropRect.right, cropRect.top) &
        Size(size.width - cropRect.right, cropRect.height);
    canvas.drawRect(top, mask);
    canvas.drawRect(bottom, mask);
    canvas.drawRect(left, mask);
    canvas.drawRect(right, mask);

    // —— 裁剪框边界线。 ——
    canvas.drawRect(
      cropRect.inflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = borderColor,
    );

    // —— 内部九宫格辅助线。 ——
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = gridColor;
    final thirdW = cropRect.width / 3;
    final thirdH = cropRect.height / 3;
    for (var i = 1; i < 3; i++) {
      final x = cropRect.left + thirdW * i;
      final y = cropRect.top + thirdH * i;
      canvas.drawLine(
          Offset(x, cropRect.top), Offset(x, cropRect.bottom), grid);
      canvas.drawLine(
          Offset(cropRect.left, y), Offset(cropRect.right, y), grid);
    }
  }

  @override
  bool shouldRepaint(_CropOverlayPainter oldDelegate) =>
      oldDelegate.cropRect != cropRect ||
      oldDelegate.maskColor != maskColor ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.gridColor != gridColor;
}