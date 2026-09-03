import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 公告栏，对应 wot `wd-notice-bar`。
class WotNoticeBar extends StatefulWidget {
  const WotNoticeBar({
    super.key,
    this.text,
    this.color,
    this.bgColor,
    this.icon,
    this.closeable = false,
    this.leftIcon = true,
    this.delay = 1,
    this.speed = 60,
    this.onClose,
    this.wrapable = false,
    this.showMore = false,
    this.textStyle,
  });

  final String? text;
  final Color? color;
  final Color? bgColor;
  final String? icon;
  final bool closeable;
  final bool leftIcon;
  final int delay;
  final int speed;
  final VoidCallback? onClose;
  final bool wrapable;
  final bool showMore;
  final TextStyle? textStyle;

  @override
  State<WotNoticeBar> createState() => _WotNoticeBarState();
}

class _WotNoticeBarState extends State<WotNoticeBar> {
  bool _closing = false;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final fg = widget.color ?? scheme.primaryOf(6);
    final bg = widget.bgColor ?? fg.withValues(alpha: 0.1);
    final iconName = widget.icon ??
        (widget.leftIcon ? 'warning' : null);

    final text = Expanded(
      child: widget.text == null
          ? const SizedBox.shrink()
          : Text(
              widget.text!,
              overflow: widget.wrapable ? null : TextOverflow.ellipsis,
              maxLines: widget.wrapable ? null : 1,
              style: widget.textStyle ??
                  TextStyle(fontSize: 13, color: fg, height: 1.4),
            ),
    );

    return AnimatedOpacity(
      opacity: _closing ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: bg,
        child: Row(
          children: [
            if (iconName != null) ...[
              WotIcon(name: iconName, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            text,
            if (widget.showMore) ...[
              const SizedBox(width: 4),
              WotIcon(name: 'arrow-right', size: 14, color: fg),
            ],
            if (widget.closeable) ...[
              const SizedBox(width: 6),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() => _closing = true);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    widget.onClose?.call();
                  });
                },
                child: WotIcon(name: 'close', size: 14, color: fg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}