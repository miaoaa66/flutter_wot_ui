import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../locale/wot_messages.dart';
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
///
/// 控制面板交互：播放中无操作 3 秒自动隐藏，点击画面切换显隐；暂停时中央显示
/// 播放按钮，点击画面或按钮即可继续播放；快退 / 快进 15 秒按钮固定在画面左右两侧
/// 垂直居中（不再挤在底栏，小屏也放得下）。
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
      barrierLabel: tr(context, 'wot.video.title'),
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

  /// 控制面板是否可见（播放中无操作后自动隐藏，暂停时常显）。
  bool _controlsVisible = true;

  /// 自动隐藏控制面板的计时器。
  Timer? _hideTimer;

  /// 上一帧的播放状态，用于只在「播放 / 暂停切换」时刷新控制面板显隐。
  bool? _lastPlaying;

  /// 播放中控制面板无操作后自动隐藏的时长。
  static const Duration _kControlsAutoHide = Duration(seconds: 3);

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
          _lastPlaying = true;
          _restartHideTimer();
        }
        setState(() => _failed = false);
      } else if (_controller.value.hasError) {
        setState(() => _failed = true);
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  /// 控制器状态变化：处理错误态，并在「播放 / 暂停切换」时刷新控制面板显隐。
  void _onControllerChanged() {
    if (!mounted) return;
    final v = _controller.value;
    if (v.hasError) {
      if (!_failed) setState(() => _failed = true);
      return;
    }
    final playing = v.isInitialized && v.isPlaying;
    if (playing != _lastPlaying) {
      _lastPlaying = playing;
      if (playing) {
        _restartHideTimer();
      } else {
        _hideTimer?.cancel();
        if (!_controlsVisible) setState(() => _controlsVisible = true);
      }
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
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

  // ---------------------------------------------------------------- 控制面板显隐

  /// 播放中重启自动隐藏计时；未播放时不启动。
  void _restartHideTimer() {
    _hideTimer?.cancel();
    final v = _controller.value;
    if (!v.isInitialized || !v.isPlaying) return;
    _hideTimer = Timer(_kControlsAutoHide, () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  /// 显示控制面板并重置自动隐藏计时。
  void _showControls() {
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    _restartHideTimer();
  }

  /// 隐藏控制面板。
  void _hideControls() {
    _hideTimer?.cancel();
    if (_controlsVisible) setState(() => _controlsVisible = false);
  }

  /// 点击画面：暂停时继续播放；播放时切换控制面板显隐。
  void _toggleControls() {
    final v = _controller.value;
    if (v.isInitialized && !v.isPlaying) {
      togglePlay();
      _showControls();
      return;
    }
    if (_controlsVisible) {
      _hideControls();
    } else {
      _showControls();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            final ready = value.isInitialized && !_failed;
            final controlsVisible = ready ? _controlsVisible : true;
            return Stack(
              fit: StackFit.expand,
              children: [
                // 画面区域：点击切换控制面板（暂停时点击 = 继续播放）。
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleControls,
                  child: _buildVideoArea(context, value),
                ),
                // 缓冲指示
                if (ready && value.isBuffering)
                  const Center(
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                // 暂停时的中央播放按钮
                if (ready && !value.isPlaying)
                  Center(
                    child: _CenterPlayButton(
                      onTap: () {
                        togglePlay();
                        _showControls();
                      },
                    ),
                  ),
                // 快退 / 快进 15 秒：画面左右两侧垂直居中
                if (ready) _buildSideSeek(controlsVisible),
                _buildTopBar(context, controlsVisible),
                if (ready) _buildBottomBar(context, value, controlsVisible),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 顶部栏：渐变遮罩 + 标题 + 操作按钮（内嵌模式为「全屏」，全屏预览为「关闭」）。
  Widget _buildTopBar(BuildContext context, bool visible) {
    final closeLeft =
        widget.closePosition == WotVideoPreviewClosePosition.leftTop;
    final action = _TopIconButton(
      icon: widget.onClose == null ? Icons.fullscreen : Icons.close,
      tooltip: widget.onClose == null
          ? tr(context, 'wot.video.fullscreen')
          : tr(context, 'wot.video.close'),
      onPressed: widget.onClose == null ? _openFullscreen : _handleClose,
    );
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            child: Row(
              children: [
                if (closeLeft) action,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      widget.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: closeLeft ? TextAlign.left : TextAlign.right,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
                if (!closeLeft) action,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 底部控制面板：第一行「播放 + 进度 + 时间」，第二行左「跳转」右「设置」。
  Widget _buildBottomBar(
      BuildContext context, VideoPlayerValue value, bool visible) {
    final scheme = context.wotScheme;
    final total = value.duration.inMilliseconds;
    final pos = value.position.inMilliseconds.clamp(0, total).toDouble();
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(8, 24, 8, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 第一行：播放/暂停 + 进度 + 时间
                Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      iconSize: 32,
                      icon: Icon(
                        value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        togglePlay();
                        _showControls();
                      },
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          activeTrackColor: scheme.primaryOf(6),
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 14),
                          overlayColor: Colors.white24,
                        ),
                        child: Slider(
                          min: 0,
                          max: total.toDouble().clamp(0, double.infinity),
                          value: pos,
                          onChanged: total > 0
                              ? (ms) {
                                  _controller
                                      .seekTo(Duration(milliseconds: ms.round()));
                                  _showControls();
                                }
                              : null,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: Text(
                        '${_format(value.position)} / ${_format(value.duration)}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // 第二行：右对齐「倍速/循环/音量/全屏」（快退/快进已移至画面两侧居中）
                Row(
                  children: [
                    const Spacer(),
                    _PlayerControl(
                      label: _speedLabel(value.playbackSpeed),
                      onTap: () {
                        nextSpeed();
                        _showControls();
                      },
                    ),
                    _PlayerControl(
                      icon: Icons.repeat,
                      active: value.isLooping,
                      onTap: () {
                        toggleLoop();
                        _showControls();
                      },
                    ),
                    _PlayerControl(
                      icon: value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                      onTap: () {
                        toggleMute();
                        _showControls();
                      },
                    ),
                    SizedBox(
                      width: 96,
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 2,
                          activeTrackColor: scheme.primaryOf(6),
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 5),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 12),
                          overlayColor: Colors.white24,
                        ),
                        child: Slider(
                          min: 0,
                          max: 1,
                          value: value.volume.clamp(0, 1),
                          onChanged: value.isInitialized
                              ? (v) {
                                  _controller.setVolume(v);
                                  _showControls();
                                }
                              : null,
                        ),
                      ),
                    ),
                    if (widget.onClose == null)
                      _PlayerControl(
                        icon: Icons.fullscreen,
                        onTap: _openFullscreen,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 画面左右两侧垂直居中的「快退 / 快进 15 秒」按钮；随控制面板一同显隐。
  Widget _buildSideSeek(bool visible) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SideSeekButton(
                  forward: false,
                  onTap: () {
                    seekRelative(-15);
                    _showControls();
                  },
                ),
                _SideSeekButton(
                  forward: true,
                  onTap: () {
                    seekRelative(15);
                    _showControls();
                  },
                ),
              ],
            ),
          ),
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
          const WotIcon(name: 'error', size: 48, color: Colors.white54),
          const SizedBox(height: 12),
          Text(
            tr(context, 'wot.video.loadFailed'),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primaryOf(6),
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 40),
            ),
            onPressed: _retry,
            child: Text(tr(context, 'wot.common.retry')),
          ),
        ],
      ),
    );
  }
}

/// 顶部圆形操作按钮（底色取自主题语义色，图标为白色）。
class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  /// 图标（内嵌为全屏、预览为关闭）。
  final IconData icon;

  /// 提示文案。
  final String tooltip;

  /// 点击回调。
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final background = context.wotScheme.opacLightCover;
    // 用 GestureDetector 而不是 InkWell，避免依赖上方有 Material（全屏预览可能是独立 overlay）。
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// 暂停时画面中央的播放按钮。
class _CenterPlayButton extends StatelessWidget {
  const _CenterPlayButton({required this.onTap});

  /// 点击回调（继续播放）。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.play_arrow, color: Colors.white, size: 34),
      ),
    );
  }
}

/// 左右两侧的快退 / 快进按钮（圆形半透明底，中央显示 15 秒）。
class _SideSeekButton extends StatelessWidget {
  const _SideSeekButton({required this.forward, required this.onTap});

  /// true 为快进（+15s），false 为快退（-15s）。
  final bool forward;

  /// 点击回调。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 同一个环形箭头图标，快进时水平镜像；文字「15」不参与镜像。
    final arrow = Icon(
      Icons.replay,
      color: Colors.white,
      size: 34,
      semanticLabel: forward
          ? tr(context, 'wot.video.forward15')
          : tr(context, 'wot.video.rewind15'),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (forward)
              Transform.scale(scaleX: -1, child: arrow)
            else
              arrow,
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Text(
                '15',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
