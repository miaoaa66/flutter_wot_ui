import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../../theme/wot_scheme.dart';

/// 单个标签页的角标配置（对应 wot `wd-badge`）。
class WotTabBadge {
  const WotTabBadge({
    this.value = 0,
    this.max = 99,
    this.isDot = false,
    this.color,
  });

  /// 角标数值，未超过 [max] 时原样显示。
  final num value;

  /// 数值上限，超过后显示为 `max+`，默认 99。
  final num max;

  /// 是否以小圆点形式显示，默认 false。
  final bool isDot;

  /// 角标背景色，默认取主题危险色。
  final Color? color;
}

/// 指示器宽度模式，对应 Flutter `TabBar` 的 `indicatorSize`。
enum WotTabsIndicatorSize {
  /// 指示器宽度等于整个标签项宽。
  tab,

  /// 指示器宽度贴合标题文字宽度。
  label,
}

/// 标签页切换时的导航信息（index/name/badge/disabled/current）。
class WotTabsNav {
  const WotTabsNav({
    required this.index,
    this.name,
    this.badge,
    this.disabled = false,
    this.current = false,
  });

  /// 标签索引。
  final int index;

  /// 标签 name 标识。
  final String? name;

  /// 该标签的角标配置。
  final WotTabBadge? badge;

  /// 该标签是否禁用。
  final bool disabled;

  /// 该标签是否为当前激活项。
  final bool current;
}

/// 标签页项，对应 wot `wd-tab`。须作为 [WotTabs] 的直接子级。
class WotTab extends StatelessWidget {
  const WotTab({
    super.key,
    this.title,
    this.label,
    this.disabled = false,
    this.name,
    this.width,
    this.badge,
    required this.child,
  });

  /// 标题文本。
  final String? title;

  /// 角标（如数字/文案）。
  final String? label;

  /// 禁用。
  final bool disabled;

  /// 唯一标识（可选）。
  final String? name;

  /// 单个 tab 宽度（可选）。设置后该项固定宽度；未设置的项按均分占位。
  final double? width;

  /// 角标配置（可选），对应 wot 的 badge-props，渲染徽标。
  final WotTabBadge? badge;

  /// 面板内容（未懒加载时，非激活项仅隐藏）。
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// 标签页组件，对应 wot `wd-tabs`。
///
/// 支持 `type`（line/card）、`grow`（均分）、颜色与指示器样式参数。
/// 通过 [modelValue]/[onChange] 受控（v-model，索引）。
///
/// 也可注入 Flutter 标准 [controller]（[TabController]）以接入
/// [DefaultTabController] 或与 [PageView]/[TabBarView] 联动：传了 [controller] 后
/// [modelValue] 失效，选中态以 [controller] 为准（[controller.length] 必须等于子项数）。
class WotTabs extends StatefulWidget {
  const WotTabs({
    super.key,
    this.modelValue = 0,
    this.onChange,
    this.onChangeTab,
    this.onClick,
    this.onDisabled,
    this.onPageChanged,
    this.type = 'line',
    this.color,
    this.inactiveColor,
    this.activeColor,
    this.grow = true,
    this.lineWidth,
    this.lineColor,
    this.indicatorWeight = 3,
    this.indicatorPadding = EdgeInsets.zero,
    this.indicatorSize = WotTabsIndicatorSize.tab,
    this.animated = false,
    this.swipeable = false,
    this.controller,
    required this.children,
  });

  /// 当前激活索引（v-model:value）。注入 [controller] 后本参数失效。
  final int modelValue;

  final ValueChanged<int>? onChange;

  /// 激活标签切换时触发的回调，参数为 [WotTabsNav]（含 index/name/badge/current）。
  final ValueChanged<WotTabsNav>? onChangeTab;

  /// 点击任意标签（含已激活项）时触发的回调，参数为 [WotTabsNav]。
  final ValueChanged<WotTabsNav>? onClick;

  /// 点击禁用标签时触发的回调，参数为 [WotTabsNav]。
  final ValueChanged<WotTabsNav>? onDisabled;

  /// 内容区因滑动切换页码时触发（来自 [swipeable] 的 PageView），参数为新索引。
  final ValueChanged<int>? onPageChanged;

  /// Tabs 样式：line（下划线）/ card（卡片式高亮）。
  final String type;

  /// 主色（指示器/激活色基底）。
  final Color? color;

  /// 未激活项文字色。
  final Color? inactiveColor;

  /// 激活项文字色。
  final Color? activeColor;

  /// 是否均分占满宽度。
  final bool grow;

  /// 指示器固定宽度（像素）。非空时忽略 [indicatorSize]，直接使用该值。
  final double? lineWidth;

  /// 指示器颜色（line 样式）。
  final Color? lineColor;

  /// 指示器厚度（像素），默认 3。
  final double indicatorWeight;

  /// 指示器内边距（四向），默认零。
  final EdgeInsetsGeometry indicatorPadding;

  /// 指示器宽度模式，默认 [WotTabsIndicatorSize.tab]。
  final WotTabsIndicatorSize indicatorSize;

  /// 是否内容切换动画。
  final bool animated;

  /// 是否开启内容区横向滑动切换，默认 false。
  final bool swipeable;

  /// Flutter 标准 [TabController]（可选）。注入后选中态以它为准，
  /// 可与 [DefaultTabController] 或外部 [TabController] 联动。
  final TabController? controller;

  final List<WotTab> children;

  @override
  State<WotTabs> createState() => _WotTabsState();
}

class _WotTabsState extends State<WotTabs> {
  late int _current;
  PageController? _pageController;
  TabController? _controller;

  /// 合法索引上界（空列表时为 0）。
  int get _maxIndex => widget.children.isNotEmpty ? widget.children.length - 1 : 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _current = (_controller?.index ?? widget.modelValue).clamp(0, _maxIndex);
    _controller?.addListener(_onControllerChanged);
    if (widget.swipeable) {
      _pageController = PageController(initialPage: _current);
    }
  }

  @override
  void didUpdateWidget(WotTabs old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      old.controller?.removeListener(_onControllerChanged);
      _controller = widget.controller;
      _controller?.addListener(_onControllerChanged);
      if (_controller != null) {
        _current = _controller!.index.clamp(0, _maxIndex);
      }
    }
    if (widget.controller == null && old.modelValue != widget.modelValue) {
      _current = widget.modelValue.clamp(0, _maxIndex);
      if (widget.swipeable && _pageController != null) {
        _pageController!.jumpToPage(_current);
      }
    }
    if (old.swipeable != widget.swipeable) {
      _pageController?.dispose();
      _pageController = widget.swipeable
          ? PageController(initialPage: _current)
          : null;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _pageController?.dispose();
    super.dispose();
  }

  /// 外部 / 内部 controller 变化同步到 UI（不在此回发 onChange，避免重复）。
  void _onControllerChanged() {
    final idx = (_controller?.index ?? _current).clamp(0, _maxIndex);
    if (idx == _current) return;
    _current = idx;
    if (widget.swipeable && _pageController != null && _pageController!.hasClients) {
      _pageController!.animateToPage(idx,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
    if (mounted) setState(() {});
  }

  WotTabsNav _navOf(int index, {bool current = false}) {
    final tab = widget.children[index];
    return WotTabsNav(
      index: index,
      name: tab.name,
      badge: tab.badge,
      disabled: tab.disabled,
      current: current,
    );
  }

  void _select(int index) {
    if (index == _current) {
      // 点击已激活项仍触发 click 事件。
      widget.onClick?.call(_navOf(index, current: true));
      return;
    }
    final tab = widget.children[index];
    if (tab.disabled) {
      widget.onDisabled?.call(_navOf(index));
      return;
    }
    // 受 controller 驱动时改走 controller.animateTo，由监听同步 UI。
    if (_controller != null) {
      _controller!.animateTo(index);
    } else {
      setState(() => _current = index.clamp(0, _maxIndex));
      if (widget.swipeable && _pageController != null && _pageController!.hasClients) {
        _pageController!.animateToPage(index,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    }
    final nav = _navOf(index, current: true);
    widget.onChange?.call(index);
    widget.onChangeTab?.call(nav);
    widget.onClick?.call(nav);
  }

  /// 滑动 Panel 触发切换（用于 swipeable 模式）。
  void _onPageChanged(int index) {
    if (index == _current) return;
    if (widget.children[index].disabled) return;
    if (_controller != null) {
      _controller!.animateTo(index);
    } else {
      setState(() => _current = index.clamp(0, _maxIndex));
    }
    final nav = _navOf(index, current: true);
    widget.onChange?.call(index);
    widget.onChangeTab?.call(nav);
    widget.onPageChanged?.call(index);
  }

  Color _textColor(
      WotScheme scheme, bool isCard, int i, Color activeColor, Color inactiveColor) {
    if (widget.children[i].disabled) return scheme.textDisabled;
    if (i != _current) return inactiveColor;
    // card 高亮底为 primary，选中文字用白色以保证可读。
    return isCard ? Colors.white : activeColor;
  }

  /// 测量第 i 项标题文字宽度（[indicatorSize]==label 时用于指示器宽度）。
  double _measureTitleWidth(int i, double maxW) {
    final text = widget.children[i].title ?? widget.children[i].name ?? 'Tab $i';
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: i == _current ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxW);
    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return const SizedBox.shrink();
    final scheme = context.wotScheme;
    final primary = widget.color ?? scheme.primaryOf(6);
    final activeColor = widget.activeColor ?? primary;
    final inactiveColor = widget.inactiveColor ?? scheme.textSecondary;
    final count = widget.children.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(scheme, activeColor, inactiveColor, primary, count),
        Expanded(child: _buildContent(count)),
      ],
    );
  }

  /// 内容区：swipeable 时渲染可横滑的 PageView，否则渲染当前激活项。
  Widget _buildContent(int count) {
    if (!widget.swipeable) {
      return Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < count; i++)
            if (i == _current)
              widget.children[i]
            else
              const Offstage(),
        ],
      );
    }
    return PageView.builder(
      controller: _pageController,
      itemCount: count,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, i) => widget.children[i],
    );
  }

  Widget _buildHeader(WotScheme scheme, Color activeColor, Color inactiveColor,
      Color primary, int count) {
    final isCard = widget.type == 'card';

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        // 单项宽度：优先取 width，否则均分。
        double itemW(int i) => widget.children[i].width ?? (maxW / count);
        // 第 i 项的左偏移（累计前 i 项宽度）。
        double offset(int i) {
          var s = 0.0;
          for (var k = 0; k < i; k++) {
            s += itemW(k);
          }
          return s;
        }

        final totalW = count > 0 ? offset(count - 1) + itemW(count - 1) : 0.0;
        final needScroll = totalW > maxW + 0.5;
        // 超宽时可横向滚动，否则禁止滚动避免误触。
        final physics = needScroll
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics();

        if (isCard) {
          final items = <Widget>[
            for (var i = 0; i < count; i++)
              SizedBox(
                width: itemW(i),
                child: _tabItem(
                    scheme, activeColor, inactiveColor, primary, i, isCard),
              ),
          ];
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: physics,
            child: Row(mainAxisSize: MainAxisSize.min, children: items),
          );
        }

        // line 样式：每个 tab 用 Positioned 精确定位 + 底部指示器。
        final lineColor = widget.lineColor ?? primary;
        final pad = widget.indicatorPadding.resolve(TextDirection.ltr);
        final indicatorWidth = widget.lineWidth ??
            (widget.indicatorSize == WotTabsIndicatorSize.label
                ? _measureTitleWidth(_current, itemW(_current))
                : itemW(_current));
        final indicatorW =
            (indicatorWidth - pad.horizontal).clamp(0.0, itemW(_current));
        final indicatorH =
            (widget.indicatorWeight - pad.vertical).clamp(0.0, widget.indicatorWeight);
        final currentLeft =
            offset(_current) + (itemW(_current) - indicatorW) / 2;

        final tabs = <Widget>[
          for (var i = 0; i < count; i++)
            Positioned(
              left: offset(i),
              top: 0,
              bottom: 0,
              width: itemW(i),
              child: _tabItem(
                  scheme, activeColor, inactiveColor, primary, i, isCard),
            ),
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: physics,
          child: SizedBox(
            height: 52,
            width: needScroll ? totalW : maxW,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ...tabs,
                AnimatedPositioned(
                  duration: widget.animated
                      ? const Duration(milliseconds: 200)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  left: currentLeft,
                  bottom: pad.bottom,
                  width: indicatorW,
                  height: indicatorH,
                  child: Container(
                    decoration: BoxDecoration(
                      color: lineColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 单个 tab 项（含点击、禁用、激活样式与标题/角标）。
  Widget _tabItem(WotScheme scheme, Color activeColor, Color inactiveColor,
      Color primary, int i, bool isCard) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 统一走 _select：内部判定禁用并发出 onDisabled/onClick 事件。
      onTap: () => _select(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: isCard
            ? BoxDecoration(
                color: i == _current ? primary : Colors.transparent,
                // 上面两个角圆角，下面两个角不圆角
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                border: Border.all(
                  color: i == _current ? primary : scheme.borderLight,
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _titleWithBadge(
                scheme, activeColor, inactiveColor, primary, i, isCard),
            if (widget.children[i].label != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.children[i].label!,
                style: TextStyle(fontSize: 10, color: scheme.textAuxiliary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 标题文本（若有角标配置则叠加徽标）。
  Widget _titleWithBadge(WotScheme scheme, Color activeColor, Color inactiveColor,
      Color primary, int i, bool isCard) {
    final title = Text(
      widget.children[i].title ?? widget.children[i].name ?? 'Tab $i',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: _textColor(scheme, isCard, i, activeColor, inactiveColor),
        fontSize: 14,
        fontWeight: i == _current ? FontWeight.w600 : FontWeight.w400,
      ),
    );
    final b = widget.children[i].badge;
    if (b == null) return title;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        title,
        Positioned(top: -8, right: -6, child: _badge(scheme, b)),
      ],
    );
  }

  /// 角标视图。
  Widget _badge(WotScheme scheme, WotTabBadge b) {
    final bg = b.color ?? scheme.dangerMain;
    if (b.isDot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      );
    }
    if (b.value <= 0) return const SizedBox.shrink();
    final text = b.value <= b.max ? '${b.value.toInt()}' : '${b.max.toInt()}+';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      constraints: const BoxConstraints(minHeight: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 10, height: 1)),
    );
  }
}
