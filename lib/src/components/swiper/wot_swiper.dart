import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 轮播图指示点位置。
enum WotSwiperIndicatorPosition { bottom, top, middleLeft, middleCenter, middleRight }

/// 轮播图，对应 wot `wd-swiper`。
///
/// 参数对齐 wot：`autoplay`、`interval`（自动播放间隔 ms）、`duration`（切换动画 ms）、
/// `loop`（是否循环）、`indicator`（是否显示指示点）、`indicatorPosition`、`sensitive`（滑动灵敏度）、
/// `onChange`。子项每页对应一张 [WotSwiperItem]。
class WotSwiper extends StatefulWidget {
  const WotSwiper({
    super.key,
    this.autoplay = false,
    this.interval = 3000,
    this.duration = 500,
    this.loop = true,
    this.indicator = true,
    this.indicatorPosition = WotSwiperIndicatorPosition.bottom,
    this.width,
    this.height,
    this.onChange,
    this.children = const [],
  });

  /// 是否自动播放，默认 false。
  final bool autoplay;

  /// 自动播放间隔（毫秒），默认 3000。
  final int interval;

  /// 切换动画时长（毫秒），默认 500。
  final int duration;

  /// 是否循环播放，默认 true。
  final bool loop;

  /// 是否显示指示点，默认 true。
  final bool indicator;

  /// 指示点位置：bottom/top/middleLeft/middleCenter/middleRight，默认 bottom。
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
  late PageController _controller;
  Timer? _timer;
  int _current = 0;

  bool get _canLoop => widget.loop && widget.children.length > 1;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1);
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(WotSwiper oldWidget) {
    super.didUpdateWidget(oldWidget);
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
      final next = (_canLoop
          ? (_current + 1) % widget.children.length
          : _current + 1);
      if (!_canLoop && next >= widget.children.length) return;
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
    setState(() => _current = index);
    widget.onChange?.call(index);
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
            itemCount: children.length,
            onPageChanged: _onPageChanged,
            physics: children.length > 1 ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) => children[i],
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
            width: i == _current ? 18 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i == _current ? scheme.primaryOf(6) : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );

    return Positioned(
      left: 0,
      right: 0,
      top: widget.indicatorPosition == WotSwiperIndicatorPosition.top
          ? 10
          : widget.indicatorPosition == WotSwiperIndicatorPosition.middleCenter
              ? null
              : null,
      bottom: widget.indicatorPosition == WotSwiperIndicatorPosition.bottom
          ? 10
          : widget.indicatorPosition == WotSwiperIndicatorPosition.middleCenter
              ? null
              : null,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: indicators,
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