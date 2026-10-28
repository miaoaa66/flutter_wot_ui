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

  /// 应用 `--wot-*` 主题变量覆盖（供 `WotConfigProvider.themeVars` 使用）。
  ///
  /// key 规则：`--wot-` + 语义令牌小写 kebab-case，例如：
  /// `--wot-text-main`、`--wot-danger-main`、`--wot-border-light`、
  /// `--wot-filled-strong`、`--wot-opac-main-cover`、`--wot-picker-view-mask-start`。
  /// 未识别的 key 静默忽略；主色梯度 [primary] 是 10 级 `List<Color>`，
  /// 不适用单色覆盖——一键换肤请用 [copyWithPrimary] 或 `copyWith(primary: …)`。
  WotScheme applyVars(Map<String, Color> vars) {
    if (vars.isEmpty) return this;
    Color? dangerMain,
        dangerHover,
        dangerClicked,
        dangerDisabled,
        dangerParticular,
        dangerSurface,
        successMain,
        successHover,
        successClicked,
        successDisabled,
        successParticular,
        successSurface,
        warningMain,
        warningHover,
        warningClicked,
        warningDisabled,
        warningParticular,
        warningSurface,
        textMain,
        textSecondary,
        textAuxiliary,
        textDisabled,
        textPlaceholder,
        textWhite,
        iconMain,
        iconSecondary,
        iconAuxiliary,
        iconDisabled,
        iconPlaceholder,
        iconWhite,
        borderExtraStrong,
        borderStrong,
        borderMain,
        borderLight,
        borderWhite,
        borderZero,
        filledExtraStrong,
        filledStrong,
        filledContent,
        filledBottom,
        filledOppo,
        filledZero,
        dividerMain,
        dividerLight,
        dividerStrong,
        dividerWhite,
        feedbackHover,
        feedbackActive,
        feedbackAccent,
        opacTooltipToastCover,
        opacMainCover,
        opacLightCover,
        pickerViewMaskStart,
        pickerViewMaskEnd;
    for (final e in vars.entries) {
      switch (e.key) {
        case '--wot-danger-main':
          dangerMain = e.value;
        case '--wot-danger-hover':
          dangerHover = e.value;
        case '--wot-danger-clicked':
          dangerClicked = e.value;
        case '--wot-danger-disabled':
          dangerDisabled = e.value;
        case '--wot-danger-particular':
          dangerParticular = e.value;
        case '--wot-danger-surface':
          dangerSurface = e.value;
        case '--wot-success-main':
          successMain = e.value;
        case '--wot-success-hover':
          successHover = e.value;
        case '--wot-success-clicked':
          successClicked = e.value;
        case '--wot-success-disabled':
          successDisabled = e.value;
        case '--wot-success-particular':
          successParticular = e.value;
        case '--wot-success-surface':
          successSurface = e.value;
        case '--wot-warning-main':
          warningMain = e.value;
        case '--wot-warning-hover':
          warningHover = e.value;
        case '--wot-warning-clicked':
          warningClicked = e.value;
        case '--wot-warning-disabled':
          warningDisabled = e.value;
        case '--wot-warning-particular':
          warningParticular = e.value;
        case '--wot-warning-surface':
          warningSurface = e.value;
        case '--wot-text-main':
          textMain = e.value;
        case '--wot-text-secondary':
          textSecondary = e.value;
        case '--wot-text-auxiliary':
          textAuxiliary = e.value;
        case '--wot-text-disabled':
          textDisabled = e.value;
        case '--wot-text-placeholder':
          textPlaceholder = e.value;
        case '--wot-text-white':
          textWhite = e.value;
        case '--wot-icon-main':
          iconMain = e.value;
        case '--wot-icon-secondary':
          iconSecondary = e.value;
        case '--wot-icon-auxiliary':
          iconAuxiliary = e.value;
        case '--wot-icon-disabled':
          iconDisabled = e.value;
        case '--wot-icon-placeholder':
          iconPlaceholder = e.value;
        case '--wot-icon-white':
          iconWhite = e.value;
        case '--wot-border-extra-strong':
          borderExtraStrong = e.value;
        case '--wot-border-strong':
          borderStrong = e.value;
        case '--wot-border-main':
          borderMain = e.value;
        case '--wot-border-light':
          borderLight = e.value;
        case '--wot-border-white':
          borderWhite = e.value;
        case '--wot-border-zero':
          borderZero = e.value;
        case '--wot-filled-extra-strong':
          filledExtraStrong = e.value;
        case '--wot-filled-strong':
          filledStrong = e.value;
        case '--wot-filled-content':
          filledContent = e.value;
        case '--wot-filled-bottom':
          filledBottom = e.value;
        case '--wot-filled-oppo':
          filledOppo = e.value;
        case '--wot-filled-zero':
          filledZero = e.value;
        case '--wot-divider-main':
          dividerMain = e.value;
        case '--wot-divider-light':
          dividerLight = e.value;
        case '--wot-divider-strong':
          dividerStrong = e.value;
        case '--wot-divider-white':
          dividerWhite = e.value;
        case '--wot-feedback-hover':
          feedbackHover = e.value;
        case '--wot-feedback-active':
          feedbackActive = e.value;
        case '--wot-feedback-accent':
          feedbackAccent = e.value;
        case '--wot-opac-tooltip-toast-cover':
          opacTooltipToastCover = e.value;
        case '--wot-opac-main-cover':
          opacMainCover = e.value;
        case '--wot-opac-light-cover':
          opacLightCover = e.value;
        case '--wot-picker-view-mask-start':
          pickerViewMaskStart = e.value;
        case '--wot-picker-view-mask-end':
          pickerViewMaskEnd = e.value;
      }
    }
    return copyWith(
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
      feedbackAccent: feedbackAccent,
      opacTooltipToastCover: opacTooltipToastCover,
      opacMainCover: opacMainCover,
      opacLightCover: opacLightCover,
      pickerViewMaskStart: pickerViewMaskStart,
      pickerViewMaskEnd: pickerViewMaskEnd,
    );
  }

  /// 仅替换主色区梯度（1-10），并可选替换 feedback-accent。
  ///
  /// 适合"主题色一键换肤"；如需精调其他色值请用 [copyWith]。
  WotScheme copyWithPrimary(List<Color> primary, {Color? accent}) {
    return copyWith(primary: primary, feedbackAccent: accent);
  }

  /// 复制并逐项替换语义色值，可用于主题色换肤或任意单色自定义。
  ///
  /// 仅覆盖传入的非空字段（保持 [WotScheme] 全字段 const/不可变语义），
  /// 未覆盖字段沿用当前值。全部色值均可在此指定，对齐
  /// `wot-ui/styles/theme/{light,dark}.scss` 的语义变量。
  WotScheme copyWith({
    List<Color>? primary,
    Color? dangerMain,
    Color? dangerHover,
    Color? dangerClicked,
    Color? dangerDisabled,
    Color? dangerParticular,
    Color? dangerSurface,
    Color? successMain,
    Color? successHover,
    Color? successClicked,
    Color? successDisabled,
    Color? successParticular,
    Color? successSurface,
    Color? warningMain,
    Color? warningHover,
    Color? warningClicked,
    Color? warningDisabled,
    Color? warningParticular,
    Color? warningSurface,
    Color? textMain,
    Color? textSecondary,
    Color? textAuxiliary,
    Color? textDisabled,
    Color? textPlaceholder,
    Color? textWhite,
    Color? iconMain,
    Color? iconSecondary,
    Color? iconAuxiliary,
    Color? iconDisabled,
    Color? iconPlaceholder,
    Color? iconWhite,
    Color? borderExtraStrong,
    Color? borderStrong,
    Color? borderMain,
    Color? borderLight,
    Color? borderWhite,
    Color? borderZero,
    Color? filledExtraStrong,
    Color? filledStrong,
    Color? filledContent,
    Color? filledBottom,
    Color? filledOppo,
    Color? filledZero,
    Color? dividerMain,
    Color? dividerLight,
    Color? dividerStrong,
    Color? dividerWhite,
    Color? feedbackHover,
    Color? feedbackActive,
    Color? feedbackAccent,
    Color? opacTooltipToastCover,
    Color? opacMainCover,
    Color? opacLightCover,
    Color? pickerViewMaskStart,
    Color? pickerViewMaskEnd,
    CategoryColors? category,
  }) {
    return WotScheme(
      primary: primary ?? this.primary,
      dangerMain: dangerMain ?? this.dangerMain,
      dangerHover: dangerHover ?? this.dangerHover,
      dangerClicked: dangerClicked ?? this.dangerClicked,
      dangerDisabled: dangerDisabled ?? this.dangerDisabled,
      dangerParticular: dangerParticular ?? this.dangerParticular,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      successMain: successMain ?? this.successMain,
      successHover: successHover ?? this.successHover,
      successClicked: successClicked ?? this.successClicked,
      successDisabled: successDisabled ?? this.successDisabled,
      successParticular: successParticular ?? this.successParticular,
      successSurface: successSurface ?? this.successSurface,
      warningMain: warningMain ?? this.warningMain,
      warningHover: warningHover ?? this.warningHover,
      warningClicked: warningClicked ?? this.warningClicked,
      warningDisabled: warningDisabled ?? this.warningDisabled,
      warningParticular: warningParticular ?? this.warningParticular,
      warningSurface: warningSurface ?? this.warningSurface,
      textMain: textMain ?? this.textMain,
      textSecondary: textSecondary ?? this.textSecondary,
      textAuxiliary: textAuxiliary ?? this.textAuxiliary,
      textDisabled: textDisabled ?? this.textDisabled,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      textWhite: textWhite ?? this.textWhite,
      iconMain: iconMain ?? this.iconMain,
      iconSecondary: iconSecondary ?? this.iconSecondary,
      iconAuxiliary: iconAuxiliary ?? this.iconAuxiliary,
      iconDisabled: iconDisabled ?? this.iconDisabled,
      iconPlaceholder: iconPlaceholder ?? this.iconPlaceholder,
      iconWhite: iconWhite ?? this.iconWhite,
      borderExtraStrong: borderExtraStrong ?? this.borderExtraStrong,
      borderStrong: borderStrong ?? this.borderStrong,
      borderMain: borderMain ?? this.borderMain,
      borderLight: borderLight ?? this.borderLight,
      borderWhite: borderWhite ?? this.borderWhite,
      borderZero: borderZero ?? this.borderZero,
      filledExtraStrong: filledExtraStrong ?? this.filledExtraStrong,
      filledStrong: filledStrong ?? this.filledStrong,
      filledContent: filledContent ?? this.filledContent,
      filledBottom: filledBottom ?? this.filledBottom,
      filledOppo: filledOppo ?? this.filledOppo,
      filledZero: filledZero ?? this.filledZero,
      dividerMain: dividerMain ?? this.dividerMain,
      dividerLight: dividerLight ?? this.dividerLight,
      dividerStrong: dividerStrong ?? this.dividerStrong,
      dividerWhite: dividerWhite ?? this.dividerWhite,
      feedbackHover: feedbackHover ?? this.feedbackHover,
      feedbackActive: feedbackActive ?? this.feedbackActive,
      feedbackAccent: feedbackAccent ?? this.feedbackAccent,
      opacTooltipToastCover: opacTooltipToastCover ?? this.opacTooltipToastCover,
      opacMainCover: opacMainCover ?? this.opacMainCover,
      opacLightCover: opacLightCover ?? this.opacLightCover,
      pickerViewMaskStart: pickerViewMaskStart ?? this.pickerViewMaskStart,
      pickerViewMaskEnd: pickerViewMaskEnd ?? this.pickerViewMaskEnd,
      category: category ?? this.category,
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