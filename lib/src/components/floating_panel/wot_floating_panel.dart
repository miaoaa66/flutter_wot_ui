import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 底部浮动面板，对应 wot `wd-floating-panel`。
///
/// 通过面板顶部把手拖动改变展开高度（min ~ max）。面板实际高度受
/// [minHeight]（像素下限，保证能容纳把手与头部，避免 Flex 溢出）约束。
class WotFloatingPanel extends StatefulWidget {
  const WotFloatingPanel({
    super.key,
    this.anchor = 0.8,
    this.min = 0.1,
    this.max = 0.95,
    this.minHeight = 56,
    this.header,
    required this.child,
  });

  /// 初始锚点比例（面板高度占可用高度的比例），默认 0.8。
  final double anchor;

  /// 最小高度比例（面板最小时占可用高度的比例），默认 0.1。
  final double min;

  /// 最大高度比例（面板最大时占可用高度的比例），默认 0.95。
  final double max;

  /// 面板最小高度（逻辑像素）。拖拽下限与最终高度都会钳制到不小于它，
  /// 防止把手 + 头部超过面板可容纳高度而溢出。
  final double minHeight;

  /// 头部内容（位于拖动把手下方）。
  final Widget? header;

  /// 面板内容区域。
  final Widget child;

  @override
  State<WotFloatingPanel> createState() => _WotFloatingPanelState();
}

class _WotFloatingPanelState extends State<WotFloatingPanel> {
  double _frac = 0.8;

  @override
  void initState() {
    super.initState();
    _frac = widget.anchor.clamp(widget.min, widget.max);
  }

  void _delta(double dy, double height) {
    // 下限换算到底部拖拽的 frac：面板不低于 minHeight。
    final lo = height > 0 ? (widget.minHeight / height).clamp(0.0, 1.0) : 0.0;
    final next = _frac - dy / height;
    setState(() => _frac = next.clamp(lo, widget.max));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        // 最终高度取 max(比例高度, minHeight)，并保证不超过可用高度。
        final h = (height * _frac).clamp(widget.minHeight, height);
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
                  // 拖动把手。
                  GestureDetector(
                    onVerticalDragUpdate: (d) => _delta(d.delta.dy, height),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
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