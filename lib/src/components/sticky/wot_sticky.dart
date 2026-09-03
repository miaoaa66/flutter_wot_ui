// Stack 内的占位尺寸元素（非相邻空白）会被误报，按需抑制。
// ignore_for_file: sized_box_for_whitespace
import 'package:flutter/material.dart';

/// 吸顶容器，对应 wot `wd-sticky`。
///
/// 包裹子内容，当其随父滚动到达 [offsetTop] 时吸附到该偏移位置。
/// 放在可滚动区域内部作为其直接内容；通过最近 [Scrollable] 自动测量定位。
class WotSticky extends StatefulWidget {
  const WotSticky({super.key, this.offsetTop = 0, this.zIndex, required this.child});

  /// 距视口顶部的吸附偏移。
  final double offsetTop;

  /// 层叠层级（可选）。
  final int? zIndex;

  final Widget child;

  @override
  State<WotSticky> createState() => _WotStickyState();
}

class _WotStickyState extends State<WotSticky> {
  final GlobalKey _childKey = GlobalKey();

  /// 本容器在滚动内容中线内（未滚动时）距视口顶部的距离。
  double? _slotTopInViewport;

  double _shift = 0;
  bool _stuck = false;
  double _height = 0;

  void _measureSlot(ScrollMetrics? m) {
    final renderer = context.findRenderObject() as RenderBox?;
    final scrollable = Scrollable.maybeOf(context);
    if (renderer == null || scrollable == null) return;
    final vpBox = scrollable.context.findRenderObject() as RenderBox?;
    if (vpBox == null) return;
    final top =
        renderer.localToGlobal(Offset.zero).dy - vpBox.localToGlobal(Offset.zero).dy;
    final pixels = m?.pixels ?? scrollable.position.pixels;
    _slotTopInViewport = top + pixels;
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;
    _measureSlot(n.metrics);
    final slot = _slotTopInViewport;
    if (slot == null) return false;
    final apparentTop = slot - n.metrics.pixels;
    final stuck = apparentTop <= widget.offsetTop;
    final shift = stuck ? (widget.offsetTop - apparentTop) : 0.0;
    if (_stuck != stuck || _shift != shift) {
      setState(() {
        _stuck = stuck;
        _shift = shift < 0 ? 0 : shift;
      });
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureSlot(null);
      final sz = _childKey.currentContext?.size;
      if (sz != null) _height = sz.height;
    });
  }

  @override
  void didUpdateWidget(WotSticky old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sz = _childKey.currentContext?.size;
      if (sz != null) _height = sz.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final childW = SizedBox(
            key: _childKey,
            width: constraints.maxWidth,
            child: widget.child,
          );
          return Container(
            width: constraints.maxWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (_stuck)
                  Container(width: double.infinity, height: _height),
                Transform.translate(
                  offset: Offset(0, -_shift),
                  child: childW,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}