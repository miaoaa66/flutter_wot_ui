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
  bool _showBack = false;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  /// 滚动高度超过阈值后显示「回到顶部」按钮。
  void _onScroll() {
    final should = _scroll.offset > 200;
    if (should != _showBack) setState(() => _showBack = should);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航组件')),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            // 预留足够缓存，避免 Web 上 Sliver（尤其 pinned header 与其后
            // SliverList 重叠区）滚动时反复进出视口导致"消失/若隐若现"重绘。
            cacheExtent: 2000,
            slivers: [
              _box(
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _NavbarDemo(),
                ),
              ),
              _box(_dividerLine(context)),
              _box(
                _TabsDemo(
                  index: _tab,
                  onChange: (i) => setState(() => _tab = i),
                ),
              ),
              _box(_dividerLine(context)),
              _box(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _section('WotIndexBar 索引栏 + WotIndexBarAnchor 锚点联动'),
                    const _IndexBarDemo(),
                  ],
                ),
              ),
              _box(_gapVertical(16)),
              _box(_section('WotSegmented 分段控制器')),
              _box(
                WotSegmented(
                  modelValue: _segment,
                  onChange: (v) => setState(() => _segment = v),
                  options: const [
                    WotSegmentedOption(label: '选项一', value: 1),
                    WotSegmentedOption(label: '选项二', value: 2),
                    WotSegmentedOption(label: '选项三', value: 3),
                    WotSegmentedOption(label: '选项四', value: 4),
                    WotSegmentedOption(label: '选项五', value: 5),
                  ],
                ),
              ),
              _box(_gapVertical(16)),
              _box(_section('WotSidebar 侧边导航')),
              _box(
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
                          WotSidebarItem(title: '标签名', name: 'd', badge: '399'),
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
              ),
              _box(_gapVertical(16)),
              _box(_section('WotPagination 分页')),
              _box(
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
              ),
              // 吸顶演示：用户按需用 Sliver 自行组合（如 SliverPersistentHeader）。
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 8),
                    child: WotCell(
                      title: '单元格 $i qqqqqqqqqq',
                      label: '单元格 $i',
                      value: '值11', 
                      desc: '值',
                      isLink: true,
                      // border: true,
                      // required: true,
                    ),
                  ),
                  childCount: 6,
                ),
              ),
              _box(_gapVertical(16)),
              _box(_section('WotTransition 过渡动画')),
              _box(const _TransitionDemo()),
              _box(const SizedBox(height: 500)),
            ],
          ),
          // 回到顶部按钮（滚动超过阈值后出现）。
          WotBacktop(
            show: _showBack,
            tip: '回顶部',
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
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: WotText(title, type: WotTextType.wotDefault, bold: true),
    );
  }
}

/// 把普通盒子组件包装成 CustomScrollView 的一个 sliver。
Widget _box(Widget child) => SliverToBoxAdapter(child: child);

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
        _gapVertical(8),
        // 左侧文字区 + 右侧图标区 + 事件。
        WotNavbar(
          title: '左右区演示',
          leftText: '取消',
          rightText: '分享',
          leftArrow: false,
          onClickLeft: () => _toast(context, '点击左侧'),
          onClickRight: () => _toast(context, '点击右侧'),
          background: const Color(0xFF36A3F7),
          color: Colors.white,
          bordered: true,
        ),
        _gapVertical(8),
        // 顶部胶囊（navbar-capsule）：标题位渲染圆角胶囊，左右半区可独立点击。
        WotNavbar(
          title: '胶囊导航',
          capsule: true,
          capsuleText: '咨询',
          onCapsuleLeft: () => _toast(context, '点击胶囊左侧'),
          onCapsuleRight: () => _toast(context, '点击胶囊右侧'),
          background: context.wotScheme.primaryOf(6),
          color: Colors.white,
          onClickLeft: () => _toast(context, '返回'),
        ),
      ],
    );
  }
}

Widget _navSectionTitle(String s) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WotText(s, type: WotTextType.wotDefault, bold: true),
    );

/// Tabs 演示（line + card + swipeable，含角标 / 自定义激活色 / 切换回调）。
class _TabsDemo extends StatelessWidget {
  const _TabsDemo({required this.index, required this.onChange});

  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _navSectionTitle('WotTabs 标签页（line / activeColor / badge / onChangeTab）'),
        // line 样式：自定义激活色 + 标签角标（WotTabBadge）+ 切换回调。
        SizedBox(
          height: 190,
          child: WotTabs(
            modelValue: index,
            activeColor: const Color(0xFF12B886),
            onChange: onChange,
            onChangeTab: (nav) => _toast(context, '切到 Tab ${nav.index + 1}'),
            onDisabled: (nav) => _toast(context, '该标签已禁用'),
            children: [
              for (var i = 0; i < 5; i++)
                WotTab(
                  title: '选项${i + 1}',
                  width: 80,
                  badge: i == 0
                      ? const WotTabBadge(value: 12)
                      : (i == 1
                          ? const WotTabBadge(value: 128)
                          : (i == 2
                              ? const WotTabBadge(isDot: true, color: Color(0xFF12B886))
                              : null)),
                  child: _panel(context, '内容${i + 1}'),
                ),
              WotTab(
                title: '禁用',
                width: 80,
                disabled: true,
                child: _panel(context, '禁用'),
              ),
            ],
          ),
        ),
        _gapVertical(8),
        _navSectionTitle('WotTabs card 样式'),
        SizedBox(
          height: 90,
          child: WotTabs(
            modelValue: index,
            onChange: onChange,
            type: 'card',
            children: [
              for (int i = 0; i < 5; i++)
                WotTab(title: '选项${i + 1}', width: 80, child: _panel(context, '内容${i + 1}')),
            ],
          ),
        ),
        _gapVertical(8),
        _navSectionTitle('WotTabs 可滑动（swipeable）'),
        SizedBox(
          height: 160,
          child: WotTabs(
            modelValue: index,
            onChange: onChange,
            swipeable: true,
            children: [
              for (var i = 0; i < 5; i++)
                WotTab(title: '页${i + 1}', child: _panel(context, '滑动内容 ${i + 1}')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _panel(BuildContext c, String s) => Container(
        alignment: Alignment.center,
        color: c.wotScheme.filledStrong,
        child: WotText(s, type: WotTextType.wotDefault),
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

/// WotIndexBar 索引栏 + WotIndexBarAnchor 锚点联动演示。
///
/// 使用 ScrollController + 每个锚点的 GlobalKey，点击/拖拽右侧索引条时
/// 计算锚点在滚动视口内的偏移并平滑滚动，同时激活索引作用域会高亮对应锚点。
class _IndexBarDemo extends StatefulWidget {
  const _IndexBarDemo();

  @override
  State<_IndexBarDemo> createState() => _IndexBarDemoState();
}

class _IndexBarDemoState extends State<_IndexBarDemo> {
  static const List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  static const Map<String, List<String>> _cities = {
    'A': ['安康', '安庆', '安阳'],
    'B': ['北京', '保定', '包头'],
    'C': ['长春', '长沙', '重庆'],
    'D': ['大连', '大庆', '德阳'],
    'E': ['鄂尔多斯', '恩施'],
    'F': ['福州', '抚顺', '阜阳'],
  };

  final ScrollController _controller = ScrollController();
  final Map<String, GlobalKey> _keys = {
    for (final l in _letters) l: GlobalKey(),
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 根据索引查找到对应锚点并平滑滚动到视口顶部。
  void _jump(String index) {
    final ctx = _keys[index]?.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox) return;

    // 锚点顶部到屏幕的全局 Y 坐标。
    final anchorTop = box.localToGlobal(Offset.zero).dy;
    // 滚动视口顶部到屏幕的全局 Y 坐标。
    final viewContext = _controller.position.context.storageContext;
    final viewBox = viewContext.findRenderObject() as RenderBox?;
    if (viewBox == null) return;
    final viewportTop = viewBox.localToGlobal(Offset.zero).dy;

    final target = _controller.offset + (anchorTop - viewportTop);
    _controller.animateTo(
      target.clamp(0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: WotIndexBar(
        indexList: _letters,
        activeColor: context.wotScheme.primaryOf(6),
        onSelect: _jump,
        child: ListView(
          controller: _controller,
          // 索引条需要读取每个锚点的 RenderObject 来计算滚动偏移，
          // 用足够大的缓存区让全部锚点常驻（避免滚出视口后被惰性销毁导致点击不跳）。
          cacheExtent: 2000,
          children: [
            for (final entry in _cities.entries)
              WotIndexBarAnchor(
                key: _keys[entry.key],
                index: entry.key,
                title: entry.key,
                child: Column(
                  children: [
                    for (final city in entry.value)
                      InkWell(
                        onTap: () => _toast(context, '选中 $city'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              WotIcon(name: 'location', size: 16),
                              const SizedBox(width: 8),
                              Text(city),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 800)));
}
