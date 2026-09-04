import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import 'pages/index_page.dart';

void main() {
  runApp(const WotExampleApp());
}

/// 示例应用根：用 [WotConfigProvider] 下发 wot 主题，并演示 Light/Dark 切换。
class WotExampleApp extends StatefulWidget {
  const WotExampleApp({super.key});

  @override
  State<WotExampleApp> createState() => _WotExampleAppState();
}

class _WotExampleAppState extends State<WotExampleApp> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    final themed = _dark ? WotThemeData.dark : WotThemeData.light;

    return WotConfigProvider(
      // 演示组件级默认配置级联：Button 全局默认小号 + 主色
      button: const WotButtonDefaults(size: 'small', type: 'primary'),
      wotTheme: themed,
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themed.scheme.primaryOf(6),
          brightness: _dark ? Brightness.dark : Brightness.light,
        ),
      ),
      child: MaterialApp(
        title: 'Wot UI Flutter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: themed.scheme.filledBottom,
          appBarTheme: AppBarTheme(
            backgroundColor: themed.scheme.filledOppo,
            foregroundColor: themed.scheme.textMain,
            elevation: 0,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: themed.scheme.primaryOf(6)),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: themed.scheme.filledBottom,
          appBarTheme: AppBarTheme(
            backgroundColor: themed.scheme.filledOppo,
            foregroundColor: themed.scheme.textMain,
            elevation: 0,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: themed.scheme.primaryOf(6),
            brightness: Brightness.dark,
          ),
        ),
        themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
        home: WotIndexPage(
          dark: _dark,
          onToggleDark: () => setState(() => _dark = !_dark),
        ),
      ),
    );
  }
}