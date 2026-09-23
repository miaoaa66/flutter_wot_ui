import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../theme/wot_theme.dart';

/// 角标位置（9 宫格：上/中/下 x 左/中/右）。
enum WotBadgePosition {
  topLeft, topCenter, topRight,
  middleLeft, middleCenter, middleRight,
  bottomLeft, bottomCenter, bottomRight,
}

/// 角标预设配色，对应 wot `type`。
enum WotBadgeType { primary, success, warning, danger, info }

/// 角标形状，对应 wot `shape`。
enum WotBadgeShape { circle, square }

/// 徽标，对应 wot `wd-badge`。
///
/// 用于在子组件上显示角标，支持数字、圆点、纯文本、自定义内容四种形式，
/// 可通过 [badgePosition] 控制角标在 9 宫格中的任意位置，[offset] 做微调。
///
/// 角标定位规则：角标覆盖在子组件对应角落/边缘上。
class WotBadge extends StatelessWidget {
  const WotBadge({
    super.key,
    this.modelValue = 0,
    this.max = 99,
    this.text,
    this.type = WotBadgeType.danger,
    this.shape = WotBadgeShape.circle,
    this.showZero = false,
    this.offset,
    this.slot,
    this.badgePosition = WotBadgePosition.topRight,
    this.bgColor,
    this.color = Colors.white,
    this.hidden = false,
    this.isDot = false,
    this.showDot = false,
    required this.child,
  });

  /// 角标值，大于 0 时显示；为 0 时按 [showZero] 决定是否显示。
  final num modelValue;

  /// 最大值，超过时显示 `${max}+`，默认 99。
  final num max;

  /// 纯文本角标（D 类 P1：value 支持 String），如 `'NEW'`、`'热'`。
  /// 优先级：[slot] > [text] > [modelValue] / 圆点。
  final String? text;

  /// 角标预设配色类型，默认 [WotBadgeType.danger]（与历史行为一致）；
  /// [bgColor] 显式传值时优先于 type。
  final WotBadgeType type;

  /// 角标形状：circle 圆角（默认）/ square 直角（微圆角 2 便于阅读）。
  /// 仅作用于内容角标，圆点恒为圆形。
  final WotBadgeShape shape;

  /// 角标值为 0 时是否显示，默认 false（隐藏）。
  final bool showZero;

  /// 在 9 宫格定位基础上叠加的自定义偏移，用于像素级微调。
  final Offset? offset;

  /// 自定义角标内容，优先级高于 [text]、[modelValue] 和 [isDot]。
  final Widget? slot;

  /// 角标位置（9 宫格），默认 [WotBadgePosition.topRight]。
  final WotBadgePosition badgePosition;

  /// 角标背景色，缺省按 [type] 取主题预设色。
  final Color? bgColor;

  /// 角标文字颜色，默认白色。
  final Color color;

  /// 是否隐藏角标，默认 false。
  final bool hidden;

  /// 是否显示为圆点，默认 false。
  final bool isDot;

  /// 是否显示圆点（兼容旧 API），默认 false。
  final bool showDot;

  /// 子组件。
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    // 配色优先级：bgColor 显式传值 > type 预设色。
    final bg = bgColor ??
        switch (type) {
          WotBadgeType.danger => scheme.dangerMain,
          WotBadgeType.primary => scheme.primaryOf(6),
          WotBadgeType.success => scheme.successMain,
          WotBadgeType.warning => scheme.warningMain,
          WotBadgeType.info => scheme.textSecondary,
        };
    final radius = shape == WotBadgeShape.square ? 2.0 : 9.0;

    Widget? badge;
    if (slot != null) {
      badge = slot;
    } else if (isDot || showDot) {
      badge = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      );
    } else if (text != null && text!.isNotEmpty) {
      badge = _buildTextBadge(text!, bg, radius);
    } else if (!hidden && (showZero || modelValue > 0)) {
      final text = modelValue <= max ? '${modelValue.toInt()}' : '$max+';
      badge = _buildTextBadge(text, bg, radius);
    }

    return _BadgeWidget(
      position: badgePosition,
      offset: offset,
      badge: badge,
      child: child,
    );
  }

  /// 内容角标（数字 / 纯文本共用样式）。
  Widget _buildTextBadge(String content, Color bg, double radius) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      constraints: const BoxConstraints(minHeight: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(content, style: TextStyle(color: color, fontSize: 10, height: 1)),
    );
  }
}

/// 自定义 RenderObject 实现徽标定位。
class _BadgeWidget extends MultiChildRenderObjectWidget {
  _BadgeWidget({
    required this.position,
    required this.offset,
    required this.badge,
    required this.child,
  }) : super(children: _buildChildren(child, badge));

  static List<Widget> _buildChildren(Widget child, Widget? badge) {
    final children = <Widget>[child];
    if (badge != null) children.add(badge);
    return children;
  }

  final WotBadgePosition position;
  final Offset? offset;
  final Widget? badge;
  final Widget child;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBadge(position: position, offset: offset);

  @override
  void updateRenderObject(BuildContext context, _RenderBadge renderObject) {
    renderObject
      ..position = position
      ..offset = offset;
  }
}

class _BadgeParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderBadge extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BadgeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BadgeParentData> {
  _RenderBadge({required WotBadgePosition position, Offset? offset})
      : _position = position,
        _offset = offset;

  WotBadgePosition _position;
  WotBadgePosition get position => _position;
  set position(WotBadgePosition value) {
    if (_position == value) return;
    _position = value;
    markNeedsLayout();
  }

  Offset? _offset;
  Offset? get offset => _offset;
  set offset(Offset? value) {
    if (_offset == value) return;
    _offset = value;
    markNeedsLayout();
  }

  RenderBox? get _child => firstChild;
  RenderBox? get _badge => lastChild == firstChild ? null : lastChild;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _BadgeParentData) {
      child.parentData = _BadgeParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => _child?.getMinIntrinsicWidth(height) ?? 0;
  @override
  double computeMaxIntrinsicWidth(double height) => _child?.getMaxIntrinsicWidth(height) ?? 0;
  @override
  double computeMinIntrinsicHeight(double width) => _child?.getMinIntrinsicHeight(width) ?? 0;
  @override
  double computeMaxIntrinsicHeight(double width) => _child?.getMaxIntrinsicHeight(width) ?? 0;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _child?.getDryLayout(constraints) ?? Size.zero;
  }

  @override
  void performLayout() {
    final child = _child;
    final badge = _badge;

    if (child == null) {
      size = Size.zero;
      return;
    }

    child.layout(constraints, parentUsesSize: true);
    final childSize = child.size;
    size = childSize;

    if (badge != null) {
      badge.layout(const BoxConstraints(), parentUsesSize: true);
      final badgeSize = badge.size;
      final base = _computeOffset(childSize, badgeSize);
      final extra = offset;
      (badge.parentData as _BadgeParentData).offset =
          extra == null ? base : base + extra;
    }
  }

  /// 计算角标偏移量。
  ///
  /// 定位规则：角标覆盖在子组件对应角落/边缘上。
  /// 例如 topRight 时，角标右上角对齐到子组件右上角。
  Offset _computeOffset(Size childSize, Size badgeSize) {
    // 水平方向：角标左上角 x 坐标
    final double dx;
    switch (_position) {
      case WotBadgePosition.topLeft:
      case WotBadgePosition.middleLeft:
      case WotBadgePosition.bottomLeft:
        dx = 0 - 5;
        break;
      case WotBadgePosition.topCenter:
      case WotBadgePosition.middleCenter:
      case WotBadgePosition.bottomCenter:
        dx = (childSize.width - badgeSize.width) / 2;
        break;
      case WotBadgePosition.topRight:
      case WotBadgePosition.middleRight:
      case WotBadgePosition.bottomRight:
        dx = childSize.width - badgeSize.width + 5;
        break;
    }

    // 垂直方向：角标左上角 y 坐标
    final double dy;
    switch (_position) {
      case WotBadgePosition.topLeft:
      case WotBadgePosition.topCenter:
      case WotBadgePosition.topRight:
        dy = 0 - 5;
        break;
      case WotBadgePosition.middleLeft:
      case WotBadgePosition.middleCenter:
      case WotBadgePosition.middleRight:
        dy = (childSize.height - badgeSize.height) / 2;
        break;
      case WotBadgePosition.bottomLeft:
      case WotBadgePosition.bottomCenter:
      case WotBadgePosition.bottomRight:
        dy = childSize.height - badgeSize.height + 5;
        break;
    }

    return Offset(dx, dy);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
