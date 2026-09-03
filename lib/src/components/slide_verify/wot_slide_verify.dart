import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 滑动验证，对应 wot `wd-slide-verify`。
///
/// 拖动滑块到达右侧终点判定通过。受控之外的交互回调 [onChange]。
class WotSlideVerify extends StatefulWidget {
  const WotSlideVerify({
    super.key,
    this.modelValue = false,
    this.onChange,
    this.text = '向右滑动完成验证',
    this.successText = '验证通过',
    this.errorText = '验证失败',
    this.disabled = false,
    this.color,
    this.height = 44,
  });

  final bool modelValue;
  final ValueChanged<bool>? onChange;
  final String text;
  final String successText;
  final String errorText;
  final bool disabled;
  final Color? color;
  final double height;

  @override
  State<WotSlideVerify> createState() => _WotSlideVerifyState();
}

class _WotSlideVerifyState extends State<WotSlideVerify> {
  double _offset = 0;
  bool _success = false;
  late double _width = 0;

  @override
  void didUpdateWidget(WotSlideVerify old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) _success = widget.modelValue;
  }

  void _update(double dx) {
    if (widget.disabled || _success) return;
    setState(() => _offset = dx);
  }

  void _end() {
    if (_width <= 0 || _success || widget.disabled) return;
    final threshold = _width - 44;
    if (_offset >= threshold) {
      setState(() {
        _offset = threshold;
        _success = true;
      });
      widget.onChange?.call(true);
    } else {
      setState(() => _offset = 0);
      widget.onChange?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = widget.color ?? scheme.primaryOf(6);

    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        final trackBg = _success ? scheme.successMain : scheme.filledStrong;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (d) => _update(_offset + d.delta.dx),
          onHorizontalDragEnd: (_) => _end(),
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: trackBg,
              borderRadius: BorderRadius.circular(widget.height / 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    _success ? widget.successText : widget.text,
                    style: TextStyle(fontSize: 14, color: scheme.textSecondary),
                  ),
                ),
                // 滑块。
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  left: _offset.clamp(0, _width - widget.height),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: widget.height,
                    decoration: BoxDecoration(
                      color: _success ? scheme.successClicked : primary,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                      ],
                    ),
                    child: Icon(
                      _success ? Icons.check : Icons.arrow_forward,
                      size: 20,
                      color: Colors.white,
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
}