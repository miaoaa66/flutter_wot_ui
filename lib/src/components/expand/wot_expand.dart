import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';
import '../text/wot_text.dart';

/// 展开更多容器，对应 wot `wd-expand`。
///
/// 内容超高时可配置默认显示高度（默认 50），容器底部向上带渐隐遮罩与「查看全部」按钮；
/// 点击展开全部内容，展开后可再次点击「收起」回到限高状态（可通过 [collapsible] 关闭收起能力）。
class WotExpand extends StatefulWidget {
  const WotExpand({
    super.key,
    this.height = 50,
    this.fadeHeight = 20,
    this.expandText = '查看全部',
    this.collapseText = '收起',
    this.collapsible = true,
    this.showArrow = true,
    this.expanded,
    this.onChange,
    required this.child,
  });

  /// 未展开时内容显示的最大高度，默认 50。
  final double height;

  /// 底部渐隐遮罩高度，默认 20。
  final double fadeHeight;

  /// 展开按钮文案，默认「查看全部」。
  final String expandText;

  /// 收起按钮文案，默认「收起」。
  final String collapseText;

  /// 展开后是否可再次收回到限高状态，默认 true。
  final bool collapsible;

  /// 是否在文案右侧显示箭头图标，默认 true。
  final bool showArrow;

  /// 受控展开状态；为 null 时由组件内部维护。
  final bool? expanded;

  /// 展开状态变化回调（`true` 展开、`false` 收起）。
  final ValueChanged<bool>? onChange;

  /// 容器内容（任意 widget）。
  final Widget child;

  @override
  State<WotExpand> createState() => _WotExpandState();
}

class _WotExpandState extends State<WotExpand> {
  final GlobalKey _measureKey = GlobalKey();
  bool _expanded = false;
  double _contentHeight = 0;
  bool _needsExpand = false;

  bool get _isExpanded => widget.expanded ?? _expanded;

  @override
  void initState() {
    super.initState();
    _measure();
  }

  @override
  void didUpdateWidget(WotExpand oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != null && widget.expanded != oldWidget.expanded) {
      _expanded = widget.expanded!;
    }
    if (widget.child != oldWidget.child ||
        widget.height != oldWidget.height ||
        widget.fadeHeight != oldWidget.fadeHeight) {
      _measure();
    }
  }

  /// 首帧后测量内容自然高度，用于判断是否超出限高、是否显示「查看全部」。
  void _measure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final h = _measureKey.currentContext?.size?.height ?? _contentHeight;
      final needs = h > widget.height + 0.5;
      if (h != _contentHeight || needs != _needsExpand) {
        setState(() {
          _contentHeight = h;
          _needsExpand = needs;
        });
      }
    });
  }

  void _toggle() {
    final next = !_isExpanded;
    setState(() => _expanded = next);
    widget.onChange?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final expanded = _isExpanded;
    final needsExpand = _needsExpand;
    final showFooter = needsExpand && (expanded ? widget.collapsible : true);

    // 未展开且内容超高时，可视区域按 限高/自然高度 的比例裁剪（内容仍按自然高度布局，避免子组件溢出）；
    // 展开或内容不足限高时按内容自然高度（1.0），避免有界高度约束下 Align 自动拉伸导致内容被裁剪。
    // 测量完成前（_contentHeight 未知）先以 0 高度占位，避免「先显示完整高度再收缩到限高」导致页面跳动。
    final double? heightFactor;
    if (_contentHeight <= 0) {
      heightFactor = 0;
    } else if (!expanded && needsExpand) {
      heightFactor = widget.height / _contentHeight;
    } else {
      heightFactor = 1.0;
    }

    // 可视内容
    final Widget content = ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: heightFactor,
        child: widget.child,
      ),
    );

    // 底部操作区：渐隐遮罩（未展开时）+ 展开/收起按钮
    final Widget footer = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!expanded)
          IgnorePointer(
            child: Container(
              height: widget.fadeHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [scheme.filledOppo.withValues(alpha: 0), scheme.filledOppo.withValues(alpha: 0.9)],
                ),
              ),
            ),
          ),
        // 无障碍：展开/收起是可点区域，补 button 角色 + 点按动作（文案本身读屏可读）。
        Semantics(
          button: true,
          onTap: _toggle,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Container(
              width: double.infinity,
              color: scheme.filledOppo.withValues(alpha: 0.9),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WotText(
                    expanded ? widget.collapseText : widget.expandText,
                    type: WotTextType.primary,
                    size: 14,
                  ),
                  if (widget.showArrow) ...[
                    const SizedBox(width: 4),
                    WotIcon(
                      name: expanded ? 'arrow-up' : 'arrow-down',
                      size: 16,
                      color: scheme.primaryOf(6),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );

    // 透明测量副本：按自然高度布局，用于判定内容是否超出限高
    final Widget measureLayer = Positioned(
      left: 0,
      top: 0,
      right: 0,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0,
          child: KeyedSubtree(key: _measureKey, child: widget.child),
        ),
      ),
    );

    if (expanded && needsExpand) {
      // 展开态：内容与底部操作按钮纵向排列，按钮不悬浮遮挡内容，保证完整文案可见
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              content,
              if (showFooter) footer,
            ],
          ),
          measureLayer,
        ],
      );
    }

    // 收起态：内容裁剪到限高，底部悬浮渐隐遮罩与「查看全部」按钮
    return Stack(
      clipBehavior: Clip.none,
      children: [
        content,
        if (showFooter)
          Positioned(left: 0, right: 0, bottom: 0, child: footer),
        measureLayer,
      ],
    );
  }
}