import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 顶部导航栏，对应 wot `wd-navbar`。
class WotNavbar extends StatelessWidget {
  const WotNavbar({
    super.key,
    this.title,
    this.titleWidget,
    this.leftText,
    this.rightText,
    this.leftArrow = true,
    this.leftArrowColor,
    this.background,
    this.color,
    this.bordered = false,
    this.capsule = false,
    this.capsuleText,
    this.capsuleBackground,
    this.onCapsuleLeft,
    this.onCapsuleRight,
    this.onClickLeft,
    this.onClickRight,
  });

  /// 标题文本（无 [titleWidget] 时使用）。
  final String? title;

  /// 自定义标题。
  final Widget? titleWidget;

  /// 左侧文字。
  final String? leftText;

  /// 右侧文字。
  final String? rightText;

  /// 是否显示返回箭头。
  final bool leftArrow;

  /// 箭头颜色。
  final Color? leftArrowColor;

  /// 背景色。
  final Color? background;

  /// 文字颜色。
  final Color? color;

  /// 是否显示底部边框。
  final bool bordered;

  /// 是否开启顶部胶囊（对齐 wot `navbar-capsule`）：标题位渲染一个圆角胶囊，左半图标、右半文字，左右半区可独立点击。
  final bool capsule;

  /// 胶囊右半区文字（默认「咨询」）。
  final String? capsuleText;

  /// 胶囊背景色。
  final Color? capsuleBackground;

  /// 点击胶囊左半区时回调。
  final VoidCallback? onCapsuleLeft;

  /// 点击胶囊右半区时回调。
  final VoidCallback? onCapsuleRight;

  /// 点击左侧区域时回调。
  final VoidCallback? onClickLeft;

  /// 点击右侧区域时回调。
  final VoidCallback? onClickRight;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final bg = background ?? scheme.filledContent;
    final fg = color ?? scheme.textMain;

    final left = _clickable(
      Row(
        children: [
          if (leftArrow)
            WotIcon(
              name: 'arrow-left',
              size: 16,
              color: leftArrowColor ?? fg,
            ),
          if (leftText != null) ...[
            const SizedBox(width: 4),
            Text(leftText!, style: TextStyle(fontSize: 14, color: fg)),
          ],
        ],
      ),
      onClickLeft,
    );

    final right = _clickable(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (rightText != null)
            Text(rightText!, style: TextStyle(fontSize: 14, color: fg)),
        ],
      ),
      onClickRight,
    );

    return Container(
      width: double.infinity,
      color: bg,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: bordered
              ? BoxDecoration(
                  border: Border(bottom: BorderSide(color: scheme.borderLight)),
                )
              : null,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              left,
              Expanded(
                child: Center(
                  child: capsule
                      ? _capsule(scheme, fg)
                      : (titleWidget ??
                          Text(
                            title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          )),
                ),
              ),
              right,
            ],
          ),
        ),
      ),
    );
  }

  Widget _clickable(Widget child, VoidCallback? onTap) {
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: child);
  }

  /// 渲染顶部胶囊（navbar-capsule）：左半图标、右半文字，各自可点。需要传入 [WotScheme]。
  Widget _capsule(WotScheme scheme, Color fg) {
    const capW = 180.0;
    const capH = 34.0;
    final cb = capsuleBackground ?? scheme.opacLightCover;
    return Container(
      width: capW,
      height: capH,
      decoration: BoxDecoration(
        color: cb,
        borderRadius: BorderRadius.circular(capH / 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: _clickable(
              Center(child: Icon(Icons.more_horiz, size: 18, color: fg)),
              onCapsuleLeft,
            ),
          ),
          Expanded(
            child: _clickable(
              Center(
                child: Text(
                  capsuleText ?? '咨询',
                  style: TextStyle(fontSize: 14, color: fg),
                ),
              ),
              onCapsuleRight,
            ),
          ),
        ],
      ),
    );
  }
}