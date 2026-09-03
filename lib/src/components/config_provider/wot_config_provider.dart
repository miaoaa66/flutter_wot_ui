import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../../theme/wot_theme_data.dart';

/// 全局配置组件，对应 wot `wd-config-provider`。
///
/// 提供：wot 主题（语义令牌）、明暗模式、语言、组件级默认配置的全局下发。
/// 支持父级级联：外层提供 `button/tag` 组件默认配置，内层可部分覆盖，
/// 未提供的字段沿用外层（对齐 wot `mergeConfig`/`mergeBucket` 语义）。
/// 用法：在应用根部用本组件包裹，子组件通过 `context.wotScheme` 获取令牌。
class WotConfigProvider extends StatelessWidget {
  const WotConfigProvider({
    super.key,
    this.wotTheme,
    this.theme,
    this.themeMode,
    this.locale,
    this.localeMessages,
    this.themeVars,
    this.button,
    this.tag,
    required this.child,
  });

  /// wot 语义主题数据（默认浅色）。
  final WotThemeData? wotTheme;

  /// 可选：Material [ThemeData]，用于整体 MaterialApp 观感。
  final ThemeData? theme;

  /// 明暗模式（默认跟随系统）。
  final ThemeMode? themeMode;

  /// 可选 wot 语言（zh_CN / en_US）。
  final String? locale;

  /// 可选自定义语言包。
  final Map<String, String>? localeMessages;

  /// 自定义主题变量（覆盖语义令牌，如 `{'--wot-text-main': Color(...)}`）。
  final Map<String, Color>? themeVars;

  /// Button 组件全局默认，支持 size/variant/type/round，可与父级级联合并。
  final WotButtonDefaults? button;

  /// Tag 组件全局默认，支持 size/variant/round，可与父级级联合并。
  final WotTagDefaults? tag;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // 从父级继承已有配置，做级联合并。
    final parent = WotConfigProvider.of(context);
    final resolved = wotTheme ?? parent.wotTheme;
    final defaults = resolved.componentDefaults;
    final mergedButton =
        (defaults.button ?? const WotButtonDefaults()).merge(button);
    final mergedTag = (defaults.tag ?? const WotTagDefaults()).merge(tag);
    final mergedTheme = resolved.copyWith(
      componentDefaults:
          WotComponentDefaults(button: mergedButton, tag: mergedTag),
    );

    return WotThemeProvider(
      theme: mergedTheme,
      child: _WotConfigInherited(
        wotTheme: mergedTheme,
        theme: theme ?? parent.theme,
        themeMode: themeMode ?? parent.themeMode,
        locale: locale ?? parent.locale,
        localeMessages: localeMessages ?? parent.messages,
        themeVars: mergeVarMap(parent.themeVars, themeVars),
        child: child,
      ),
    );
  }

  /// 从当前上下文读取 wot 配置（主题/模式/语言/组件默认）。
  static WotConfigScope of(BuildContext context) {
    final inherited =
        context.getInheritedWidgetOfExactType<_WotConfigInherited>();
    if (inherited != null) return inherited.scope;
    return WotConfigScope(
      WotThemeData.light,
      ThemeMode.system,
      null,
      null,
      const {},
      null,
    );
  }
}

/// 合并 themeVars：父级 + 当前覆盖（值为 null 的键忽略）。
Map<String, Color> mergeVarMap(
    Map<String, Color> base, Map<String, Color>? override) {
  if (override == null || override.isEmpty) return base;
  return {...base, ...override};
}

/// 供 [WotConfigProvider] 下发的可读配置快照。
class WotConfigScope {
  const WotConfigScope(
      this.wotTheme, this.themeMode, this.locale, this.messages,
      [this.themeVars = const {}, this.theme]);

  final WotThemeData wotTheme;
  final ThemeMode themeMode;
  final String? locale;
  final Map<String, String>? messages;
  final Map<String, Color> themeVars;
  final ThemeData? theme;
}

class _WotConfigInherited extends InheritedWidget {
  const _WotConfigInherited({
    required this.wotTheme,
    required this.theme,
    required this.themeMode,
    required this.locale,
    required this.localeMessages,
    required this.themeVars,
    required super.child,
  });

  final WotThemeData wotTheme;
  final ThemeData? theme;
  final ThemeMode? themeMode;
  final String? locale;
  final Map<String, String>? localeMessages;
  final Map<String, Color> themeVars;

  WotConfigScope get scope => WotConfigScope(
        wotTheme,
        themeMode ?? ThemeMode.system,
        locale,
        localeMessages,
        themeVars,
      );

  @override
  bool updateShouldNotify(_WotConfigInherited oldWidget) {
    return wotTheme != oldWidget.wotTheme ||
        theme != oldWidget.theme ||
        themeMode != oldWidget.themeMode ||
        locale != oldWidget.locale ||
        localeMessages != oldWidget.localeMessages ||
        themeVars != oldWidget.themeVars;
  }
}