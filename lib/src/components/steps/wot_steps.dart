import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 步骤条方向。
enum WotStepsDirection { horizontal, vertical }

/// 步骤项状态。
enum WotStepDataStatus { waiting, process, finished, error }

/// 步骤项数据。
class WotStepData {
  const WotStepData({
    this.title,
    this.description,
    this.status = WotStepDataStatus.waiting,
  });

  /// 标题。
  final String? title;

  /// 描述。
  final String? description;

  /// 状态；为空时由当前激活索引推导。
  final WotStepDataStatus status;
}

/// 步骤项，对应 wot `wd-step`。
class WotStep extends StatelessWidget {
  const WotStep({
    super.key,
    this.index = 0,
    this.active = 0,
    required this.data,
    this.activeColor,
    this.inactiveColor,
    this.onClick,
  });

  final int index;
  final int active;
  final WotStepData data;
  final Color? activeColor;
  final Color? inactiveColor;
  final VoidCallback? onClick;

  bool get _done => index < active;
  bool get _current => index == active;

  Color _color(BuildContext context) {
    if (index >= active) {
      return _current ? (activeColor ?? context.wotScheme.primaryOf(6)) : (inactiveColor ?? context.wotScheme.textDisabled);
    }
    return activeColor ?? context.wotScheme.successMain;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final color = _color(context);

    final circle = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: _done
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 12,
                color: _current || _done ? Colors.white : scheme.textSecondary,
              ),
            ),
    );

    final label = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.title ?? '',
          style: TextStyle(fontSize: 13, color: _current || _done ? scheme.textMain : scheme.textDisabled),
        ),
        if (data.description != null) ...[
          const SizedBox(height: 4),
          Text(data.description!, style: TextStyle(fontSize: 11, color: scheme.textAuxiliary)),
        ],
      ],
    );

    return InkWell(
      onTap: onClick,
      child: Row(
        children: [
          circle,
          const SizedBox(width: 8),
          Expanded(child: label),
        ],
      ),
    );
  }
}

/// 步骤条，对应 wot `wd-steps`。
///
/// 参数对齐 wot：`active`（当前激活索引）、`direction`、`activeColor`、`inactiveColor`、
/// `onChange`（点击步骤回调，参数为步骤索引）。子项通过 [children] 传入 [WotStep]。
class WotSteps extends StatelessWidget {
  const WotSteps({
    super.key,
    this.active = 0,
    this.direction = WotStepsDirection.horizontal,
    this.activeColor,
    this.inactiveColor,
    this.onChange,
    this.children = const [],
  });

  final int active;
  final WotStepsDirection direction;
  final Color? activeColor;
  final Color? inactiveColor;
  final ValueChanged<int>? onChange;
  final List<Widget> children;

  /// 从水平排列的步骤中构建。
  List<Widget> _buildHorizontal(BuildContext context) {
    final scheme = context.wotScheme;
    final list = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      // 支持直接传 WotStep 或已由外部构造号的步骤。
      final WotStep step;
      if (child is WotStep) {
        step = child;
      } else {
        step = WotStep(index: i, active: active, data: WotStepData(title: '步骤${i + 1}'));
      }
      list.add(
        Expanded(
          child: onChange == null
              ? step
              : GestureDetector(
                  onTap: () => onChange!(i),
                  child: step,
                ),
        ),
      );
      if (i < children.length - 1) {
        list.add(
          Container(
            width: 16,
            height: 2,
            margin: const EdgeInsets.only(bottom: 16),
            color: i < active ? (activeColor ?? scheme.successMain) : scheme.borderMain,
          ),
        );
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;

    if (direction == WotStepsDirection.vertical) {
      final items = <Widget>[];
      for (var i = 0; i < children.length; i++) {
        final child = children[i];
        items.add(child is WotStep
            ? child
            : WotStep(index: i, active: active, data: WotStepData(title: '步骤${i + 1}')));
        if (i < children.length - 1) {
          items.add(
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Container(width: 2, height: 16, color: i < active ? (activeColor ?? scheme.successMain) : scheme.borderMain),
            ),
          );
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: items,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _buildHorizontal(context),
    );
  }
}