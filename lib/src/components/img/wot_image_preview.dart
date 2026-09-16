import 'package:flutter/material.dart';

/// 图片预览指示器位置，对应 wot `closeIconPosition`/指示器 top/bottom。
enum WotImagePreviewIndicatorPosition { top, bottom }

/// 关闭按钮位置，对应 wot `closeIconPosition`。
enum WotImagePreviewClosePosition {
  /// 左上角（wot 默认）。
  topLeft,

  /// 右上角。
  topRight,

  /// 左下角。
  bottomLeft,

  /// 右下角。
  bottomRight,
}

/// 图片预览服务（命令式），对应 wot `useImagePreview`。
class WotImagePreview {
  const WotImagePreview._();

  /// 打开图片预览全屏展示，当前图显示 initialIndex 张。
  ///
  /// [indicatorPosition] 控制指示器/页码位置；[showIndex] 是否显示页码；
  /// [closeOnClickOverlay] 是否点击图片或遮罩时关闭（默认 true）；
  /// [onChange] 在切换图片时回调当前索引。
  static Future<void> show(
    List<String> urls, {
    int initialIndex = 0,
    BuildContext? context,
    WotImagePreviewIndicatorPosition indicatorPosition =
        WotImagePreviewIndicatorPosition.bottom,
    bool showIndex = true,
    bool closeOnClickOverlay = true,
    bool closeable = true,
    WotImagePreviewClosePosition closeIconPosition =
        WotImagePreviewClosePosition.topLeft,
    ValueChanged<int>? onChange,
    void Function()? onOpen,
    void Function()? onClose,
  }) async {
    final ctx = context;
    if (ctx == null) return;
    await Navigator.of(ctx, rootNavigator: true)
        .push<void>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => _PreviewPage(
              urls: urls,
              initialIndex: initialIndex,
              indicatorPosition: indicatorPosition,
              showIndex: showIndex,
              closeOnClickOverlay: closeOnClickOverlay,
              closeable: closeable,
              closeIconPosition: closeIconPosition,
              onChange: onChange,
              onOpen: onOpen,
            ),
          ),
        );
    onClose?.call();
  }

  /// 关闭当前预览。
  static void close(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class _PreviewPage extends StatefulWidget {
  const _PreviewPage({
    required this.urls,
    this.initialIndex = 0,
    this.indicatorPosition = WotImagePreviewIndicatorPosition.bottom,
    this.showIndex = true,
    this.closeOnClickOverlay = true,
    this.closeable = true,
    this.closeIconPosition = WotImagePreviewClosePosition.topLeft,
    this.onChange,
    this.onOpen,
  });

  final List<String> urls;
  final int initialIndex;
  final WotImagePreviewIndicatorPosition indicatorPosition;
  final bool showIndex;
  final bool closeOnClickOverlay;

  /// 是否显示右上角/指定角的关闭按钮，默认 true。
  final bool closeable;

  /// 关闭按钮位置，默认 [WotImagePreviewClosePosition.topLeft]。
  final WotImagePreviewClosePosition closeIconPosition;
  final ValueChanged<int>? onChange;
  final VoidCallback? onOpen;

  @override
  State<_PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<_PreviewPage> {
  late PageController _page;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _page = PageController(initialPage: widget.initialIndex);
    // 路由页面是在 Navigator 的 buildScope 内挂载的，此时同步回调 onOpen
    // 会让调用方的 setState 撞上「setState() called during build」。
    // 因此延后到本帧构建结束后再发出（与 WotImg 的 _notify 同一处理）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onOpen?.call();
    });
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _onChanged(int i) {
    setState(() => _current = i);
    widget.onChange?.call(i);
  }

  @override
  Widget build(BuildContext context) {
    final indicator = widget.showIndex && widget.urls.length > 1
        ? Positioned(
            top: widget.indicatorPosition == WotImagePreviewIndicatorPosition.top
                ? MediaQuery.of(context).padding.top + 16
                : null,
            bottom:
                widget.indicatorPosition == WotImagePreviewIndicatorPosition.top
                    ? null
                    : MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.urls.length; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color:
                          i == _current ? Colors.white : Colors.white.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          )
        : const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: widget.closeOnClickOverlay ? () => WotImagePreview.close(context) : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _page,
              onPageChanged: _onChanged,
              itemCount: widget.urls.length,
              itemBuilder: (_, i) {
                final url = widget.urls[i];
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3,
                  child: Center(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(Icons.broken_image, size: 48, color: Colors.white54),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (widget.showIndex && widget.urls.length > 1)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_current + 1}/${widget.urls.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            indicator,
            if (widget.closeable) _closeButton(),
          ],
        ),
      ),
    );
  }

  /// 关闭按钮：位于 [WotImagePreviewClosePosition] 指定的角落，自动避让状态栏/安全区。
  Widget _closeButton() {
    final pad = MediaQuery.of(context).padding;
    final double top;
    final double bottom;
    final double? left;
    final double? right;
    switch (widget.closeIconPosition) {
      case WotImagePreviewClosePosition.topLeft:
        top = pad.top + 8;
        bottom = double.infinity;
        left = 8;
        right = null;
      case WotImagePreviewClosePosition.topRight:
        top = pad.top + 8;
        bottom = double.infinity;
        left = null;
        right = 8;
      case WotImagePreviewClosePosition.bottomLeft:
        top = double.infinity;
        bottom = pad.bottom + 12;
        left = 8;
        right = null;
      case WotImagePreviewClosePosition.bottomRight:
        top = double.infinity;
        bottom = pad.bottom + 12;
        left = null;
        right = 8;
    }
    return Positioned(
      top: top == double.infinity ? null : top,
      bottom: bottom == double.infinity ? null : bottom,
      left: left,
      right: right,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => WotImagePreview.close(context),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}