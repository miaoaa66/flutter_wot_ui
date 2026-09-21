import 'dart:async';

import 'package:flutter/material.dart';

import '../../locale/wot_messages.dart';
import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 通知栏滚动方向。
enum WotNoticeDirection { horizontal, vertical }

/// 通知栏右侧操作模式。
enum WotNoticeMode { normal, closeable, link }

/// 公告栏，对应 wot `wd-notice-bar`。
class WotNoticeBar extends StatefulWidget {
  const WotNoticeBar({
    super.key,
    this.text,
    this.texts,
    this.direction = WotNoticeDirection.horizontal,
    this.scrollable = true,
    this.mode,
    this.color,
    this.bgColor,
    this.icon,
    this.closeable = false,
    this.leftIcon = true,
    this.delay = 1,
    this.speed = 50,
    this.duration,
    this.onClose,
    this.onNext,
    this.onClick,
    this.wrapable = false,
    this.showMore = false,
    this.textStyle,
  });

  /// 通知栏文案。
  final String? text;

  /// 多文本数组：当 [direction] 为 vertical 且长度大于 1 时，开启垂直轮播；
  /// 为空时仅使用 [text]。
  final List<String>? texts;

  /// 滚动方向，可选 `horizontal`/`vertical`，默认 horizontal。
  final WotNoticeDirection direction;

  /// 是否开启滚动/轮播动画，默认 true；为 false 时静态展示。
  final bool scrollable;

  /// 右侧操作模式，可选 `normal`/`closeable`/`link`；为空时按 [closeable]/[showMore] 推导。
  final WotNoticeMode? mode;

  /// 文字与图标颜色；不传时用主题主色。
  final Color? color;

  /// 背景颜色；不传时按 [color] 生成浅色背景。
  final Color? bgColor;

  /// 左侧图标名称（wot icon）；不传时按 [leftIcon] 决定默认图标。
  final String? icon;

  /// 是否显示关闭按钮（推导出 closeable 模式时生效）。
  final bool closeable;

  /// 是否显示左侧默认图标；为 false 时图标随 [icon] 决定。
  final bool leftIcon;

  /// 垂直轮播时每条文案的停留/切换间隔（秒），即上一条滑出、下一条滑入之间的停顿；默认 1。
  /// 这是“停顿”而非动画时长，动画时长另见 [duration]。
  final int delay;

  /// 滚动速度（px/s），默认 50。影响横向跑马灯速度；纵向轮播仅当 [duration] 为 null 时，
  /// 按 pageH/speed 推算“默认”切换时长。
  final int speed;

  /// 垂直轮播切换动画时长（毫秒）。为 null 时按 [speed] 与行高推算（约 pageH/speed）。
  /// 调大更慢更柔和，调小更利落。与 [delay] 独立：一次完整切换周期 = 停留(delay) + 动画(duration)。
  final int? duration;

  /// 点击关闭按钮（closeable 模式，动画结束后）时回调。
  final VoidCallback? onClose;

  /// 垂直轮播切换到下一条文本时回调，参数为当前展示文本的数组索引。
  final ValueChanged<int>? onNext;

  /// 点击内容区时回调，参数依次为当前文案与其索引。
  final void Function(String text, int index)? onClick;

  /// 是否换行展示全文（为 true 时不做单行省略）。
  final bool wrapable;

  /// 是否在右侧显示“更多”箭头（推导出 link 模式时生效）。
  final bool showMore;

  /// 文案自定义样式；不传时使用内置 13px 主色样式。
  final TextStyle? textStyle;

  @override
  State<WotNoticeBar> createState() => _WotNoticeBarState();
}

class _WotNoticeBarState extends State<WotNoticeBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _closing = false;

  /// closeable 关闭后是否已彻底移除（为 true 时不再占位，build 返回空）。
  bool _closed = false;

  // 横向跑马灯状态
  bool _scrolling = false;
  double _marqueeTotal = 0;

  // 垂直轮播状态
  int _vIndex = 0;
  Timer? _vTimer;
  Duration? _vInterval;

  WotNoticeMode get _mode {
    final m = widget.mode;
    if (m != null) return m;
    if (widget.closeable) return WotNoticeMode.closeable;
    if (widget.showMore) return WotNoticeMode.link;
    return WotNoticeMode.normal;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, lowerBound: 0, upperBound: 1)
      ..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(WotNoticeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.texts != oldWidget.texts) {
      setState(() => _vIndex = 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _vTimer?.cancel();
    super.dispose();
  }

  String _single() {
    final list = widget.texts ?? const <String>[];
    return widget.text ?? (list.isNotEmpty ? list.first : '');
  }

  // 当前内容对应索引：单条 text 恒为 0，数组时取当前轮播索引。
  int _currentIndex() {
    final list = widget.texts ?? const <String>[];
    if (widget.text != null) return 0;
    return list.isNotEmpty ? _vIndex : 0;
  }

  // 横向跑马灯：根据布局测量结果启停控制器。
  void _applySummary() {
    if (!_scrolling || _marqueeTotal <= 0) {
      _ctrl.stop();
      _ctrl.value = 0;
      return;
    }
    final spd = widget.speed > 0 ? widget.speed : 1.0;
    final dur = Duration(
      microseconds: (_marqueeTotal / spd * 1000 * 1000).round(),
    );
    if (_ctrl.duration != dur) {
      _ctrl.duration = dur;
      _ctrl.value = 0;
    }
    if (!_ctrl.isAnimating) _ctrl.repeat();
  }

  // 垂直轮播：定时推进索引。
  void _syncVerticalTimer(Duration interval) {
    if (_vInterval == interval && _vTimer != null) return;
    _vInterval = interval;
    _vTimer?.cancel();
    final list = widget.texts ?? const <String>[];
    _vTimer = Timer.periodic(interval, (_) {
      if (!mounted || list.length < 2) return;
      final next = (_vIndex + 1) % list.length;
      setState(() => _vIndex = next);
      widget.onNext?.call(next);
    });
  }

  TextStyle _effectiveStyle(Color fg, double fontSize) {
    return widget.textStyle ?? TextStyle(fontSize: fontSize, color: fg, height: 1.4);
  }

  Widget _buildHorizontalContent(Color fg, double fontSize) {
    final content = _single();
    final style = _effectiveStyle(fg, fontSize);
    final tp = TextPainter(
      text: TextSpan(text: content, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final contentW = tp.width;
    const gap = 24.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = constraints.maxWidth;
        final shouldScroll =
            widget.scrollable && content.isNotEmpty && contentW > viewport;

        if (shouldScroll != _scrolling ||
            (shouldScroll && _marqueeTotal != contentW + gap)) {
          _scrolling = shouldScroll;
          _marqueeTotal = shouldScroll ? contentW + gap : 0;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _applySummary();
          });
        }

        if (!shouldScroll) {
          if (widget.wrapable) {
            return Text(content, style: style);
          }
          return Text(content, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
        }

        // 跑马灯：滚动内容放进横向 SingleChildScrollView（不可滚动）。
        // 它会给孩子 unbounded 宽度，子 Row 按内容尺寸布局、不再被视口宽度约束而溢出报错；
        // 外层 ClipRect 仍按视口裁切。
        return ClipRect(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) => Transform.translate(
              offset: Offset(-_ctrl.value * (contentW + gap), 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.ltr,
                  children: [
                    SizedBox(width: contentW, child: Text(content, style: style, maxLines: 1)),
                    const SizedBox(width: gap),
                    SizedBox(width: contentW, child: Text(content, style: style, maxLines: 1)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalContent(Color fg, double fontSize, TextStyle style) {
    final list = widget.texts ?? const <String>[];
    final pageH = (style.fontSize ?? fontSize) * (style.height ?? 1.4);

    if (list.length > 1 && widget.scrollable) {
      final spd = widget.speed > 0 ? widget.speed : 1.0;
      // 切换动画时长：优先用显式 duration，否则按 speed 与行高推算（与横向跑马灯同源）。
      final animMs = widget.duration ?? ((pageH / spd * 1000).round());
      final animDuration = Duration(milliseconds: animMs);
      // 完整切换周期 = 停留(delay 秒) + 动画(animMs)；动画只用于滑动过程，停顿时文本静止，
      // 解决此前“动画时长 == 周期、文字一直连轴上滚、没有停顿”的生硬感。
      final period = Duration(milliseconds: widget.delay * 1000 + animMs);
      _syncVerticalTimer(period);
      final current = list[_vIndex % list.length];
      return SizedBox(
        height: pageH,
        child: ClipRect(
          child: AnimatedSwitcher(
            duration: animDuration,
            // 自定义 layoutBuilder：显式裁剪，长短文案切换时不出现横向溢出/位移。
            // 注意：本 SDK 不支持空感知集合元素（currentChild?）语法，故用 .add 形式，
            // 既能把进入的子组件纳入 Stack，又规避 use_null_aware_elements 提示。
            layoutBuilder: (currentChild, previousChildren) {
              final children = <Widget>[...previousChildren];
              if (currentChild != null) children.add(currentChild);
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: children,
              );
            },
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(anim),
              child: child,
            ),
            child: KeyedSubtree(
              key: ValueKey<int>(_vIndex),
              // 文案容器撑满宽度并左对齐：长短文案切换时位置稳定，不再“右移”。
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  current,
                  style: style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        ),
      );
    }

    _vTimer?.cancel();
    _vTimer = null;
    final one = list.isNotEmpty ? list.first : (widget.text ?? '');
    return Text(one, style: style, maxLines: widget.wrapable ? null : 1);
  }

  Widget _buildContent(Color fg, double fontSize) {
    final style = _effectiveStyle(fg, fontSize);
    Widget content;
    if (widget.direction == WotNoticeDirection.vertical) {
      content = _buildVerticalContent(fg, fontSize, style);
    } else {
      content = _buildHorizontalContent(fg, fontSize);
    }
    final cur = widget.text ?? (widget.texts?.isNotEmpty == true ? widget.texts!.first : '');
    final idx = _currentIndex();
    // 无障碍：公告栏本体可点，补 button 角色 + 点按动作（公告文本读屏可读）。
    return Semantics(
      button: true,
      onTap: () => widget.onClick?.call(cur, idx),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onClick?.call(cur, idx),
        child: Align(alignment: Alignment.centerLeft, child: content),
      ),
    );
  }

  void _handleClose() {
    setState(() => _closing = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _closed = true);
      widget.onClose?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 已关闭：彻底移除，不再占位（onClose 已在上方回调）。
    if (_closed) return const SizedBox.shrink();

    final scheme = context.wotScheme;
    final fg = widget.color ?? scheme.primaryOf(6);
    final bg = widget.bgColor ?? fg.withValues(alpha: 0.1);
    final iconName = widget.icon ?? (widget.leftIcon ? 'warning' : null);
    final mode = _mode;
    const baseFontSize = 13.0;

    final trailing = switch (mode) {
      WotNoticeMode.closeable => Semantics(
          // 无障碍：关闭是图标按钮，补 button 角色 + 文案（图标本身对读屏不可读）。
          button: true,
          label: tr(context, 'wot.common.close'),
          onTap: _handleClose,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleClose,
            child: WotIcon(name: 'close', size: 14, color: fg),
          ),
        ),
      WotNoticeMode.link => Semantics(
          // 无障碍：链接图标补 button 角色 + 点按动作（图标名 WotIcon 已带语义）。
          button: true,
          onTap: () {
            final cur = widget.text ?? (widget.texts?.isNotEmpty == true ? widget.texts!.first : '');
            widget.onClick?.call(cur, 0);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final cur = widget.text ?? (widget.texts?.isNotEmpty == true ? widget.texts!.first : '');
              widget.onClick?.call(cur, 0);
            },
            child: WotIcon(name: 'arrow-right', size: 14, color: fg),
          ),
        ),
      WotNoticeMode.normal => const SizedBox.shrink(),
    };

    return AnimatedOpacity(
      opacity: _closing ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: bg,
        child: Row(
          children: [
            if (iconName != null) ...[
              WotIcon(name: iconName, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Expanded(child: _buildContent(fg, baseFontSize)),
            const SizedBox(width: 6),
            trailing,
          ],
        ),
      ),
    );
  }
}