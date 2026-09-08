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

  /// 徽标值上限，超过该值显示为 `max+`，默认 99。
  final num max;

  /// 自定义徽标内容。
  final Widget? slot;

  /// 徽标显示位置，默认 `topRight`。
  final WotBadgePosition badgePosition;

  /// 背景颜色，默认取主题危险色。
  final Color? bgColor;

  /// 徽标文字颜色，默认白色。
  final Color color;

  /// 是否隐藏徽标，默认 false。
  final bool hidden;

  /// 是否以小圆点形式显示，默认 false。
  final bool isDot;

  /// 是否显示小圆点，默认 false。
  final bool showDot;

  /// 承载徽标的子组件。
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

    final offset = switch (badgePosition) {
      WotBadgePosition.topRight => const Offset(6, -6),
      WotBadgePosition.topLeft => const Offset(-6, -6),
      WotBadgePosition.bottomRight => const Offset(6, 6),
      WotBadgePosition.bottomLeft => const Offset(-6, 6),
    };

    // 无论是否显示徽标都统一用 Stack 包裹 child：保证 hidden / shown 两种状态下
    // 给子元素相同的宽松约束，避免隐藏徽标时裸 child 在 stretch 布局里被拉满宽度。
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (badge != null)
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