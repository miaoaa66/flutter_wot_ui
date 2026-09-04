import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../theme/wot_theme.dart';

/// 纠错级别，对齐 wot `errorLevel`。
enum WotQrCodeErrorLevel { l, m, q, h }

/// 二维码，对应 wot `wd-qr-code`。
///
/// 参数对齐 wot：`value`（内容）、`size`（边长）、`errorLevel`（纠错级别）、
/// `color`（前景色）、`backgroundColor`（背景色）、`border`（边框宽度，0 表示无边框）、
/// `borderColor`。基于三方纯 Dart 库 `qr_flutter` 生成。
class WotQrCode extends StatelessWidget {
  const WotQrCode({
    super.key,
    required this.value,
    this.size = 160,
    this.errorLevel = WotQrCodeErrorLevel.m,
    this.color,
    this.backgroundColor,
    this.border = 0,
    this.borderColor,
  });

  /// 二维码内容（文本/链接等）。
  final String value;

  /// 二维码边长（逻辑像素），默认 160。
  final double size;

  /// 纠错级别：l/m/q/h（L/M/Q/H），默认 m。级别越高容错越强但图案越密。
  final WotQrCodeErrorLevel errorLevel;

  /// 前景色（二维码色块），默认主题主色。
  final Color? color;

  /// 背景色，默认主题填充色。
  final Color? backgroundColor;

  /// 边框宽度，0 表示无边框，默认 0。
  final double border;

  /// 边框颜色，默认主题描边色。
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;

    final fg = color ?? scheme.primaryOf(6);
    final bg = backgroundColor ?? scheme.filledOppo;

    final qr = QrImageView(
      data: value,
      size: size,
      errorCorrectionLevel: _toQrLevel(errorLevel),
      backgroundColor: bg,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: fg,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: fg,
      ),
      gapless: true,
    );

    if (border <= 0) return qr;

    return Container(
      padding: EdgeInsets.all(border),
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.filledOppo,
        border: Border.all(color: borderColor ?? scheme.borderMain, width: border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: QrImageView(
        data: value,
        size: size - border * 2,
        errorCorrectionLevel: _toQrLevel(errorLevel),
        backgroundColor: bg,
        eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: fg),
        dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: fg),
      ),
    );
  }

  int _toQrLevel(WotQrCodeErrorLevel level) {
    return switch (level) {
      // qr_flutter 的整型常量与 wot 各 N 相同。
      WotQrCodeErrorLevel.l => QrErrorCorrectLevel.L,
      WotQrCodeErrorLevel.m => QrErrorCorrectLevel.M,
      WotQrCodeErrorLevel.q => QrErrorCorrectLevel.Q,
      WotQrCodeErrorLevel.h => QrErrorCorrectLevel.H,
    };
  }
}