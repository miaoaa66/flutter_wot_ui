import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../../theme/wot_scheme.dart';
import '../icon/wot_icon.dart';

/// 悬浮按钮颜色（对齐 wot `type`）。
enum WotFabType { primary, success, info, warning, danger }

/// 悬浮按钮位置。
enum WotFabPosition { left, right, custom }

/// 悬浮按钮组件，对应 wot `wd-fab`。
///
/// 渲染一个带图标（可选文字）的可点击按钮；定位由外层 `Stack`/容器通过
/// [position]/[customPosition] 控制，或由调用方自行 `Positioned` 包裹。
class WotFab extends StatelessWidget {
  const WotFab({
    super.key,
    this.show = true,
    this.type = WotFabType.primary,
    this.position = WotFabPosition.right,
    this.customPosition,
    this.icon = 'add',
    this.text,
    this.label,
    this.labelHidden = false,
    this.iconColor = Colors.white,
    this.bgColor,
    this.onClick,
  });

  /// 是否展示（v-model:value / modelValue）。
  final bool show;

  /// 颜色类型。
  final WotFabType type;

  /// 位置（left/right/custom）。
  final WotFabPosition position;

  /// custom 位置时的偏移。
  final Offset? customPosition;

  /// 图标名。
  final String icon;

  /// 图标旁的文字（按钮扩展）。
  final String? text;

  /// 按钮外标签文字（显示在按钮外侧）。
  final String? label;

  /// 是否隐藏 [label]。
  final bool labelHidden;

  final Color iconColor;
  final Color? bgColor;

  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    final scheme = context.wotScheme;
    final color = bgColor ?? _colorOf(scheme, type);

    final button = Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onClick,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                WotIcon(name: icon, size: 22, color: iconColor),
                if (text != null) ...[
                  const SizedBox(width: 4),
                  Text(text!,
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // custom 位置：由上层 Stack 通过 Positioned 定位；此处仅当提供了 offset 时返回定位包装。
    if (position == WotFabPosition.custom && customPosition != null) {
      return Positioned(
        left: customPosition!.dx,
        top: customPosition!.dy,
        child: button,
      );
    }
    return button;
  }

  Color _colorOf(WotScheme scheme, WotFabType t) => switch (t) {
        WotFabType.success => scheme.successMain,
        WotFabType.info => scheme.textSecondary,
        WotFabType.warning => scheme.warningMain,
        WotFabType.danger => scheme.dangerMain,
        WotFabType.primary => scheme.primaryOf(6),
      };
}