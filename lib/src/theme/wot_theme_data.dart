import 'package:flutter/material.dart';

import 'wot_colors.dart';
import 'wot_scheme.dart';

/// 构建 wot-ui 默认主题的语义方案。
///
/// 默认主题采用源码 `styles/theme/light.scss` 的令牌映射
/// 与 `styles/theme/dark.scss` 的暗色映射。
abstract class WotSchemeBuilder {
  /// 浅色（默认）语义方案。
  static WotScheme light() {
    return WotScheme(
      // 主色 primary = blue 1..10
      primary: [
        WotPalette.blue1,
        WotPalette.blue2,
        WotPalette.blue3,
        WotPalette.blue4,
        WotPalette.blue5,
        WotPalette.blue6,
        WotPalette.blue7,
        WotPalette.blue8,
        WotPalette.blue9,
        WotPalette.blue10,
      ],
      // danger = red
      dangerMain: WotPalette.red6,
      dangerHover: WotPalette.red5,
      dangerClicked: WotPalette.red7,
      dangerDisabled: WotPalette.red3,
      dangerParticular: WotPalette.red2,
      dangerSurface: WotPalette.red1,
      // success = green
      successMain: WotPalette.green6,
      successHover: WotPalette.green5,
      successClicked: WotPalette.green7,
      successDisabled: WotPalette.green3,
      successParticular: WotPalette.green2,
      successSurface: WotPalette.green1,
      // warning = orange
      warningMain: WotPalette.orange6,
      warningHover: WotPalette.orange5,
      warningClicked: WotPalette.orange7,
      warningDisabled: WotPalette.orange3,
      warningParticular: WotPalette.orange2,
      warningSurface: WotPalette.orange1,
      // 文字 = coolgrey
      textMain: WotPalette.coolgrey10,
      textSecondary: WotPalette.coolgrey8,
      textAuxiliary: WotPalette.coolgrey6,
      textDisabled: WotPalette.coolgrey4,
      textPlaceholder: WotPalette.coolgrey5,
      textWhite: WotPalette.baseWhite,
      // 图标 = coolgrey
      iconMain: WotPalette.coolgrey10,
      iconSecondary: WotPalette.coolgrey8,
      iconAuxiliary: WotPalette.coolgrey6,
      iconDisabled: WotPalette.coolgrey4,
      iconPlaceholder: WotPalette.coolgrey5,
      iconWhite: WotPalette.baseWhite,
      // 边框
      borderExtraStrong: WotPalette.coolgrey6,
      borderStrong: WotPalette.coolgrey4,
      borderMain: WotPalette.coolgrey3,
      borderLight: WotPalette.coolgrey2,
      borderWhite: WotPalette.baseWhite,
      borderZero: const Color(0x00000000),
      // 填充
      filledExtraStrong: WotPalette.coolgrey4,
      filledStrong: WotPalette.coolgrey3,
      filledContent: WotPalette.coolgrey2,
      filledBottom: WotPalette.coolgrey1,
      filledOppo: WotPalette.baseWhite,
      filledZero: const Color(0x00000000),
      // 分割线
      dividerMain: WotBlackAlpha.a8,
      dividerLight: WotBlackAlpha.a4,
      dividerStrong: WotBlackAlpha.a15,
      dividerWhite: WotPalette.baseWhite,
      // 反馈
      feedbackHover: WotBlackAlpha.a4,
      feedbackActive: WotBlackAlpha.a8,
      feedbackAccent: WotPalette.blueOpac,
      // 遮罩
      opacTooltipToastCover: WotBlackAlpha.a75,
      opacMainCover: WotBlackAlpha.a55,
      opacLightCover: WotBlackAlpha.a30,
      pickerViewMaskStart: wotHex('#FFFFFFD9'),
      pickerViewMaskEnd: wotHex('#FFFFFF33'),
      // 分类色（light）
      category: CategoryColors(
        yellowBackground: WotPalette.yellow1,
        yellowBorder: WotPalette.yellow3,
        yellowContent: WotPalette.yellow6,
        cyanBackground: WotPalette.cyan1,
        cyanBorder: WotPalette.cyan3,
        cyanContent: WotPalette.cyan6,
        purpleBackground: WotPalette.purple1,
        purpleBorder: WotPalette.purple3,
        purpleContent: WotPalette.purple6,
        grapeBackground: WotPalette.grape1,
        grapeBorder: WotPalette.grape3,
        grapeContent: WotPalette.grape6,
        pinkBackground: WotPalette.pink1,
        pinkBorder: WotPalette.pink3,
        pinkContent: WotPalette.pink6,
      ),
    );
  }

  /// 深色语义方案（映射自 dark.scss）。
  static WotScheme dark() {
    return WotScheme(
      primary: [
        WotPalette.blue10,
        WotPalette.blue9,
        WotPalette.blue8,
        WotPalette.blue7,
        WotPalette.blue6,
        WotPalette.blue5,
        WotPalette.blue4,
        WotPalette.blue3,
        WotPalette.blue2,
        WotPalette.blue1,
      ],
      dangerMain: WotPalette.red5,
      dangerHover: WotPalette.red6,
      dangerClicked: WotPalette.red4,
      dangerDisabled: WotPalette.red8,
      dangerParticular: WotPalette.red9,
      dangerSurface: WotPalette.red10,
      successMain: WotPalette.green5,
      successHover: WotPalette.green6,
      successClicked: WotPalette.green4,
      successDisabled: WotPalette.green8,
      successParticular: WotPalette.green9,
      successSurface: WotPalette.green10,
      warningMain: WotPalette.orange5,
      warningHover: WotPalette.orange6,
      warningClicked: WotPalette.orange4,
      warningDisabled: WotPalette.orange8,
      warningParticular: WotPalette.orange9,
      warningSurface: WotPalette.orange10,
      textMain: WotPalette.coolgrey1,
      textSecondary: WotPalette.coolgrey3,
      textAuxiliary: WotPalette.coolgrey5,
      textDisabled: WotPalette.coolgrey7,
      textPlaceholder: WotPalette.coolgrey6,
      textWhite: const Color(0xFFFFFFFF),
      iconMain: WotPalette.coolgrey1,
      iconSecondary: WotPalette.coolgrey3,
      iconAuxiliary: WotPalette.coolgrey5,
      iconDisabled: WotPalette.coolgrey7,
      iconPlaceholder: WotPalette.coolgrey6,
      iconWhite: const Color(0xFFFFFFFF),
      borderExtraStrong: WotPalette.coolgrey3,
      borderStrong: WotPalette.coolgrey5,
      borderMain: WotPalette.coolgrey7,
      borderLight: WotPalette.coolgrey9,
      borderWhite: const Color(0xFFFFFFFF),
      borderZero: const Color(0x00000000),
      filledExtraStrong: WotPalette.coolgrey7,
      filledStrong: WotPalette.coolgrey8,
      filledContent: WotPalette.coolgrey9,
      filledBottom: WotPalette.coolgrey10,
      filledOppo: WotPalette.baseBlack,
      filledZero: const Color(0x00000000),
      dividerMain: const Color(0x14FFFFFF),
      dividerLight: const Color(0x0AFFFFFF),
      dividerStrong: const Color(0x26FFFFFF),
      dividerWhite: const Color(0xFFFFFFFF),
      feedbackHover: const Color(0x0AFFFFFF),
      feedbackActive: const Color(0x14FFFFFF),
      feedbackAccent: WotPalette.blueOpac,
      opacTooltipToastCover: WotBlackAlpha.a75,
      opacMainCover: WotBlackAlpha.a55,
      opacLightCover: WotBlackAlpha.a30,
      pickerViewMaskStart: WotBlackAlpha.a85,
      pickerViewMaskEnd: WotBlackAlpha.a20,
      category: CategoryColors(
        yellowBackground: WotPalette.yellow10,
        yellowBorder: WotPalette.yellow8,
        yellowContent: WotPalette.yellow5,
        cyanBackground: WotPalette.cyan10,
        cyanBorder: WotPalette.cyan8,
        cyanContent: WotPalette.cyan5,
        purpleBackground: WotPalette.purple10,
        purpleBorder: WotPalette.purple8,
        purpleContent: WotPalette.purple5,
        grapeBackground: WotPalette.grape10,
        grapeBorder: WotPalette.grape8,
        grapeContent: WotPalette.grape5,
        pinkBackground: WotPalette.pink10,
        pinkBorder: WotPalette.pink8,
        pinkContent: WotPalette.pink5,
      ),
    );
  }
}

/// 明暗共通的设计尺度（圆角/尺寸等），后续组件按需扩充。
@immutable
class WotMetrics {
  const WotMetrics({
    this.fontSize = 14,
    this.radiusSmall = 4,
    this.radiusMedium = 8,
    this.radiusLarge = 16,
  });

  final double fontSize;
  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
}

/// 组件级默认配置，对应 wot `GlobalConfig.button/tag` 等。
class WotComponentDefaults {
  const WotComponentDefaults({this.button, this.tag});

  final WotButtonDefaults? button;
  final WotTagDefaults? tag;
}

class WotButtonDefaults {
  const WotButtonDefaults({this.type, this.size, this.variant, this.round});

  /// button type: primary/success/info/warning/danger
  final String? type;
  final String? size;
  final String? variant;
  final bool? round;

  /// 合并：以 [override] 中非空字段覆盖当前值（对齐 wot `mergeBucket`）。
  WotButtonDefaults merge(WotButtonDefaults? override) {
    if (override == null) return this;
    return WotButtonDefaults(
      type: override.type ?? type,
      size: override.size ?? size,
      variant: override.variant ?? variant,
      round: override.round ?? round,
    );
  }
}

class WotTagDefaults {
  const WotTagDefaults({this.size, this.variant, this.round});

  final String? size;
  final String? variant;
  final bool? round;

  /// 合并：以 [override] 中非空字段覆盖当前值（对齐 wot `mergeBucket`）。
  WotTagDefaults merge(WotTagDefaults? override) {
    if (override == null) return this;
    return WotTagDefaults(
      size: override.size ?? size,
      variant: override.variant ?? variant,
      round: override.round ?? round,
    );
  }
}

/// 完整主题数据。
@immutable
class WotThemeData {
  const WotThemeData({
    required this.scheme,
    this.metrics = const WotMetrics(),
    this.componentDefaults = const WotComponentDefaults(),
  });

  final WotScheme scheme;
  final WotMetrics metrics;
  final WotComponentDefaults componentDefaults;

  static final WotThemeData light =
      WotThemeData(scheme: WotSchemeBuilder.light());
  static final WotThemeData dark = WotThemeData(scheme: WotSchemeBuilder.dark());

  /// 复制并覆盖主题数据，可自定义 [scheme]（含主题色与各色值）、尺寸与组件默认配置。
  WotThemeData copyWith({
    WotScheme? scheme,
    WotMetrics? metrics,
    WotComponentDefaults? componentDefaults,
  }) {
    return WotThemeData(
      scheme: scheme ?? this.scheme,
      metrics: metrics ?? this.metrics,
      componentDefaults: componentDefaults ?? this.componentDefaults,
    );
  }
}