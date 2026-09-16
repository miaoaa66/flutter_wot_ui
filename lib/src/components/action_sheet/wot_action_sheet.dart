import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';
import '../loading/wot_loading.dart';

/// 操作表单项。
class WotActionSheetItem {
  const WotActionSheetItem({
    required this.name,
    this.color,
    this.disabled = false,
    this.loading = false,
    this.icon,
  });

  /// 选项名称。
  final String name;

  /// 选项文字颜色。
  final Color? color;

  /// 是否禁用，禁用后不可点击，默认 false。
  final bool disabled;

  /// 是否加载中，默认 false。
  final bool loading;

  /// 选项图标名称（可选）。
  final String? icon;
}

/// 操作菜单（底部弹出选项列表），对应 wot `wd-action-sheet`。
///
/// 命令式：调用 [WotActionSheet.show] 弹出，点击返回对应项，点击遮罩返回 null。
///
/// 补充参数：[showCancel] 是否显示取消按钮（默认 true）；[onSelect] 选中项回调；
/// [onCancel] 点击取消按钮回调。
class WotActionSheet {
  WotActionSheet._();

  static Future<WotActionSheetItem?> show(
    BuildContext context, {
    /// 选项列表。
    List<WotActionSheetItem> actions = const [],

    /// 标题。
    String? title,

    /// 取消按钮文案，默认「取消」。
    String? cancelText,

    /// 是否显示取消按钮；默认 true。
    bool showCancel = true,

    /// 选中某项时的回调（禁用/加载中不会触发）。
    ValueChanged<WotActionSheetItem>? onSelect,

    /// 点击取消按钮时的回调。
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet<WotActionSheetItem>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ActionSheetPanel(
        actions: actions,
        title: title,
        cancelText: cancelText ?? '取消',
        showCancel: showCancel,
        onSelect: onSelect,
        onCancel: onCancel,
      ),
    );
  }
}

class _ActionSheetPanel extends StatelessWidget {
  const _ActionSheetPanel({
    required this.actions,
    this.title,
    required this.cancelText,
    this.showCancel = true,
    this.onSelect,
    this.onCancel,
  });
  final List<WotActionSheetItem> actions;
  final String? title;
  final String cancelText;
  final bool showCancel;
  final ValueChanged<WotActionSheetItem>? onSelect;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final bg = scheme.filledContent;

    Widget group(List<Widget> children) {
      return Material(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      );
    }

    final items = <Widget>[
      for (final a in actions) _item(context, a),
    ];

    final panel = group([
      if (title != null)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          child: Text(
            title!,
            style: TextStyle(fontSize: 13, color: scheme.textAuxiliary),
          ),
        ),
      ...items,
    ]);

    final cancelWidgets = <Widget>[
      panel,
      if (showCancel)
        Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              onCancel?.call();
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              child: Text(cancelText,
                  style: TextStyle(fontSize: 14, color: scheme.textSecondary)),
            ),
          ),
        ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
            mainAxisSize: MainAxisSize.min, children: cancelWidgets),
      ),
    );
  }

  Widget _item(BuildContext context, WotActionSheetItem a) {
    final scheme = context.wotScheme;
    final color = a.color ?? scheme.textMain;
    return InkWell(
      onTap: a.disabled || a.loading
          ? null
          : () {
              onSelect?.call(a);
              Navigator.of(context).pop(a);
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.borderLight, width: 0.5)),
        ),
        // 加载中优先展示 loading 指示器，而非文字。
        child: a.loading
            ? WotLoading(size: 18, loadingColor: scheme.primaryOf(6))
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (a.icon != null && a.icon!.isNotEmpty) ...[
                    WotIcon(
                      name: a.icon,
                      size: 18,
                      color: a.disabled ? scheme.textDisabled : color,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      a.name,
                      style: TextStyle(
                        fontSize: 15,
                        color: a.disabled ? scheme.textDisabled : color,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}