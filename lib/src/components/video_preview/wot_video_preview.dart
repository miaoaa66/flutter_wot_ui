import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 视频预览关闭按钮位置，对齐 wot `close-position`（可选 `left-top`、`right-top`）。
enum WotVideoPreviewClosePosition { leftTop, rightTop }

/// 视频预览组件，对应 wot `wd-video-preview`。
///
/// 提供两种使用方式：
/// - **命令式**：调用 [WotVideoPreview.show] 全屏弹出视频预览层；
/// - **组件式**：将 [WotVideoPreview] 放入页面自渲染，可通过
///   [GlobalKey]&lt;[WotVideoPreviewState]&gt; 拿到 [WotVideoPreviewState] 调用
///   [WotVideoPreviewState.play] / [WotVideoPreviewState.pause] 控制播放。
///
/// 画面为黑底（[Colors.black]），其上控件使用白色图标/文字（[Colors.white]），
/// 其余 UI（如关闭按钮背景、上下渐变遮罩）使用 [BuildContext.wotScheme] 语义令牌。
class WotVideoPreview extends StatefulWidget {
  const WotVideoPreview({
    super.key,
    required this.src,
    this.title,
    this.poster,
    this.autoplay = false,
    this.loop = true,
    this.closePosition = WotVideoPreviewClosePosition.leftTop,
    this.onOpen,
    this.onClose,
  });

  /// 命令式全屏视频预览，对齐 wot `previewVideo`。
  ///
  /// - [src] 视频资源地址（必填）；
  /// - 默认 [autoplay] 为 true、[loop] 为 true（对齐 wot 原生 video 自动播放 + 循环）；
  /// - [onOpen] / [onClose] 分别在打开 / 关闭时触发。
  static Future<void> show(
    BuildContext context,
    String src, {
    String? title,
    String? poster,
    bool autoplay = true,
    bool loop = true,
    WotVideoPreviewClosePosition closePosition = WotVideoPreviewClosePosition.leftTop,
    VoidCallback? onOpen,
    VoidCallback? onClose,
  }) {
    onOpen?.call();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '视频预览',
      barrierColor: Colors.transparent,
      pageBuilder: (ctx, _, _) => WotVideoPreview(
        src: src,
        title: title,
        poster: poster,
        autoplay: autoplay,
        loop: loop,
        closePosition: closePosition,
        onClose: () {
          onClose?.call();
          Navigator.of(ctx, rootNavigator: true).pop();
        },
      ),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (_, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// 视频资源地址。
  final String src;

  /// 视频标题（可选），显示在顶部。
  final String? title;

  /// 视频封面地址（可选），初始化完成前显示。
  final String? poster;

  /// 是否自动播放；组件式默认 false，命令式 [show] 默认 true。
  final bool autoplay;

  /// 是否循环播放；默认 true。
  final bool loop;

  /// 关闭按钮位置；默认左上角。
  final WotVideoPreviewClosePosition closePosition;

  /// 打开时的回调。
  final VoidCallback? onOpen;

  /// 关闭时的回调。
  final VoidCallback? onClose;

  @override
  State<WotVideoPreview> createState() => WotVideoPreviewState();
}

/// [WotVideoPreview] 的状态，暴露播放控制方法。
///
/// 可通过 `final key = GlobalKey<WotVideoPreviewState>()` 取得本类型，
/// 调用 [play] / [pause] / [togglePlay] 进行命令式控制。
class WotVideoPreviewState extends State<WotVideoPreview> {
  /// 视频控制器，负责解码、播放与进度。
  late VideoPlayerController _controller;

  /// 是否处于加载失败状态（初始化抛错或 [VideoPlayerValue.hasError] 为 true）。
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    widget.onOpen?.call();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.src));
    _controller.addListener(_onControllerChanged);
    _init();
  }

  /// 初始化/（重试）重载视频并播放。
  Future<void> _init() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      if (_controller.value.isInitialized) {
        await _controller.setLooping(widget.loop);
        if (widget.autoplay || _controller.value.isPlaying) {
          await _controller.play();
        }
        setState(() => _failed = false);
      } else if (_controller.value.hasError) {
        setState(() => _failed = true);
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  /// 控制器状态变化时的兜底刷新（主要处理错误态）。
  void _onControllerChanged() {
    if (!mounted) return;
    if (_controller.value.hasError) {
      setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    widget.onClose?.call();
    super.dispose();
  }

  /// 开始播放；若未初始化则忽略。
  Future<void> play() async {
    if (!_controller.value.isInitialized || _failed) return;
    await _controller.play();
  }

  /// 暂停播放；若未初始化则忽略。
  Future<void> pause() async {
    if (!_controller.value.isInitialized || _failed) return;
    await _controller.pause();
  }

  /// 切换播放 / 暂停。
  Future<void> togglePlay() async {
    if (!_controller.value.isInitialized || _failed) return;
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
  }

  /// 重试加载视频（本地重建控制器后重新 [initState] 中初始化流程）。
  Future<void> _retry() async {
    setState(() => _failed = false);
    final old = _controller;
    old.removeListener(_onControllerChanged);
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.src));
    _controller.addListener(_onControllerChanged);
    // 延迟到下一帧 old.dispose，避免与旧实例异步回调冲突。
    await _init();
    old.dispose();
  }

  /// 将毫秒进度格式化为 `hh:mm:ss` / `mm:ss` 文本。
  String _format(Duration d) {
    final h = d.inHours;
    final hh = h.toString();
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$hh:$mm:$ss';
    return '$mm:$ss';
  }

  /// 关闭处理：触发 [widget.onClose]（命令式下由调用方负责 pop）。
  void _handleClose() {
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildVideoArea(context, value),
                // 顶部渐变遮罩 + 关闭按钮 + 标题
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                    child: Stack(
                      children: [
                        if (widget.title != null && widget.title!.isNotEmpty)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                widget.title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ),
                        Align(
                          alignment: widget.closePosition == WotVideoPreviewClosePosition.leftTop
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: _CloseButton(
                            background: scheme.opacLightCover,
                            onPressed: _handleClose,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 底部控制条
                if (value.isInitialized && !_failed)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                iconSize: 34,
                                icon: Icon(
                                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: togglePlay,
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 3,
                                    activeTrackColor: scheme.primaryOf(6),
                                    inactiveTrackColor: Colors.white24,
                                    thumbColor: Colors.white,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape:
                                        const RoundSliderOverlayShape(overlayRadius: 14),
                                    overlayColor: Colors.white24,
                                  ),
                                  child: Slider(
                                    min: 0,
                                    max: value.duration.inMilliseconds.toDouble().clamp(
                                          0,
                                          double.infinity,
                                        ),
                                    value: value.position.inMilliseconds
                                        .toDouble()
                                        .clamp(0, value.duration.inMilliseconds.toDouble()),
                                    onChanged: value.duration.inMilliseconds > 0
                                        ? (ms) => _controller
                                            .seekTo(Duration(milliseconds: ms.round()))
                                        : null,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  '${_format(value.position)} / ${_format(value.duration)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 绘制视频区域：加载失败占位 / 封面 / 视频。
  Widget _buildVideoArea(BuildContext context, VideoPlayerValue value) {
    if (_failed || value.hasError) return _buildError(context);
    if (!value.isInitialized) {
      if (widget.poster != null && widget.poster!.isNotEmpty) {
        return Image.network(
          widget.poster!,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
            ),
          ),
        );
      }
      return const Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
        ),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }

  /// 加载失败占位：提示图标 + 文案 + 重试按钮（背景用主题语义色）。
  Widget _buildError(BuildContext context) {
    final scheme = context.wotScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WotIcon(name: 'error', size: 48, color: Colors.white54),
          const SizedBox(height: 12),
          const Text(
            '视频加载失败',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primaryOf(6),
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 40),
            ),
            onPressed: _retry,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}

/// 顶部的方形关闭按钮（底色取自主题语义色，图标用白色）。
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.background, required this.onPressed});

  /// 背景颜色（来自 [BuildContext.wotScheme] 语义令牌）。
  final Color background;

  /// 点击关闭回调。
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          '完成',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}