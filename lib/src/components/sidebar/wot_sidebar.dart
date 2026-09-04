import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../badge/wot_badge.dart';
import '../icon/wot_icon.dart';

/// 侧边导航项，对应 wot `wd-sidebar-item`。须作为 [WotSidebar] 的直接子级。
class WotSidebarItem extends StatelessWidget {
  const WotSidebarItem({
    super.key,
    this.title,
    this.name,
    this.disabled = false,
    this.badge,
    this.icon,
    this.value,
    this.max = 99,
    this.isDot = false,
  });

  /// 导航项标题文本。
  final String? title;

  /// 唯一标识，与 [WotSidebar.modelValue] 匹配。
  final Object? name;

  /// 是否禁用该导航项，默认 false。
  final bool disabled;

  /// 角标（数字/文案）。
  final String? badge;

  /// 导航项图标名称（显示在标题左侧，激活时变色）。
  final String? icon;

  /// 徽标显示值（数字，与 [isDot]/[max] 配合经 [WotBadge] 渲染）。
  final num? value;

  /// 徽标最大值，超过时显示为 `{max}+`，默认 99。
  final num max;

  /// 是否显示点状徽标（红点），默认 false。
  final bool isDot;

  @override
  Widget build(BuildContext context) {
    final data = _WotSidebarScope.of(context);
    final active = data.modelValue == name;
    final scheme = context.wotScheme;
    final activeColor = data.activeColor ?? scheme.primaryOf(6);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : () => data.onSelect?.call(this),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        color: active
            ? (data.inactiveColor ?? scheme.filledStrong)
            : Colors.transparent,
        child: Row(
          children: [
            // 左侧激活条。
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 3 : 0,
              height: 16,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            if (icon != null) ...[
              WotIcon(
                name: icon!,
                size: 16,
                color: disabled
                    ? scheme.textDisabled
                    : (active ? activeColor : scheme.textMain),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? '',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: disabled
                          ? scheme.textDisabled
                          : (active ? activeColor : scheme.textMain),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: scheme.dangerMain,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(color: Colors.white, fontSize: 9, height: 1),
                      ),
                    ),
                ],
              ),
            ),
            // 数字/点状徽标（经 [WotBadge] 渲染，显示在导航项右侧）。
            if (value != null || isDot)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: WotBadge(
                  modelValue: value ?? 0,
                  max: max,
                  isDot: isDot,
                  child: const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 侧边导航，对应 wot `wd-sidebar`。受控（v-model:value）。
class WotSidebar extends StatefulWidget {
  const WotSidebar({
    super.key,
    this.modelValue,
    this.onChange,
    this.activeColor,
    this.inactiveColor,
    this.width = 80,
    required this.children,
  });

  /// 当前选中项的标识（受控）。
  final Object? modelValue;

  /// 选中项变化回调，参数为选中项的 [WotSidebarItem.name]。
  final ValueChanged<Object?>? onChange;

  /// 激活项颜色（高亮色），默认使用主题主色。
  final Color? activeColor;

  /// 未激活项背景色。
  final Color? inactiveColor;

  /// 宽度。
  final double width;

  /// 导航项列表（[WotSidebarItem]）。
  final List<WotSidebarItem> children;

  @override
  State<WotSidebar> createState() => _WotSidebarState();
}

class _WotSidebarState extends State<WotSidebar> {
  Object? _current;

  @override
  void initState() {
    super.initState();
    _current = widget.modelValue;
  }

  @override
  void didUpdateWidget(WotSidebar old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) _current = widget.modelValue;
  }

  void _onSelect(WotSidebarItem item) {
    if (item.disabled || _current == item.name) return;
    setState(() => _current = item.name);
    widget.onChange?.call(item.name);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final data = _WotSidebarData(
      modelValue: _current,
      activeColor: widget.activeColor,
      inactiveColor: widget.inactiveColor,
      onSelect: _onSelect,
    );

    return SizedBox(
      width: widget.width,
      height: double.infinity,
      child: Container(
        color: scheme.filledContent,
        child: _WotSidebarScope(
          data: data,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final item in widget.children)
                WotSidebarItem(
                  key: ObjectKey(item),
                  title: item.title,
                  name: item.name,
                  disabled: item.disabled,
                  badge: item.badge,
                  icon: item.icon,
                  value: item.value,
                  max: item.max,
                  isDot: item.isDot,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WotSidebarData {
  const _WotSidebarData({
    this.modelValue,
    this.activeColor,
    this.inactiveColor,
    this.onSelect,
  });

  final Object? modelValue;
  final Color? activeColor;
  final Color? inactiveColor;
  final ValueChanged<WotSidebarItem>? onSelect;
}

class _WotSidebarScope extends InheritedWidget {
  const _WotSidebarScope({required this.data, required super.child});

  final _WotSidebarData data;

  static _WotSidebarData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_WotSidebarScope>();
    return scope?.data ??
        const _WotSidebarData(); // 无父级时返回默认（自身不要求存在）
  }

  @override
  bool updateShouldNotify(_WotSidebarScope oldWidget) =>
      data.modelValue != oldWidget.data.modelValue ||
      data.activeColor != oldWidget.data.activeColor ||
      data.inactiveColor != oldWidget.data.inactiveColor ||
      data.onSelect != oldWidget.data.onSelect;
}