import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

/// 导航 + 交互组件演示页（Navbar/Tabs/Tabbar/Segmented/Sidebar/Pagination/Sticky/Backtop）。
class WotNavPage extends StatefulWidget {
  const WotNavPage({super.key});

  @override
  State<WotNavPage> createState() => _WotNavPageState();
}

class _WotNavPageState extends State<WotNavPage> {
  int _tab = 0;
  Object? _segment = 1;
  Object? _sidebar = 'a';
  int _page = 1;
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航组件')),
      body: Stack(
        children: [
          ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            children: [
              _NavbarDemo(),
              _dividerLine(context),
              _TabsDemo(
                index: _tab,
                onChange: (i) => setState(() => _tab = i),
              ),
              _dividerLine(context),
              _section('WotSegmented 分段控制器'),
              WotSegmented(
                modelValue: _segment,
                onChange: (v) => setState(() => _segment = v),
                options: const [
                  WotSegmentedOption(label: '选项一', value: 1),
                  WotSegmentedOption(label: '选项二', value: 2),
                  WotSegmentedOption(label: '选项三', value: 3),
                ],
              ),
              _gapVertical(16),
              _section('WotSidebar 侧边导航'),
              SizedBox(
                height: 220,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WotSidebar(
                      modelValue: _sidebar,
                      onChange: (v) => setState(() => _sidebar = v),
                      children: const [
                        WotSidebarItem(title: '标签名', name: 'a'),
                        WotSidebarItem(title: '标签名', name: 'b'),
                        WotSidebarItem(title: '标签名', name: 'c'),
                        WotSidebarItem(title: '标签名', name: 'd', badge: '3'),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        color: context.wotScheme.filledStrong,
                        alignment: Alignment.center,
                        child: WotText('当前：$_sidebar'),
                      ),
                    ),
                  ],
                ),
              ),
              _gapVertical(16),
              _section('WotPagination 分页'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  WotPagination(
                    modelValue: _page,
                    total: 86,
                    onChange: (p) => setState(() => _page = p),
                  ),
                  WotPagination(
                    modelValue: _page,
                    total: 38,
                    mode: WotPaginationMode.button,
                    onChange: (p) => setState(() => _page = p),
                  ),
                  WotPagination(
                    modelValue: _page,
                    total: 18,
                    mode: WotPaginationMode.simple,
                    onChange: (p) => setState(() => _page = p),
                  ),
                ],
              ),
              _gapVertical(16),
              _section('WotSticky 吸顶（滚动体验上方导航吸顶）'),
              _StickyDemo(),
              _gapVertical(16),
              _section('WotTransition 过渡动画'),
              const _TransitionDemo(),
            ],
          ),
          // 回到顶部按钮。
          WotBacktop(
            show: true,
            bottom: 80,
            right: 16,
            onClick: () {
              _scroll.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          ),
          // 悬浮按钮。
          const Positioned(
            right: 16,
            top: 16,
            child: WotFab(
              position: WotFabPosition.custom,
              customPosition: Offset(0, 0),
              show: false,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _TabbarDemo(
        value: _segment,
        onChange: (v) => setState(() => _segment = v),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WotText(title, type: WotTextType.secondary, strong: true),
    );
  }
}

Widget _dividerLine(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: WotDivider(text: '分割 Divider'),
  );
}

Widget _gapVertical(double h) => SizedBox(height: h);

/// 顶部导航栏演示。
class _NavbarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _navSectionTitle('WotNavbar 顶部导航栏'),
        WotNavbar(
          title: '导航栏标题',
          rightText: '分享',
          leftArrowColor: context.wotScheme.textMain,
          onClickRight: () => _toast(context, '点击右侧'),
          onClickLeft: () => _toast(context, '返回'),
        ),
        _gapVertical(8),
        WotNavbar(
          title: '自定义标题',
          titleWidget: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              WotIcon(name: 'search', size: 16),
              SizedBox(width: 6),
              Text('搜索'),
            ],
          ),
          background: context.wotScheme.primaryOf(6),
          color: Colors.white,
          bordered: true,
        ),
      ],
    );
  }
}

Widget _navSectionTitle(String s) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WotText(s, type: WotTextType.secondary, strong: true),
    );

/// Tabs 演示（line + card 两个实例）。
class _TabsDemo extends StatelessWidget {
  const _TabsDemo({required this.index, required this.onChange});

  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _navSectionTitle('WotTabs 标签页（line / card）'),
        SizedBox(
          height: 180,
          child: WotTabs(
            modelValue: index,
            onChange: onChange,
            children: [
              WotTab(title: '选项一', child: _panel(context, '内容一')),
              WotTab(title: '选项二', child: _panel(context, '内容二')),
              WotTab(title: '选项三', child: _panel(context, '内容三')),
              WotTab(title: '禁用', disabled: true, child: _panel(context, '禁用')),
            ],
          ),
        ),
        _gapVertical(8),
        SizedBox(
          height: 90,
          child: WotTabs(
            modelValue: index,
            onChange: onChange,
            type: 'card',
            children: [
              WotTab(title: '选项一', child: _panel(context, '内容一')),
              WotTab(title: '选项二', child: _panel(context, '内容二')),
              WotTab(title: '选项三', child: _panel(context, '内容三')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _panel(BuildContext c, String s) => Container(
        alignment: Alignment.center,
        color: c.wotScheme.filledStrong,
        child: WotText(s, type: WotTextType.secondary),
      );
}

/// 底部标签栏演示（挂在 bottomNavigationBar）。
class _TabbarDemo extends StatelessWidget {
  const _TabbarDemo({required this.value, required this.onChange});

  final Object? value;
  final ValueChanged<Object?> onChange;

  @override
  Widget build(BuildContext context) {
    return WotTabbar(
      modelValue: value,
      onChange: onChange,
      children: [
        WotTabbarItem(name: 1, icon: 'home', label: '首页'),
        WotTabbarItem(name: 2, icon: 'search', label: '搜索'),
        WotTabbarItem(name: 3, icon: 'user', label: '我的', badge: '99+'),
      ],
    );
  }
}

/// 吸顶演示。
class _StickyDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WotSticky(
          offsetTop: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: context.wotScheme.primaryOf(6),
            child: const Row(
              children: [
                WotIcon(name: 'arrow-down', size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text('吸顶内容，滚动观察', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        for (var i = 0; i < 6; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: WotCell(
              title: '单元格 $i',
              value: '值',
              isLink: i.isOdd,
            ),
          ),
      ],
    );
  }
}

/// 过渡动画演示。
class _TransitionDemo extends StatefulWidget {
  const _TransitionDemo();

  @override
  State<_TransitionDemo> createState() => _TransitionDemoState();
}

class _TransitionDemoState extends State<_TransitionDemo> {
  bool _show = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WotButton(
          text: _show ? '隐藏' : '显示',
          size: WotButtonSize.small,
          onClick: () => setState(() => _show = !_show),
        ),
        const SizedBox(height: 8),
        WotTransition(
          inShow: _show,
          name: WotTransitionName.slideUp,
          child: Container(
            width: 120,
            height: 60,
            color: context.wotScheme.primaryOf(6),
            alignment: Alignment.center,
            child: const Text('过渡动画', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 800)));
}
