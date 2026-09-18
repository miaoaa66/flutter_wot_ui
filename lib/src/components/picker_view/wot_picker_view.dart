import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 选择器单列选项。
class WotColumnOption {
  const WotColumnOption({
    required this.text,
    this.value,
    this.disabled = false,
    this.children = const [],
  });

  final String text;
  final Object? value;
  final bool disabled;

  /// 子级选项（级联场景）；非级联时为空。
  final List<WotColumnOption> children;

  /// 从任意 Map 建立选项，键名由 [valueKey] / [labelKey] / [childrenKey] 指定。
  factory WotColumnOption.fromMap(
    Map<dynamic, dynamic> map, {
    String valueKey = 'value',
    String labelKey = 'text',
    String childrenKey = 'children',
  }) {
    final rawChildren = map[childrenKey];
    return WotColumnOption(
      text: map[labelKey]?.toString() ?? '',
      value: map[valueKey],
      children: WotPickerViewOptions.listFrom(
        rawChildren,
        valueKey: valueKey,
        labelKey: labelKey,
        childrenKey: childrenKey,
      ),
    );
  }
}

/// 由原始 Map 数据构建选择器列（支持自定义键名与任意层级嵌套）。
class WotPickerViewOptions {
  const WotPickerViewOptions._();

  /// 把 [data] 转成 [WotColumnOption] 列表；[data] 元素可以是 Map 或 [WotColumnOption]。
  ///
  /// 键名可用 [valueKey] / [labelKey] / [childrenKey] 覆盖，用于对接
  /// `{id, name, subList}` 这类非默认结构的后端数据。
  static List<WotColumnOption> listFrom(
    Object? data, {
    String valueKey = 'value',
    String labelKey = 'text',
    String childrenKey = 'children',
  }) {
    if (data == null) return const [];
    if (data is! Iterable) return const [];
    final out = <WotColumnOption>[];
    for (final e in data) {
      if (e is WotColumnOption) {
        out.add(e);
      } else if (e is Map) {
        out.add(WotColumnOption.fromMap(
          e,
          valueKey: valueKey,
          labelKey: labelKey,
          childrenKey: childrenKey,
        ));
      }
    }
    return out;
  }
}

/// 单列滚轮（自绘，不引三方），作为 picker/picker-view/cascader/datetime 的公共底座。
class WotPickerColumn extends StatefulWidget {
  const WotPickerColumn({
    super.key,
    required this.options,
    required this.selectedIndex,
    this.onChange,
    double? height,
    this.itemExtent = 40,
    this.visibleItemCount = 5,
    this.color,
    this.disabled = false,
  }) : height = height ?? itemExtent * visibleItemCount;

  final List<WotColumnOption> options;
  final int selectedIndex;
  final ValueChanged<int>? onChange;
  final double height;
  final double itemExtent;

  /// 可见行数；未显式传 [height] 时以 `itemExtent * visibleItemCount` 推断高度。
  final int visibleItemCount;
  final Color? color;
  final bool disabled;

  @override
  State<WotPickerColumn> createState() => _WotPickerColumnState();
}

class _WotPickerColumnState extends State<WotPickerColumn> {
  late FixedExtentScrollController _controller;
  int _current = 0;

  /// 拖动起点索引，用于推算松手时的滚动方向（正向 +1 / 反向 -1）。
  int _dragStartIndex = 0;

  /// 是否处于程序化同步中（初始化初值 / didUpdateWidget 跳转）。此时滚轮触发的
  /// `onSelectedItemChanged` 仅更新样式、不向父级汇报，避免在 build 阶段 setState。
  bool _syncing = true;

  @override
  void initState() {
    super.initState();
    _current = widget.selectedIndex.clamp(0, widget.options.length - 1);
    _dragStartIndex = _current;
    _controller = FixedExtentScrollController(initialItem: _current);
    // 初值对应的首次布局回调在 build 阶段触发，延后到帧末再解除抑制。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _syncing = false);
    });
  }

  @override
  void didUpdateWidget(WotPickerColumn old) {
    super.didUpdateWidget(old);
    if (widget.selectedIndex != _current) {
      _current = widget.selectedIndex;
      if (_controller.hasClients) {
        _syncing = true;
        _controller.jumpToItem(_current.clamp(0, widget.options.length - 1));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _syncing = false);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final highlight = widget.color ?? scheme.primaryOf(6);

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollStartNotification) {
                // 记录拖动起点，供松手时判断滚动方向。
                _dragStartIndex = _controller.selectedItem;
              } else if (n is ScrollEndNotification) {
                // 松手后若停在禁用项，沿滚动方向吸附到最近的可用项
                // （wot `disabled` 语义：禁止选中禁用项，但允许滚过它）。
                final settled = _controller.selectedItem;
                if (!_enabledAt(settled)) {
                  final dir = settled > _dragStartIndex
                      ? 1
                      : (settled < _dragStartIndex ? -1 : 1);
                  final target = _nearestEnabledFrom(settled, dir);
                  if (target != settled && _controller.hasClients) {
                    _controller.animateToItem(
                      target,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                }
              }
              return false;
            },
            child: ListWheelScrollView(
              controller: _controller,
              itemExtent: widget.itemExtent,
              physics: widget.disabled
                  ? const NeverScrollableScrollPhysics()
                  : const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (i) {
                // 拖动过程中可能短暂停在禁用项，仅更新显示、不在此时吸附；
                // 真正的吸附交给 ScrollEndNotification，从而保证能「滚过」
                // 禁用项到达下一个启用项（而非被拉回上一个启用项）。
                setState(() => _current = i);
                // 程序化同步或落在禁用项时不上报，避免父级在 build 阶段 setState
                // 以及把禁用值回传。
                if (!_syncing && _enabledAt(i)) widget.onChange?.call(i);
              },
            useMagnifier: true,
            magnification: 1.1,
            overAndUnderCenterOpacity: 0.4,
            children: [
              for (final o in widget.options)
                Center(
                  child: Container(
                    height: widget.itemExtent,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: iIsSelected(widget.options.indexOf(o))
                        ? BoxDecoration(
                            // 选中项药丸背景与文字同框，保证高亮与文字天然对齐。
                            color: highlight.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Text(
                      o.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: iIsSelected(widget.options.indexOf(o))
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: o.disabled
                            ? scheme.textDisabled
                            : (iIsSelected(widget.options.indexOf(o))
                                ? highlight
                                : scheme.textAuxiliary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          ),
        ],
      ),
    );
  }

  bool iIsSelected(int i) => i == _current || i == widget.selectedIndex;

  bool _enabledAt(int i) =>
      i >= 0 && i < widget.options.length && !widget.options[i].disabled;

  /// 从 [from] 出发，沿滚动方向 [dir]（+1 正向 / -1 反向）优先寻找最近的未禁用项；
  /// 该方向无可用项时再搜索反方向；整列都禁用时返回 [from]。
  int _nearestEnabledFrom(int from, int dir) {
    if (_enabledAt(from)) return from;
    final n = widget.options.length;
    for (var d = 1; d < n; d++) {
      if (dir >= 0) {
        if (_enabledAt(from + d)) return from + d;
        if (_enabledAt(from - d)) return from - d;
      } else {
        if (_enabledAt(from - d)) return from - d;
        if (_enabledAt(from + d)) return from + d;
      }
    }
    return from;
  }
}

/// 单列滚轮便捷封装（隐藏内部索引状态，直接回调选中项 value）。
class WotPickerViewColumn extends StatelessWidget {
  const WotPickerViewColumn({
    super.key,
    required this.options,
    required this.value,
    required this.onChange,
    this.color,
    double? height,
    this.itemExtent = 40,
    this.visibleItemCount = 5,
    this.disabled = false,
    this.loading = false,
  }) : height = height ?? itemExtent * visibleItemCount;

  final List<WotColumnOption> options;
  final Object? value;
  final ValueChanged<Object?> onChange;
  final Color? color;
  final double height;
  final double itemExtent;

  /// 可见行数；未显式传 [height] 时以 `itemExtent * visibleItemCount` 推断高度。
  final int visibleItemCount;
  final bool disabled;

  /// 是否显示加载中状态（禁用交互并覆盖加载动画）。
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final idx = options.indexWhere((o) => o.value == value);
    final start = idx >= 0 ? idx : 0;
    // 列通常被放在 Row/Expanded 内（已有界宽），直接尺寸填满即可；
    // 不要用 UnconstrainedBox，否则 SizedBox(width: Infinity) 会触发 infinite width。
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
          children: [
            WotPickerColumn(
              options: options,
              selectedIndex: start,
              height: height,
              itemExtent: itemExtent,
              visibleItemCount: visibleItemCount,
              color: color,
              disabled: disabled || loading,
              onChange: (i) {
                if (i >= 0 && i < options.length) onChange(options[i].value!);
              },
            ),
            if (loading)
              Positioned.fill(
                child: ColoredBox(
                  color: context.wotScheme.filledBottom.withValues(alpha: 0.5),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),
              ),
          ],
        ),
    );
  }
}

/// 多列滚轮选择器（基础视图），对应 wot `wd-picker-view`。
class WotPickerView extends StatelessWidget {
  const WotPickerView({
    super.key,
    required this.columns,
    required this.values,
    required this.onChange,
    this.color,
    double? height,
    this.itemExtent = 40,
    this.visibleItemCount = 5,
    this.disabled = false,
    this.loading = false,
  }) : height = height ?? itemExtent * visibleItemCount;

  /// 每列的选项列表（二维数组，按列顺序展示各列滚轮）。
  final List<List<WotColumnOption>> columns;

  /// 当前选中值列表（每列一个值），作为 `modelValue` 受控。
  final List<Object?> values;

  /// 选中值变化回调（滚动联动时用整列值列表回调）。
  final ValueChanged<List<Object?>> onChange;

  /// 选中高亮/箭头主题色；不传时用主题主色。
  final Color? color;

  /// 滚轮可视高度；未显式传入时按「itemExtent × visibleItemCount」推断。
  ///
  /// 默认值与原先硬编码的 200 一致（40 × 5），因此不改变既有调用的效果。
  final double height;

  /// 单行高度；会透传给 [WotPickerViewColumn]。
  final double itemExtent;

  /// 可见行数；会透传给 [WotPickerViewColumn]。
  final int visibleItemCount;

  /// 是否禁用全部滚轮交互。
  final bool disabled;

  /// 是否显示加载中状态（覆盖加载动画并禁用交互）。
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var c = 0; c < columns.length; c++)
          Expanded(
            child: WotPickerViewColumn(
              options: columns[c],
              value: c < values.length ? values[c] : null,
              color: color,
              height: height,
              itemExtent: itemExtent,
              visibleItemCount: visibleItemCount,
              disabled: disabled,
              loading: loading,
              onChange: (v) {
                final next = [...values];
                while (next.length <= c) {
                  next.add(null);
                }
                next[c] = v;
                onChange(next);
              },
            ),
          ),
      ],
    );
  }
}

/// 便捷：由文本列表建选项。
List<WotColumnOption> wotOptions(List<Object> texts) => [
      for (final t in texts)
        WotColumnOption(text: t.toString(), value: t),
    ];

/// 便捷：找到最小内的索引（供外部换算）。
int wotIndexListIndex<T>(List<T> list, T value) => list.indexOf(value);