import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 命令式对话框服务，对应 wot `useDialog`（+ wd-dialog 渲染）。
class WotDialog {
  WotDialog._();

  /// 展示确认框，返回是否确认。
  static Future<bool> confirm(
    BuildContext context, {
    required String message,
    String title = '提示',
    String confirmText = '确定',
    String cancelText = '取消',
    bool showCancelButton = true,
    WotDialogType type = WotDialogType.info,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => WotDialogView(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        showCancelButton: showCancelButton,
        type: type,
      ),
    );
    return ok ?? false;
  }

  /// 提示框（仅确定）。
  static Future<void> alert(
    BuildContext context, {
    required String message,
    String title = '提示',
    String confirmText = '确定',
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => WotDialogView(
        title: title,
        message: message,
        confirmText: confirmText,
        showCancelButton: false,
      ),
    );
  }

  /// 展示自定义内容对话框并返回结果。
  static Future<T?> show<T>(BuildContext context, Widget content) {
    return showDialog<T>(
      context: context,
      builder: (_) => content,
    );
  }
}

/// 对话框类型（决定左侧辅助色条，对齐 wot `WotDialogType`）。
enum WotDialogType { info, warning, error, success }

/// 对话框内容视图（内部用于命令式，也可内嵌）。
class WotDialogView extends StatelessWidget {
  const WotDialogView({
    super.key,
    this.title,
    this.message,
    this.showTitle = true,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.showCancelButton = true,
    this.type = WotDialogType.info,
    this.onConfirm,
    this.onCancel,
    this.content,
    this.confirmButtonColor,
  });

  final String? title;
  final String? message;
  final bool showTitle;
  final String confirmText;
  final String cancelText;
  final bool showCancelButton;
  final WotDialogType type;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? content;
  final Color? confirmButtonColor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = confirmButtonColor ?? scheme.primaryOf(6);

    final messageWidget = content ??
        (message != null
            ? Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: scheme.textMain),
              )
            : null);

    return Dialog(
      backgroundColor: scheme.filledOppo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showTitle && title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: scheme.textMain,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ?messageWidget,
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextButton(
                      onPressed: () {
                        onCancel?.call();
                        Navigator.of(context).pop(false);
                      },
                      child: Text(cancelText,
                          style: TextStyle(color: scheme.textSecondary)),
                    ),
                  ),
                ),
                if (showCancelButton) const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        onConfirm?.call();
                        Navigator.of(context).pop(true);
                      },
                      child: Text(confirmText),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}