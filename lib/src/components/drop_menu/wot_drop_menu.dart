import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 下拉菜单展开方向。
enum WotDropMenuDirection { down, up }

/// 下拉菜单，对应 wot `wd-drop-menu`。
///
/// 顶部菜单项，点击下弹出对应的 [WotDropMenu] 高度内容面板；支持遮罩关闭。
class WotDropMenu extends StatefulWidget {
  const WotDropMenu({
    super.key,
    this.menuBarHeight = 40,
    this.activeColor,
    this.duration = const Duration(milliseconds: 200),
    this.direction = WotDropMenuDirection.down,
    this.closeOnClickOverlay = true,
    required this.menus,
  });

  /// 顶部菜单栏高度（逻辑像素），默认 40。
  final double menuBarHeight;

  /// 激活菜单项的高亮颜色；为空时取主题主色。
  final Color? activeColor;

  /// 展开/收起动画时长，默认 200ms。
  final Duration duration;

  /// 菜单展开方向：[WotDropMenuDirection.down] 面板在菜单栏下方（默认）/
  /// [WotDropMenuDirection.up] 面板在菜单栏上方，默认 down。
  final WotDropMenuDirection direction;

  /// 点击遮罩是否关闭菜单；默认 true。
  final bool closeOnClickOverlay;

  /// 子项：[WotDropMenuItem]（含名称）+ 对应展开内容。
  final List<Widget> menus;

  @override
  State<WotDropMenu> createState() => _WotDropMenuState();
}

/// 下拉菜单选项（对齐 wot `wd-drop-menu-item` 的 `options` 项结构）。
class WotDropMenuOption {
  const WotDropMenuOption({required this.label, this.value, this.tip});

  /// 选项显示文本。
  final String label;

  /// 选项值。
  final dynamic value;

  /// 选项补充说明（可选，展示在文本右侧）。
  final String? tip;
}

/// 下拉菜单项：标题 + 展开内容。
///
/// 两种用法：
/// - 自定义内容：传入 [panel]（此时 [options] 为空）。
/// - 选项列表：传入 [options]/[modelValue]/[onChange]，展开区自动渲染选项列表，勾选当前选中值。
class WotDropMenuItem extends StatelessWidget {
  const WotDropMenuItem({
    super.key,
    this.title,
    this.panel = const SizedBox.shrink(),
    this.modelValue,
    this.options = const <WotDropMenuOption>[],
    this.onChange,
    this.closeOnClick = true,
    this.disabled = false,
  });

  /// 菜单项标题；不传时在 [options] 下取当前选中项 [label] 展示。
  final String? title;

  /// 展开时显示的面板内容（自定义内容场景）。
  final Widget panel;

  /// 当前选中值。
  final dynamic modelValue;

  /// 选项列表（对齐 wot `options`）。
  final List<WotDropMenuOption> options;

  /// 选中值变化回调，参数为选中项的 [WotDropMenuOption.value]（对齐 wot `change`）。
  final ValueChanged<dynamic>? onChange;

  /// 选中选项后是否自动收起菜单；默认 true。
  final bool closeOnClick;

  /// 是否禁用该菜单项，禁用后不可点击；默认 false。
  final bool disabled;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _WotDropMenuState extends State<WotDropMenu> {
  int? _open;

  /// 菜单栏锚点：浮层（蒙层上方的菜单栏镜像 + 面板）经 LayerLink 跟随菜单栏，
  /// 页面滚动 / 窗口变化时由合成器实时重算变换，不会出现蒙层错位。
  final LayerLink _barLink = LayerLink();

  /// 菜单栏 key：浮层镜像栏读取其实时宽度以等宽覆盖。
  final GlobalKey _barKey = GlobalKey();

  /// 菜单栏宽度（浮层镜像栏等宽对齐用）。
  double _barWidth = 0;

  /// 全屏蒙层（Overlay 承载，位于页面之上、浮层之下）。
  OverlayEntry? _barrierEntry;

  /// 浮层：菜单栏镜像 + 展开面板（Overlay 承载，始终位于蒙层之上）。
  OverlayEntry? _floatEntry;

  /// 浮层刚挂载时先以收起高度构建一帧，保证面板展开动画从 0 起播。
  bool _floatSettling = false;

  /// 收起动画播完后的摘除定时器。
  Timer? _removeTimer;

  bool get _isOpen => _open != null;

  void _toggle(int index) {
    final m = index < widget.menus.length ? widget.menus[index] : null;
    if (m is WotDropMenuItem && m.disabled) return;
    setState(() => _open = _open == index ? null : index);
    _syncOverlay();
  }

  void close() {
    if (!_isOpen) return;
    setState(() => _open = null);
    _syncOverlay();
  }

  @override
  void didUpdateWidget(covariant WotDropMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isOpen) return;
    // 展开期间数据/配置变化：同步浮层内容，并按 closeOnClickOverlay 挂/摘蒙层。
    if (widget.closeOnClickOverlay && _barrierEntry == null) {
      _barrierEntry = OverlayEntry(builder: _buildBarrier);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_isOpen || _barrierEntry == null) return;
        Overlay.maybeOf(context)?.insert(_barrierEntry!, below: _floatEntry);
      });
    } else if (!widget.closeOnClickOverlay && _barrierEntry != null) {
      _barrierEntry!.remove();
      _barrierEntry = null;
    }
    _floatEntry?.markNeedsBuild();
  }

  @override
  void dispose() {
    _removeTimer?.cancel();
    _barrierEntry?.remove();
    _barrierEntry = null;
    _floatEntry?.remove();
    _floatEntry = null;
    super.dispose();
  }

  /// 按展开状态同步浮层挂载：展开时挂蒙层 + 浮层；收起时等收起动画播完再摘除。
  void _syncOverlay() {
    _removeTimer?.cancel();
    _removeTimer = null;
    if (_isOpen) {
      _floatEntry?.markNeedsBuild();
      if (_floatEntry != null) return;
      _barrierEntry =
          widget.closeOnClickOverlay ? OverlayEntry(builder: _buildBarrier) : null;
      _floatEntry = OverlayEntry(builder: _buildFloating);
      _floatSettling = true;
      // 延后到本帧构建结束，避免 build 阶段操作 Overlay。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_isOpen || _floatEntry == null) return;
        final overlay = Overlay.maybeOf(context);
        if (overlay == null) return;
        if (_barrierEntry != null) overlay.insert(_barrierEntry!);
        overlay.insert(_floatEntry!);
      });
    } else if (_floatEntry != null) {
      _floatEntry?.markNeedsBuild(); // 播放面板收起动画
      _removeTimer = Timer(widget.duration, _detachOverlay);
    }
  }

  void _detachOverlay() {
    _removeTimer = null;
    _barrierEntry?.remove();
    _barrierEntry = null;
    _floatEntry?.remove();
    _floatEntry = null;
  }

  /// 全屏蒙层：点击关闭菜单；菜单栏镜像与面板浮于其上。
  Widget _buildBarrier(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: close,
        child: ColoredBox(color: context.wotScheme.opacMainCover),
      ),
    );
  }

  /// 浮层：菜单栏镜像 + 展开面板，经 LayerLink 锚定到真实菜单栏（滚动实时跟随），
  /// 镜像栏与真实菜单栏等宽等位覆盖，保证菜单栏始终亮于蒙层且可点切换。
  Widget _buildFloating(BuildContext context) {
    final up = widget.direction == WotDropMenuDirection.up;
    if (_floatSettling) {
      // 首帧以收起高度构建，下一帧展开，保证展开动画从 0 起播。
      _floatSettling = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isOpen) _floatEntry?.markNeedsBuild();
      });
    }
    return Material(
      type: MaterialType.transparency,
      // Overlay 的 theater 对非定位 entry 施加 tight 全屏约束，会一路传给
      // follower 并把 follower.size 拉成全屏（followerAnchor 沿其 size 计算，
      // up/down 锚定全错）。UnconstrainedBox 解除约束，使 follower 以内容
      // 尺寸布局：镜像栏宽度等于 _barWidth，anchor 沿内容尺寸计算。
      child: UnconstrainedBox(
        alignment: Alignment.topLeft,
        clipBehavior: Clip.none,
        child: CompositedTransformFollower(
          link: _barLink,
          showWhenUnlinked: false,
          // up：镜像列底缘（镜像栏底）对齐真实栏底缘；down：顶缘对齐顶缘。
          targetAnchor: up ? Alignment.bottomLeft : Alignment.topLeft,
          followerAnchor: up ? Alignment.bottomLeft : Alignment.topLeft,
          child: SizedBox(
            width: _barWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (up) _buildAnimatedPanel(context),
                _buildMenuBar(context),
                if (!up) _buildAnimatedPanel(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 展开面板（AnimatedSize 驱动展开/收起动画；无展开时为 0 高度占位）。
  Widget _buildAnimatedPanel(BuildContext context) {
    return AnimatedSize(
      duration: widget.duration,
      curve: Curves.ease,
      child: (_isOpen && _open! < widget.menus.length)
          ? _buildPanel(context, widget.menus[_open!])
          : const SizedBox.shrink(),
    );
  }

  /// 计算单个菜单项的标题（自定义 title 优先，否则取 options 选中项 label）。
  String _titleOf(WotDropMenuItem m) {
    if (m.title != null) return m.title!;
    for (final o in m.options) {
      if (o.value == m.modelValue) return o.label;
    }
    return '';
  }

  /// 是否展示选项列表（非自定义内容）。
  bool _isOptions(WotDropMenuItem m) => m.options.isNotEmpty;

  /// 菜单栏：inline 真身与浮层镜像共用同一构建。
  Widget _buildMenuBar(BuildContext context) {
    final scheme = context.wotScheme;
    final active = widget.activeColor ?? scheme.primaryOf(6);
    final menus = widget.menus;

    final titles = [
      for (final m in menus) if (m is WotDropMenuItem) _titleOf(m),
    ];

    return Container(
      height: widget.menuBarHeight,
      decoration: BoxDecoration(
        color: scheme.filledOppo,
        border: Border(bottom: BorderSide(color: scheme.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < menus.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => _toggle(i),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        i < titles.length ? titles[i] : '',
                        style: TextStyle(
                          fontSize: 14,
                          color: _open == i ? active : scheme.textMain,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _open == i ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        size: 16,
                        color: _open == i ? active : scheme.iconAuxiliary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 菜单栏宽度实时同步给浮层镜像栏（窗口尺寸变化时跟随）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final w = _barKey.currentContext?.size?.width;
      if (w != null && w != _barWidth) {
        _barWidth = w;
        _floatEntry?.markNeedsBuild();
      }
    });

    // inline 只保留菜单栏真身；展开面板与菜单栏镜像挂 Overlay 浮于蒙层之上。
    return CompositedTransformTarget(
      key: _barKey,
      link: _barLink,
      child: _buildMenuBar(context),
    );
  }

  Widget _buildPanel(BuildContext context, Widget menu) {
    final scheme = context.wotScheme;
    final active = widget.activeColor ?? scheme.primaryOf(6);
    Widget panel;
    if (menu is WotDropMenuItem && _isOptions(menu)) {
      panel = _buildOptions(context, menu, active);
    } else if (menu is WotDropMenuItem) {
      panel = menu.panel;
    } else {
      panel = const SizedBox.shrink();
    }
    return Material(
      color: scheme.filledOppo,
      child: panel,
    );
  }

  /// 渲染选项列表：点击选中项触发 [WotDropMenuItem.onChange]，并按 [closeOnClick] 决定是否收起。
  Widget _buildOptions(
      BuildContext context, WotDropMenuItem menu, Color active) {
    final scheme = context.wotScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < menu.options.length; i++) ...[
          InkWell(
            onTap: () {
              final value = menu.options[i].value;
              menu.onChange?.call(value);
              if (menu.closeOnClick) close();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  top: i == 0
                      ? BorderSide(color: scheme.borderLight, width: 0.5)
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      menu.options[i].label,
                      style: TextStyle(
                        fontSize: 14,
                        color: menu.options[i].value == menu.modelValue
                            ? active
                            : scheme.textMain,
                      ),
                    ),
                  ),
                  if (menu.options[i].tip != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      menu.options[i].tip!,
                      style: TextStyle(
                          fontSize: 13, color: scheme.textAuxiliary),
                    ),
                  ],
                  if (menu.options[i].value == menu.modelValue)
                    Icon(Icons.check, size: 16, color: active),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
