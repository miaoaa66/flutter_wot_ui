import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../../theme/wot_scheme.dart';

/// 标签页项，对应 wot `wd-tab`。须作为 [WotTabs] 的直接子级。
class WotTab extends StatelessWidget {
  const WotTab({
    super.key,
    this.title,
    this.label,
    this.disabled = false,
    this.name,
    required this.child,
  });

  /// 标题文本。
  final String? title;

  /// 角标（如数字/文案）。
  final String? label;

  /// 禁用。
  final bool disabled;

  /// 唯一标识（可选）。
  final String? name;

  /// 面板内容（未懒加载时，非激活项仅隐藏）。
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// 标签页组件，对应 wot `wd-tabs`。
///
/// 支持 `type`（line/card）、`grow`（均分）、颜色与指示器样式参数。
/// 通过 [modelValue]/[onChange] 受控（v-model，索引）。
class WotTabs extends StatefulWidget {
  const WotTabs({
    super.key,
    this.modelValue = 0,
    this.onChange,
    this.type = 'line',
    this.color,
    this.inactiveColor,
    this.activeColor,
    this.grow = true,
    this.lineWidth,
    this.lineColor,
    this.animated = false,
    required this.children,
  });

  /// 当前激活索引（v-model:value）。
  final int modelValue;

  final ValueChanged<int>? onChange;

  /// Tabs 样式：line（下划线）/ card（卡片式高亮）。
  final String type;

  /// 主色（指示器/激活色基底）。
  final Color? color;

  /// 未激活项文字色。
  final Color? inactiveColor;

  /// 激活项文字色。
  final Color? activeColor;

  /// 是否均分占满宽度。
  final bool grow;

  /// 指示器宽度。
  final double? lineWidth;

  /// 指示器颜色。
  final Color? lineColor;

  /// 是否内容切换动画。
  final bool animated;

  final List<WotTab> children;

  @override
  State<WotTabs> createState() => _WotTabsState();
}

class _WotTabsState extends State<WotTabs> {
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.modelValue;
  }

  @override
  void didUpdateWidget(WotTabs old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) {
      _current = widget.modelValue;
    }
  }

  void _select(int index) {
    if (index == _current) return;
    if (widget.children[index].disabled) return;
    setState(() => _current = index);
    widget.onChange?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = widget.color ?? scheme.primaryOf(6);
    final activeColor = widget.activeColor ?? primary;
    final inactiveColor = widget.inactiveColor ?? scheme.textSecondary;
    final count = widget.children.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(scheme, activeColor, inactiveColor, primary, count),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              for (var i = 0; i < count; i++)
                if (i == _current)
                  widget.children[i]
                else
                  const Offstage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(WotScheme scheme, Color activeColor, Color inactiveColor,
      Color primary, int count) {
    final isCard = widget.type == 'card';
    final items = <Widget>[
      for (var i = 0; i < count; i++)
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.children[i].disabled ? null : () => _select(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: isCard
                  ? BoxDecoration(
                      color: i == _current ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: i == _current ? primary : scheme.borderLight,
                      ),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.children[i].title ?? widget.children[i].name ?? 'Tab $i',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.children[i].disabled
                          ? scheme.textDisabled
                          : (i == _current ? activeColor : inactiveColor),
                      fontSize: 14,
                      fontWeight: i == _current ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (widget.children[i].label != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.children[i].label!,
                      style: TextStyle(fontSize: 10, color: scheme.textAuxiliary),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
    ];

    if (isCard) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Row(children: items),
      );
    }

    // line 样式：Header + 底部指示器。
    final lineColor = widget.lineColor ?? primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cell = count > 0 ? width / count : width;
        final indicatorWidth = widget.lineWidth ?? (cell * 0.6).clamp(16.0, 48.0);
        return SizedBox(
          height: 52,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(bottom: 0, child: Row(children: items)),
              // 指示器。
              AnimatedPositioned(
                duration: widget.animated
                    ? const Duration(milliseconds: 200)
                    : Duration.zero,
                curve: Curves.easeOut,
                left: cell * _current + (cell - indicatorWidth) / 2,
                bottom: 0,
                width: indicatorWidth,
                height: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}