import 'package:flutter/material.dart';

import '../../locale/wot_messages.dart';
import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';

/// 命令式对话框服务，对应 wot `useDialog`（+ wd-dialog 渲染）。
class WotDialog {
  WotDialog._();

  /// 展示确认框，返回是否确认。
  ///
  /// 补充参数：[showConfirmButton] 是否显示确定按钮；[confirmButtonText]/[cancelButtonText]
  /// 覆盖默认按钮文案；[showClose] 是否显示右上角关闭按钮；[onConfirm]/[onCancel]/[onClose]
  /// 分别为确定/取消/关闭回调；[confirmColor] 确定按钮高亮颜色（为空时取主题主色）。
  static Future<bool> confirm(
    BuildContext context, {
    required String message,
    String? title,
    String? confirmText,
    String? cancelText,
    bool showCancelButton = true,
    WotDialogType type = WotDialogType.info,
    bool showConfirmButton = true,
    String? confirmButtonText,
    String? cancelButtonText,
    bool showClose = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    VoidCallback? onClose,
    Color? confirmColor,
    Future<bool> Function()? beforeConfirm,
  }) async {
    // 确认前拦截（D 类 P1）：返回 false 时取消本次弹窗，返回 false。
    if (beforeConfirm != null) {
      final pass = await beforeConfirm();
      if (!pass || !context.mounted) return false;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => WotDialogView(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        showCancelButton: showCancelButton,
        type: type,
        showConfirmButton: showConfirmButton,
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
        showClose: showClose,
        onConfirm: onConfirm,
        onCancel: onCancel,
        onClose: onClose,
        confirmColor: confirmColor,
      ),
    );
    return ok ?? false;
  }

  /// 提示框（仅确定）。
  static Future<void> alert(
    BuildContext context, {
    required String message,
    String? title,
    String? confirmText,
    bool showClose = false,
    bool showConfirmButton = true,
    String? confirmButtonText,
    WotDialogType type = WotDialogType.info,
    VoidCallback? onConfirm,
    VoidCallback? onClose,
    Color? confirmColor,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => WotDialogView(
        title: title,
        message: message,
        confirmText: confirmText,
        showCancelButton: false,
        showConfirmButton: showConfirmButton,
        confirmButtonText: confirmButtonText,
        type: type,
        showClose: showClose,
        onConfirm: onConfirm,
        onClose: onClose,
        confirmColor: confirmColor,
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
    this.confirmText,
    this.cancelText,
    this.showCancelButton = true,
    this.showConfirmButton = true,
    this.type = WotDialogType.info,
    this.onConfirm,
    this.onCancel,
    this.onClose,
    this.content,
    this.confirmButtonColor,
    this.confirmColor,
    this.confirmButtonText,
    this.cancelButtonText,
    this.showClose = false,
  });

  /// 标题文案。
  final String? title;

  /// 提示文案（无 [content] 时以居中文案文本展示）。
  final String? message;

  /// 是否显示标题；默认 true。
  final bool showTitle;

  /// 确定按钮文案，默认“确定”。
  final String? confirmText;

  /// 取消按钮文案，默认“取消”。
  final String? cancelText;

  /// 是否显示取消按钮；默认 true。
  final bool showCancelButton;

  /// 是否显示确定按钮；默认 true（对齐 wot `showConfirmButton`）。
  final bool showConfirmButton;

  /// 对话框类型（决定左侧辅助色条），可选 [WotDialogType]，默认 info。
  final WotDialogType type;

  /// 点击确定按钮的回调（弹窗关闭后触发）。
  final VoidCallback? onConfirm;

  /// 点击取消按钮的回调（弹窗关闭后触发）。
  final VoidCallback? onCancel;

  /// 点击右上角关闭按钮（[showClose] 为 true 时可见）的回调。
  final VoidCallback? onClose;

  /// 自定义内容 widget（优先级高于 [message]）。
  final Widget? content;

  /// 确定按钮高亮颜色；为空时取主题主色。
  final Color? confirmButtonColor;

  /// 确定按钮高亮颜色的别名（与 [confirmButtonColor] 二选一，同时设置时优先 [confirmButtonColor]）。
  ///
  /// 对齐 wot `confirmButtonProps.color`（主色语义）。
  final Color? confirmColor;

  /// 确定按钮文案高级别名，覆盖 [confirmText]（对齐 wot `confirmButtonText`）。
  final String? confirmButtonText;

  /// 取消按钮文案高级别名，覆盖 [cancelText]（对齐 wot `cancelButtonText`）。
  final String? cancelButtonText;

  /// 是否显示右上角关闭按钮（对齐 wot `showClose`）；点击触发 [onClose]。
  final bool showClose;

  /// [type] 对应的左侧辅助色条颜色。
  Color _accent(WotScheme scheme, Color primary) => switch (type) {
        WotDialogType.success => scheme.successMain,
        WotDialogType.warning => scheme.warningMain,
        WotDialogType.error => scheme.dangerMain,
        WotDialogType.info => primary,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = confirmButtonColor ?? confirmColor ?? scheme.primaryOf(6);
    final confirmLabel = confirmButtonText ??
        confirmText ??
        tr(context, 'wot.common.confirm');
    final cancelLabel = cancelButtonText ??
        cancelText ??
        tr(context, 'wot.common.cancel');

    final messageWidget = content ??
        (message != null
            ? Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: scheme.textMain),
              )
            : null);

    final buttons = <Widget>[];
    if (showCancelButton) {
      buttons.add(
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextButton(
              // 与确认按钮保持一致的圆角；用浅灰实心底，使其与弹窗白底区分开来。
              style: TextButton.styleFrom(
                backgroundColor: scheme.filledContent,
                foregroundColor: scheme.textMain,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                onCancel?.call();
                Navigator.of(context).pop(false);
              },
              child: Text(cancelLabel,
                  style: TextStyle(color: scheme.textMain)),
            ),
          ),
        ),
      );
    }
    if (showConfirmButton) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));
      buttons.add(
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
              child: Text(confirmLabel),
            ),
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: scheme.filledOppo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // 左侧辅助色条需随圆角裁切，否则会顶出圆角外。
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // [type] 对应的左侧辅助色条（宽 4，铺满高度）。
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: _accent(scheme, primary)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, showClose ? 32 : 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showTitle && title != null) ...[
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: scheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ?messageWidget,
                if (buttons.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(children: buttons),
                ],
              ],
            ),
          ),
          if (showClose)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(Icons.close, size: 18, color: scheme.iconAuxiliary),
                onPressed: () {
                  onClose?.call();
                  Navigator.of(context).pop(false);
                },
              ),
            ),
        ],
      ),
    );
  }
}