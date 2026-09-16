import 'package:flutter/material.dart';

/// 过渡动画名称，对齐 wot `wd-transition` 的 name 枚举。
enum WotTransitionName { fade, slideUp, slideDown, slideLeft, slideRight, zoom, none }

/// 过渡动画组件，对应 wot `wd-transition`。
///
/// `in` 由外部控制：为 true 时显示并播放入场动画，为 false 时播放出场动画并隐藏。
class WotTransition extends StatefulWidget {
  const WotTransition({
    super.key,
    this.inShow = true,
    this.name = WotTransitionName.fade,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.ease,
    this.onEnter,
    this.onLeave,
    this.onAfterEnter,
    this.onAfterLeave,
    required this.child,
  });

  /// 是否展示（v-model:value）。
  final bool inShow;

  /// 动画名称。
  final WotTransitionName name;

  /// 动画时长。
  final Duration duration;

  /// 缓动曲线。
  final Curve curve;

  final VoidCallback? onEnter;
  final VoidCallback? onLeave;
  final VoidCallback? onAfterEnter;
  final VoidCallback? onAfterLeave;

  final Widget child;

  @override
  State<WotTransition> createState() => _WotTransitionState();
}

class _WotTransitionState extends State<WotTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double>? _opacity;
  Animation<Offset>? _offset;
  Animation<double>? _scale;

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    )..addStatusListener(_onStatus);
    _rebuildAnimations();
    if (widget.inShow) {
      _controller.value = 1.0;
      _visible = true;
    }
  }

  @override
  void didUpdateWidget(WotTransition old) {
    super.didUpdateWidget(old);
    if (old.duration != widget.duration) {
      _controller.duration = widget.duration;
      _controller.reverseDuration = widget.duration;
    }
    if (old.name != widget.name) _rebuildAnimations();
    if (old.inShow != widget.inShow) {
      if (widget.inShow) {
        _visible = true;
        setState(() {});
        _controller.forward(from: 0);
        // didUpdateWidget 处于 build 阶段，回调里 setState 会撞上
        // 「setState() called during build」，延后到本帧构建结束。
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.onEnter?.call();
        });
      } else {
        _controller.reverse();
      }
    }
  }

  void _rebuildAnimations() {
    final c = CurvedAnimation(parent: _controller, curve: widget.curve);
    final name = widget.name;
    _opacity = name == WotTransitionName.none
        ? null
        : Tween(begin: 0.0, end: 1.0).animate(c);
    _offset = switch (name) {
      WotTransitionName.slideUp => Tween<Offset>(
              begin: const Offset(0, 1), end: Offset.zero)
          .animate(c),
      WotTransitionName.slideDown => Tween<Offset>(
              begin: const Offset(0, -1), end: Offset.zero)
          .animate(c),
      WotTransitionName.slideLeft => Tween<Offset>(
              begin: const Offset(1, 0), end: Offset.zero)
          .animate(c),
      WotTransitionName.slideRight => Tween<Offset>(
              begin: const Offset(-1, 0), end: Offset.zero)
          .animate(c),
      _ => null,
    };
    _scale = name == WotTransitionName.zoom
        ? Tween(begin: 0.0, end: 1.0).animate(c)
        : null;
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onAfterEnter?.call();
    } else if (status == AnimationStatus.dismissed) {
      widget.onLeave?.call();
      widget.onAfterLeave?.call();
      setState(() => _visible = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _opacity ?? const AlwaysStoppedAnimation(1),
      child: SlideTransition(
        position: _offset ?? const AlwaysStoppedAnimation(Offset.zero),
        child: ScaleTransition(
          scale: _scale ?? const AlwaysStoppedAnimation(1),
          child: widget.child,
        ),
      ),
    );
  }
}