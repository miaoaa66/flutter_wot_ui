import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../../theme/wot_scheme.dart';
import '../icon/wot_icon.dart';
import 'wot_image_preview.dart';

/// 图片填充模式，对齐 wot `wd-img` 的 `mode`（同 uni-app image mode）。
enum WotImgMode {
  scaleToFill,
  aspectFit,
  aspectFill,
  widthFix,
  top,
  bottom,
  center,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// 图片，对应 wot `wd-img`。
///
/// 参数对齐 wot：`src`、`mode`、`width`、`height`、`radius`、`round`、
/// `error`（加载失败自定义内容）、`loading`（加载中自定义内容）、`preview`（点击是否预览原始图）、
/// `onClick`。
class WotImg extends StatelessWidget {
  const WotImg({
    super.key,
    this.src,
    this.mode = WotImgMode.aspectFit,
    this.width,
    this.height,
    this.radius = 0,
    this.round = false,
    this.error,
    this.loading,
    this.preview = false,
    this.previewList,
    this.onClick,
  });

  final String? src;

  /// 填充模式，对应 wot `mode`。
  final WotImgMode mode;

  final double? width;
  final double? height;

  /// 圆角半径；`round` 为 true 时覆盖为圆形。
  final double radius;

  final bool round;

  /// 加载失败占位（默认显示 error 图标）。
  final Widget? error;

  /// 加载中占位（默认灰色底）。
  final Widget? loading;

  /// 点击是否触发图片预览。
  final bool preview;

  /// 预览图片列表（含原始图链接）；为空时用 [src] 单图预览。
  final List<String>? previewList;

  final VoidCallback? onClick;

  BoxFit get _fit => switch (mode) {
        WotImgMode.scaleToFill => BoxFit.fill,
        WotImgMode.aspectFit => BoxFit.contain,
        WotImgMode.aspectFill => BoxFit.cover,
        WotImgMode.widthFix => BoxFit.fitWidth,
        _ => BoxFit.contain,
      };

  Alignment get _align => switch (mode) {
        WotImgMode.top => Alignment.topCenter,
        WotImgMode.bottom => Alignment.bottomCenter,
        WotImgMode.center || WotImgMode.aspectFit || WotImgMode.aspectFill => Alignment.center,
        WotImgMode.left => Alignment.centerLeft,
        WotImgMode.right => Alignment.centerRight,
        WotImgMode.topLeft => Alignment.topLeft,
        WotImgMode.topRight => Alignment.topRight,
        WotImgMode.bottomLeft => Alignment.bottomLeft,
        WotImgMode.bottomRight => Alignment.bottomRight,
        _ => Alignment.center,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;

    final box = Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.filledStrong,
        borderRadius: BorderRadius.circular(round ? (width ?? height ?? 16) / 2 : radius),
      ),
      alignment: _align,
      child: src == null || src!.isEmpty
          ? (error ?? _errorSlot(scheme))
          : Image.network(
              src!,
              width: width ?? double.infinity,
              height: height,
              fit: _fit,
              alignment: _align,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return loading ?? _loadingSlot(scheme);
              },
              errorBuilder: (_, _, _) => error ?? _errorSlot(scheme),
            ),
    );

    Widget result = box;
    if (preview || onClick != null) {
      result = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onClick?.call();
          if (preview) {
            final urls = previewList ?? [if (src != null && src!.isNotEmpty) src!];
            if (urls.isNotEmpty) WotImagePreview.show(urls, context: context);
          }
        },
        child: box,
      );
    }
    return result;
  }

  Widget _loadingSlot(WotScheme scheme) {
    return Container(
      width: width,
      height: height,
      color: scheme.filledStrong,
      child: Center(child: WotIcon(name: 'image', size: 24, color: scheme.iconDisabled)),
    );
  }

  Widget _errorSlot(WotScheme scheme) {
    return Container(
      width: width,
      height: height,
      color: scheme.filledStrong,
      child: Center(child: WotIcon(name: 'error', size: 24, color: scheme.iconDisabled)),
    );
  }
}