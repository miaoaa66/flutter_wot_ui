import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 顶部导航栏，对应 wot `wd-navbar`。
///
/// 实现 [PreferredSizeWidget]，因此可直接放进 `Scaffold.appBar` /
/// `NestedScrollView.headerSliverBuilder` / `SliverAppBar` 等需要该约束的位置。
///
/// **作为 appBar 使用时应把 [safeArea] 置为 false**：`Scaffold` 已经处理了状态栏避让，
/// 再套一层 `SafeArea` 会导致顶部多出一段空白。此时用 [topPadding] 把状态栏高度
/// 计入 [preferredSize] 即可。
class WotNavbar extends StatelessWidget implements PreferredSizeWidget {
  const WotNavbar({
    super.key,
    this.title,
    this.titleWidget,
    this.leftText,
    this.rightText,
    this.leftArrow = false,
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
    this.height = 44,
    this.topPadding = 0,
    this.safeArea = true,
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

  /// 导航栏内容区高度（不含 [topPadding]），默认 44。
  final double height;

  /// 计入 [preferredSize] 的顶部额外高度（通常填状态栏高度）。
  ///
  /// 只为让 [preferredSize] 算准，组件内部不会额外绘制这段高度。
  final double topPadding;

  /// 是否自行套一层 [SafeArea] 避让状态栏，默认 true。
  ///
  /// 放进 `Scaffold.appBar` 时应置为 false（由 Scaffold 统一避让）。
  final bool safeArea;

  @override
  Size get preferredSize => Size.fromHeight(height + topPadding);

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

    final bar = Container(
      decoration: bordered
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: scheme.borderLight)),
            )
          : null,
      height: height,
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
    );

    return Container(
      width: double.infinity,
      color: bg,
      child: safeArea ? SafeArea(bottom: false, child: bar) : bar,
    );
  }

  Widget _clickable(Widget child, VoidCallback? onTap) {
    // 无障碍：导航项补 button 角色 + 点按动作。
    return Semantics(
      button: true,
      onTap: onTap,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque, onTap: onTap, child: child),
    );
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