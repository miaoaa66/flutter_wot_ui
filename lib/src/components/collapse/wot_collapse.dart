import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 折叠子项数据描述，对应 wot `name`/`title`/`value`/`iconName`/`disabled`。
class WotCollapseItemData {
  const WotCollapseItemData({
    required this.name,
    this.title,
    this.content,
    this.iconName,
    this.disabled = false,
  });

  /// 子项唯一名称（参与展开状态）。
  final String name;

  /// 标题文字。
  final String? title;

  /// 内容文字。
  final String? content;

  /// 标题前的图标名。
  final String? iconName;

  /// 是否禁用。
  final bool disabled;
}

/// 折叠面板，对应 wot `wd-collapse`。
///
/// 参数对齐 wot：`modelValue`（当前展开的 name 列表）、`accordion`（是否手风琴）、
/// `showArrow`（是否显示箭头）、`onChange`。子项通过 [children] 传入 [WotCollapseItem]。
class WotCollapse extends StatefulWidget {
  const WotCollapse({
    super.key,
    this.modelValue,
    this.accordion = false,
    this.showArrow = true,
    this.onChange,
    this.children = const [],
  });

  /// 当前展开项的名称集合；为空时由组件内部维护。
  final List<String>? modelValue;

  /// 是否手风琴模式（同时只能展开一项）。
  final bool accordion;

  /// 是否显示右侧箭头。
  final bool showArrow;

  /// 展开状态变化回调（返回当前展开的名称集合）。
  final ValueChanged<List<String>>? onChange;

  /// 折叠子项。
  final List<Widget> children;

  @override
  State<WotCollapse> createState() => _WotCollapseState();
}

class _WotCollapseState extends State<WotCollapse> {
  late Set<String> _active;

  @override
  void initState() {
    super.initState();
    _active = (widget.modelValue ?? const []).toSet();
  }

  @override
  void didUpdateWidget(WotCollapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.modelValue != null) _active = widget.modelValue!.toSet();
  }

  bool isActive(String name) => _active.contains(name);

  void toggle(String name, bool disabled) {
    if (disabled) return;
    setState(() {
      final wasActive = _active.contains(name);
      if (widget.accordion) {
        _active.clear();
        if (!wasActive) _active.add(name);
      } else {
        wasActive ? _active.remove(name) : _active.add(name);
      }
    });
    widget.onChange?.call(_active.toList());
  }

  @override
  Widget build(BuildContext context) {
    return _CollapseScope(
      isActive: isActive,
      toggle: toggle,
      showArrow: widget.showArrow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.children,
      ),
    );
  }
}

class _CollapseScope extends InheritedWidget {
  const _CollapseScope({
    required this.isActive,
    required this.toggle,
    required this.showArrow,
    required super.child,
  });

  final bool Function(String name) isActive;
  final void Function(String name, bool disabled) toggle;
  final bool showArrow;

  static _CollapseScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_CollapseScope>()!;
  }

  @override
  bool updateShouldNotify(_CollapseScope oldWidget) {
    return oldWidget.showArrow != showArrow;
  }
}

/// 折叠子项，对应 wot `wd-collapse-item`。
class WotCollapseItem extends StatelessWidget {
  const WotCollapseItem({
    super.key,
    required this.data,
    this.title,
    this.content,
    this.children,
  });

  /// 子项数据。
  final WotCollapseItemData data;

  /// 自定义标题（优先级高于 [data.title]）。
  final Widget? title;

  /// 自定义内容（优先级高于 [data.content]）。
  final Widget? content;

  /// 自定义内容区（优先级高于 [data.content] 与 [content]）。
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final scope = _CollapseScope.of(context);
    final active = scope.isActive(data.name);
    final showArrow = scope.showArrow;

    final header = InkWell(
      onTap: data.disabled ? null : () => scope.toggle(data.name, data.disabled),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: scheme.filledOppo,
        child: Row(
          children: [
            if (data.iconName != null) ...[
              WotIcon(name: data.iconName, size: 18, color: scheme.iconMain),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: title ??
                  Text(
                    data.title ?? '',
                    style: TextStyle(fontSize: 14, color: data.disabled ? scheme.textDisabled : scheme.textMain),
                  ),
            ),
            if (showArrow)
              AnimatedRotation(
                turns: active ? 0.75 : 0,
                duration: const Duration(milliseconds: 200),
                child: WotIcon(name: 'arrow-right', size: 16, color: scheme.iconSecondary),
              ),
          ],
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: scheme.filledOppo,
        border: Border(bottom: BorderSide(color: scheme.borderLight, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: children != null
                  ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: children!)
                  : content ?? Text(data.content ?? '', style: TextStyle(fontSize: 12, color: scheme.textSecondary)),
            ),
            crossFadeState: active ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}