import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';
import '../loading/wot_loading.dart';

/// 按钮类型（对齐 wot `wd-button/types.ts`）。
enum WotButtonType { primary, success, info, warning, danger }

/// 按钮尺寸。
enum WotButtonSize { mini, small, medium, large }

/// 按钮变体（样式）。
enum WotButtonVariant { base, plain, dashed, soft, subtle, text }

WotButtonType _typeFromString(String? s) => switch (s) {
      'success' => WotButtonType.success,
      'info' => WotButtonType.info,
      'warning' => WotButtonType.warning,
      'danger' => WotButtonType.danger,
      _ => WotButtonType.primary,
    };

WotButtonSize _sizeFromString(String? s) => switch (s) {
      'mini' => WotButtonSize.mini,
      'small' => WotButtonSize.small,
      'large' => WotButtonSize.large,
      _ => WotButtonSize.medium,
    };

WotButtonVariant _variantFromString(String? s) => switch (s) {
      'plain' => WotButtonVariant.plain,
      'dashed' => WotButtonVariant.dashed,
      'soft' => WotButtonVariant.soft,
      'subtle' => WotButtonVariant.subtle,
      'text' => WotButtonVariant.text,
      _ => WotButtonVariant.base,
    };

/// 按钮组件，对应 wot `wd-button`。参数与事件对齐源码。
class WotButton extends StatelessWidget {
  const WotButton({
    super.key,
    this.text,
    this.child,
    this.type,
    this.size,
    this.variant,
    this.round,
    this.disabled = false,
    this.hairline = false,
    this.block = false,
    this.loading = false,
    this.icon,
    this.color,
    this.textColor,
    this.loadingColor,
    this.classPrefix = 'wd-icon',
    this.onClick,
    this.onTap,
    this.border,
    this.padding,
    this.margin,
  });

  /// 按钮文本（无 [child] 时生效）。
  final String? text;

  /// 自定义内容，若提供则覆盖 [text]/[icon]。
  final Widget? child;

  /// 按钮类型（字符串亦兼容全局配置）。
  final WotButtonType? type;
  final WotButtonSize? size;
  final WotButtonVariant? variant;
  final bool? round;
  final bool disabled;
  final bool hairline;
  final bool block;
  final bool loading;
  final String? icon;
  final Color? color;
  final Color? textColor;
  final Color? loadingColor;
  final String classPrefix;
  final VoidCallback? onClick;
  final VoidCallback? onTap;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  EdgeInsetsGeometry paddingOf(WotButtonSize s) {
    if (padding != null) return padding!;
    return switch (s) {
      WotButtonSize.mini => const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      WotButtonSize.small => const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      WotButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      WotButtonSize.large => const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
    };
  }

  double fontSizeOf(WotButtonSize s) => switch (s) {
        WotButtonSize.mini => 12,
        WotButtonSize.small => 13,
        WotButtonSize.medium => 14,
        WotButtonSize.large => 16,
      };

  Color typeColorOf(WotScheme scheme, WotButtonType t) => switch (t) {
        WotButtonType.danger => scheme.dangerMain,
        WotButtonType.success => scheme.successMain,
        WotButtonType.warning => scheme.warningMain,
        WotButtonType.info => scheme.textSecondary,
        WotButtonType.primary => scheme.primaryOf(6),
      };

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final theme = context.wotTheme;
    final defaults = theme.componentDefaults.button;

    final effType = type ?? _typeFromString(defaults?.type);
    final effSize = size ?? _sizeFromString(defaults?.size);
    final effVariant = variant ?? _variantFromString(defaults?.variant);
    final effRound = round ?? defaults?.round ?? false;

    final baseColor = color ?? typeColorOf(scheme, effType);
    final radius = BorderRadius.circular(effRound ? 999 : 8);
    final isDisabled = disabled || loading;

    // 变体配色
    final Color background = switch (effVariant) {
      WotButtonVariant.base => isDisabled ? scheme.filledExtraStrong : baseColor,
      WotButtonVariant.soft =>
        isDisabled ? scheme.filledStrong : baseColor.withValues(alpha: 0.12),
      WotButtonVariant.subtle =>
        isDisabled ? scheme.filledStrong : baseColor.withValues(alpha: 0.06),
      WotButtonVariant.plain => Colors.transparent,
      WotButtonVariant.dashed => Colors.transparent,
      WotButtonVariant.text => Colors.transparent,
    };

    final Color foreground = switch (effVariant) {
      WotButtonVariant.base => isDisabled ? scheme.textMain : Colors.white,
      WotButtonVariant.soft || WotButtonVariant.subtle => baseColor,
      WotButtonVariant.plain ||
      WotButtonVariant.dashed ||
      WotButtonVariant.text =>
        isDisabled ? scheme.textDisabled : baseColor,
    };

    final bool showBorder = effVariant == WotButtonVariant.plain ||
        effVariant == WotButtonVariant.dashed;

    final Widget content;
    if (child != null) {
      content = child!;
    } else {
      final showIcon = loading ||
          (icon != null && icon!.isNotEmpty);
      final Widget? leading;
      if (showIcon) {
        leading = loading
            ? WotLoading(size: fontSizeOf(effSize) + 2, color: foreground, loadingColor: loadingColor, strokeWidth: 2)
            : WotIcon(name: icon, size: fontSizeOf(effSize) + 2, color: foreground);
      } else {
        leading = null;
      }
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[leading, const SizedBox(width: 6)],
          Flexible(
            child: Text(
              text ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor ?? foreground,
                fontSize: fontSizeOf(effSize),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    Widget button = Material(
      color: background,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isDisabled ? null : (onTap ?? onClick),
        child: Container(
          padding: paddingOf(effSize),
          decoration: showBorder
              ? BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color:
                        isDisabled && effVariant == WotButtonVariant.plain
                            ? scheme.borderMain
                            : baseColor,
                    width: hairline ? 0.5 : 1,
                  ),
                )
              : null,
          child: DefaultTextStyle.merge(
            child: content,
          ),
        ),
      ),
    );

    if (block) {
      button = SizedBox(width: double.infinity, child: button);
    }
    if (margin != null) {
      button = Padding(padding: margin!, child: button);
    }
    return button;
  }
}