import 'package:flutter/material.dart';

import 'wot_scheme.dart';
import 'wot_theme_data.dart';

/// 通过 [BuildContext] 访问 wot 主题。
extension WotTheme on BuildContext {
  /// 取当前 wot 主题方案（语义令牌）。
  WotScheme get wotScheme => wotTheme.scheme;

  /// 取当前 wot 主题数据。
  WotThemeData get wotTheme => WotTheme.of(this);

  /// 取当前 [WotThemeData]，未由 [WotThemeProvider] 包裹时回退浅色默认。
  static WotThemeData of(BuildContext context) {
    return context
            .getInheritedWidgetOfExactType<WotThemeProvider>()
            ?.theme ??
        WotThemeData.light;
  }
}

/// 主题 [InheritedWidget]，由 [WotConfigProvider] 注入。
class WotThemeProvider extends InheritedWidget {
  const WotThemeProvider({super.key, required this.theme, required super.child});

  final WotThemeData theme;

  @override
  bool updateShouldNotify(WotThemeProvider oldWidget) =>
      theme != oldWidget.theme;
}