import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 水印，对应 wot `wd-watermark`。
///
/// 支持文字水印与图片水印；参数对齐 wot：`content`（水印文案）、`image`（图片地址）、
/// `fullScreen`（是否覆盖全屏，否则跟随子元素区域）、`fontSize`、`color`、`opacity`、
/// `rotate`（旋转角，度）、`gap`（间距）、`zIndex`（层级）、`repeat`（是否平铺）。
/// 内容挂在 [child] 之下、水印覆盖其上。
class WotWatermark extends StatefulWidget {
  const WotWatermark({
    super.key,
    this.content = '',
    this.image,
    this.imageWidth = 100,
    this.imageHeight = 40,
    this.fullScreen = true,
    this.fontSize = 14,
    this.fontColor,
    this.color,
    this.opacity = 0.15,
    this.rotate = -25,
    this.lineHeight = 80,
    this.gap,
    @Deprecated('zIndex 从未生效，将在后续版本移除。') this.zIndex,
    this.repeat = true,
    this.fontWeight,
    this.fontStyle = FontStyle.normal,
    this.fontFamily,
    this.child,
  });

  /// 水印文案；支持用 `\n` 换行。
  final String content;

  /// 水印图片地址（网络图）；传入后优先渲染图片水印（此时 [content] 不生效）。
  final String? image;

  /// 水印图片宽度（逻辑像素），默认 40。
  final double imageWidth;

  /// 水印图片高度（逻辑像素），默认 40。
  final double imageHeight;

  /// 是否铺满全屏，默认 true（对齐 wot）。
  ///
  /// 为 true 时水印通过 Overlay 脱离 [child] 布局、覆盖整个屏幕；
  /// 为 false 时仅在 [child] 区域内平铺。
  final bool fullScreen;

  /// 水印字号（逻辑像素），默认 14。
  final double fontSize;

  /// 水印文字颜色（旧参数，兼容保留）；与 [color] 同时传入时以 [color] 优先。
  final Color? fontColor;

  /// 水印文字颜色；为空时按 [fontColor] 或主题次要文字色推导。
  final Color? color;

  /// 水印透明度，取值范围 0~1，默认 0.15。
  final double opacity;

  /// 水印旋转角度（度），默认 -25。
  final double rotate;

  /// 行间距（旧参数，兼容保留）；[gap] 未指定时作为水印单元间距使用。
  final double lineHeight;

  /// 水印单元 X/Y 间距（逻辑像素）；为空时取 [lineHeight]。
  final double? gap;

  /// **已废弃**：该参数从未被 `build` 消费（死参数），仅表达"期望层级"。
  ///
  /// Flutter 的 `Stack` 按绘制顺序分层，水印恒定在 [child] 之上，无法通过数值调整。
  /// 如需把水印浮到整页之上，请改用 [fullScreen]。
  @Deprecated('zIndex 从未生效（Flutter Stack 按绘制顺序分层）。如需浮到整页之上请改用 fullScreen。')
  final int? zIndex;

  /// 是否平铺，默认 true；为 false 时仅在区域中心渲染一个水印。
  final bool repeat;

  /// 水印字体粗细；为空时使用常规字重。
  final FontWeight? fontWeight;

  /// 水印字体样式，可选 normal/italic/oblique，默认 normal。
  final FontStyle fontStyle;

  /// 水印字体系列；为空时使用默认字体。
  final String? fontFamily;

  /// 水印下层内容。
  final Widget? child;

  @override
  State<WotWatermark> createState() => _WotWatermarkState();
}

class _WotWatermarkState extends State<WotWatermark> {
  ui.Image? _image;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  /// 全屏模式下承载水印的浮层；非全屏模式下为 null。
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadImage();
    _syncOverlay();
  }

  @override
  void didUpdateWidget(WotWatermark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) _loadImage();
    _syncOverlay();
  }

  @override
  void dispose() {
    _removeOverlay();
    _removeListener();
    super.dispose();
  }

  /// 依据 [WotWatermark.fullScreen] 同步浮层的插入、刷新或移除。
  ///
  /// 插入必须延后到当前帧结束，避免在 build 阶段操作 Overlay 触发
  /// 「markedNeedsBuild during build」一类错误。
  void _syncOverlay() {
    if (!widget.fullScreen) {
      _removeOverlay();
      return;
    }
    final existing = _overlayEntry;
    if (existing != null) {
      existing.markNeedsBuild();
      return;
    }
    final entry = OverlayEntry(builder: (_) => _buildFullScreenOverlay());
    _overlayEntry = entry;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _overlayEntry != entry) return;
      final overlay = Overlay.maybeOf(context);
      if (overlay == null) {
        _overlayEntry = null;
        return;
      }
      overlay.insert(entry);
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _removeListener() {
    final st = _stream;
    final l = _listener;
    if (st != null && l != null) st.removeListener(l);
    _stream = null;
    _listener = null;
  }

  void _loadImage() {
    _removeListener();
    _image = null;
    final url = widget.image;
    if (url == null || url.isEmpty) return;
    final stream = NetworkImage(url).resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener((info, _) {
      if (!mounted) return;
      setState(() => _image = info.image);
      _syncOverlay();
    }, onError: (_, _) {
      // 图片加载失败时静默回退为空（不显示水印）。
    });
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  double get _gapSize => widget.gap ?? widget.lineHeight;

  /// 构造水印绘制器，全屏浮层与内嵌模式共用。
  _WatermarkPainter _buildPainter() {
    final scheme = context.wotScheme;
    final base = widget.color ?? widget.fontColor ?? scheme.textSecondary;
    final color = base.withValues(alpha: widget.opacity);
    return _WatermarkPainter(
      content: widget.content,
      image: _image,
      imageWidth: widget.imageWidth,
      imageHeight: widget.imageHeight,
      color: color,
      fontSize: widget.fontSize,
      rotate: widget.rotate,
      gap: _gapSize,
      repeat: widget.repeat,
      fontWeight: widget.fontWeight,
      fontStyle: widget.fontStyle,
      fontFamily: widget.fontFamily,
    );
  }

  /// 全屏模式下承载的水印内容：铺满整个屏幕且不拦截手势。
  Widget _buildFullScreenOverlay() {
    return IgnorePointer(
      child: CustomPaint(
        painter: _buildPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 全屏模式下水印由 Overlay 承载，这里只渲染下层内容。
    // 浮层的插入/刷新/移除统一由 initState、didUpdateWidget、dispose 驱动，
    // 避免在 build 阶段操作 Overlay 触发重入错误。
    if (widget.fullScreen) {
      return widget.child ?? const SizedBox.shrink();
    }

    final watermark = CustomPaint(
      painter: _buildPainter(),
      child: const SizedBox.expand(),
    );

    final overlay = Positioned.fill(
      child: RepaintBoundary(
        child: IgnorePointer(
          child: ClipRect(
            child: watermark,
          ),
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        widget.child ?? const SizedBox.expand(),
        overlay,
      ],
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  _WatermarkPainter({
    required this.content,
    required this.image,
    required this.imageWidth,
    required this.imageHeight,
    required this.color,
    required this.fontSize,
    required this.rotate,
    required this.gap,
    required this.repeat,
    this.fontWeight,
    required this.fontStyle,
    this.fontFamily,
  });

  final String content;
  final ui.Image? image;
  final double imageWidth;
  final double imageHeight;
  final Color color;
  final double fontSize;
  final double rotate;
  final double gap;
  final bool repeat;
  final FontWeight? fontWeight;
  final FontStyle fontStyle;
  final String? fontFamily;

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null && content.isEmpty) return;

    // 单口裁剪：水印仅在容器区域内绘制，旋转/平铺探出的部分一并被裁掉，
    // 避免水印内容跑到容器外面。
    canvas.clipRect(Offset.zero & size);

    double halfW = gap / 2;
    double halfH = gap / 2;
    _tp = null;

    if (image != null) {
      halfW = imageWidth / 2;
      halfH = imageHeight / 2;
    } else {
      final tp = _textPainter();
      tp.layout(maxWidth: gap);
      _tp = tp;
      halfW = tp.width / 2;
      halfH = tp.height / 2;
    }

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotate * 3.141592653589793 / 180);

    if (!repeat) {
      _drawOne(canvas, Offset(-halfW, -halfH));
    } else {
      final step = gap;
      if (step <= 0) {
        _drawOne(canvas, Offset(-halfW, -halfH));
      } else {
        final rows = (size.height / step).ceil() + 2;
        final cols = (size.width / step).ceil() + 2;
        for (var r = -rows ~/ 2; r < rows ~/ 2; r++) {
          for (var c = -cols ~/ 2; c < cols ~/ 2; c++) {
            _drawOne(canvas, Offset(c * step - halfW, r * step - halfH));
          }
        }
      }
    }
    canvas.restore();
    _tp = null;
  }

  TextPainter? _tp;

  TextPainter _textPainter() {
    return TextPainter(
      text: TextSpan(
        text: content,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          fontFamily: fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
  }

  void _drawOne(Canvas canvas, Offset offset) {
    final img = image;
    if (img != null) {
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Rect.fromLTWH(offset.dx, offset.dy, imageWidth, imageHeight),
        Paint()..color = color,
      );
      return;
    }
    var tp = _tp;
    if (tp == null) {
      tp = _textPainter()..layout(maxWidth: gap);
      _tp = tp;
    }
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_WatermarkPainter old) {
    return old.content != content ||
        old.image != image ||
        old.imageWidth != imageWidth ||
        old.imageHeight != imageHeight ||
        old.color != color ||
        old.fontSize != fontSize ||
        old.rotate != rotate ||
        old.gap != gap ||
        old.repeat != repeat ||
        old.fontWeight != fontWeight ||
        old.fontStyle != fontStyle ||
        old.fontFamily != fontFamily;
  }
}