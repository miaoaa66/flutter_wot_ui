import 'package:flutter/material.dart';

/// 单一明暗模式下的全部语义令牌，对应
/// `wot-ui/src/uni_modules/wot-ui/styles/theme/{light,dark}.scss`。
@immutable
class WotScheme {
  const WotScheme({
    required this.primary,
    required this.dangerMain,
    required this.dangerHover,
    required this.dangerClicked,
    required this.dangerDisabled,
    required this.dangerParticular,
    required this.dangerSurface,
    required this.successMain,
    required this.successHover,
    required this.successClicked,
    required this.successDisabled,
    required this.successParticular,
    required this.successSurface,
    required this.warningMain,
    required this.warningHover,
    required this.warningClicked,
    required this.warningDisabled,
    required this.warningParticular,
    required this.warningSurface,
    required this.textMain,
    required this.textSecondary,
    required this.textAuxiliary,
    required this.textDisabled,
    required this.textPlaceholder,
    required this.textWhite,
    required this.iconMain,
    required this.iconSecondary,
    required this.iconAuxiliary,
    required this.iconDisabled,
    required this.iconPlaceholder,
    required this.iconWhite,
    required this.borderExtraStrong,
    required this.borderStrong,
    required this.borderMain,
    required this.borderLight,
    required this.borderWhite,
    required this.borderZero,
    required this.filledExtraStrong,
    required this.filledStrong,
    required this.filledContent,
    required this.filledBottom,
    required this.filledOppo,
    required this.filledZero,
    required this.dividerMain,
    required this.dividerLight,
    required this.dividerStrong,
    required this.dividerWhite,
    required this.feedbackHover,
    required this.feedbackActive,
    required this.feedbackAccent,
    required this.opacTooltipToastCover,
    required this.opacMainCover,
    required this.opacLightCover,
    required this.pickerViewMaskStart,
    required this.pickerViewMaskEnd,
    required this.category,
  });

  /// 主色 10 级梯度（primary-1..10）。
  final List<Color> primary;

  final Color dangerMain;
  final Color dangerHover;
  final Color dangerClicked;
  final Color dangerDisabled;
  final Color dangerParticular;
  final Color dangerSurface;

  final Color successMain;
  final Color successHover;
  final Color successClicked;
  final Color successDisabled;
  final Color successParticular;
  final Color successSurface;

  final Color warningMain;
  final Color warningHover;
  final Color warningClicked;
  final Color warningDisabled;
  final Color warningParticular;
  final Color warningSurface;

  final Color textMain;
  final Color textSecondary;
  final Color textAuxiliary;
  final Color textDisabled;
  final Color textPlaceholder;
  final Color textWhite;

  final Color iconMain;
  final Color iconSecondary;
  final Color iconAuxiliary;
  final Color iconDisabled;
  final Color iconPlaceholder;
  final Color iconWhite;

  final Color borderExtraStrong;
  final Color borderStrong;
  final Color borderMain;
  final Color borderLight;
  final Color borderWhite;
  final Color borderZero;

  final Color filledExtraStrong;
  final Color filledStrong;
  final Color filledContent;
  final Color filledBottom;
  final Color filledOppo;
  final Color filledZero;

  final Color dividerMain;
  final Color dividerLight;
  final Color dividerStrong;
  final Color dividerWhite;

  final Color feedbackHover;
  final Color feedbackActive;
  final Color feedbackAccent;

  final Color opacTooltipToastCover;
  final Color opacMainCover;
  final Color opacLightCover;

  final Color pickerViewMaskStart;
  final Color pickerViewMaskEnd;

  final CategoryColors category;

  /// 便捷取主色之一（level 1-10）。
  Color primaryOf(int level) => primary[level - 1];

  /// 替换主色区梯度（用于主题变体切换），并可选替换 feedback-accent。
  WotScheme copyWithPrimary(List<Color> primary, {Color? accent}) {
    return WotScheme(
      primary: primary,
      dangerMain: dangerMain,
      dangerHover: dangerHover,
      dangerClicked: dangerClicked,
      dangerDisabled: dangerDisabled,
      dangerParticular: dangerParticular,
      dangerSurface: dangerSurface,
      successMain: successMain,
      successHover: successHover,
      successClicked: successClicked,
      successDisabled: successDisabled,
      successParticular: successParticular,
      successSurface: successSurface,
      warningMain: warningMain,
      warningHover: warningHover,
      warningClicked: warningClicked,
      warningDisabled: warningDisabled,
      warningParticular: warningParticular,
      warningSurface: warningSurface,
      textMain: textMain,
      textSecondary: textSecondary,
      textAuxiliary: textAuxiliary,
      textDisabled: textDisabled,
      textPlaceholder: textPlaceholder,
      textWhite: textWhite,
      iconMain: iconMain,
      iconSecondary: iconSecondary,
      iconAuxiliary: iconAuxiliary,
      iconDisabled: iconDisabled,
      iconPlaceholder: iconPlaceholder,
      iconWhite: iconWhite,
      borderExtraStrong: borderExtraStrong,
      borderStrong: borderStrong,
      borderMain: borderMain,
      borderLight: borderLight,
      borderWhite: borderWhite,
      borderZero: borderZero,
      filledExtraStrong: filledExtraStrong,
      filledStrong: filledStrong,
      filledContent: filledContent,
      filledBottom: filledBottom,
      filledOppo: filledOppo,
      filledZero: filledZero,
      dividerMain: dividerMain,
      dividerLight: dividerLight,
      dividerStrong: dividerStrong,
      dividerWhite: dividerWhite,
      feedbackHover: feedbackHover,
      feedbackActive: feedbackActive,
      feedbackAccent: accent ?? feedbackAccent,
      opacTooltipToastCover: opacTooltipToastCover,
      opacMainCover: opacMainCover,
      opacLightCover: opacLightCover,
      pickerViewMaskStart: pickerViewMaskStart,
      pickerViewMaskEnd: pickerViewMaskEnd,
      category: category,
    );
  }
}

/// 分类色：yellow/cyan/purple/grape/pink 的 background/border/content。
@immutable
class CategoryColors {
  const CategoryColors({
    required this.yellowBackground,
    required this.yellowBorder,
    required this.yellowContent,
    required this.cyanBackground,
    required this.cyanBorder,
    required this.cyanContent,
    required this.purpleBackground,
    required this.purpleBorder,
    required this.purpleContent,
    required this.grapeBackground,
    required this.grapeBorder,
    required this.grapeContent,
    required this.pinkBackground,
    required this.pinkBorder,
    required this.pinkContent,
  });

  final Color yellowBackground, yellowBorder, yellowContent;
  final Color cyanBackground, cyanBorder, cyanContent;
  final Color purpleBackground, purpleBorder, purpleContent;
  final Color grapeBackground, grapeBorder, grapeContent;
  final Color pinkBackground, pinkBorder, pinkContent;
}