import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';

/// 气泡相对目标元素的方位（对齐 wot `TourPlacement`）。
enum WotTourPlacement {
  /// 自动：取四周可用空间最大的一侧。
  auto,

  /// 气泡展示在目标上方。
  top,

  /// 气泡展示在目标下方。
  bottom,

  /// 气泡展示在目标左侧。
  left,

  /// 气泡展示在目标右侧。
  right,
}

/// 单步引导数据（对齐 wot `TourStep`）。
class WotTourStep {
  const WotTourStep({
    this.target,
    this.title,
    this.description,
    this.placement,
    this.maskPadding,
    this.nextButtonText,
    this.prevButtonText,
    this.onEnter,
    this.onLeave,
    this.autoScroll = true,
    this.scrollController,
    this.targetScrollOffset = 0,
  });

  /// 高亮目标，需用 [GlobalKey] 标记已渲染的 widget。
  ///
  /// 通过 `key.currentContext.findRenderObject()` 的全局坐标定位；若目标
  /// 尚未渲染或拿不到 key，则本步无高亮框，气泡居中展示。
  final GlobalKey? target;

  /// 步骤标题。
  final String? title;

  /// 步骤描述说明。
  final String? description;

  /// 气泡相对目标的方位，为空时取全局 [WotTour.show] 的 [placement]。
  final WotTourPlacement? placement;

  /// 高亮区域外扩（内边距），覆盖全局 [WotTour.show] 的 [maskPadding]。
  final double? maskPadding;

  /// 本步“下一步”按钮文案，覆盖全局 [nextButtonText]，仅为最后一步时用“完成”。
  final String? nextButtonText;

  /// 本步“上一步”按钮文案，覆盖全局 [prevButtonText]。
  final String? prevButtonText;

  /// 进入本步时回调（可在此准备/挂载目标，例如打开含目标元素的弹框）。
  final VoidCallback? onEnter;

  /// 离开本步时回调（常用于清理本步引入的状态，如关闭弹框）。
  final VoidCallback? onLeave;

  /// 是否自动滚动到目标并保证蓝框圈住，默认 true。
  final bool autoScroll;

  /// 目标所在的滚动容器；当目标被惰性回收（拿不到定位）时，先滚动到
  /// [targetScrollOffset] 使目标重新挂载，再定位并圈住。用于引导页内的列表元素。
  final ScrollController? scrollController;

  /// 配合 [scrollController] 使用的期望滚动偏移；目标在列表顶部时用 0（默认）。
  final double targetScrollOffset;
}

/// 引导控制器，由 [WotTour.show] 返回，用于控制导航与关闭。
class WotTourController {
  WotTourController._(this._entry);

  final OverlayEntry _entry;
  _WotTourViewState? _state;

  void _attach(_WotTourViewState s) => _state = s;

  /// 当前步骤索引（从 0 开始）。
  int get stepIndex => _state?._stepIndex ?? 0;

  /// 切换上一步（已在第一步时无操作）。
  void prev() => _state?.prev();

  /// 切换下一步（已是最后一步时触发完成并关闭）。
  void next() => _state?.next();

  /// 关闭引导并移除遮罩。
  void close() {
    if (_entry.mounted) _entry.remove();
    _state = null;
  }
}

/// 新手引导蒙层（漫游），对应 wot `wd-tour`。
///
/// 在页面根浮层上渲染暗色遮罩，用 CustomPaint 镂空当前步骤高亮的目标区域，
/// 并在目标旁展示说明气泡卡片（标题/描述 + 跳过/上一步/下一步 或 完成）。
/// 采用命令式 [WotTour.show]，返回 [WotTourController] 便于外部导航/关闭。
///
/// 用法：
/// ```dart
/// final controller = WotTour.show(
///   context,
///   steps: [
///     WotTourStep(
///       target: _key1,
///       title: '第一步',
///       description: '这是第一个可高亮的目标',
///     ),
///     WotTourStep(target: _key2, title: '第二步', description: '第二个目标'),
///   ],
///   onFinish: () => print('引导完成'),
/// );
/// // controller.next() / controller.prev() / controller.close()
/// ```
class WotTour {
  WotTour._();

  static OverlayEntry? _currentEntry;

  /// 展示新手引导，返回可关闭/导航的 [WotTourController]。
  ///
  /// 基础参数：[steps] 引导步骤列表；[initialIndex] 初始步骤索引，默认 0；
  /// [showMask] 是否显示整页遮罩，默认 true；
  /// [closeOnClickMask] 点击遮罩是否关闭，默认 false；
  /// [clickMaskNext] 点击遮罩是否进入下一步（优先于 [closeOnClickMask]），默认 false。
  ///
  /// 高亮参数：[maskPadding] 高亮区域外扩（内边距），默认 8；
  /// [borderRadius] 高亮框圆角，默认 8；[offset] 气泡与高亮区域的间距，默认 16。
  ///
  /// 气泡参数：[placement] 气泡相对目标方位，默认 [WotTourPlacement.auto]；
  /// [maxWidth] 气泡最大宽度，默认 260；
  /// [skipButtonText]/[prevButtonText]/[nextButtonText]/[finishButtonText]
  /// 依次为“跳过/上一步/下一步/完成”文案。
  ///
  /// 回调：[onChange] 步骤变化（参数为新索引）；[onNext]/[onPrev] 分别在
  /// 点击下一步/上一步时触发；[onFinish] 完成后触发；[onSkip] 跳过后触发；
  /// [onClose] 引导关闭时触发。
  static WotTourController show(
    BuildContext context, {
    required List<WotTourStep> steps,
    int initialIndex = 0,
    bool showMask = true,
    bool closeOnClickMask = false,
    bool clickMaskNext = false,
    double maskPadding = 8,
    double borderRadius = 8,
    double offset = 16,
    WotTourPlacement placement = WotTourPlacement.auto,
    double maxWidth = 260,
    String skipButtonText = '跳过',
    String prevButtonText = '上一步',
    String nextButtonText = '下一步',
    String finishButtonText = '完成',
    ValueChanged<int>? onChange,
    ValueChanged<int>? onNext,
    ValueChanged<int>? onPrev,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
    VoidCallback? onClose,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final current = _currentEntry;
    if (current != null && current.mounted) current.remove();

    late final WotTourController controller;
    final entry = OverlayEntry(
      builder: (ctx) => _WotTourView(
        steps: steps,
        initialIndex: initialIndex,
        showMask: showMask,
        closeOnClickMask: closeOnClickMask,
        clickMaskNext: clickMaskNext,
        maskPadding: maskPadding,
        borderRadius: borderRadius,
        offset: offset,
        placement: placement,
        maxWidth: maxWidth,
        skipButtonText: skipButtonText,
        prevButtonText: prevButtonText,
        nextButtonText: nextButtonText,
        finishButtonText: finishButtonText,
        onChange: onChange,
        onNext: onNext,
        onPrev: onPrev,
        onFinish: onFinish,
        onSkip: onSkip,
        onClose: onClose,
        controller: controller,
      ),
    );
    controller = WotTourController._(entry);
    _currentEntry = entry;
    overlay.insert(entry);
    return controller;
  }
}

class _WotTourView extends StatefulWidget {
  const _WotTourView({
    required this.steps,
    required this.initialIndex,
    required this.showMask,
    required this.closeOnClickMask,
    required this.clickMaskNext,
    required this.maskPadding,
    required this.borderRadius,
    required this.offset,
    required this.placement,
    required this.maxWidth,
    required this.skipButtonText,
    required this.prevButtonText,
    required this.nextButtonText,
    required this.finishButtonText,
    required this.controller,
    this.onChange,
    this.onNext,
    this.onPrev,
    this.onFinish,
    this.onSkip,
    this.onClose,
  });

  final List<WotTourStep> steps;
  final int initialIndex;
  final bool showMask;
  final bool closeOnClickMask;
  final bool clickMaskNext;
  final double maskPadding;
  final double borderRadius;
  final double offset;
  final WotTourPlacement placement;
  final double maxWidth;
  final String skipButtonText;
  final String prevButtonText;
  final String nextButtonText;
  final String finishButtonText;
  final WotTourController controller;
  final ValueChanged<int>? onChange;
  final ValueChanged<int>? onNext;
  final ValueChanged<int>? onPrev;
  final VoidCallback? onFinish;
  final VoidCallback? onSkip;
  final VoidCallback? onClose;

  @override
  State<_WotTourView> createState() => _WotTourViewState();
}

class _WotTourViewState extends State<_WotTourView> {
  late int _stepIndex;

  bool get _isLast => _stepIndex >= widget.steps.length - 1;

  WotTourStep get _step => widget.steps[_stepIndex.clamp(0, widget.steps.length - 1)];

  @override
  void initState() {
    super.initState();
    _stepIndex = widget.initialIndex.clamp(0, widget.steps.length - 1);
    widget.controller._attach(this);
    // 首帧后触发首步的进入回调与自动滚动，确保目标已布局。
    WidgetsBinding.instance.addPostFrameCallback((_) => _enterStep());
  }

  /// 触发当前步的 [WotTourStep.onEnter] 并自动滚动到目标。
  void _enterStep() {
    final step = widget.steps[_stepIndex.clamp(0, widget.steps.length - 1)];
    step.onEnter?.call();
    if (mounted && step.autoScroll) _scrollToTarget(step);
    if (mounted) setState(() {});
  }

  /// 离开当前步（触发 [WotTourStep.onLeave]）。
  void _leaveStep() {
    widget.steps[_stepIndex.clamp(0, widget.steps.length - 1)].onLeave?.call();
  }

  /// 自动滚动到目标使其进入视口并重算高亮矩形（让“蓝框”圈住目标）。
  ///
  /// 目标可能由 [WotTourStep.onEnter]（如打开弹框）引入而尚未挂载，或属于
  /// 可滚动列表中被惰性回收的项（拿不到定位）。此时若有 [WotTourStep.scrollController]，
  /// 先滚动到 [WotTourStep.targetScrollOffset] 使目标重新挂载，再定位圈住。
  void _scrollToTarget(WotTourStep step) {
    final ctx = step.target?.currentContext;
    if (ctx == null) {
      final sc = step.scrollController;
      if (sc != null && sc.hasClients) {
        final target = step.targetScrollOffset.clamp(
                0.0, sc.position.maxScrollExtent)
            .toDouble();
        sc.animateTo(target,
            duration: const Duration(milliseconds: 320), curve: Curves.easeOut).then((_) {
          if (!mounted) return;
          final retry = step.target?.currentContext;
          if (retry != null) {
            // ignore: use_build_context_synchronously (已用 mounted 守卫，GlobalKey 定位重试)
            Scrollable.ensureVisible(retry,
                    duration: const Duration(milliseconds: 320), alignment: 0.5)
                .then((_) {
              if (mounted) setState(() {});
            });
          } else {
            setState(() {});
          }
        });
      } else {
        // 无滚动容器则下一帧重试一次；仍不可得时用居中的兜底气泡保证可退出。
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final retry = step.target?.currentContext;
          if (retry != null) {
            Scrollable.ensureVisible(retry,
                    duration: const Duration(milliseconds: 320), alignment: 0.5)
                .then((_) {
              if (mounted) setState(() {});
            });
          } else {
            setState(() {});
          }
        });
      }
      return;
    }
    Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 320), alignment: 0.5)
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  /// 计算目标在全局（浮层）坐标系中的矩形。
  ///
  /// 目标需已渲染；拿不到 key 或尚未渲染时返回 null（此时无高亮框）。
  static Rect? _targetRect(GlobalKey? key) {
    if (key == null) return null;
    final renderContext = key.currentContext;
    if (renderContext == null) return null;
    final object = renderContext.findRenderObject();
    if (object is! RenderBox) return null;
    final origin = object.localToGlobal(Offset.zero);
    return origin & object.size;
  }

  void prev() {
    _leaveStep();
    if (_stepIndex == 0) return;
    final prevIndex = _stepIndex - 1;
    setState(() => _stepIndex = prevIndex);
    widget.onPrev?.call(prevIndex);
    widget.onChange?.call(prevIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) => _enterStep());
  }

  void next() {
    if (_isLast) {
      _leaveStep();
      finish();
      return;
    }
    _leaveStep();
    final nextIndex = _stepIndex + 1;
    setState(() => _stepIndex = nextIndex);
    widget.onNext?.call(nextIndex);
    widget.onChange?.call(nextIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) => _enterStep());
  }

  void finish() {
    widget.onFinish?.call();
    _close();
  }

  void skip() {
    widget.onSkip?.call();
    _close();
  }

  void _close() {
    if (mounted && widget.controller._entry.mounted) {
      widget.controller._entry.remove();
    }
    widget.controller._state = null;
    widget.onClose?.call();
  }

  void _handleMaskTap() {
    if (widget.clickMaskNext && !_isLast) {
      next();
    } else if (widget.closeOnClickMask) {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final media = MediaQuery.of(context);
    final size = media.size;
    final safeArea = EdgeInsets.fromLTRB(
      media.padding.left,
      media.padding.top,
      media.padding.right,
      media.padding.bottom,
    );

    final step = _step;
    final rect = _targetRect(step.target);
    // 目标拿不到定位（如该项被懒加载回收）时，用屏幕中央的小区域兜底，
    // 保证气泡（含“跳过/完成”按钮）始终渲染，用户永远可以退出引导。
    final base = rect ??
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: 24,
          height: 24,
        );
    final highlight = base.inflate(step.maskPadding ?? widget.maskPadding);

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            if (widget.showMask)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _handleMaskTap,
                  child: CustomPaint(
                    painter: _TourMaskPainter(
                      highlight: highlight,
                      borderRadius: widget.borderRadius,
                      maskColor: scheme.opacMainCover,
                      primary: scheme.primaryOf(6),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: _TourBubble(
                placement: _resolvePlacement(step, highlight, size, safeArea),
                highlight: highlight,
                offset: widget.offset,
                size: size,
                safeArea: safeArea,
                maxWidth: widget.maxWidth,
                scheme: scheme,
                index: _stepIndex,
                total: widget.steps.length,
                step: step,
                nextButtonText: step.nextButtonText ?? widget.nextButtonText,
                prevButtonText: step.prevButtonText ?? widget.prevButtonText,
                skipButtonText: widget.skipButtonText,
                finishButtonText: widget.finishButtonText,
                showPrev: _stepIndex > 0,
                isLast: _isLast,
                onPrev: prev,
                onNext: next,
                onSkip: skip,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 解析气泡实际方位：`auto` 时取目标四周可用空间最大的一侧，否则用给定方位。
  WotTourPlacement _resolvePlacement(
    WotTourStep step,
    Rect highlight,
    Size size,
    EdgeInsets safeArea,
  ) {
    final placement = step.placement ?? widget.placement;
    if (placement != WotTourPlacement.auto) return placement;

    double freeTop = highlight.top - safeArea.top;
    double freeBottom = size.height - safeArea.bottom - highlight.bottom;
    double freeLeft = highlight.left - safeArea.left;
    double freeRight = size.width - safeArea.right - highlight.right;

    final candidates = <WotTourPlacement, double>{
      WotTourPlacement.top: freeTop,
      WotTourPlacement.bottom: freeBottom,
      WotTourPlacement.left: freeLeft,
      WotTourPlacement.right: freeRight,
    };
    return candidates.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }
}

/// 遮罩画笔：整页暗色填充并在高亮区域镂空圆角矩形，并描一圈主色细边。
class _TourMaskPainter extends CustomPainter {
  _TourMaskPainter({
    required this.highlight,
    required this.borderRadius,
    required this.maskColor,
    required this.primary,
  });

  final Rect? highlight;
  final double borderRadius;
  final Color maskColor;
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = maskColor;
    if (highlight == null) {
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }

    final outer = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          highlight!,
          Radius.circular(borderRadius),
        ),
      );
    final clipPath = Path.combine(PathOperation.difference, outer, hole);
    canvas.drawPath(clipPath, paint);

    // 高亮框描边，提示可聚焦区域。
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(highlight!, Radius.circular(borderRadius)),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_TourMaskPainter old) =>
      old.highlight != highlight ||
      old.borderRadius != borderRadius ||
      old.maskColor != maskColor ||
      old.primary != primary;
}

/// 气泡卡片，展示标题/描述 + 进度 + 跳过/上一步/下一步（最后一步为完成）。
class _TourBubble extends StatelessWidget {
  const _TourBubble({
    required this.placement,
    required this.highlight,
    required this.offset,
    required this.size,
    required this.safeArea,
    required this.maxWidth,
    required this.scheme,
    required this.index,
    required this.total,
    required this.step,
    required this.nextButtonText,
    required this.prevButtonText,
    required this.skipButtonText,
    required this.finishButtonText,
    required this.showPrev,
    required this.isLast,
    required this.onPrev,
    required this.onNext,
    required this.onSkip,
  });

  final WotTourPlacement placement;
  final Rect highlight;
  final double offset;
  final Size size;
  final EdgeInsets safeArea;
  final double maxWidth;
  final WotScheme scheme;
  final int index;
  final int total;
  final WotTourStep step;
  final String nextButtonText;
  final String prevButtonText;
  final String skipButtonText;
  final String finishButtonText;
  final bool showPrev;
  final bool isLast;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _BubbleLayoutDelegate(
        highlight: highlight,
        placement: placement,
        offset: offset,
        size: size,
        safeArea: safeArea,
      ),
      child: _card(context),
    );
  }

  Widget _card(BuildContext context) {
    final description = step.description;
    final title = step.title;
    return Container(
      width: maxWidth < size.width - 24 ? maxWidth : null,
      constraints: BoxConstraints(maxWidth: size.width - 24),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      decoration: BoxDecoration(
        color: scheme.filledOppo,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || total > 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: title == null
                        ? const SizedBox.shrink()
                        : Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: scheme.textMain,
                            ),
                          ),
                  ),
                  Text(
                    '${index + 1}/$total',
                    style: TextStyle(fontSize: 12, color: scheme.textAuxiliary),
                  ),
                ],
              ),
            ),
          if (title != null && description != null) const SizedBox(height: 8),
          if (description != null)
            Text(
              description,
              style: TextStyle(fontSize: 14, color: scheme.textSecondary),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              _textButton(skipButtonText, scheme.textSecondary, onSkip),
              const Spacer(),
              if (showPrev) ...[
                _textButton(prevButtonText, scheme.textSecondary, onPrev),
                const SizedBox(width: 8),
              ],
              _filledButton(isLast ? finishButtonText : nextButtonText, onNext),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Text(label, style: TextStyle(fontSize: 13, color: color)),
      ),
    );
  }

  Widget _filledButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: scheme.primaryOf(6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}

/// 将气泡定位到高亮区域指定方位，并做屏幕边界约束。
class _BubbleLayoutDelegate extends SingleChildLayoutDelegate {
  _BubbleLayoutDelegate({
    required this.highlight,
    required this.placement,
    required this.offset,
    required this.size,
    required this.safeArea,
  });

  final Rect highlight;
  final WotTourPlacement placement;
  final double offset;
  final Size size;
  final EdgeInsets safeArea;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen();
  }

  double _clamp(double value, double min, double max) {
    if (max < min) return min;
    return value.clamp(min, max);
  }

  @override
  Offset getPositionForChild(Size layoutSize, Size childSize) {
    final margin = 8.0;
    final maxX = size.width - childSize.width - margin;
    final maxY = size.height - childSize.height - margin;
    final centerX = highlight.center.dx - childSize.width / 2;
    final centerY = highlight.center.dy - childSize.height / 2;

    double x = centerX;
    double y = centerY;
    switch (placement) {
      case WotTourPlacement.auto:
      case WotTourPlacement.top:
        x = _clamp(centerX, margin, maxX);
        y = highlight.top - offset - childSize.height;
        break;
      case WotTourPlacement.bottom:
        x = _clamp(centerX, margin, maxX);
        y = highlight.bottom + offset;
        break;
      case WotTourPlacement.left:
        x = highlight.left - offset - childSize.width;
        y = _clamp(centerY, margin, maxY);
        break;
      case WotTourPlacement.right:
        x = highlight.right + offset;
        y = _clamp(centerY, margin, maxY);
        break;
    }
    return Offset(
      _clamp(x, margin, maxX < margin ? margin : maxX),
      _clamp(y, margin, maxY < margin ? margin : maxY),
    );
  }

  @override
  bool shouldRelayout(_BubbleLayoutDelegate old) =>
      old.highlight != highlight ||
      old.placement != placement ||
      old.offset != offset ||
      old.size != size ||
      old.safeArea != safeArea;
}