import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';

/// 侧滑操作所在的一侧。
enum WotSwipeActionSide {
  /// 操作显示在右侧，内容向左滑出（常规「左滑露出右侧操作」）。
  right,

  /// 操作显示在左侧，内容向右滑出（右滑露出左侧操作）。
  left,
}

/// 单条侧滑操作项配置，可在调用组件处声明列表。
class WotSwipeActionItem {
  const WotSwipeActionItem({
    this.text,
    this.bgColor,
    this.color = Colors.white,
    this.icon,
    this.onClick,
    this.shouldShow = true,
    this.disabled = false,
  });

  /// 操作名称。
  final String? text;

  /// 操作背景色；为空时按组件的 [WotSwipeAction.show] 场景取主题危险色。
  final Color? bgColor;

  /// 操作文字颜色，默认白色。
  final Color color;

  /// 操作图标名（`wotIcon.name`）。（仅占位展示，非 must）
  final String? icon;

  /// 点击操作回调（会在收起滑动后触发）。
  final VoidCallback? onClick;

  /// 是否显示该操作，默认 true；为 false 时从操作区隐藏。
  final bool shouldShow;

  /// 是否禁用该操作，默认 false；禁用时置灰且点击无效。
  final bool disabled;
}

/// 侧滑操作，对应 wot `wd-swipe-action`。
///
/// 在调用处用 [WotSwipeActionItem] 声明操作配置，支持自定义每个操作的
/// 名称/背景色/文字色/回调/是否显示/是否禁用；整条支持左右滑动方向
/// （[side]）与禁止滑动（[disabled]）。
class WotSwipeAction extends StatefulWidget {
  const WotSwipeAction({
    super.key,
    this.show = false,
    this.onChange,
    this.disabled = false,
    this.side = WotSwipeActionSide.right,
    this.actions = const [],
    required this.child,
  });

  /// 是否展开操作区（受控）。
  final bool show;

  /// 展开/收起变化回调（参数为是否展开）。
  final ValueChanged<bool>? onChange;

  /// 是否禁止滑动（整条禁用侧滑手势），默认 false。
  final bool disabled;

  /// 操作显示在左侧还是右侧，决定左滑还是右滑露出，默认右侧（左滑）。
  final WotSwipeActionSide side;

  /// 操作配置列表（在调用处声明）。
  final List<WotSwipeActionItem> actions;

  /// 滑动主体内容。
  final Widget child;

  /// 单个操作按钮宽度。
  static const double itemWidth = 64;

  @override
  State<WotSwipeAction> createState() => _WotSwipeActionState();
}

class _WotSwipeActionState extends State<WotSwipeAction> {
  double _open = 0; // 0 关闭，1 展开。

  void _set(double v) {
    setState(() => _open = v.clamp(0.0, 1.0));
  }

  /// 实际参与展示的操作（过滤掉 shouldShow=false）。
  List<WotSwipeActionItem> get _visibleActions =>
      widget.actions.where((a) => a.shouldShow).toList();

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final visible = _visibleActions;
    final aw = visible.length * WotSwipeAction.itemWidth;
    final right = widget.side == WotSwipeActionSide.right;
    // 右侧操作：左滑露：内容向左移动（负偏移）。左侧操作：右滑露：内容向右移动（正偏移）。
    final offset = (right ? -1.0 : 1.0) * _open * aw;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // 操作区（right → 右侧；left → 左侧）。
            Positioned.fill(
              child: Align(
                alignment: right ? Alignment.centerRight : Alignment.centerLeft,
                child: SizedBox(
                  width: aw,
                  child: Row(
                    children: [
                      for (final a in visible) Expanded(child: _action(a, scheme)),
                    ],
                  ),
                ),
              ),
            ),
            // 内容（随位移）。
            GestureDetector(
              onHorizontalDragStart: widget.disabled
                  ? null
                  : (_) => _dragging = true,
              onHorizontalDragUpdate: widget.disabled
                  ? null
                  : (d) {
                      if (!_dragging) return;
                      // 右侧操作滑动方向为左负；左侧操作为右正。
                      final sign = right ? -1.0 : 1.0;
                      final delta = sign * d.delta.dx / aw;
                      final next = (_open + delta).clamp(0.0, 1.0);
                      setState(() => _open = next);
                    },
              onHorizontalDragEnd: (_) {
                _dragging = false;
                if (_open > 0 && _open < 0.5) _set(0);
                if (_open >= 0.5) _set(1);
              },
              child: Transform.translate(
                offset: Offset(offset, 0),
                child: Container(
                  width: width,
                  color: scheme.filledOppo,
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _dragging = false;

  Widget _action(WotSwipeActionItem a, WotScheme scheme) {
    final content = Text(
      a.text ?? '操作',
      style: TextStyle(
        color: a.disabled ? scheme.textDisabled : a.color,
        fontSize: 14,
      ),
    );
    return GestureDetector(
      onTap: a.disabled
          ? null
          : () {
              a.onClick?.call();
              _set(0);
              widget.onChange?.call(false);
            },
      child: Opacity(
        opacity: a.disabled ? 0.5 : 1,
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          color: a.bgColor ?? scheme.dangerMain,
          child: content,
        ),
      ),
    );
  }
}