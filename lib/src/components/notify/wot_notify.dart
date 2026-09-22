import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 顶部通知类型。
///
/// 对齐 wot：`primary`（主色）、`success`（成功）、`warning`（警告）、`error`（危险）。
/// `info` 为 `primary` 的别名，语义相同。
enum WotNotifyType { primary, success, warning, error, info }

/// 通知显示位置，对应 wot `position`。
enum WotNotifyPosition { top, bottom }

/// 命令式顶部通知服务，对应 wot `useNotify`。
class WotNotify {
  WotNotify._();

  static OverlayEntry? _entry;
  static Timer? _timer;
  static VoidCallback? _onClosed;

  /// 展示顶部通知。
  ///
  /// [type] 通知类型（primary/success/warning/error/info）；[duration] 展示时长；
  /// [onClose] 超时自动消失后的回调；[onClosed] 任何方式关闭（超时 / 点击关闭按钮 /
  /// 手动 [close]）后统一触发的回调。
  ///
  /// D 类 P1 补齐：[position] 显示在顶部或底部；[color] 文字与图标颜色（默认白）；
  /// [background] 背景色（覆盖 type 预设色）；[closable] 显示关闭按钮；
  /// [safeHeight] 在安全区之外的额外偏移；[onClick] 点击通知条回调；
  /// [onOpened] 通知插入后触发。
  static void show(
    BuildContext context, {
    String message = '',
    WotNotifyType type = WotNotifyType.info,
    Duration duration = const Duration(milliseconds: 3000),
    VoidCallback? onClose,
    WotNotifyPosition position = WotNotifyPosition.top,
    Color? color,
    Color? background,
    bool closable = false,
    double safeHeight = 0,
    VoidCallback? onClick,
    VoidCallback? onOpened,
    VoidCallback? onClosed,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    _timer?.cancel();
    final e = _entry;
    if (e != null && e.mounted) e.remove();

    _onClosed = onClosed;
    void dismiss() {
      _timer?.cancel();
      final cur = _entry;
      if (cur != null && cur.mounted) cur.remove();
      _entry = null;
      _onClosed?.call();
      _onClosed = null;
    }

    final entry = OverlayEntry(
      builder: (ctx) => _NotifyBar(
        message: message,
        type: type,
        position: position,
        color: color,
        background: background,
        closable: closable,
        safeHeight: safeHeight,
        onClick: onClick,
        onDismiss: dismiss,
      ),
    );
    _entry = entry;
    overlay.insert(entry);
    onOpened?.call();

    _timer = Timer(duration, () {
      if (entry.mounted) entry.remove();
      if (_entry == entry) _entry = null;
      onClose?.call();
      _onClosed?.call();
      _onClosed = null;
    });
  }

  static void primary(BuildContext context, String message) =>
      show(context, message: message, type: WotNotifyType.primary);

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: WotNotifyType.success);
  static void error(BuildContext context, String message) =>
      show(context, message: message, type: WotNotifyType.error);
  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: WotNotifyType.warning);

  /// 立即关闭当前顶部通知（不触发 [WotNotify.show] 的 [onClose]，onClose 仅在超时自动消失时触发；
  /// [onClosed] 在包括本方法在内的任何关闭方式后统一触发）。
  static void close(BuildContext context) {
    _timer?.cancel();
    final e = _entry;
    if (e != null) {
      if (e.mounted) e.remove();
      _entry = null;
      _onClosed?.call();
      _onClosed = null;
    }
  }
}

class _NotifyBar extends StatelessWidget {
  const _NotifyBar({
    required this.message,
    required this.type,
    required this.position,
    this.color,
    this.background,
    required this.closable,
    required this.safeHeight,
    this.onClick,
    required this.onDismiss,
  });
  final String message;
  final WotNotifyType type;
  final WotNotifyPosition position;
  final Color? color;
  final Color? background;
  final bool closable;
  final double safeHeight;
  final VoidCallback? onClick;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final bgColor = background ?? switch (type) {
      WotNotifyType.success => scheme.successMain,
      WotNotifyType.warning => scheme.warningMain,
      WotNotifyType.error => scheme.dangerMain,
      WotNotifyType.primary || WotNotifyType.info => scheme.primaryOf(6),
    };
    final icon = switch (type) {
      WotNotifyType.success => Icons.check_circle,
      WotNotifyType.warning => Icons.error_outline,
      WotNotifyType.error => Icons.cancel,
      WotNotifyType.primary || WotNotifyType.info => Icons.info_outline,
    };
    final contentColor = color ?? Colors.white;

    final bar = Material(
      color: bgColor,
      child: SafeArea(
        bottom: position == WotNotifyPosition.top,
        top: position == WotNotifyPosition.bottom,
        child: GestureDetector(
          onTap: onClick,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: contentColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: contentColor, fontSize: 14),
                  ),
                ),
                if (closable) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDismiss,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close, color: contentColor, size: 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return position == WotNotifyPosition.top
        ? Positioned(top: safeHeight, left: 0, right: 0, child: bar)
        : Positioned(bottom: safeHeight, left: 0, right: 0, child: bar);
  }
}