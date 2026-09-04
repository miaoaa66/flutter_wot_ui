import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 空状态占位，对应 wot `wd-empty`。
class WotEmpty extends StatelessWidget {
  const WotEmpty({
    super.key,
    this.icon = 'empty',
    this.image,
    this.description,
    this.descriptionColor,
    this.imageSize = 80,
    this.imageContent,
    this.footer,
    this.children,
  });

  /// 缺省图标名称（wot icon），默认 `empty`；仅在未传入 [image]/[imageContent] 时生效。
  final String? icon;

  /// 自定义图片地址（网络图）；为空时用占位图标。
  final String? image;

  /// 提示文案。
  final String? description;

  /// 提示文案颜色；为空时取主题次要文字色。
  final Color? descriptionColor;

  /// 图片/图标尺寸（逻辑像素），默认 80。
  final double imageSize;

  /// 自定义图片 widget，优先级最高，覆盖 [image]/[icon] 的占位渲染。
  final Widget? imageContent;

  /// 底部操作区；与 [children] 等效，同时传入时以 [children] 为准。
  final Widget? footer;

  /// 底部自定义内容（wot `bottom` 插槽）；与 [footer] 等效，优先级更高。
  final Widget? children;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final bottomSlot = children ?? footer;
    final img = imageContent ??
        (image != null && image!.isNotEmpty
            ? Image.network(image!, width: imageSize, height: imageSize, fit: BoxFit.contain)
            : WotIcon(name: icon ?? 'empty', size: imageSize, color: scheme.iconDisabled));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        img,
        if (description != null) ...[
          const SizedBox(height: 12),
          Text(
            description!,
            style: TextStyle(
              fontSize: 14,
              color: descriptionColor ?? scheme.textAuxiliary,
            ),
          ),
        ],
        if (bottomSlot != null) ...[
          const SizedBox(height: 12),
          bottomSlot,
        ],
      ],
    );
  }
}