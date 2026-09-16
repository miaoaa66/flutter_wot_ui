import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../form/wot_form.dart';

/// 评分，对应 wot `wd-rate`。受控（v-model:value，0~`count`）。
class WotRate extends StatelessWidget {
  const WotRate({
    super.key,
    this.modelValue = 0,
    this.onChange,
    this.count = 5,
    this.size = 24,
    this.color,
    this.activeColor,
    this.gutter = 8,
    this.icon,
    this.activeIcon,
    this.readonly = false,
    this.disabled = false,
    this.allowHalf = false,
    this.name,
  });

  /// 当前评分值，0~[count]，受控（v-model）。支持 0.5 步进（半选）。
  final double modelValue;

  /// 评分变化回调。
  final ValueChanged<double>? onChange;

  /// 图标总数，默认 5。
  final int count;

  /// 图标尺寸，默认 24。
  final double size;

  /// 未选中图标颜色（`voidColor`），默认使用主题描边浅色。
  final Color? color;

  /// 已选中图标颜色（`activeColor`），默认使用主题警示色。
  final Color? activeColor;

  /// 图标间距，默认 8。
  final double gutter;

  /// 未选中图标（`voidIcon`），缺省使用星形图标。
  final IconData? icon;

  /// 已选中图标（`activeIcon`），缺省使用星形图标。
  final IconData? activeIcon;

  /// 是否只读，默认 false。
  final bool readonly;

  /// 是否禁用，默认 false。
  final bool disabled;

  /// 是否允许半选（半星显示），默认 false。
  final bool allowHalf;

  /// 表单字段名（用于原生表单提交示例）。
  final String? name;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final active = activeColor ?? scheme.warningMain;
    final inactive = color ?? scheme.borderLight;
    final voidIcon = icon ?? Icons.star;
    final activeIconData = activeIcon ?? Icons.star;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= count; i++) ...[
          if (i > 1) SizedBox(width: gutter),
          _StarTapArea(
            index: i,
            size: size,
            allowHalf: allowHalf,
            readonly: readonly,
            disabled: disabled,
            onChange: (v) {
              wotFormPushValue(context, name, v);
              onChange?.call(v);
            },
            child: _Star(
              size: size,
              icon: voidIcon,
              activeIcon: activeIconData,
              activeColor: active,
              inactiveColor: inactive,
              filled: modelValue >= i,
              half: allowHalf && modelValue > i - 1 && modelValue < i,
            ),
          ),
        ],
      ],
    );
  }
}

/// 单个星星的点击区域，处理半选逻辑。
class _StarTapArea extends StatelessWidget {
  const _StarTapArea({
    required this.index,
    required this.size,
    required this.allowHalf,
    required this.readonly,
    required this.disabled,
    required this.onChange,
    required this.child,
  });

  final int index;
  final double size;
  final bool allowHalf;
  final bool readonly;
  final bool disabled;
  final ValueChanged<double>? onChange;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (readonly || disabled)
          ? null
          : (d) {
              if (allowHalf) {
                // 使用当前星星的 renderBox 计算局部坐标
                final box = context.findRenderObject() as RenderBox?;
                if (box != null) {
                  final local = box.globalToLocal(d.globalPosition);
                  final isLeftHalf = local.dx < size / 2;
                  final rv = isLeftHalf ? index - 0.5 : index.toDouble();
                  onChange?.call(rv);
                } else {
                  onChange?.call(index.toDouble());
                }
              } else {
                onChange?.call(index.toDouble());
              }
            },
      child: child,
    );
  }
}

/// 单个评分图标，支持整星填充与半星显示。
class _Star extends StatelessWidget {
  const _Star({
    required this.size,
    required this.icon,
    required this.activeIcon,
    required this.activeColor,
    required this.inactiveColor,
    required this.filled,
    required this.half,
  });

  final double size;
  final IconData icon;
  final IconData activeIcon;
  final Color activeColor;
  final Color inactiveColor;
  final bool filled;
  final bool half;

  @override
  Widget build(BuildContext context) {
    if (!filled && !half) {
      return Icon(icon, size: size, color: inactiveColor);
    }
    if (!half) {
      return Icon(activeIcon, size: size, color: activeColor);
    }
    // 半星：左侧半高亮，右侧保持未选中色。
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Icon(icon, size: size, color: inactiveColor),
          Align(
            alignment: Alignment.centerLeft,
            child: ClipRect(
              clipper: _HalfClipper(),
              child: Icon(activeIcon, size: size, color: activeColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// 裁剪左侧一半，用于半星显示。
class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width / 2, size.height);

  @override
  bool shouldReclip(_HalfClipper oldClipper) => false;
}
