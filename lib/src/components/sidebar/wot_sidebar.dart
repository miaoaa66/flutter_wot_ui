import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 侧边导航项，对应 wot `wd-sidebar-item`。须作为 [WotSidebar] 的直接子级。
class WotSidebarItem extends StatelessWidget {
  const WotSidebarItem({
    super.key,
    this.title,
    this.name,
    this.disabled = false,
    this.badge,
  });

  final String? title;

  /// 唯一标识，与 [WotSidebar.modelValue] 匹配。
  final Object? name;

  final bool disabled;

  /// 角标（数字/文案）。
  final String? badge;

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
            Expanded(
              child: Text(
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
            ),
            if (badge != null)
              Container(
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

  final Object? modelValue;
  final ValueChanged<Object?>? onChange;
  final Color? activeColor;

  /// 未激活项背景色。
  final Color? inactiveColor;

  /// 宽度。
  final double width;

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