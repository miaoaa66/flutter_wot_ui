import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 回到顶部，对应 wot `wd-backtop`。
///
/// 通过 [show] 控制显隐（v-model:value）；定位由外层 `Stack`/容器处理。
/// 也可配合 [ensureVisible] 由外部调用滚回顶部。
class WotBacktop extends StatelessWidget {
  const WotBacktop({
    super.key,
    this.show = true,
    this.tip,
    this.color,
    this.bottom,
    this.right,
    this.onClick,
  });

  /// 是否显示（v-model:value）。
  final bool show;

  /// 提示文案（可选）。
  final String? tip;

  /// 图标颜色。
  final Color? color;

  /// 距底部距离（由外层 Stack 定位时可选）。
  final double? bottom;

  /// 距右侧距离（由外层 Stack 定位时可选）。
  final double? right;

  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    final scheme = context.wotScheme;
    final fg = color ?? scheme.primaryOf(6);

    final btn = Material(
      color: scheme.filledContent,
      elevation: 3,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onClick,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WotIcon(name: 'arrow-up', size: 16, color: fg),
                if (tip != null)
                  Text(
                    tip!,
                    style: TextStyle(fontSize: 9, color: fg, height: 1.1),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (bottom == null && right == null) return btn;
    return Positioned(
      right: right ?? 10,
      bottom: bottom ?? 24,
      child: btn,
    );
  }
}