import 'package:flutter/material.dart';

/// 图片预览指示器位置，对应 wot `closeIconPosition`/指示器 top/bottom。
enum WotImagePreviewIndicatorPosition { top, bottom }

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
    this.onChange,
    this.onOpen,
  });

  final List<String> urls;
  final int initialIndex;
  final WotImagePreviewIndicatorPosition indicatorPosition;
  final bool showIndex;
  final bool closeOnClickOverlay;
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
    widget.onOpen?.call();
    _page = PageController(initialPage: widget.initialIndex);
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
            if (widget.urls.length > 1)
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
          ],
        ),
      ),
    );
  }
}