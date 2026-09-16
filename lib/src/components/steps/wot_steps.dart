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

/// 步骤圆点（序号/完成勾 + 状态色），供 [WotStep] 与横向 [WotSteps] 复用。
class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.index,
    required this.active,
    this.status = WotStepDataStatus.waiting,
    this.activeColor,
    this.inactiveColor,
  });

  final int index;
  final int active;
  final WotStepDataStatus status;
  final Color? activeColor;
  final Color? inactiveColor;

  /// [WotStepDataStatus.waiting] 视为「未显式指定」，仍按 [active] 索引推导，
  /// 以保证既有用法的表现不变。
  bool get _explicit => status != WotStepDataStatus.waiting;
  bool get _error => status == WotStepDataStatus.error;
  bool get _done =>
      status == WotStepDataStatus.finished || (!_explicit && index < active);
  bool get _current =>
      status == WotStepDataStatus.process || (!_explicit && index == active);

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final color = _error
        ? scheme.dangerMain
        : _done
            ? (activeColor ?? scheme.successMain)
            : _current
                ? (activeColor ?? scheme.primaryOf(6))
                : (inactiveColor ?? scheme.textDisabled);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: _error
          ? const Icon(Icons.close, size: 14, color: Colors.white)
          : _done
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _current || _done ? Colors.white : scheme.textSecondary,
                  ),
                ),
    );
  }
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

  /// 步骤项索引（从 0 开始）。
  final int index;

  /// 当前激活步骤索引。
  final int active;

  /// 步骤项数据（标题/描述/状态）。
  final WotStepData data;

  /// 激活/已完成步骤颜色，默认使用主题主色/成功色。
  final Color? activeColor;

  /// 未激活步骤颜色，默认使用主题禁用文本色。
  final Color? inactiveColor;

  /// 点击步骤回调。
  final VoidCallback? onClick;

  bool get _done => index < active;
  bool get _current => index == active;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;

    final circle = SizedBox(
      width: 24,
      height: 24,
      child: _StepCircle(
        index: index,
        active: active,
        status: data.status,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
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

  /// 当前激活步骤索引，默认 0。
  final int active;

  /// 排列方向：horizontal（水平）/vertical（垂直），默认 horizontal。
  final WotStepsDirection direction;

  /// 激活/已完成步骤颜色，默认使用主题主色/成功色。
  final Color? activeColor;

  /// 未激活步骤颜色，默认使用主题禁用文本色。
  final Color? inactiveColor;

  /// 点击步骤回调，参数为步骤索引。
  final ValueChanged<int>? onChange;

  /// 步骤项列表（可为 [WotStep] 或普通 [Widget]）。
  final List<Widget> children;

  /// 将第 [index] 个步骤子项（[WotStep] 或普通 [Widget]）物化为带正确
  /// 状态参数的 [WotStep]，确保序号/激活色/完成色由 [WotSteps] 统一下发。
  WotStep _stepFor(int index, Widget child) {
    final WotStepData data;
    if (child is WotStep) {
      data = child.data;
    } else {
      data = WotStepData(title: '步骤${index + 1}');
    }
    return WotStep(
      index: index,
      active: active,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      data: data,
    );
  }

  /// 从水平排列的步骤中构建：每步一个等宽 [Expanded] 列，
  /// 圆点两侧各一条连接线横向延伸到列边界，相邻列线相接成连续线并与圆点同一水平线。
  List<Widget> _buildHorizontal(BuildContext context) {
    final scheme = context.wotScheme;
    // 第 idx 段连接线（连接第 idx 与 idx+1 个圆点）的颜色：idx 已激活则用激活色，否则边框色。
    Color seg(int idx) =>
        idx < active ? (activeColor ?? scheme.successMain) : scheme.borderMain;

    final list = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      final data = children[i] is WotStep
          ? (children[i] as WotStep).data
          : WotStepData(title: '步骤${i + 1}');
      final isDone = i < active;
      final isCurrent = i == active;

      final column = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 圆点左段连接线（首步无左侧线，但保留等宽以让圆点水平居中）。
              Expanded(
                child: i == 0
                    ? const SizedBox.shrink()
                    : Container(height: 2, color: seg(i - 1)),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: _StepCircle(
                  index: i,
                  active: active,
                  status: data.status,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ),
              // 圆点右段连接线（末步无右侧线）。
              Expanded(
                child: i == children.length - 1
                    ? const SizedBox.shrink()
                    : Container(height: 2, color: seg(i)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: data.status == WotStepDataStatus.error
                        ? scheme.dangerMain
                        : (isCurrent || isDone
                            ? scheme.textMain
                            : scheme.textDisabled),
                  ),
                ),
                if (data.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    data.description!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: scheme.textAuxiliary),
                  ),
                ],
              ],
            ),
          ),
        ],
      );

      list.add(
        Expanded(
          child: onChange == null
              ? column
              : GestureDetector(onTap: () => onChange!(i), child: column),
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;

    if (direction == WotStepsDirection.vertical) {
      final items = <Widget>[];
      for (var i = 0; i < children.length; i++) {
        items.add(_stepFor(i, children[i]));
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

    // 横向：每个步骤一个等宽 [Expanded] 列平铺，圆点行顶对齐。
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildHorizontal(context),
    );
  }
}