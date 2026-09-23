import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../locale/wot_messages.dart';
import '../../theme/wot_theme.dart';

/// 纠错级别，对齐 wot `errorLevel`。
enum WotQrCodeErrorLevel { l, m, q, h }

/// 数据点形状（D 类 P1），映射到 qr_flutter 的 dataModuleShape。
enum WotQrCodeDotType { square, circle }

/// 二维码，对应 wot `wd-qr-code`。
///
/// 参数对齐 wot：`value`（内容）、`size`（边长）、`errorLevel`（纠错级别）、
/// `color`（前景色）、`backgroundColor`（背景色）、`border`（边框宽度，0 表示无边框）、
/// `borderColor`。基于三方纯 Dart 库 `qr_flutter` 生成。
class WotQrCode extends StatelessWidget {
  const WotQrCode({
    super.key,
    required this.value,
    this.size = 200,
    this.errorLevel = WotQrCodeErrorLevel.h,
    this.color,
    this.backgroundColor,
    this.border = 0,
    this.borderColor,
    this.dotType = WotQrCodeDotType.square,
    this.gapless = true,
    this.margin,
    this.logo,
    this.logoSize,
    this.onError,
  });

  /// 数据点形状（D 类 P1）：square（默认）/ circle，映射到 qr_flutter 的
  /// dataModuleShape；定位眼恒为 square。
  final WotQrCodeDotType dotType;

  /// 点阵之间是否无缝，默认 true（qr_flutter 原生参数透传）。
  final bool gapless;

  /// 二维码内边距（qr_flutter 原生参数透传），默认零边距。
  final EdgeInsets? margin;

  /// 中心 logo 图片（D 类 P1），传入后嵌在二维码中央（建议配合较高纠错级别）。
  final ImageProvider? logo;

  /// 中心 logo 尺寸，缺省为边长的 22%。
  final double? logoSize;

  /// 生成失败回调（D 类 P1）；失败时组件渲染内置错误占位。
  final ValueChanged<Object?>? onError;

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
    final moduleShape = dotType == WotQrCodeDotType.circle
        ? QrDataModuleShape.circle
        : QrDataModuleShape.square;
    final embeddedStyle = logo == null
        ? null
        : QrEmbeddedImageStyle(size: Size.square(logoSize ?? size * 0.22));

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
        dataModuleShape: moduleShape,
        color: fg,
      ),
      gapless: gapless,
      padding: margin ?? EdgeInsets.zero,
      embeddedImage: logo,
      embeddedImageStyle: embeddedStyle,
      errorStateBuilder: (ctx, err) {
        onError?.call(err);
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Text(
            tr(context, 'wot.qrCode.loadFailed'),
            style: TextStyle(fontSize: 12, color: scheme.textAuxiliary),
          ),
        );
      },
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
        dataModuleStyle: QrDataModuleStyle(dataModuleShape: moduleShape, color: fg),
        gapless: gapless,
        padding: margin ?? EdgeInsets.zero,
        embeddedImage: logo,
        embeddedImageStyle: embeddedStyle,
        errorStateBuilder: (ctx, err) {
          onError?.call(err);
          return Container(
            width: size - border * 2,
            height: size - border * 2,
            alignment: Alignment.center,
            child: Text(
              tr(context, 'wot.qrCode.loadFailed'),
              style: TextStyle(fontSize: 12, color: scheme.textAuxiliary),
            ),
          );
        },
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