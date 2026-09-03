import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 操作表单项。
class WotActionSheetItem {
  const WotActionSheetItem({
    required this.name,
    this.color,
    this.disabled = false,
    this.loading = false,
    this.icon,
  });
  final String name;
  final Color? color;
  final bool disabled;
  final bool loading;
  final String? icon;
}

/// 操作菜单（底部弹出选项列表），对应 wot `wd-action-sheet`。
///
/// 命令式：调用 [WotActionSheet.show] 弹出，点击返回对应项，点击遮罩返回 null。
class WotActionSheet {
  WotActionSheet._();

  static Future<WotActionSheetItem?> show(
    BuildContext context, {
    List<WotActionSheetItem> actions = const [],
    String? title,
    String? cancelText,
  }) {
    return showModalBottomSheet<WotActionSheetItem>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ActionSheetPanel(
        actions: actions,
        title: title,
        cancelText: cancelText ?? '取消',
      ),
    );
  }
}

class _ActionSheetPanel extends StatelessWidget {
  const _ActionSheetPanel({
    required this.actions,
    this.title,
    required this.cancelText,
  });
  final List<WotActionSheetItem> actions;
  final String? title;
  final String cancelText;

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

    final cancel = Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Text(cancelText,
              style: TextStyle(fontSize: 14, color: scheme.textSecondary)),
        ),
      ),
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [panel, cancel]),
      ),
    );
  }

  Widget _item(BuildContext context, WotActionSheetItem a) {
    final scheme = context.wotScheme;
    final color = a.color ?? scheme.textMain;
    return InkWell(
      onTap: a.disabled
          ? null
          : () => Navigator.of(context).pop(a),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.borderLight, width: 0.5)),
        ),
        child: Text(
          a.name,
          style: TextStyle(
            fontSize: 15,
            color: a.disabled ? scheme.textDisabled : color,
          ),
        ),
      ),
    );
  }
}