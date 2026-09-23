import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 浮动面板吸附点：面板拖拽松手后可停靠的高度。
///
/// - [WotFloatingPanelAnchor.pixels]：固定像素高度（如把手上方留 100）。
/// - [WotFloatingPanelAnchor.fraction]：占可用高度的比例（如 0.4H）。
///
/// 例：`[pixels(100), fraction(0.4), fraction(0.7)]` 表示面板可停在
/// 「100px / 40% 高 / 70% 高」三个档位，这是原来的 min/max 比例近似表达不了的。
class WotFloatingPanelAnchor {
  const WotFloatingPanelAnchor.pixels(this.value) : isFraction = false;
  const WotFloatingPanelAnchor.fraction(this.value) : isFraction = true;

  /// 像素值（[isFraction] 为 false）或比例值（[isFraction] 为 true，0~1）。
  final double value;

  /// 是否为占可用高度的比例。
  final bool isFraction;
}

/// 底部浮动面板，对应 wot `wd-floating-panel`。
///
/// 通过面板顶部把手拖动改变展开高度；松手后回弹到最近的 [anchors] 吸附点。
/// 既可以自管理高度（默认），也可由父组件通过 [height] + [onHeightChange] 受控。
class WotFloatingPanel extends StatefulWidget {
  const WotFloatingPanel({
    super.key,
    this.anchors = const [
      WotFloatingPanelAnchor.fraction(0.1),
      WotFloatingPanelAnchor.fraction(0.5),
      WotFloatingPanelAnchor.fraction(0.95),
    ],
    this.initialAnchor,
    this.minHeight = 56,
    this.height,
    this.onHeightChange,
    this.header,
    required this.child,
  });

  /// 吸附点列表（建议升序）。拖拽松手后回弹到最近的吸附点。
  final List<WotFloatingPanelAnchor> anchors;

  /// 初始停靠的吸附点；为空时取 [anchors] 的中间项。
  final WotFloatingPanelAnchor? initialAnchor;

  /// 面板最小高度（逻辑像素）。最终高度与拖拽下限都钳制到不小于它，
  /// 防止把手 + 头部超过面板可容纳高度而溢出。
  final double minHeight;

  /// 受控高度（逻辑像素）。非空时面板高度以父组件为准，拖拽时仍通过
  /// [onHeightChange] 回传当前高度，父组件更新此值即可双向同步。
  final double? height;

  /// 高度变化回调。拖拽过程与吸附动画中均会触发（受控 / 非受控都触发）。
  final ValueChanged<double>? onHeightChange;

  /// 头部内容（位于拖动把手下方）。
  final Widget? header;

  /// 面板内容区域。
  final Widget child;

  @override
  State<WotFloatingPanel> createState() => _WotFloatingPanelState();
}

class _WotFloatingPanelState extends State<WotFloatingPanel>
    with SingleTickerProviderStateMixin {
  double _availH = 0;
  double _height = 0;
  late final AnimationController _anim;
  double _animFrom = 0;
  double _animTo = 0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _anim.addListener(_onAnimTick);
  }

  @override
  void didUpdateWidget(covariant WotFloatingPanel old) {
    super.didUpdateWidget(old);
    // 受控：父组件改了 height，直接采用（不回传，避免抖动）。
    if (widget.height != null && widget.height != old.height) {
      _setHeight(widget.height!, notify: false);
    }
  }

  @override
  void dispose() {
    _anim.removeListener(_onAnimTick);
    _anim.dispose();
    super.dispose();
  }

  void _onAnimTick() {
    _setHeight(_animFrom + (_animTo - _animFrom) * _anim.value, notify: true);
  }

  /// 把锚点解析为当前可用高度下的像素高度。
  double _resolveAnchor(WotFloatingPanelAnchor a) {
    final raw = a.isFraction ? a.value * _availH : a.value;
    return raw.clamp(widget.minHeight, _availH);
  }

  double _initialHeight() {
    final a = widget.initialAnchor ?? widget.anchors[widget.anchors.length ~/ 2];
    return _resolveAnchor(a);
  }

  void _setHeight(double h, {required bool notify}) {
    final clamped = h.clamp(widget.minHeight, _availH);
    if (clamped == _height) return;
    _height = clamped;
    if (notify) widget.onHeightChange?.call(_height);
    if (mounted) setState(() {});
  }

  void _onDragStart(DragStartDetails _) => _anim.stop();

  void _onDragUpdate(DragUpdateDetails d) {
    _anim.stop();
    _setHeight(_height - d.delta.dy, notify: true);
  }

  void _onDragEnd(DragEndDetails _) {
    // 找最近吸附点并回弹。
    var best = _resolveAnchor(widget.anchors.first);
    var bestDist = double.infinity;
    for (final a in widget.anchors) {
      final px = _resolveAnchor(a);
      final dist = (px - _height).abs();
      if (dist < bestDist) {
        bestDist = dist;
        best = px;
      }
    }
    _animFrom = _height;
    _animTo = best;
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final avail = constraints.maxHeight;
        final firstFrame = _availH == 0;
        _availH = avail;
        if (firstFrame) {
          // 首帧再确定初始高度（需要可用高度）。
          _height = widget.height ?? _initialHeight();
        } else if (widget.height != null) {
          _height = widget.height!.clamp(widget.minHeight, avail);
        }
        final h = _height.clamp(widget.minHeight, avail);
        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: h,
            child: Material(
              color: scheme.filledOppo,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // 拖动把手（整条都可拖）。
                  GestureDetector(
                    onVerticalDragStart: _onDragStart,
                    onVerticalDragUpdate: _onDragUpdate,
                    onVerticalDragEnd: _onDragEnd,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: scheme.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  if (widget.header != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      alignment: Alignment.center,
                      child: widget.header,
                    ),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
