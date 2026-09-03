import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 角标位置。
enum WotBadgePosition { topRight, topLeft, bottomRight, bottomLeft }

/// 徽标，对应 wot `wd-badge`。
class WotBadge extends StatelessWidget {
  const WotBadge({
    super.key,
    this.modelValue = 0,
    this.max = 99,
    this.slot,
    this.badgePosition = WotBadgePosition.topRight,
    this.bgColor,
    this.color = Colors.white,
    this.hidden = false,
    this.isDot = false,
    this.showDot = false,
    required this.child,
  });

  /// 徽标值。
  final num modelValue;
  final num max;

  /// 自定义徽标内容。
  final Widget? slot;
  final WotBadgePosition badgePosition;
  final Color? bgColor;
  final Color color;
  final bool hidden;
  final bool isDot;
  final bool showDot;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final bg = bgColor ?? scheme.dangerMain;

    Widget? badge;
    if (slot != null) {
      badge = slot;
    } else if (isDot || showDot) {
      badge = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      );
    } else if (modelValue > 0 && !hidden) {
      final text = modelValue <= max ? '${modelValue.toInt()}' : '$max+';
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        constraints: const BoxConstraints(minHeight: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 10, height: 1)),
      );
    }

    if (badge == null) return child;

    final offset = switch (badgePosition) {
      WotBadgePosition.topRight => const Offset(6, -6),
      WotBadgePosition.topLeft => const Offset(-6, -6),
      WotBadgePosition.bottomRight => const Offset(6, 6),
      WotBadgePosition.bottomLeft => const Offset(-6, 6),
    };

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: badgePosition == WotBadgePosition.topRight || badgePosition == WotBadgePosition.bottomRight ? 0 : null,
          left: badgePosition == WotBadgePosition.topLeft || badgePosition == WotBadgePosition.bottomLeft ? 0 : null,
          top: badgePosition == WotBadgePosition.topRight || badgePosition == WotBadgePosition.topLeft ? 0 : null,
          bottom: badgePosition == WotBadgePosition.bottomRight || badgePosition == WotBadgePosition.bottomLeft ? 0 : null,
          child: Transform.translate(offset: offset, child: badge),
        ),
      ],
    );
  }
}