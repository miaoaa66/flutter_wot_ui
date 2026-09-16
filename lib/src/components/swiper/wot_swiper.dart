import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 轮播图指示点位置（2 行 x 3 列 = 6 个位置）。
enum WotSwiperIndicatorPosition {
  topLeft, topCenter, topRight,
  bottomLeft, bottomCenter, bottomRight,
}

/// 轮播图，对应 wot `wd-swiper`。
///
/// 参数对齐 wot：`autoplay`、`interval`（自动播放间隔 ms）、`duration`（切换动画 ms）、
/// `loop`（是否循环）、`indicator`（是否显示指示点）、`indicatorPosition`、`sensitive`（滑动灵敏度）、
/// `onChange`。子项每页对应一张 [WotSwiperItem]。
class WotSwiper extends StatefulWidget {
  const WotSwiper({
    super.key,
    this.autoplay = true,
    this.interval = 5000,
    this.duration = 300,
    this.loop = true,
    this.indicator = true,
    this.indicatorPosition = WotSwiperIndicatorPosition.bottomCenter,
    this.width,
    this.height,
    this.onChange,
    this.children = const [],
  });

  /// 是否自动播放，默认 true（对齐 wot）。
  final bool autoplay;

  /// 自动播放间隔（毫秒），默认 5000（对齐 wot）。
  final int interval;

  /// 切换动画时长（毫秒），默认 300（对齐 wot）。
  final int duration;

  /// 是否循环播放，默认 true。
  final bool loop;

  /// 是否显示指示点，默认 true。
  final bool indicator;

  /// 指示点位置（上/下 x 左/中/右），默认 bottomCenter。
  final WotSwiperIndicatorPosition indicatorPosition;

  /// 轮播图宽度。
  final double? width;

  /// 轮播图高度。
  final double? height;

  /// 页码变化回调，参数为当前页索引。
  final ValueChanged<int>? onChange;

  /// 子项列表（每项对应一页，可为 [WotSwiperItem]）。
  final List<Widget> children;

  @override
  State<WotSwiper> createState() => _WotSwiperState();
}

class _WotSwiperState extends State<WotSwiper> with SingleTickerProviderStateMixin {
  /// 循环模式的起始页。取足够大的数，使用户无论向哪一侧滑动都有充足余量，
  /// 从而实现视觉上的无限循环（大数取模法）。
  static const int _loopBase = 10000;

  late PageController _controller;
  Timer? _timer;

  /// PageView 的真实页索引（循环模式下会一直递增/递减）。
  int _raw = 0;

  bool get _canLoop => widget.loop && widget.children.length > 1;

  /// 子项数量；为空列表时至少按 1 计，避免取模除零。
  int get _count => widget.children.isEmpty ? 1 : widget.children.length;

  /// 对外暴露的逻辑页索引（0 .. count-1）。
  int get _realIndex => _canLoop ? _raw % _count : _raw;

  void _initController() {
    _controller = PageController(
      viewportFraction: 1,
      initialPage: _canLoop ? _loopBase : 0,
    );
    _raw = _canLoop ? _loopBase : 0;
  }

  @override
  void initState() {
    super.initState();
    _initController();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(WotSwiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 循环开关变化会改变页数语义（有限 ↔ 无限），必须重建控制器。
    if (oldWidget.loop != widget.loop) {
      _controller.dispose();
      _initController();
    }
    if (oldWidget.autoplay != widget.autoplay ||
        oldWidget.interval != widget.interval ||
        oldWidget.loop != widget.loop) {
      _restartAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (!widget.autoplay || widget.children.length < 2) return;
    _timer = Timer.periodic(Duration(milliseconds: widget.interval), (_) {
      if (!_controller.hasClients) return;
      // 循环模式下直接前进到下一页（索引无限增长），非循环模式到末尾即停。
      final next = _raw + 1;
      if (!_canLoop && next >= _count) return;
      animateTo(next);
    });
  }

  void _restartAutoPlay() {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _startAutoPlay();
  }

  void animateTo(int index) {
    _controller.animateToPage(
      index,
      duration: Duration(milliseconds: widget.duration),
      curve: Curves.ease,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _raw = index);
    widget.onChange?.call(_realIndex);
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.children.isNotEmpty ? widget.children : [_emptySlot(context)];

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            // 循环模式用无限列表 + 取模复用子项；非循环模式为有限列表。
            itemCount: _canLoop ? null : children.length,
            onPageChanged: _onPageChanged,
            physics: children.length > 1 ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) => children[_canLoop ? i % children.length : i],
          ),
          if (widget.indicator && children.length > 1)
            _buildIndicator(context),
        ],
      ),
    );
  }

  Widget _buildIndicator(BuildContext context) {
    final scheme = context.wotScheme;
    final indicators = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
          for (var i = 0; i < widget.children.length; i++)
          AnimatedContainer(
            duration: Duration(milliseconds: widget.duration),
            width: i == _realIndex ? 18 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i == _realIndex ? scheme.primaryOf(6) : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );

    final isTop = widget.indicatorPosition == WotSwiperIndicatorPosition.topLeft ||
        widget.indicatorPosition == WotSwiperIndicatorPosition.topCenter ||
        widget.indicatorPosition == WotSwiperIndicatorPosition.topRight;

    final alignment = switch (widget.indicatorPosition) {
      WotSwiperIndicatorPosition.topLeft => Alignment.topLeft,
      WotSwiperIndicatorPosition.topCenter => Alignment.topCenter,
      WotSwiperIndicatorPosition.topRight => Alignment.topRight,
      WotSwiperIndicatorPosition.bottomLeft => Alignment.bottomLeft,
      WotSwiperIndicatorPosition.bottomCenter => Alignment.bottomCenter,
      WotSwiperIndicatorPosition.bottomRight => Alignment.bottomRight,
    };

    return Positioned(
      left: 0,
      right: 0,
      top: isTop ? 10 : null,
      bottom: isTop ? null : 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: indicators,
          ),
        ),
      ),
    );
  }

  Widget _emptySlot(BuildContext context) {
    final scheme = context.wotScheme;
    return Container(
      color: scheme.filledStrong,
      alignment: Alignment.center,
      child: WotIcon(name: 'image', size: 24, color: scheme.iconDisabled),
    );
  }
}

/// 轮播项，对应 wot `wd-swiper-item`。
class WotSwiperItem extends StatelessWidget {
  const WotSwiperItem({
    super.key,
    this.child,
  });

  /// 轮播项子内容。
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: child);
  }
}
