import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 顶部通知类型。
enum WotNotifyType { success, warning, error, info }

/// 命令式顶部通知服务，对应 wot `useNotify`。
class WotNotify {
  WotNotify._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    String message = '',
    WotNotifyType type = WotNotifyType.info,
    Duration duration = const Duration(milliseconds: 2500),
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
      _entry = null;
    });
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: WotNotifyType.success);
  static void error(BuildContext context, String message) =>
      show(context, message: message, type: WotNotifyType.error);
  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: WotNotifyType.warning);
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
      WotNotifyType.info => scheme.primaryOf(6),
    };
    final icon = switch (type) {
      WotNotifyType.success => Icons.check_circle,
      WotNotifyType.warning => Icons.error_outline,
      WotNotifyType.error => Icons.cancel,
      WotNotifyType.info => Icons.info_outline,
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