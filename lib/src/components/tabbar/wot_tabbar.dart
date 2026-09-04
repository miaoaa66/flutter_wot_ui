import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../badge/wot_badge.dart';
import '../icon/wot_icon.dart';

/// 标签栏项，对应 wot `wd-tabbar-item`。须作为 [WotTabbar] 的直接子级。
class WotTabbarItem extends StatelessWidget {
  const WotTabbarItem({
    super.key,
    this.name,
    this.icon,
    this.label,
    this.modelValue,
    this.onChange,
    this.onClick,
    this.badge,
    this.activeIcon,
    this.value,
    this.max = 99,
    this.isDot = false,
    this.child,
  });

  /// 唯一标识，与 [WotTabbar.modelValue] 匹配。
  final Object? name;

  /// 图标名（激活时用 [activeIcon]）。
  final String? icon;

  /// 激活图标名。
  final String? activeIcon;

  /// 底部文字。
  final String? label;

  /// 角标内容（数字或文案）。
  final String? badge;

  /// 徽标显示值（数字，与 [isDot]/[max] 配合经 [WotBadge] 渲染）。
  final num? value;

  /// 徽标最大值，超过时显示为 `{max}+`，默认 99。
  final num max;

  /// 是否显示点状徽标（图标右上角小红点），默认 false。
  final bool isDot;

  /// 自定义整个标签项内容（优先于默认的图标+文字布局）。
  final Widget? child;

  /// 受控激活状态（由父级注入）。
  final Object? modelValue;

  /// 点击回调（由 [WotTabbar] 注入）。
  final ValueChanged<WotTabbarItem>? onChange;

  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    final active = modelValue == name;
    final scheme = context.wotScheme;
    final tabbar = WotTabbar.of(context);

    final iconColor =
        active ? (tabbar.activeColor ?? scheme.primaryOf(6)) : (tabbar.inactiveColor ?? scheme.textSecondary);
    final labelColor = active
        ? (tabbar.activeColor ?? scheme.primaryOf(6))
        : (tabbar.inactiveColor ?? scheme.textSecondary);

    Widget content;
    if (child != null) {
      // 自定义整个标签项内容。
      content = Center(child: child);
    } else {
      // 图标（激活时用 activeIcon），数字/点状徽标经 [WotBadge] 渲染。
      Widget iconWidget = WotIcon(
        name: active && activeIcon != null ? activeIcon : icon,
        size: tabbar.iconSize,
        color: iconColor,
      );
      if (isDot || (value != null && value! > 0)) {
        iconWidget = WotBadge(
          modelValue: value ?? 0,
          max: max,
          isDot: isDot,
          child: iconWidget,
        );
      }
      // 兼容旧版字符串角标（数字/文案。
      if (badge != null && badge!.isNotEmpty) {
        iconWidget = Stack(
          clipBehavior: Clip.none,
          children: [
            iconWidget,
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: scheme.dangerMain,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(minHeight: 15),
                alignment: Alignment.center,
                child: Text(
                  badge!,
                  style: const TextStyle(color: Colors.white, fontSize: 9, height: 1),
                ),
              ),
            ),
          ],
        );
      }

      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 点击切换时的图标淡入淡出动画。
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(key: ValueKey(active), child: iconWidget),
          ),
          const SizedBox(height: 2),
          // 点击切换时的文字颜色过渡动画。
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(fontSize: 10, color: labelColor),
            child: Text(label ?? ''),
          ),
        ],
      );
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onClick?.call();
          onChange?.call(this);
        },
        child: content,
      ),
    );
  }
}

/// 底部标签栏，对应 wot `wd-tabbar`。
///
/// 受控（v-model）：通过 [modelValue]/[onChange] 匹配 [WotTabbarItem.name]。
class WotTabbar extends StatefulWidget {
  const WotTabbar({
    super.key,
    this.modelValue,
    this.onChange,
    this.activeColor,
    this.inactiveColor,
    this.fixed = false,
    this.bordered = true,
    this.iconSize = 22,
    required this.children,
  });

  final Object? modelValue;
  final ValueChanged<Object?>? onChange;
  final Color? activeColor;
  final Color? inactiveColor;

  /// 是否固定于屏幕底部（内部使用 bottomNavigationBar 演示不适用；置于底部时由外层布局决定）。
  final bool fixed;
  final bool bordered;

  /// 图标尺寸。
  final double iconSize;

  final List<WotTabbarItem> children;

  /// 供 [WotTabbarItem] 读取父级配置。
  static WotTabbarData of(BuildContext context) {
    final item = context.dependOnInheritedWidgetOfExactType<_WotTabbarScope>();
    return item?.data ?? const WotTabbarData();
  }

  @override
  State<WotTabbar> createState() => _WotTabbarState();
}

class _WotTabbarState extends State<WotTabbar> {
  Object? _current;

  @override
  void initState() {
    super.initState();
    _current = widget.modelValue;
  }

  @override
  void didUpdateWidget(WotTabbar old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) _current = widget.modelValue;
  }

  void _onItem(WotTabbarItem item) {
    if (_current == item.name) return;
    setState(() => _current = item.name);
    widget.onChange?.call(item.name);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final bar = Material(
      color: scheme.filledContent,
      elevation: 0,
      child: Container(
        decoration: widget.bordered
            ? BoxDecoration(
                border: Border(top: BorderSide(color: scheme.borderLight)),
              )
            : null,
        height: 56,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: _WotTabbarScope(
          data: WotTabbarData(
            activeColor: widget.activeColor,
            inactiveColor: widget.inactiveColor,
            iconSize: widget.iconSize,
          ),
          child: Row(
            children: [
              for (final item in widget.children)
                WotTabbarItem(
                  // 通过 clone 注入受控信息，避免修改用户传入的 item。
                  key: ObjectKey(item),
                  name: item.name,
                  icon: item.icon,
                  activeIcon: item.activeIcon,
                  label: item.label,
                  badge: item.badge,
                  value: item.value,
                  max: item.max,
                  isDot: item.isDot,
                  modelValue: _current,
                  onChange: _onItem,
                  child: item.child,
                ),
            ],
          ),
        ),
      ),
    );

    return bar;
  }
}

class WotTabbarData {
  const WotTabbarData({
    this.activeColor,
    this.inactiveColor,
    this.iconSize = 22,
  });

  final Color? activeColor;
  final Color? inactiveColor;
  final double iconSize;
}

class _WotTabbarScope extends InheritedWidget {
  const _WotTabbarScope({required this.data, required super.child});

  final WotTabbarData data;

  @override
  bool updateShouldNotify(_WotTabbarScope oldWidget) =>
      data.iconSize != oldWidget.data.iconSize ||
      data.activeColor != oldWidget.data.activeColor ||
      data.inactiveColor != oldWidget.data.inactiveColor;
}