import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 空状态占位，对应 wot `wd-empty`。
class WotEmpty extends StatelessWidget {
  const WotEmpty({
    super.key,
    this.image,
    this.description,
    this.descriptionColor,
    this.imageSize = 80,
    this.imageContent,
    this.footer,
  });

  /// 自定义图片地址（网络图）；为空时用占位图标。
  final String? image;
  final String? description;
  final Color? descriptionColor;
  final double imageSize;

  /// 自定义图片 widget。
  final Widget? imageContent;

  /// 底部操作区。
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final img = imageContent ??
        (image != null && image!.isNotEmpty
            ? Image.network(image!, width: imageSize, height: imageSize, fit: BoxFit.contain)
            : WotIcon(name: 'empty', size: imageSize, color: scheme.iconDisabled));

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
        if (footer != null) ...[
          const SizedBox(height: 12),
          footer!,
        ],
      ],
    );
  }
}