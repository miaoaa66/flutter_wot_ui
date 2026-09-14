import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../theme/wot_theme.dart';

/// 角标位置（9 宫格：上/中/下 x 左/中/右）。
enum WotBadgePosition {
  topLeft, topCenter, topRight,
  middleLeft, middleCenter, middleRight,
  bottomLeft, bottomCenter, bottomRight,
}

/// 徽标，对应 wot `wd-badge`。
///
/// 用于在子组件上显示角标，支持数字、圆点、自定义内容三种形式，
/// 可通过 [badgePosition] 控制角标在 9 宫格中的任意位置。
///
/// 角标定位规则：角标覆盖在子组件对应角落/边缘上。
class WotBadge extends StatelessWidget {
  const WotBadge({
    super.key,
    this.modelValue = 0,
    this.max = 99,
    this.slot,
    this.badgePosition = WotBadgePosition.topRight,
    this.bgColor,
    this.color = Colors.white,
    this.hidden = false,
    this.isDot = false,
    this.showDot = false,
    required this.child,
  });

  /// 角标值，大于 0 时显示。
  final num modelValue;

  /// 最大值，超过时显示 `${max}+`，默认 99。
  final num max;

  /// 自定义角标内容，优先级高于 [modelValue] 和 [isDot]。
  final Widget? slot;

  /// 角标位置（9 宫格），默认 [WotBadgePosition.topRight]。
  final WotBadgePosition badgePosition;

  /// 角标背景色，默认使用主题 dangerMain。
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
    final bg = bgColor ?? scheme.dangerMain;

    Widget? badge;
    if (slot != null) {
      badge = slot;
    } else if (isDot || showDot) {
      badge = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      );
    } else if (modelValue > 0 && !hidden) {
      final text = modelValue <= max ? '${modelValue.toInt()}' : '$max+';
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        constraints: const BoxConstraints(minHeight: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 10, height: 1)),
      );
    }

    return _BadgeWidget(
      position: badgePosition,
      badge: badge,
      child: child,
    );
  }
}

/// 自定义 RenderObject 实现徽标定位。
class _BadgeWidget extends MultiChildRenderObjectWidget {
  _BadgeWidget({
    required this.position,
    required this.badge,
    required this.child,
  }) : super(children: [child, if (badge != null) badge]);

  final WotBadgePosition position;
  final Widget? badge;
  final Widget child;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderBadge(position: position);

  @override
  void updateRenderObject(BuildContext context, _RenderBadge renderObject) {
    renderObject.position = position;
  }
}

class _BadgeParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderBadge extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BadgeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BadgeParentData> {
  _RenderBadge({required WotBadgePosition position}) : _position = position;

  WotBadgePosition _position;
  WotBadgePosition get position => _position;
  set position(WotBadgePosition value) {
    if (_position == value) return;
    _position = value;
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
      final offset = _computeOffset(childSize, badgeSize);
      (badge.parentData as _BadgeParentData).offset = offset;
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
