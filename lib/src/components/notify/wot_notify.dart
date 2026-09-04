import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 顶部通知类型。
///
/// 对齐 wot：`primary`（主色）、`success`（成功）、`warning`（警告）、`error`（危险）。
/// `info` 为 `primary` 的别名，语义相同。
enum WotNotifyType { primary, success, warning, error, info }

/// 命令式顶部通知服务，对应 wot `useNotify`。
class WotNotify {
  WotNotify._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  /// 展示顶部通知。
  ///
  /// 补充参数：[type] 通知类型（primary/success/warning/error/info）；[duration] 展示时长；
  /// [onClose] 关闭（超时自动消失）后的回调。
  static void show(
    BuildContext context, {
    String message = '',
    WotNotifyType type = WotNotifyType.info,
    Duration duration = const Duration(milliseconds: 2500),
    VoidCallback? onClose,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    _timer?.cancel();
    final e = _entry;
    if (e != null && e.mounted) e.remove();

    final entry = OverlayEntry(
      builder: (ctx) => _NotifyBar(message: message, type: type),
    );
    _entry = entry;
    overlay.insert(entry);

    _timer = Timer(duration, () {
      if (entry.mounted) entry.remove();
      if (_entry == entry) _entry = null;
      onClose?.call();
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

  /// 立即关闭当前顶部通知（不触发 [WotNotify.show] 的 [onClose]，onClose 仅在超时自动消失时触发）。
  static void close(BuildContext context) {
    _timer?.cancel();
    final e = _entry;
    if (e != null) {
      if (e.mounted) e.remove();
      _entry = null;
    }
  }
}

class _NotifyBar extends StatelessWidget {
  const _NotifyBar({required this.message, required this.type});
  final String message;
  final WotNotifyType type;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final color = switch (type) {
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

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: color,
        child: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}