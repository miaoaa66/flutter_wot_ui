import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 回到顶部，对应 wot `wd-backtop`。
///
/// 通过 [show] 控制显隐（v-model:value）；定位由外层 `Stack`/容器处理，
/// 或通过 [bottom]/[right] 交由本组件 `Positioned` 定位。
///
/// 传入 [scrollController] 后可自动监听滚动：滚动距离超过 [distance] 时自动显示，
/// 点击时默认平滑滚回顶部（[onClick] 存在则优先使用 [onClick]）。
class WotBacktop extends StatefulWidget {
  const WotBacktop({
    super.key,
    this.show = true,
    this.tip,
    this.color,
    this.bottom,
    this.right,
    this.onClick,
    this.scrollController,
    this.distance = 300,
    this.safeArea = false,
    this.child,
  });

  /// 是否显示（v-model:value）；当传入 [scrollController] 时还与滚动距离联动。
  final bool show;

  /// 提示文案（可选）。
  final String? tip;

  /// 图标颜色。
  final Color? color;

  /// 距底部距离（需外层为 Stack 时本组件以 `Positioned` 定位）。
  final double? bottom;

  /// 距右侧距离（需外层为 Stack 时本组件以 `Positioned` 定位）。
  final double? right;

  /// 点击回到顶部按钮时触发的回调（为空且提供 [scrollController] 时自动平滑滚动到顶部）。
  final VoidCallback? onClick;

  /// 滚动控制器：监听其滚动位置，滚动距离超过 [distance] 时自动展示按钮。
  final ScrollController? scrollController;

  /// 滚动距离超过该值（逻辑像素）时自动显示按钮，默认 300。
  final double distance;

  /// 定位在底部时是否计入底部安全区（刘海屏 padding），默认 false。
  final bool safeArea;

  /// 自定义按钮内容（优先于默认的图标+[tip]）。
  final Widget? child;

  @override
  State<WotBacktop> createState() => _WotBacktopState();
}

class _WotBacktopState extends State<WotBacktop> {
  ScrollController? _controller;
  bool _pastThreshold = true;

  bool get _listening => _controller != null;

  @override
  void initState() {
    super.initState();
    _controller = widget.scrollController;
    if (_listening) {
      _pastThreshold = _controller!.hasClients && _controller!.offset > widget.distance;
      _controller!.addListener(_onScroll);
    }
  }

  @override
  void didUpdateWidget(WotBacktop old) {
    super.didUpdateWidget(old);
    if (widget.scrollController != old.scrollController) {
      old.scrollController?.removeListener(_onScroll);
      _controller = widget.scrollController;
      if (_listening) {
        _pastThreshold = _controller!.hasClients && _controller!.offset > widget.distance;
        _controller!.addListener(_onScroll);
      } else {
        // 无滚动控制器时仅由 [show] 控制。
        _pastThreshold = true;
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final past = _controller!.hasClients && _controller!.offset > widget.distance;
    if (past != _pastThreshold) setState(() => _pastThreshold = past);
  }

  void _handleTap() {
    if (widget.onClick != null) {
      widget.onClick!();
      return;
    }
    if (_controller != null && _controller!.hasClients) {
      _controller!.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 显隐 = [show] 开关 × 滚动阈值（未监听滚动时仅由 [show] 决定）。
    final visible = widget.show && _pastThreshold;
    if (!visible) return const SizedBox.shrink();
    final scheme = context.wotScheme;
    final fg = widget.color ?? scheme.primaryOf(6);

    Widget inner;
    if (widget.child != null) {
      inner = Center(child: widget.child);
    } else {
      inner = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WotIcon(name: 'arrow-up', size: 16, color: fg),
            if (widget.tip != null)
              Text(
                widget.tip!,
                style: TextStyle(fontSize: 9, color: fg, height: 1.1),
              ),
          ],
        ),
      );
    }

    final btn = Material(
      color: scheme.filledContent,
      elevation: 3,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _handleTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: inner,
        ),
      ),
    );

    if (widget.bottom == null && widget.right == null) return btn;
    final bottomPadding = widget.safeArea ? MediaQuery.of(context).padding.bottom : 0.0;
    return Positioned(
      right: widget.right ?? 10,
      bottom: (widget.bottom ?? 24) + bottomPadding,
      child: btn,
    );
  }
}