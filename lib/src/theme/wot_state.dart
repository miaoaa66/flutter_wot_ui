import 'package:flutter/material.dart';

import 'wot_scheme.dart';

/// 字段可用性三态。
///
/// 这是本库「三态语义规范」的代码化定义（完整规范见 `COMPONENT_AUDIT.md`
/// 的「三态语义规范」一节）。三态指同一个字段在业务上的三种可用性：
///
/// - [editable] 可编辑：用户可输入/修改。视觉为 常规底色 / 主字色 / 可见边框。
/// - [readonly] 只读：有值、内容**有效可读**，但不可修改。
///   视觉为 常规底色 / **主字色（关键：不灰化）** / **无边框**（表达「非输入区」）。
/// - [disabled] 禁用：整体**失效**、不可交互（如无权限、流程已归档）。
///   视觉为 **浅灰底** / **禁用字色** / **保留边框**（结构仍在，只是不可用）。
///
/// **最关键的一条**：[readonly] 保持正常字色，只有 [disabled] 才灰化。
/// 这是「以 disabled 代 readonly」长期歧义的解药——只读内容本身是有效的，
/// 用户需要正常阅读它；而禁用内容是失效的，才应该灰掉。
enum WotFieldState {
  /// 可编辑（默认态）。
  editable,

  /// 只读：内容有效可读，但不可修改。
  readonly,

  /// 禁用：整体失效，不可交互。
  disabled,
}

/// 三态 + 校验态的取色结果，由 [wotFieldStyle] 产出。
///
/// 组件按自身形态取用其中的字段（如输入框取 [text] / [border]，
/// 单元格取 [text] / [icon]），从而保证全库三态视觉一致。
@immutable
class WotFieldStyle {
  const WotFieldStyle({
    required this.background,
    required this.text,
    required this.icon,
    required this.border,
    required this.label,
    required this.placeholder,
  });

  /// 底色差异：仅 [WotFieldState.disabled] 返回浅灰，其余为透明。
  ///
  /// 语义是「三态带来的底色变化」而非「组件的固定底色」——
  /// 因此可编辑 / 只读返回透明，组件自身的基础底色不受影响；
  /// 组件可直接 `color: style.background` 而不必额外判断。
  final Color background;

  /// 值文本色。
  final Color text;

  /// 图标色。
  final Color icon;

  /// 边框 / 下划线色。
  final Color border;

  /// 标签（title / label）色。
  final Color label;

  /// 占位符（placeholder）色。
  final Color placeholder;
}

/// 按三态 + 校验态解析取色（三态规范的**单一真相源**）。
///
/// [baseBorder] 为组件在「可编辑态」自身使用的边框色，缺省用
/// [WotScheme.borderMain]。传它可让不同形态的组件（下划线式输入框、
/// 框式文本域等）保留各自的常规边框，同时自动获得三态差异：
/// 只读仍为无边框、error 仍为红边框，只有可编辑 / 禁用沿用它。
///
/// [error] 是**独立的叠加维度**：命中即红边框 + 红标签，与可用性态无关。
/// 注意 [WotFieldState.disabled] 优先级更高——禁用的字段通常不参与校验，
/// 因此不给它叠加 error 视觉。
WotFieldStyle wotFieldStyle(
  WotScheme scheme,
  WotFieldState state, {
  bool error = false,
  Color? baseBorder,
}) {
  final disabled = state == WotFieldState.disabled;
  final readonly = state == WotFieldState.readonly;
  final base = baseBorder ?? scheme.borderMain;

  // 边框：禁用优先吃掉 error；否则 error 红 > 只读无边框 > 常规边框。
  final Color border;
  if (disabled) {
    border = base;
  } else if (error) {
    border = scheme.dangerMain;
  } else if (readonly) {
    border = scheme.borderZero;
  } else {
    border = base;
  }

  final label = disabled
      ? scheme.textDisabled
      : error
          ? scheme.dangerMain
          : scheme.textMain;

  return WotFieldStyle(
    background: disabled ? scheme.filledContent : scheme.borderZero,
    text: disabled ? scheme.textDisabled : scheme.textMain,
    icon: disabled ? scheme.iconDisabled : scheme.iconMain,
    border: border,
    label: label,
    placeholder: disabled ? scheme.textDisabled : scheme.textPlaceholder,
  );
}

/// 三态下发：`WotFormItem` 用它包裹子控件，把自身的可用性态与校验态
/// 传给内部录入控件（如 `WotInput`），实现「整项一处配置、内部控件跟随」。
///
/// 子控件读取优先级：**显式传参 > 本 scope > 默认可编辑**。
/// 例如 `WotFormItem(disabled: true, child: WotInput())` 时，输入框自动禁用；
/// 若写成 `WotInput(disabled: false)` 则显式参数胜出。
class WotFieldScope extends InheritedWidget {
  const WotFieldScope({
    super.key,
    required this.state,
    this.error = false,
    required super.child,
  });

  /// 当前字段的可用性态。
  final WotFieldState state;

  /// 当前字段是否校验失败。
  final bool error;

  /// 读取当前字段域（建立依赖，值变化时重建子树）。
  static WotFieldScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WotFieldScope>();

  /// 读取当前字段域，**不建立**依赖（用于回调等非 build 场景）。
  static WotFieldScope? read(BuildContext context) {
    final el = context.getElementForInheritedWidgetOfExactType<WotFieldScope>();
    return (el?.widget as WotFieldScope?);
  }

  @override
  bool updateShouldNotify(WotFieldScope oldWidget) =>
      state != oldWidget.state || error != oldWidget.error;
}
