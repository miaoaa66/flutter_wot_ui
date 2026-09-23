import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 单元格分组，对应 wot `wd-cell-group`。
///
/// 将若干 [WotCell] 包裹成卡片/分段列表；`inset` 为内嵌卡片（带圆角与边距），
/// `bordered` 控制是否显示分割线与边框，并经 [WotCellGroupScope] 下发给组内
/// [WotCell]（D 类 P1：分组属性继承——cell 未显式传 border 时跟随组的 bordered）。
/// 颜色取自语义令牌 `borderLight/borderStrong` 等。
class WotCellGroup extends StatelessWidget {
  const WotCellGroup({
    super.key,
    this.title,
    this.value,
    this.inset = false,
    this.bordered = true,
    this.rounded = true,
    this.space = 0,
    this.customStyle,
    required this.children,
  });

  /// 分组标题（D 类 P1），显示在分组上方左侧。
  final String? title;

  /// 标题右侧的说明文字（D 类 P1）。
  final String? value;

  /// 是否以内嵌卡片样式展示（带外边距与圆角）。
  final bool inset;

  /// 是否显示分割线 / 边框。默认 true（对齐 wot Vue 的 border 默认值；
  /// 此前默认 false 且未下发给 cell，属漂移，本次一并修正——
  /// 依赖旧默认 false 隐藏外框的调用方需显式传 false）。
  /// 同时经 [WotCellGroupScope] 下发：组内 cell 未显式传 border 时跟随此值。
  final bool bordered;

  /// 是否圆角。
  final bool rounded;

  /// 每项间距。
  final double space;

  /// 透传 style（此处为非关键视觉扩展，可选）。
  final BoxDecoration? customStyle;

  /// 分组内展示的单元格列表。
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final borderColor = scheme.borderLight;

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0 && space > 0) SizedBox(height: space),
          children[i],
        ],
      ],
    );

    if (!inset) {
      if (!bordered) {
        body = _wrapScope(body);
      } else {
        body = _wrapScope(
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: borderColor),
              ),
            ),
            child: body,
          ),
        );
      }
    } else {
      // 内嵌卡片：外边距 + 圆角 + 整体边框。
      body = _wrapScope(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DecoratedBox(
            decoration: (customStyle ?? const BoxDecoration()).copyWith(
              color: scheme.filledContent,
              borderRadius: rounded ? BorderRadius.circular(12) : null,
              border: bordered
                  ? Border.all(color: borderColor)
                  : (customStyle?.border),
            ),
            child: ClipRRect(
              borderRadius: rounded ? BorderRadius.circular(12) : BorderRadius.zero,
              child: body,
            ),
          ),
        ),
      );
    }

    // 标题区（D 类 P1）：title 左、value 右，显示在分组上方。
    if (title == null && value == null) return body;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              if (title != null)
                Text(
                  title!,
                  style: TextStyle(fontSize: 14, color: scheme.textMain),
                ),
              const Spacer(),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(fontSize: 12, color: scheme.textAuxiliary),
                ),
            ],
          ),
        ),
        body,
      ],
    );
  }

  /// 下发分组属性给组内 cell（D 类 P1：分组属性继承）。
  Widget _wrapScope(Widget child) {
    return WotCellGroupScope(bordered: bordered, child: child);
  }
}

/// 分组属性下发通道（D 类 P1）：组内 [WotCell] 读取 [bordered]，
/// cell 未显式传 border 时跟随组的 bordered。
class WotCellGroupScope extends InheritedWidget {
  const WotCellGroupScope({
    super.key,
    required this.bordered,
    required super.child,
  });

  /// 组的分割线 / 边框开关。
  final bool bordered;

  static WotCellGroupScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WotCellGroupScope>();

  @override
  bool updateShouldNotify(WotCellGroupScope oldWidget) =>
      oldWidget.bordered != bordered;
}