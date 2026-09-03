import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 头像形状。
enum WotAvatarShape { circle, square }

/// 头像，对应 wot `wd-avatar`。
class WotAvatar extends StatelessWidget {
  const WotAvatar({
    super.key,
    this.src,
    this.size = 40,
    this.shape = WotAvatarShape.circle,
    this.icon,
    this.onClick,
    this.bgColor,
    this.color,
    this.name,
    this.round,
  });

  /// 图片地址。
  final String? src;
  final double size;
  final WotAvatarShape shape;
  final String? icon;
  final VoidCallback? onClick;
  final Color? bgColor;
  final Color? color;
  final String? name;
  final bool? round;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final bg = bgColor ?? scheme.filledStrong;
    final fg = color ?? scheme.textSecondary;
    final radius = shape == WotAvatarShape.circle
        ? BorderRadius.circular(size / 2)
        : BorderRadius.circular(round ?? false ? 6 : 2);

    Widget content;
    if (src != null && src!.isNotEmpty) {
      content = Image.network(
        src!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(context, fg),
      );
    } else {
      content = _fallback(context, fg);
    }

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    if (onClick == null) return avatar;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onClick, child: avatar);
  }

  Widget _fallback(BuildContext context, Color fg) {
    // 有文字优先显示文字，否则显示 person 图标。
    if (name != null && name!.isNotEmpty) {
      return Center(
        child: Text(
          name!,
          style: TextStyle(fontSize: size * 0.4, color: fg, fontWeight: FontWeight.w500),
        ),
      );
    }
    return Icon(Icons.person, size: size * 0.6, color: fg);
  }
}

/// 头像组，对应 wot `wd-avatar-group`。
class WotAvatarGroup extends StatelessWidget {
  const WotAvatarGroup({
    super.key,
    this.children = const [],
    this.avatarList = const [],
    this.size = 40,
    this.margin = -8,
    this.shape = WotAvatarShape.circle,
    this.max = 5,
  });

  final List<Widget> children;
  final List<String> avatarList;
  final double size;
  final double margin;
  final WotAvatarShape shape;
  final int max;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final avatars = <Widget>[
      ...children,
      for (final a in avatarList) WotAvatar(src: a, size: size, shape: shape),
    ];
    if (avatars.length > max) {
      final overflow = avatars.length - max;
      avatars.removeRange(max, avatars.length);
      avatars.add(
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: scheme.filledStrong,
            shape: shape == WotAvatarShape.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: shape == WotAvatarShape.circle ? null : BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text('+$overflow',
              style: TextStyle(fontSize: size * 0.3, color: scheme.textSecondary)),
        ),
      );
    }

    // 用 Transform.translate 实现头像重叠：负 margin 不为 Container 所支持，
    // 改为视觉平移（不占用布局宽度），offset.dx = margin（默认 -8 → 向左叠加）。
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < avatars.length; i++)
          Transform.translate(
            offset: Offset(i == 0 ? 0 : margin, 0),
            child: avatars[i],
          ),
      ],
    );
  }
}