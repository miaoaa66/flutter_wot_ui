import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../loading/wot_loading.dart';

/// 轻提示内容类型。
enum WotToastType { success, warning, error, loading, info }

/// 命令式轻提示服务，对应 wot `useToast`（+ wd-toast 渲染）。
///
/// 基于 [OverlayEntry] + 队列实现：后到的 toast 会顶替前一个（wot 队列语义）。
class WotToast {
  WotToast._();

  static OverlayEntry? _current;
  static Timer? _timer;

  static OverlayState? _overlayOf(BuildContext context) =>
      Overlay.of(context, rootOverlay: true);

  static void _show(
    BuildContext context, {
    required Widget child,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    final overlay = _overlayOf(context);
    if (overlay == null) return;
    _dismiss(overlay);

    final entry = OverlayEntry(
      builder: (context) => _ToastOverlay(child: child),
    );
    _current = entry;
    overlay.insert(entry);

    _timer = Timer(duration, () {
      entry.remove();
      _current = null;
    });
  }

  static void _dismiss(OverlayState overlay) {
    _timer?.cancel();
    final e = _current;
    if (e != null && e.mounted) e.remove();
    _current = null;
  }

  static void text(BuildContext context, String msg, {Duration? duration}) {
    _show(context, child: _ToastText(msg: msg), duration: duration ?? const Duration(milliseconds: 2000));
  }

  /// 带图标状态 toast。
  static void show(
    BuildContext context,
    String msg, {
    WotToastType type = WotToastType.info,
    Duration? duration,
  }) {
    _show(
      context,
      child: _ToastIcon(type: type, msg: msg),
      duration: duration ?? const Duration(milliseconds: 2000),
    );
  }

  /// 成功提示。
  static void success(BuildContext context, String msg, {Duration? duration}) =>
      show(context, msg, type: WotToastType.success, duration: duration);

  /// 失败提示。
  static void error(BuildContext context, String msg, {Duration? duration}) =>
      show(context, msg, type: WotToastType.error, duration: duration);

  /// 加载中（不自动关闭）。
  static void loading(BuildContext context, String msg) {
    _show(context, child: _ToastIcon(type: WotToastType.loading, msg: msg));
  }

  /// 关闭当前 toast。
  static void dismiss(BuildContext context) {
    final overlay = _overlayOf(context);
    if (overlay == null) return;
    _dismiss(overlay);
  }
}

class _ToastOverlay extends StatelessWidget {
  const _ToastOverlay({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Center(child: child),
      ),
    );
  }
}

class _ToastText extends StatelessWidget {
  const _ToastText({required this.msg});
  final String msg;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.opacTooltipToastCover,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }
}

class _ToastIcon extends StatelessWidget {
  const _ToastIcon({required this.type, required this.msg});
  final WotToastType type;
  final String msg;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final isLoading = type == WotToastType.loading;
    final color = switch (type) {
      WotToastType.success => const Color(0xFF12B886),
      WotToastType.warning => const Color(0xFFFF9F0F),
      WotToastType.error => const Color(0xFFF14646),
      _ => Colors.white,
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 90),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: scheme.opacTooltipToastCover,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            WotLoading(size: 30, loadingColor: Colors.white)
          else
            Icon(_iconOf(type), size: 30, color: color),
          if (msg.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              msg,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconOf(WotToastType t) => switch (t) {
        WotToastType.success => Icons.check_circle,
        WotToastType.warning => Icons.error_outline,
        WotToastType.error => Icons.cancel,
        WotToastType.info => Icons.info_outline,
        WotToastType.loading => Icons.autorenew,
      };
}