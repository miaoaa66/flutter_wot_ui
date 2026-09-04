import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 侧滑操作按钮。
class WotSwipeActionItem {
  const WotSwipeActionItem({
    this.text,
    this.bgColor,
    this.color = Colors.white,
    this.icon,
    this.onClick,
  });
  final String? text;
  final Color? bgColor;
  final Color color;
  final String? icon;
  final VoidCallback? onClick;
}

/// 左滑显示操作，对应 wot `wd-swipe-action`。
class WotSwipeAction extends StatefulWidget {
  const WotSwipeAction({
    super.key,
    this.show = false,
    this.onChange,
    this.disabled = false,
    this.actions = const [],
    required this.child,
  });

  final bool show;
  final ValueChanged<bool>? onChange;
  final bool disabled;
  final List<WotSwipeActionItem> actions;
  final Widget child;

  @override
  State<WotSwipeAction> createState() => _WotSwipeActionState();
}

class _WotSwipeActionState extends State<WotSwipeAction> {
  double _open = 0; // 0 关闭，1 展开。
  bool _dragging = false;

  void _set(double v) {
    setState(() => _open = v.clamp(0.0, 1.0));
  }

  double get _actionsWidth => widget.actions.length * 64.0;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final aw = _actionsWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final offset = -_open * aw;

        final content = Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // 操作按钮（右侧）。
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: aw,
                  child: Row(
                    children: [
                      for (final a in widget.actions)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              a.onClick?.call();
                              _set(0);
                              widget.onChange?.call(false);
                            },
                            child: Container(
                              height: double.infinity,
                              alignment: Alignment.center,
                              color: a.bgColor ?? scheme.dangerMain,
                              child: a.icon != null
                                  ? Text(a.text ?? '',
                                      style: TextStyle(color: a.color, fontSize: 14))
                                  : Text(
                                      a.text ?? '操作',
                                      style: TextStyle(color: a.color, fontSize: 14),
                                    ),
                            ),
                          ),
                        ),
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
                      final delta = -d.delta.dx / aw;
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

        return content;
      },
    );
  }
}

// 供 demo 直接构造若干操作项。
List<WotSwipeActionItem> wotSwipeActions({
  String delete = '删除',
  VoidCallback? onDelete,
}) {
  return [
    WotSwipeActionItem(text: '收藏'),
    // 删除按钮不写死红色，交由构建处 `bgColor ?? scheme.dangerMain` 取主题危险色。
    WotSwipeActionItem(text: delete, onClick: onDelete),
  ];
}