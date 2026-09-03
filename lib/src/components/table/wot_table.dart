import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 列对齐。
enum WotTableAlign { left, center, right }

/// 表格列定义，对应 wot `wd-table-column`。
class WotTableColumn {
  const WotTableColumn({
    required this.prop,
    this.label,
    this.width,
    this.align = WotTableAlign.left,
    this.bordered = false,
    this.formatter,
  });

  /// 数据字段名。
  final String prop;

  /// 列头文本。
  final String? label;

  /// 列宽（逻辑像素）。
  final double? width;

  /// 对齐方式。
  final WotTableAlign align;

  /// 是否启用该列单元格边框。
  final bool bordered;

  /// 单元格自定义格式化。
  final String Function(dynamic value, dynamic row)? formatter;

  TextAlign get _textAlign => switch (align) {
        WotTableAlign.left => TextAlign.left,
        WotTableAlign.center => TextAlign.center,
        WotTableAlign.right => TextAlign.right,
      };
}

/// 表格，对应 wot `wd-table`。
///
/// 参数对齐 wot：`data`（行数据）、`columns`（列定义）、`stripe`（斑马纹）、
/// `border`（是否显示边框）、`maxHeight`、`emptyText`、`showHead`、`onRowClick`。
class WotTable extends StatelessWidget {
  const WotTable({
    super.key,
    required this.columns,
    this.data = const [],
    this.stripe = false,
    this.border = false,
    this.maxHeight,
    this.emptyText = '暂无数据',
    this.showHead = true,
    this.headerRowHeight = 40,
    this.rowHeight = 44,
    this.onRowClick,
  });

  final List<WotTableColumn> columns;
  final List<Map<String, dynamic>> data;
  final bool stripe;
  final bool border;
  final double? maxHeight;
  final String emptyText;
  final bool showHead;
  final double headerRowHeight;
  final double rowHeight;

  /// 行点击回调。
  final void Function(Map<String, dynamic> row, int index)? onRowClick;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;

    final borderColor = scheme.borderLight;

    Widget cell(Widget child, {double? width, TextAlign? align, bool? bordered}) {
      final cellBorder = (border || (bordered ?? false))
          ? Border(
              right: BorderSide(color: borderColor, width: 0.5),
              bottom: BorderSide(color: borderColor, width: 0.5),
            )
          : const Border();
      return Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: align == TextAlign.right
            ? Alignment.centerRight
            : align == TextAlign.center
                ? Alignment.center
                : Alignment.centerLeft,
        decoration: BoxDecoration(border: cellBorder),
        child: child,
      );
    }

    Widget buildRow(Map<String, dynamic> row, int rowIndex) {
      final isStripe = stripe && rowIndex.isOdd;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onRowClick == null ? null : () => onRowClick!(row, rowIndex),
        child: Container(
          height: rowHeight,
          color: isStripe ? scheme.filledContent : Colors.transparent,
          child: Row(
            children: [
              for (final c in columns)
                cell(
                  Text(
                    c.formatter != null ? c.formatter!(row[c.prop], row) : '${row[c.prop] ?? ''}',
                    style: TextStyle(fontSize: 13, color: scheme.textMain),
                    textAlign: c._textAlign,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  width: c.width,
                  align: c._textAlign,
                  bordered: c.bordered,
                ),
            ],
          ),
        ),
      );
    }

    final table = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHead)
          Container(
            height: headerRowHeight,
            color: scheme.filledContent,
            child: Row(
              children: [
                for (final c in columns)
                  cell(
                    Text(
                      c.label ?? c.prop,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.textMain),
                      textAlign: c._textAlign,
                    ),
                    width: c.width,
                    align: c._textAlign,
                    bordered: true,
                  ),
              ],
            ),
          ),
        if (data.isEmpty)
          Container(
            height: 120,
            alignment: Alignment.center,
            child: Text(emptyText, style: TextStyle(color: scheme.textAuxiliary, fontSize: 13)),
          )
        else
          for (var i = 0; i < data.length; i++) buildRow(data[i], i),
      ],
    );

    // 首列左边框。
    Widget wrap = table;
    if (maxHeight != null) {
      wrap = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight!),
        child: SingleChildScrollView(child: table),
      );
    }
    return wrap;
  }
}