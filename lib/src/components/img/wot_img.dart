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
    this.placeholder,
    this.preview = false,
    this.previewList,
    this.lazyLoad = false,
    this.fit,
    this.onLoad,
    this.onError,
    this.onClick,
  });

  /// 图片链接。
  final String? src;

  /// 填充模式，对应 wot `mode`。
  final WotImgMode mode;

  /// 图片宽度（逻辑像素），不传时撑满容器。
  final double? width;

  /// 图片高度（逻辑像素）。
  final double? height;

  /// 圆角半径；`round` 为 true 时覆盖为圆形。
  final double radius;

  /// 是否显示为圆形；开启后半径取宽高较大者的一半。
  final bool round;

  /// 加载失败占位（默认显示 error 图标）。
  final Widget? error;

  /// 加载中占位（默认灰色底）。
  final Widget? loading;

  /// 加载中占位（与 [loading] 作用一致，优先取 [loading]）。
  final Widget? placeholder;

  /// 点击是否触发图片预览。
  final bool preview;

  /// 预览图片列表（含原始图链接）；为空时用 [src] 单图预览。
  final List<String>? previewList;

  /// 是否开启图片懒加载：渲染到屏幕后再发起网络请求，默认 false。
  final bool lazyLoad;

  /// 图片填充方式；为空时按 [mode] 推导（对齐 wot `fill` 语义）。
  final BoxFit? fit;

  /// 图片加载完成回调。
  final VoidCallback? onLoad;

  /// 图片加载失败回调。
  final VoidCallback? onError;

  /// 点击图片时回调；同时会触发预览（若 [preview] 为 true）。
  final VoidCallback? onClick;

  BoxFit get _fit => fit ?? switch (mode) {
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
          : _networkImage(scheme),
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

  Widget _networkImage(WotScheme scheme) {
    final Widget? loadSlot;
    if (loading != null || placeholder != null) {
      loadSlot = loading ?? placeholder;
    } else {
      loadSlot = _loadingSlot(scheme);
    }
    return _WotNetworkImage(
      src: src!,
      width: width ?? double.infinity,
      height: height,
      fit: _fit,
      alignment: _align,
      lazyLoad: lazyLoad,
      loadPlaceholder: loadSlot,
      errorPlaceholder: error ?? _errorSlot(scheme),
      onLoad: onLoad,
      onError: onError,
    );
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

/// 网络图片：处理加载中/失败占位、加载完成/失败事件，并支持懒加载。
class _WotNetworkImage extends StatefulWidget {
  const _WotNetworkImage({
    required this.src,
    this.width,
    this.height,
    required this.fit,
    required this.alignment,
    this.lazyLoad = false,
    this.loadPlaceholder,
    this.errorPlaceholder,
    this.onLoad,
    this.onError,
  });

  final String src;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final bool lazyLoad;
  final Widget? loadPlaceholder;
  final Widget? errorPlaceholder;
  final VoidCallback? onLoad;
  final VoidCallback? onError;

  @override
  State<_WotNetworkImage> createState() => _WotNetworkImageState();
}

class _WotNetworkImageState extends State<_WotNetworkImage> {
  late bool _visible;
  bool _loaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _visible = !widget.lazyLoad;
    if (widget.lazyLoad) {
      // 渲染后再发起请求，从而延迟图片网络加载。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  @override
  void didUpdateWidget(covariant _WotNetworkImage old) {
    super.didUpdateWidget(old);
    if (old.src != widget.src) {
      _loaded = false;
      _failed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.loadPlaceholder ?? const SizedBox.shrink();
    return Image.network(
      widget.src,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          if (!_loaded) {
            _loaded = true;
            widget.onLoad?.call();
          }
          return child;
        }
        return widget.loadPlaceholder ?? child;
      },
      errorBuilder: (_, _, _) {
        if (!_failed) {
          _failed = true;
          widget.onError?.call();
        }
        return widget.errorPlaceholder ?? const SizedBox.shrink();
      },
    );
  }
}