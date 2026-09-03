import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 底部浮动面板，对应 wot `wd-floating-panel`。
///
/// 通过面板顶部把手拖动改变展开高度（min ~ max）。
class WotFloatingPanel extends StatefulWidget {
  const WotFloatingPanel({
    super.key,
    this.anchor = 0.8,
    this.min = 0.1,
    this.max = 0.95,
    this.header,
    required this.child,
  });

  final double anchor;
  final double min;
  final double max;
  final Widget? header;
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
    final next = _frac - dy / height;
    setState(() => _frac = next.clamp(widget.min, widget.max));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final h = height * _frac;
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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