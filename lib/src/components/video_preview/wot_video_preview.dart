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

  /// 是否已触发关闭回调，防止按钮点击与 [dispose] 重复触发一次以上。
  bool _closed = false;

  /// 可选倍速档位（线性递增），用于循环切换。
  static const List<double> _rates = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  /// 记住取消静音前的音量，便于一键恢复。
  double _savedVolume = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.src));
    // initState 处于父级的 build 阶段，同步回调 onOpen 会让调用方的 setState
    // 撞上「setState() called during build」。延后到本帧构建结束后再发出。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onOpen?.call();
    });
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
    // 仅触发一次关闭回调，避免与按钮路径重复 pop / 在树 finalization 阶段做祖先查找。
    _notifyClose();
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

  /// 循环切换倍速档位（0.5x → 2x）。
  Future<void> nextSpeed() async {
    if (!_controller.value.isInitialized) return;
    var i = _rates.indexWhere(
        (r) => (r - _controller.value.playbackSpeed).abs() < 0.001);
    if (i < 0) i = _rates.indexOf(1.0);
    await _controller.setPlaybackSpeed(_rates[(i + 1) % _rates.length]);
  }

  /// 切换是否循环播放。
  Future<void> toggleLoop() async {
    if (!_controller.value.isInitialized) return;
    await _controller.setLooping(!_controller.value.isLooping);
  }

  /// 切换静音 / 恢复音量。
  Future<void> toggleMute() async {
    if (!_controller.value.isInitialized) return;
    final v = _controller.value.volume;
    await _controller.setVolume(v == 0 ? (_savedVolume > 0 ? _savedVolume : 1.0) : 0.0);
    if (v > 0) _savedVolume = v;
  }

  /// 相对当前位置快退 / 快进 [seconds] 秒。
  Future<void> seekRelative(int seconds) async {
    final durMs = _controller.value.duration.inMilliseconds;
    if (durMs <= 0) return;
    final ms = (_controller.value.position.inMilliseconds + seconds * 1000)
        .clamp(0, durMs);
    await _controller.seekTo(Duration(milliseconds: ms));
  }

  /// 将播放倍率格式化为简短文本，如 `1x`、`1.25x`。
  String _speedLabel(double s) {
    if (s == s.roundToDouble()) return '${s.toStringAsFixed(0)}x';
    return '${s.toStringAsFixed(2)}x';
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
    _notifyClose();
  }

  /// 内嵌模式：以全屏命令式方式打开当前视频预览。
  void _openFullscreen() {
    WotVideoPreview.show(
      context,
      widget.src,
      title: widget.title,
      poster: widget.poster,
      loop: widget.loop,
      closePosition: widget.closePosition,
    );
  }

  /// 触发一次且仅一次的关闭回调。
  void _notifyClose() {
    if (_closed) return;
    _closed = true;
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return Material(
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
                            label: widget.onClose == null ? '全屏' : '关闭',
                            background: scheme.opacLightCover,
                            onPressed:
                                widget.onClose == null ? _openFullscreen : _handleClose,
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _PlayerControl(
                                label: '-15s',
                                onTap: () => seekRelative(-15),
                              ),
                              _PlayerControl(
                                label: _speedLabel(value.playbackSpeed),
                                onTap: nextSpeed,
                              ),
                              _PlayerControl(
                                icon: Icons.repeat,
                                active: value.isLooping,
                                onTap: toggleLoop,
                              ),
                              _PlayerControl(
                                icon: value.volume > 0
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                onTap: toggleMute,
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 2,
                                    activeTrackColor: scheme.primaryOf(6),
                                    inactiveTrackColor: Colors.white24,
                                    thumbColor: Colors.white,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 5,
                                    ),
                                    overlayShape:
                                        const RoundSliderOverlayShape(overlayRadius: 12),
                                    overlayColor: Colors.white24,
                                  ),
                                  child: Slider(
                                    min: 0,
                                    max: 1,
                                    value: value.volume.clamp(0, 1),
                                    onChanged: value.isInitialized
                                        ? (v) => _controller.setVolume(v)
                                        : null,
                                  ),
                                ),
                              ),
                              _PlayerControl(
                                label: '+15s',
                                onTap: () => seekRelative(15),
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

/// 顶部方形按钮（底色取自主题语义色，文字/图标用白色）。
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.label, required this.background, required this.onPressed});

  /// 按钮文案（内嵌为「全屏」，全屏预览为「关闭」）。
  final String label;

  /// 背景颜色（来自 [BuildContext.wotScheme] 语义令牌）。
  final Color background;

  /// 点击回调。
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // 用 GestureDetector 而不是 InkWell，避免依赖上方有 Material（全屏预览可能是独立 overlay）。
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

/// 底栏的单个媒体控制（图标或文字）；激活态使用主题主色。
class _PlayerControl extends StatelessWidget {
  const _PlayerControl({
    required this.onTap,
    this.icon,
    this.label,
    this.active = false,
  });

  /// 点击回调。
  final VoidCallback onTap;

  /// 图标（与 [label] 二选一，优先图标）。
  final IconData? icon;

  /// 文字（如倍速 `1x`、跳转 `-15s`）。
  final String? label;

  /// 是否处于激活态（如已开启循环），激活时文字/图标用主题主色。
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final color = active ? scheme.primaryOf(6) : Colors.white;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 36,
        child: Center(
          child: icon != null
              ? Icon(icon, color: color, size: 24)
              : Text(
                  label ?? '',
                  style: TextStyle(color: color, fontSize: 14),
                ),
        ),
      ),
    );
  }
}