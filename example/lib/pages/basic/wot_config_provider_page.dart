import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotConfigProvider 全局配置示例页：
/// 主题下发 / 组件级默认级联 / 语言切换。
class WotConfigProviderPage extends StatefulWidget {
  const WotConfigProviderPage({super.key});

  @override
  State<WotConfigProviderPage> createState() => _WotConfigProviderPageState();
}

class _WotConfigProviderPageState extends State<WotConfigProviderPage> {
  bool _useDark = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotConfigProvider 全局配置',
      children: [
        demoSection('组件级默认下发（button / tag，支持父子级联合并）'),
        demoBlock(
            '外层下发 button 默认（size: small + round: true），'
            '下排按钮未显式传参，直接吃到全局默认',
            WotConfigProvider(
              button: const WotButtonDefaults(size: 'small', round: true),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WotButton(text: '吃到默认：small + round'),
                  SizedBox(height: 8),
                  WotButton(text: '显式传参优先（large）', size: WotButtonSize.large),
                ],
              ),
            )),
        demoBlock(
            '级联合并：外层 small + round，内层只覆盖 type: danger——'
            '内层按钮 = small + round + danger（未提供的字段沿用外层）',
            WotConfigProvider(
              button: const WotButtonDefaults(size: 'small', round: true),
              child: WotConfigProvider(
                button: const WotButtonDefaults(type: 'danger'),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WotButton(text: '内层：级联合并结果'),
                    SizedBox(height: 8),
                    WotButton(text: '外层默认不受内层影响'),
                  ],
                ),
              ),
            )),
        demoBlock('tag 默认下发（size: large + round: true）',
            WotConfigProvider(
              tag: const WotTagDefaults(size: 'large', round: true),
              child: const Wrap(spacing: 8, children: [
                WotTag(text: '吃到默认'),
                WotTag(text: '显式 small', size: WotTagSize.small),
              ]),
            )),
        demoSection('主题下发（wotTheme，语义令牌整体切换）'),
        demoBlock(
            '内层 WotConfigProvider(wotTheme: WotThemeData.dark)：'
            '子树的 context.wotScheme 变为暗色令牌，按钮配色随令牌走',
            WotConfigProvider(
              wotTheme: WotThemeData.dark,
              child: Wrap(
                spacing: 8,
                children: [
                  WotButton(text: '暗色令牌按钮', onClick: () {}),
                  WotTag(text: '暗色令牌标签'),
                ],
              ),
            )),
        demoSection('明暗模式切换（themeMode，现场切换）'),
        demoBlock(
            'themeMode 在 light/dark 间切换，同一棵子树整体换肤（当前: ${_useDark ? 'dark' : 'light'}）',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FilledButton.tonal(
                onPressed: () => setState(() => _useDark = !_useDark),
                child: Text('切换为 ${_useDark ? 'light' : 'dark'}'),
              ),
              const SizedBox(height: 8),
              WotConfigProvider(
                themeMode: _useDark ? ThemeMode.dark : ThemeMode.light,
                child: const Wrap(spacing: 8, children: [
                  WotButton(text: '按钮跟随模式'),
                  WotTag(text: '标签跟随模式'),
                ]),
              ),
            ])),
        demoSection('语言切换（locale / localeMessages）'),
        demoBlock(
            '内层 locale: en_US：子树里走 tr() 的文案切到英文'
            '（观察下方 Loadmore 失败态文案），自定义语言包 localeMessages 可整体覆盖',
            WotConfigProvider(
              locale: 'en_US',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WotLoadmore(state: WotLoadmoreState.loadingFailed),
                  const SizedBox(height: 4),
                  WotLoadmore(state: WotLoadmoreState.noMore),
                ],
              ),
            )),
        demoSection('自定义语义令牌（themeVars）'),
        demoBlock(
            'themeVars 覆盖语义令牌：--wot-danger-main 换紫色、--wot-success-main 换青色——'
            'key 规则为 --wot- + 令牌小写 kebab-case（54 个语义色全量支持），'
            '在当前明暗模式解析结果之上叠加',
            WotConfigProvider(
              themeVars: const {
                '--wot-danger-main': Color(0xFF7C3AED),
                '--wot-success-main': Color(0xFF06B6D4),
              },
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                WotButton(
                    text: 'danger 已变紫',
                    type: WotButtonType.danger,
                    onClick: () {}),
                WotTag(text: 'success 已变青', type: WotTagType.success),
                WotTag(text: 'danger 已变紫', type: WotTagType.danger),
              ]),
            )),
      ],
    );
  }
}
