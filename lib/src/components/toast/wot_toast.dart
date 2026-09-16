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

  /// [duration] 为 null 时表示常驻不自动关闭（loading 语义），只能由 [close] / 下一个 toast 顶替。
  static void _show(
    BuildContext context, {
    required Widget child,
    Duration? duration = const Duration(milliseconds: 2000),
    String position = 'center',
  }) {
    final overlay = _overlayOf(context);
    if (overlay == null) return;
    _dismiss(overlay);

    final entry = OverlayEntry(
      builder: (context) => _ToastOverlay(position: position, child: child),
    );
    _current = entry;
    overlay.insert(entry);

    final d = duration;
    if (d == null) return;
    _timer = Timer(d, () {
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

  static void text(BuildContext context, String msg,
      {Duration? duration, String position = 'center'}) {
    _show(
        context,
        child: _ToastText(msg: msg),
        duration: duration ?? const Duration(milliseconds: 2000),
        position: position);
  }

  /// 带图标状态 toast。
  ///
  /// 补充参数：[duration] 展示时长；[position] 展示位置，可选 `top`/`center`/`bottom`；
  /// [icon] 自定义图标（覆盖 [type] 对应默认图标）。
  static void show(
    BuildContext context,
    String msg, {
    WotToastType type = WotToastType.info,
    Duration? duration,
    String position = 'center',
    IconData? icon,
  }) {
    _show(
      context,
      child: _ToastIcon(type: type, msg: msg, icon: icon),
      duration: duration ?? const Duration(milliseconds: 2000),
      position: position,
    );
  }

  /// 成功提示。
  static void success(BuildContext context, String msg,
          {Duration? duration, String position = 'center'}) =>
      show(context, msg,
          type: WotToastType.success,
          duration: duration,
          position: position);

  /// 失败提示。
  static void error(BuildContext context, String msg,
          {Duration? duration, String position = 'center'}) =>
      show(context, msg,
          type: WotToastType.error,
          duration: duration,
          position: position);

  /// 警告提示。
  static void warning(BuildContext context, String msg,
          {Duration? duration, String position = 'center'}) =>
      show(context, msg,
          type: WotToastType.warning,
          duration: duration,
          position: position);

  /// 常规提示（info 语义）。
  static void info(BuildContext context, String msg,
          {Duration? duration, String position = 'center'}) =>
      show(context, msg, duration: duration, position: position);

  /// 加载中（不自动关闭，须显式调用 [close]）。
  static void loading(BuildContext context, String msg,
      {String position = 'center'}) {
    _show(
        context,
        child: _ToastIcon(type: WotToastType.loading, msg: msg),
        duration: null,
        position: position);
  }

  /// 关闭当前 toast（wot `close` 语义别名）。
  static void close(BuildContext context) {
    final overlay = _overlayOf(context);
    if (overlay == null) return;
    _dismiss(overlay);
  }

  /// 关闭当前 toast。
  static void dismiss(BuildContext context) => close(context);
}

class _ToastOverlay extends StatelessWidget {
  const _ToastOverlay({required this.child, this.position = 'center'});
  final Widget child;
  final String position;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: _positioned(child),
      ),
    );
  }

  Widget _positioned(Widget child) {
    switch (position) {
      case 'top':
        return Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Align(alignment: Alignment.topCenter, child: child),
        );
      case 'bottom':
        return Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Align(alignment: Alignment.bottomCenter, child: child),
        );
      default:
        return Align(alignment: Alignment.center, child: child);
    }
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
  const _ToastIcon({required this.type, required this.msg, this.icon});
  final WotToastType type;
  final String msg;

  /// 自定义图标，覆盖 [type] 对应的默认图标。
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final isLoading = type == WotToastType.loading;
    final color = switch (type) {
      WotToastType.success => scheme.successMain,
      WotToastType.warning => scheme.warningMain,
      WotToastType.error => scheme.dangerMain,
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
            Icon(icon ?? _iconOf(type), size: 30, color: color),
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