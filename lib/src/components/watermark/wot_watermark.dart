import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 水印，对应 wot `wd-watermark`。
///
/// 参数对齐 wot：`content`（水印文案）、`fullScreen`（是否覆盖全屏，否则跟随子元素区域）、
/// `fontSize`、`fontColor`、`opacity`、`rotate`（旋转角，度）、`lineHeight`（行间距）、
/// `repeat`（是否平铺）。内容挂在 [child] 之下、水印覆盖其上。
class WotWatermark extends StatelessWidget {
  const WotWatermark({
    super.key,
    this.content = '',
    this.fullScreen = false,
    this.fontSize = 14,
    this.fontColor,
    this.opacity = 0.15,
    this.rotate = -22,
    this.lineHeight = 80,
    this.repeat = true,
    this.child,
  });

  /// 水印文案；支持用 `\n` 换行，也按行间距重复铺设。
  final String content;

  /// 是否铺满全屏（借助全屏透明定位）；否则平铺在 [child] 区域内。
  final bool fullScreen;

  final double fontSize;
  final Color? fontColor;
  final double opacity;
  final double rotate;
  final double lineHeight;
  final bool repeat;

  /// 水印下层内容。
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final color = (fontColor ?? scheme.textSecondary).withValues(alpha: opacity);

    final painter = _WatermarkPainter(
      content: content,
      color: color,
      fontSize: fontSize,
      rotate: rotate,
      lineHeight: lineHeight,
      repeat: repeat,
    );

    final watermark = CustomPaint(
      painter: painter,
      size: Size.infinite,
      child: const SizedBox.expand(),
    );

    if (!fullScreen) {
      return Stack(
        children: [
          child ?? const SizedBox.expand(),
          IgnorePointer(
            child: Positioned.fill(
              child: watermark,
            ),
          ),
        ],
      );
    }

    // 全屏模式：用 Overlay 之外的 Positioned 占满可用区域。
    return Stack(
      children: [
        child ?? const SizedBox.expand(),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: IgnorePointer(child: watermark),
        ),
      ],
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  _WatermarkPainter({
    required this.content,
    required this.color,
    required this.fontSize,
    required this.rotate,
    required this.lineHeight,
    required this.repeat,
  });

  final String content;
  final Color color;
  final double fontSize;
  final double rotate;
  final double lineHeight;
  final bool repeat;

  @override
  void paint(Canvas canvas, Size size) {
    if (content.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(text: content, style: TextStyle(fontSize: fontSize, color: color)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotate * 3.141592653589793 / 180);

    final halfW = tp.width / 2;
    final halfH = tp.height / 2;
    final step = lineHeight;

    if (!repeat) {
      tp.paint(canvas, Offset(-halfW, -halfH));
    } else {
      final rows = (size.height / step).ceil() + 2;
      final cols = (size.width / step).ceil() + 2;
      for (var r = -rows ~/ 2; r < rows ~/ 2; r++) {
        for (var c = -cols ~/ 2; c < cols ~/ 2; c++) {
          tp.paint(canvas, Offset(c * step - halfW, r * step - halfH));
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WatermarkPainter old) {
    return old.content != content ||
        old.color != color ||
        old.fontSize != fontSize ||
        old.rotate != rotate ||
        old.lineHeight != lineHeight ||
        old.repeat != repeat;
  }
}