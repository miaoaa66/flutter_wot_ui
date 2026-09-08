import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../../theme/wot_scheme.dart';
import '../badge/wot_badge.dart';
import '../icon/wot_icon.dart';

/// 悬浮按钮颜色（对齐 wot `type`）。
enum WotFabType { primary, success, info, warning, danger }

/// 悬浮按钮位置。
enum WotFabPosition { left, right, custom }

/// 悬浮按钮事件动作，对应 wot `wd-fab` 默认插槽中的动作按钮。
class WotFabAction {
  const WotFabAction({
    this.icon,
    this.text,
    this.onClick,
    this.badge,
    this.isDot = false,
    this.max = 99,
  });

  /// 动作图标名。
  final String? icon;

  /// 动作文字（无图标时居中显示）。
  final String? text;

  /// 点击该动作触发的回调。
  final VoidCallback? onClick;

  /// 动作徽标显示值（数字）。
  final num? badge;

  /// 是否显示点状徽标，默认 false。
  final bool isDot;

  /// 徽标最大值，超过时显示为 `{max}+`，默认 99。
  final num max;
}

/// 悬浮按钮组件，对应 wot `wd-fab`。
///
/// 渲染一个带图标（可选文字）的主按钮；当传入 [actions] 时会成为可展开的动作菜单：
/// 点击主按钮展开/收起动作列表（受 [active]/[onActiveChange] 双向控制，v-model:active）。
///
/// 定位由外层 `Stack`/容器通过 [position]/[customPosition] 或 [bottom]/[right] 控制，
/// 或由调用方自行 `Positioned` 包裹（此时不传定位参数）。
class WotFab extends StatefulWidget {
  const WotFab({
    super.key,
    this.show = true,
    this.type = WotFabType.primary,
    this.position = WotFabPosition.right,
    this.customPosition,
    this.icon = 'add',
    this.text,
    this.label,
    this.labelHidden = false,
    this.iconColor = Colors.white,
    this.bgColor,
    this.onClick,
    this.active = false,
    this.onActiveChange,
    this.actions,
    this.bottom,
    this.right,
    this.safeArea = false,
    this.closeOnClickOverlay = false,
    this.status = false,
  });

  /// 是否展示（v-model:value / modelValue）。
  final bool show;

  /// 颜色类型。
  final WotFabType type;

  /// 位置（left/right/custom）。
  final WotFabPosition position;

  /// custom 位置时的偏移。
  final Offset? customPosition;

  /// 图标名。
  final String icon;

  /// 图标旁的文字（按钮扩展）。
  final String? text;

  /// 按钮外标签文字（显示在按钮外侧）。
  final String? label;

  /// 是否隐藏 [label]。
  final bool labelHidden;

  /// 图标颜色，默认白色。
  final Color iconColor;

  /// 自定义背景颜色；为空时按 [type] 取主题色。
  final Color? bgColor;

  /// 点击主按钮回调（展开动作菜单时点击主按钮同样触发）。
  final VoidCallback? onClick;

  /// 是否展开动作菜单（v-model:active），默认 false。
  final bool active;

  /// 展开/收起状态变化回调，参数为最新展开状态。
  final ValueChanged<bool>? onActiveChange;

  /// 动作按钮列表（非空时可展开成动作菜单）。
  final List<WotFabAction>? actions;

  /// 距屏幕/容器底部的距离（配合 [right] 使用，需外层为 Stack），单位逻辑像素。
  final double? bottom;

  /// 距屏幕/容器右侧的距离（配合 [bottom] 使用，需外层为 Stack），单位逻辑像素。
  final double? right;

  /// 定位在底部时是否计入底部安全区（刘海屏 padding），默认 false。
  final bool safeArea;

  /// 展开时点击遮罩（页面其他区域）是否自动收起，默认 false。
  final bool closeOnClickOverlay;

  /// 是否在主按钮右上角显示红色状态小圆点，默认 false。
  final bool status;

  @override
  State<WotFab> createState() => _WotFabState();
}

class _WotFabState extends State<WotFab> {
  late bool _active;

  @override
  void initState() {
    super.initState();
    _active = widget.active;
  }

  @override
  void didUpdateWidget(WotFab old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active) _active = widget.active;
  }

  bool get _hasActions => widget.actions != null && widget.actions!.isNotEmpty;

  /// 切换展开/收起。
  void _toggle() {
    if (!_hasActions) {
      // 无动作菜单时仅触发点击回调。
      widget.onClick?.call();
      return;
    }
    final next = !_active;
    setState(() => _active = next);
    widget.onActiveChange?.call(next);
    widget.onClick?.call();
  }

  void _close() {
    if (!_active) return;
    setState(() => _active = false);
    widget.onActiveChange?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();
    final scheme = context.wotScheme;
    final color = widget.bgColor ?? _colorOf(scheme, widget.type);

    final body = _buildTrigger(scheme, color);

    Widget positioned;
    if (widget.position == WotFabPosition.custom && widget.customPosition != null) {
      positioned = Positioned(
        left: widget.customPosition!.dx,
        top: widget.customPosition!.dy,
        child: body,
      );
    } else if (widget.bottom != null || widget.right != null) {
      final bottomPadding = widget.safeArea ? MediaQuery.of(context).padding.bottom : 0.0;
      positioned = Positioned(
        right: widget.right ?? 16,
        bottom: (widget.bottom ?? 24) + bottomPadding,
        child: body,
      );
    } else {
      // 未提供定位参数时退回纯按钮（由调用方自行 Positioned 包裹）。
      positioned = body;
    }

    // 展开时点击遮罩自动收起。
    if (_active && widget.closeOnClickOverlay) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              child: const SizedBox.expand(),
            ),
          ),
          positioned,
        ],
      );
    }
    return positioned;
  }

  /// 主按钮 + 展开后的动作列表。
  Widget _buildTrigger(WotScheme scheme, Color color) {
    final main = _buildMainButton(scheme, color);

    if (!_hasActions) return main;

    final actions = widget.actions!;
    final alignEnd = widget.position != WotFabPosition.left;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        for (final a in actions)
          IgnorePointer(
            ignoring: !_active,
            child: AnimatedOpacity(
              opacity: _active ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: _buildAction(scheme, a),
            ),
          ),
        const SizedBox(height: 12),
        main,
      ],
    );
  }

  /// 主按钮本体（含状态红点）。
  Widget _buildMainButton(WotScheme scheme, Color color) {
    final hasText = widget.text != null;
    Widget button = Material(
      color: color,
      // 带文字时改为胶囊（自适应宽度），否则为圆形，避免内容溢出 48px。
      shape: hasText ? const StadiumBorder() : const CircleBorder(),
      elevation: 4,
      child: InkWell(
        // 圆角统一用 StadiumBorder，保证点击水波与形状一致。
        customBorder: hasText ? const StadiumBorder() : const CircleBorder(),
        onTap: _toggle,
        child: ConstrainedBox(
          constraints: hasText ? const BoxConstraints(minHeight: 48) : const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Padding(
            padding: hasText ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12) : EdgeInsets.zero,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WotIcon(name: widget.icon, size: 22, color: widget.iconColor),
                  if (widget.text != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      widget.text!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.status) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: scheme.dangerMain,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.filledContent, width: 2),
              ),
            ),
          ),
        ],
      );
    }
    return button;
  }

  /// 单个动作按钮（圆形，可带徽标）。
  Widget _buildAction(WotScheme scheme, WotFabAction a) {
    Widget circle = Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.filledContent,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: a.icon != null
          ? WotIcon(name: a.icon!, size: 18, color: scheme.textMain)
          : (a.text != null
              ? Text(a.text!, style: TextStyle(fontSize: 12, color: scheme.textMain))
              : const SizedBox.shrink()),
    );

    if (a.badge != null || a.isDot) {
      circle = WotBadge(
        modelValue: a.badge ?? 0,
        max: a.max,
        isDot: a.isDot,
        child: circle,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: a.onClick,
        child: circle,
      ),
    );
  }

  Color _colorOf(WotScheme scheme, WotFabType t) => switch (t) {
        WotFabType.success => scheme.successMain,
        WotFabType.info => scheme.textSecondary,
        WotFabType.warning => scheme.warningMain,
        WotFabType.danger => scheme.dangerMain,
        WotFabType.primary => scheme.primaryOf(6),
      };
}