import 'package:flutter/material.dart';

/// 图片预览服务（命令式），对应 wot `useImagePreview`。
class WotImagePreview {
  const WotImagePreview._();

  /// 打开图片预览全屏展示，当前图显示 initialIndex 张。
  static Future<void> show(
    List<String> urls, {
    int initialIndex = 0,
    BuildContext? context,
  }) async {
    final ctx = context;
    if (ctx == null) return;
    return Navigator.of(ctx, rootNavigator: true).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _PreviewPage(urls: urls, initialIndex: initialIndex),
      ),
    );
  }

  /// 关闭当前预览。
  static void close(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class _PreviewPage extends StatefulWidget {
  const _PreviewPage({required this.urls, this.initialIndex = 0});

  final List<String> urls;
  final int initialIndex;

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
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => WotImagePreview.close(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _page,
              onPageChanged: (i) => setState(() => _current = i),
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
                bottom: 40,
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
                          color: i == _current ? Colors.white : Colors.white.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}