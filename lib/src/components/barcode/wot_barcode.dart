import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 条码类型，对齐 wot `wd-barcode` 的 `type` 可选值。
enum WotBarcodeType {
  /// Code 128：高密度线性条码，支持全 ASCII，通用。
  code128,

  /// Code 39：字母数字条码。
  code39,

  /// EAN-13：13 位商品码。
  ean13,

  /// EAN-8：8 位商品码。
  ean8,

  /// UPC-A：美国 12 位商品码。
  upcA,

  /// UPC-E：美国压缩商品码。
  upcE,

  /// ISBN 图书编码。
  isbn,

  /// ITF-14 物流/箱码。
  itf14,

  /// Codabar 条码。
  codabar,
}

Barcode _toBarcode(WotBarcodeType type) {
  return switch (type) {
    WotBarcodeType.code128 => Barcode.code128(),
    WotBarcodeType.code39 => Barcode.code39(),
    WotBarcodeType.ean13 => Barcode.ean13(),
    WotBarcodeType.ean8 => Barcode.ean8(),
    WotBarcodeType.upcA => Barcode.upcA(),
    WotBarcodeType.upcE => Barcode.upcE(),
    WotBarcodeType.isbn => Barcode.isbn(),
    WotBarcodeType.itf14 => Barcode.itf14(),
    WotBarcodeType.codabar => Barcode.codabar(),
  };
}

/// 条形码，对应 wot `wd-barcode`。
///
/// 编码由纯 Dart 三方库 `barcode` 完成（与 `qr_flutter` 同类），渲染用自绘
/// [CustomPainter] 逐条绘制。参数对齐 wot：`value`（内容）、`type`（编码类型）、
/// `width`/`height`（尺寸）、`color`（条码色）、`backgroundColor`（背景色）、
/// `showValue`（是否在条码下方展示可读文本）。
class WotBarcode extends StatelessWidget {
  const WotBarcode({
    super.key,
    required this.value,
    this.type = WotBarcodeType.code128,
    this.width = 200,
    this.height = 60,
    this.color,
    this.backgroundColor,
    this.showValue = true,
    this.valueStyle,
  });

  /// 条形码内容（字符串）。
  final String value;

  /// 编码类型，默认 [WotBarcodeType.code128]。
  final WotBarcodeType type;

  /// 条码区宽度（逻辑像素），默认 200。
  final double width;

  /// 条码区高度（逻辑像素，不含可读文本），默认 60。
  final double height;

  /// 条码前景色，默认黑色。
  final Color? color;

  /// 背景色，默认白色。
  final Color? backgroundColor;

  /// 是否在条码下方显示可读文本（`value` 原文），默认 true。
  final bool showValue;

  /// 可读文本样式。
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final fg = color ?? Colors.black;
    final bg = backgroundColor ?? scheme.filledOppo;

    final barcode = _toBarcode(type);
    final ok = barcode.isValid(value);

    return Container(
      color: bg,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: width,
            height: height,
            child: CustomPaint(
              // 编码异常时绘制占位斜线提示，避免空白画面。
              painter: ok
                  ? _WotBarcodePainter(
                      elements: barcode.make(value, width: width, height: height),
                      color: fg,
                    )
                  : _InvalidBarcodePainter(color: fg),
              size: Size(width, height),
            ),
          ),
          if (showValue)
            Padding(
              padding: EdgeInsets.only(top: height > 30 ? 6 : 2),
              child: Text(
                value,
                style: valueStyle ?? TextStyle(fontSize: 11, color: fg, height: 1.1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

/// 正常条码绘制：把 `barcode` 库产出的黑色条单元逐条画出。
class _WotBarcodePainter extends CustomPainter {
  _WotBarcodePainter({required this.elements, required this.color});

  final Iterable<BarcodeElement> elements;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final e in elements) {
      if (e is BarcodeBar && e.black) {
        canvas.drawRect(
          Rect.fromLTWH(e.left, e.top, e.width, e.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_WotBarcodePainter old) =>
      old.color != color || old.elements != elements;
}

/// 编码失败时的占位：两条对角斜线示意不可用。
class _InvalidBarcodePainter extends CustomPainter {
  _InvalidBarcodePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_InvalidBarcodePainter old) => old.color != color;
}