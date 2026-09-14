import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';

/// 列对齐。
enum WotTableAlign { left, center, right }

/// 列固定方向，对应 wot `fixed`（`left`/`right`）。
///
/// 仅当表格设置了 [WotTable.maxHeight]（启用有界滚动）且存在横向滚动时才真正把列吸在左右两侧。
enum WotTableFixed { left, right }

/// 单元格插槽：返回任意控件以展示输入框、按钮、开关等。
typedef WotTableCellBuilder = Widget Function(
    dynamic value, Map<String, dynamic> row, int rowIndex);

/// 表头排序方向。
enum WotTableSortDirection { none, ascending, descending }

/// 行选择模式。
enum WotTableRowSelection {
  /// 单选，点击选择列切换。
  single,

  /// 多选，表头含全选复选框。
  multiple,
}

/// 表格列定义，对应 wot `wd-table-column`。
///
/// - 文本格式化用 [formatter]（返回字符串）。
/// - 任意控件插槽用 [builder]（返回 [Widget]，优先级高于 [formatter]）。
/// - [fixed] 可将某列固定在表格左侧或右侧（配合 [WotTable.maxHeight]）。
/// - [sortable] 开启表头排序（配合 [WotTable.onSort]）。
class WotTableColumn {
  const WotTableColumn({
    required this.prop,
    this.label,
    this.width,
    this.align = WotTableAlign.left,
    this.bordered = false,
    this.formatter,
    this.builder,
    this.fixed,
    this.sortable = false,
  });

  /// 数据字段名。
  final String prop;

  /// 列头文本。
  final String? label;

  /// 列宽（逻辑像素）。固定列（[fixed]）建议显式设置宽度；未设置宽度时自动平摊剩余空间。
  final double? width;

  /// 对齐方式。
  final WotTableAlign align;

  /// 是否启用该列单元格边框。
  final bool bordered;

  /// 单元格文本格式化，返回字符串（仅修饰文本）。
  final String Function(dynamic value, dynamic row)? formatter;

  /// 单元格控件插槽，返回任意 [Widget]（优先级高于 [formatter]）。
  final WotTableCellBuilder? builder;

  /// 列固定方向（`left`/`right`）。
  final WotTableFixed? fixed;

  /// 是否允许点击表头对该列排序。
  final bool sortable;

  TextAlign get _textAlign => switch (align) {
        WotTableAlign.left => TextAlign.left,
        WotTableAlign.center => TextAlign.center,
        WotTableAlign.right => TextAlign.right,
      };
}

/// 表格，对应 wot `wd-table`。
///
/// 内置能力：
/// - 设置 [maxHeight] 后表头固定、数据虚拟滚动（`ListView.builder`）、表宽超容器时可横向滚动，
///   配合 [WotTableColumn.fixed] 实现左右固定列。
/// - [WotTableColumn.builder] 单元格控件插槽（输入框、按钮、开关等），
///   [WotTableColumn.formatter] 仅修饰文本。
/// - 行选择：[rowSelection] 单选 / 多选。
/// - 补充：[loading]、[footer] 合计行、[showOverflowTooltip]、表头排序。
class WotTable extends StatefulWidget {
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
    this.loading = false,
    this.showOverflowTooltip = false,
    this.footer,
    this.onSort,
    this.rowSelection,
    this.selectedRows,
    this.onSelectionChange,
    this.rowSelectionWidth = 46,
  });

  /// 列定义列表。
  final List<WotTableColumn> columns;

  /// 表格行数据，每行为字典 {字段名: 值}。
  final List<Map<String, dynamic>> data;

  /// 是否开启斑马纹背景（隔行异色），默认 false。
  final bool stripe;

  /// 是否显示外边框和所有单元格边框，默认 false。
  final bool border;

  /// 表格最大高度。设置后启用表头固定 + 数据虚拟滚动 + 横向滚动能力。
  final double? maxHeight;

  /// 数据为空时的提示文本，默认「暂无数据」。
  final String emptyText;

  /// 是否显示表头，默认 true。
  final bool showHead;

  /// 表头行高，默认 40。
  final double headerRowHeight;

  /// 数据行高，默认 44（虚拟滚动使用固定行高）。
  final double rowHeight;

  /// 行点击回调。
  final void Function(Map<String, dynamic> row, int index)? onRowClick;

  /// 是否处于加载中；为 true 时数据区显示 loading 占位。
  final bool loading;

  /// 单元格文本是否在悬停时显示完整内容（超出省略时用 [Tooltip]），默认 false。
  final bool showOverflowTooltip;

  /// 底部合计行文案，长度应与列数一致（空项跳过）。
  final List<String?>? footer;

  /// 表头排序回调。点击可排序列时触发，参数为列与其点击后的方向。
  ///
  /// 组件内部会按当前方向对可见数据排序；若想完全外部控制数据，请在回调里重排并更新 [data]。
  final void Function(WotTableColumn column, WotTableSortDirection direction)? onSort;

  /// 行选择模式；为 null 时不启用行选择。
  final WotTableRowSelection? rowSelection;

  /// 已选中的行索引集合（受控）。未传入时组件内部持有选择状态。
  final Set<int>? selectedRows;

  /// 选择变化回调（参数为最新选中的行索引集合）。
  final ValueChanged<Set<int>>? onSelectionChange;

  /// 选择列宽度，默认 46。
  final double rowSelectionWidth;

  @override
  State<WotTable> createState() => _WotTableState();
}

class _WotTableState extends State<WotTable> {
  late final ScrollController _hCtrl = ScrollController(); // 横向滚动（主体 + 表头）
  late final ScrollController _vCtrl = ScrollController(); // 数据区垂直（主体）
  late final ScrollController _vLeftCtrl = ScrollController(); // 左固定列垂直（同步 _vCtrl）
  late final ScrollController _vRightCtrl = ScrollController(); // 右固定列垂直（同步 _vCtrl）

  /// 排序列与方向。
  String? _sortProp;
  WotTableSortDirection _sortDirection = WotTableSortDirection.none;

  /// 选择状态（未受控时自维护）。
  late Set<int> _selRows = widget.selectedRows ?? <int>{};

  bool get _isControlledSelection => widget.selectedRows != null;

  Set<int> get _currentSel => _isControlledSelection ? widget.selectedRows! : _selRows;

  /// 是否启用了行选择。
  bool get _hasSelection => widget.rowSelection != null;

  /// 展示数据（含排序）。
  List<Map<String, dynamic>> get _displayData {
    if (_sortProp == null || _sortDirection == WotTableSortDirection.none) {
      return widget.data;
    }
    final prop = _sortProp!;
    final ascending = _sortDirection == WotTableSortDirection.ascending;
    final copy = [...widget.data];
    copy.sort((a, b) {
      final va = a[prop];
      final vb = b[prop];
      if (va is num && vb is num) {
        return ascending ? (va - vb).sign.toInt() : (vb - va).sign.toInt();
      }
      final sa = '$va';
      final sb = '$vb';
      return ascending ? sa.compareTo(sb) : sb.compareTo(sa);
    });
    return copy;
  }

  @override
  void initState() {
    super.initState();
    // 固定列为不可拖动，仅由主体垂直滚动驱动镜像同步（避免双向 jumpTo 竞争卡住主体）。
    _vCtrl.addListener(_syncFixedScroll);
  }

  @override
  void didUpdateWidget(covariant WotTable old) {
    super.didUpdateWidget(old);
    // 受控选择切换时同步内部缓存起始值。
    if (old.selectedRows != widget.selectedRows) {
      _selRows = widget.selectedRows ?? <int>{};
    }
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _vCtrl.dispose();
    _vLeftCtrl.dispose();
    _vRightCtrl.dispose();
    super.dispose();
  }

  /// 主体垂直滚动时同步固定列（左右）垂直位置。
  void _syncFixedScroll() {
    _syncFixedColumn(_vLeftCtrl);
    _syncFixedColumn(_vRightCtrl);
  }

  void _syncFixedColumn(ScrollController fixed) {
    if (fixed.hasClients && _vCtrl.hasClients) {
      if ((fixed.offset - _vCtrl.offset).abs() > 0.1) {
        fixed.jumpTo(_vCtrl.offset);
      }
    }
  }

  /// 固定列的滚动（拖动 + 惯性甩动）时把主体同步到其位置；
  /// jumpTo 不产生 ScrollUpdateNotification，因此主体引起的同步不会在这里回环。
  bool _onFixedScroll(ScrollUpdateNotification n, ScrollController fixed) {
    if (_vCtrl.hasClients) {
      if ((fixed.offset - _vCtrl.offset).abs() > 0.1) {
        _vCtrl.jumpTo(fixed.offset);
      }
    }
    return false;
  }

  // ===== 选择逻辑 =====
  Set<int> _toggleIn(Set<int> set, int i) {
    final s = {...set};
    if (s.contains(i)) {
      s.remove(i);
    } else {
      s.add(i);
    }
    return s;
  }

  void _emitSelection(Set<int> value) {
    if (!_isControlledSelection) {
      setState(() => _selRows = value);
    }
    widget.onSelectionChange?.call(value);
  }

  void _handleSelectRow(int index) {
    _emitSelection(_toggleIn(_currentSel, index));
  }

  void _handleSelectSingle(int index) {
    final now = _currentSel;
    _emitSelection(now.contains(index) ? <int>{} : {index});
  }

  void _toggleSelectAll(int count) {
    if (count <= 0) return;
    final all = <int>{for (var i = 0; i < count; i++) i};
    final current = _currentSel;
    final allSelected = current.length == count;
    _emitSelection(allSelected ? <int>{} : all);
  }

  // ===== 表头排序 =====
  void _handleHeaderSort(WotTableColumn c) {
    if (!c.sortable) return;
    setState(() {
      if (_sortProp != c.prop) {
        _sortProp = c.prop;
        _sortDirection = WotTableSortDirection.ascending;
      } else {
        _sortDirection = switch (_sortDirection) {
          WotTableSortDirection.none => WotTableSortDirection.ascending,
          WotTableSortDirection.ascending => WotTableSortDirection.descending,
          WotTableSortDirection.descending => WotTableSortDirection.none,
        };
        if (_sortDirection == WotTableSortDirection.none) _sortProp = null;
      }
    });
    widget.onSort?.call(c, _sortDirection);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // 父容器可能给无界宽度，归一化为有限值，避免总表宽传播成 infinity 导致 web 端空引用崩溃。
      final viewportWidth =
          constraints.maxWidth.isFinite ? constraints.maxWidth : 800.0;

      if (widget.maxHeight != null) {
        // ===== 有界模式：表头固定 + 虚拟滚动 + 横向滚动 + 左右固定列 + 选择列 =====
        // 普通列只分配「视口宽 − 左右固定区」的可用区，避免铺满整视口后与固定列错位露白。
        final padLeft = _padLeft();
        final padRight = _padRight();
        final avail = math.max(1.0, viewportWidth - padLeft - padRight);
        final layout = _computeLayout(avail, _scrollableCols());
        final hasHScroll = layout.tableWidth > avail;
        final body =
            _buildBody(context, layout, hasHScroll, viewportWidth, padLeft, padRight);
        return _buildBounded(body, layout, viewportWidth);
      }

      // ===== 轻量模式：全量渲染 =====
      final layout = _computeLayout(viewportWidth, widget.columns);
      final table = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 选择列（轻量模式下作为首列并固定展示，不进入横向滚动）。
          if (widget.showHead)
            _buildHeaderRow(context, layout, includeSelection: _hasSelection),
          if (widget.loading)
            _buildLoading(context)
          else if (_displayData.isEmpty)
            _buildEmpty(context)
          else
            for (var i = 0; i < _displayData.length; i++)
              _buildLightRow(context, layout, _displayData[i], i,
                  hasSelectionCell: _hasSelection),
          if (widget.footer != null) _buildFooter(context, layout),
        ],
      );
      return Container(
        decoration: widget.border
            ? BoxDecoration(border: Border.all(color: _borderColor(context), width: 0.5))
            : null,
        child: table,
      );
    });
  }

  // ============================= 有界模式 =============================
  Widget _buildBounded(Widget body, _TableLayout layout, double maxWidth) {
    return Container(
      decoration: widget.border
          ? BoxDecoration(border: Border.all(color: _borderColor(context), width: 0.5))
          : null,
      width: maxWidth,
      height: widget.maxHeight!,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(child: body),
            // 左侧固定层：选择列 + 左固定列。
            if (widget.maxHeight != null && (_padLeft() > 0))
              _buildFixedLayer(context, layout, _leftFixedCols(), _padLeft(),
                  alignRight: false, fixedCtrl: _vLeftCtrl),
            // 右侧固定层。
            if (widget.maxHeight != null && (_padRight() > 0))
              _buildFixedLayer(context, layout, _rightFixedCols(), _padRight(),
                  alignRight: true, fixedCtrl: _vRightCtrl),
          ],
        ),
      ),
    );
  }

  List<WotTableColumn> _leftFixedCols() =>
      widget.columns.where((c) => c.fixed == WotTableFixed.left).toList();

  List<WotTableColumn> _rightFixedCols() =>
      widget.columns.where((c) => c.fixed == WotTableFixed.right).toList();

  /// 非固定列（有界模式下这些列才出现在主体滚动区，固定列由覆盖层叠加显示）。
  List<WotTableColumn> _scrollableCols() =>
      widget.columns.where((c) => c.fixed == null).toList();

  double _selWidth() => _hasSelection ? widget.rowSelectionWidth : 0;

  /// 固定列可视宽度（固定列建议给显式 width；未给时按 60 兜底）。
  double _fixedColW(WotTableColumn c) => c.width ?? 60;

  /// 左固定区总宽（选择列 + 左固定列），用于主体垫位与左覆盖层宽度。
  double _padLeft() =>
      _selWidth() +
      _leftFixedCols().fold<double>(0, (s, c) => s + _fixedColW(c));

  /// 右固定区总宽（右固定列），用于主体垫位与右覆盖层宽度。
  double _padRight() =>
      _rightFixedCols().fold<double>(0, (s, c) => s + _fixedColW(c));

  /// 构建主体的横向滚动区（表头 + 虚拟数据）。
  Widget _buildBody(BuildContext context, _TableLayout layout, bool hasHScroll,
      double viewportWidth, double padLeft, double padRight) {
    // 有界模式下的可用数据区高度 = 总高 - 表头(可选) - footer(可选)。
    final footerH = widget.footer == null ? 0.0 : widget.rowHeight;
    final headerH = widget.showHead ? widget.headerRowHeight : 0.0;
    // 表头/合计行的 0.5px 上下边框实际参与渲染，会让内容比 maxHeight 多约 1px；
    // dataH 预留 1px 容差，避免 Column 垂直方向溢出告警。
    final dataH =
        math.max(1.0, widget.maxHeight! - headerH - footerH - 1.0);
    return SingleChildScrollView(
      controller: hasHScroll ? _hCtrl : null,
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        // 内容至少占满「视口 − 左右固定区」，避免比固定区窄时右侧露空白。
        constraints: BoxConstraints(
          minWidth: math.max(1.0, viewportWidth - padLeft - padRight),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: padLeft, right: padRight),
          child: Column(
            // 行宽度由各单元格显式求和（tableWidth），不能 stretch，
            // 否则在横向滚动（水平方向无限宽）里会被拉成 infinite width。
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主体只渲染非固定列，固定列由覆盖层叠加（避免重复显示）。
              if (widget.showHead)
                _buildHeaderRow(context, layout, cols: _scrollableCols()),
              if (widget.loading)
                SizedBox(
                  width: layout.tableWidth,
                  height: dataH,
                  child: _buildLoading(context),
                )
              else if (_displayData.isEmpty)
                SizedBox(
                  width: layout.tableWidth,
                  height: dataH,
                  child: _buildEmpty(context),
                )
              else
                SizedBox(
                  width: layout.tableWidth,
                  height: dataH,
                  child: ListView.builder(
                    controller: _vCtrl,
                    itemExtent: widget.rowHeight,
                    itemCount: _displayData.length,
                    itemBuilder: (_, i) => _buildScrollRow(
                        context, layout, _displayData[i], i,
                        cols: _scrollableCols()),
                  ),
                ),
              // 普通列合计行：放在主体横向滚动区，随主体滚动并可随列对齐，
              // 修复窄屏（如手机）下合计行被裁剪/挤压的问题。
              if (widget.footer != null)
                _buildFooter(context, layout, cols: _scrollableCols()),
            ],
          ),
        ),
      ),
    );
  }

  /// 固定列覆盖层（含选择列 + 左固定列，或右固定列）。
  Widget _buildFixedLayer(
    BuildContext context,
    _TableLayout layout,
    List<WotTableColumn> cols,
    double width, {
    required bool alignRight,
    required ScrollController fixedCtrl,
  }) {
    return Positioned(
      left: alignRight ? null : 0,
      right: alignRight ? 0 : null,
      top: 0,
      bottom: 0,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: alignRight
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 6,
                    offset: const Offset(-4, 0),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 6,
                    offset: const Offset(4, 0),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showHead)
              _buildFixedHeaderRow(context, layout, cols, alignRight: alignRight),
            if (widget.loading || _displayData.isEmpty)
              const SizedBox()
            else
              Expanded(
                // 隐藏固定列的独立滚动条（平台默认会为每个可滚动区域各自画滚动条，
                // 导致固定列与主体的滚动条不在同一水平线）；滚动功能不受影响。
                child: ScrollConfiguration(
                  behavior:
                      const ScrollBehavior().copyWith(scrollbars: false),
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (n) => _onFixedScroll(n, fixedCtrl),
                    child: ListView.builder(
                      controller: fixedCtrl,
                      itemExtent: widget.rowHeight,
                      itemCount: _displayData.length,
                      itemBuilder: (_, i) {
                        final row = _displayData[i];
                        List<Widget> cells = [];
                        if (alignRight == false) {
                          cells.addAll(
                              _buildSelectionCells(context, layout, row, i));
                        }
                        for (final c in cols) {
                          cells.add(_cell(context, layout, c, row, i));
                        }
                        return _fixedRowContainer(context, row, i, cells, layout,
                            onSelect: alignRight == false
                                ? () => _selectByMode(i)
                                : null);
                      },
                    ),
                  ),
                ),
              ),
              // 固定列合计行：左固定层含选择列占位 + 左固定列，右固定层含右固定列。
              if (widget.footer != null)
                _buildFooter(context, layout,
                    cols: cols, includeSelection: alignRight == false),
          ],
        ),
      ),
    );
  }

  /// 根据选择模式响应点击（单选点击行，多选仅点复选框）。
  void _selectByMode(int index) {
    final mode = widget.rowSelection;
    if (mode == WotTableRowSelection.single) {
      _handleSelectSingle(index);
    } else if (mode == WotTableRowSelection.multiple) {
      // 多选由复选框触发，整行不响应；此处仅单选使用。
    }
  }

  // ============================= 单元格 =============================
  Widget _cell(BuildContext context, _TableLayout layout, WotTableColumn c,
      Map<String, dynamic> row, int rowIndex) {
    return _cellContainer(context, layout, c, _cellContent(context, c, row, rowIndex));
  }

  Widget _cellContent(BuildContext context, WotTableColumn c,
      Map<String, dynamic> row, int rowIndex) {
    if (c.builder != null) return c.builder!(row[c.prop], row, rowIndex);
    final text = c.formatter != null
        ? c.formatter!(row[c.prop], row)
        : '${row[c.prop] ?? ''}';
    final label = Text(
      text,
      style: TextStyle(fontSize: 13, color: _scheme(context).textMain),
      textAlign: c._textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (widget.showOverflowTooltip) {
      return Tooltip(message: text, child: label);
    }
    return label;
  }

  Widget _cellContainer(BuildContext context, _TableLayout layout, WotTableColumn c,
      Widget child) {
    final scheme = _scheme(context);
    final showBorder = widget.border || c.bordered;
    final b = showBorder
        ? Border(
            right: BorderSide(color: scheme.borderLight, width: 0.5),
            bottom: BorderSide(color: scheme.borderLight, width: 0.5))
        : const Border();
    return Container(
      width: layout.widthOf(c),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: switch (c._textAlign) {
        TextAlign.right => Alignment.centerRight,
        TextAlign.center => Alignment.center,
        _ => Alignment.centerLeft,
      },
      decoration: BoxDecoration(border: b),
      child: child,
    );
  }

  /// 选择单元格（复选框或单选点）。
  Widget _selectCell(BuildContext context, int index, {required double selWidth}) {
    final scheme = _scheme(context);
    final selected = _currentSel.contains(index);
    final mode = widget.rowSelection;
    final icon = mode == WotTableRowSelection.multiple
        ? (selected ? Icons.check_box : Icons.check_box_outline_blank)
        : (selected
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked);
    final onTap = mode == WotTableRowSelection.multiple
        ? () => _handleSelectRow(index)
        : () => _handleSelectSingle(index);
    return Container(
      width: selWidth,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: scheme.borderLight, width: 0.5),
          bottom: BorderSide(color: scheme.borderLight, width: 0.5),
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Icon(icon, size: 18,
            color: selected ? scheme.primaryOf(7) : scheme.iconAuxiliary),
      ),
    );
  }

  /// 表头全选复选框。
  Widget _selectHeaderCell(BuildContext context, {required double selWidth}) {
    final scheme = _scheme(context);
    final n = _displayData.length;
    final count = _currentSel.length;
    final allSelected = n > 0 && count >= n;
    final indeterminate = !allSelected && count > 0;
    final IconData icon;
    if (indeterminate) {
      icon = Icons.remove_circle; // 半选示意
    } else {
      icon = allSelected ? Icons.check_box : Icons.check_box_outline_blank;
    }
    return Container(
      width: selWidth,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border(
        right: BorderSide(color: scheme.borderLight, width: 0.5),
        bottom: BorderSide(color: scheme.borderLight, width: 0.5))),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggleSelectAll(n),
        child: Icon(icon, size: 18, color: scheme.primaryOf(7)),
      ),
    );
  }

  // ============================= 行与表头 =============================
  Widget _buildScrollRow(BuildContext context, _TableLayout layout,
      Map<String, dynamic> row, int index,
      {List<WotTableColumn>? cols}) {
    final scheme = _scheme(context);
    final columns = cols ?? widget.columns;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onRowClick == null ? null : () => widget.onRowClick!(row, index),
      child: Container(
        height: widget.rowHeight,
        color: (widget.stripe && index.isOdd) ? scheme.filledContent : Colors.transparent,
        child: Row(
          children: [
            for (final c in columns) _cell(context, layout, c, row, index),
          ],
        ),
      ),
    );
  }

  Widget _fixedRowContainer(BuildContext context, Map<String, dynamic> row,
      int index, List<Widget> cells, _TableLayout layout,
      {VoidCallback? onSelect}) {
    final scheme = _scheme(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
      child: Container(
        height: widget.rowHeight,
        color: (widget.stripe && index.isOdd) ? scheme.filledContent : Colors.transparent,
        child: Row(
          children: cells,
        ),
      ),
    );
  }

  /// 轻量模式行（含选择列单元格）。
  Widget _buildLightRow(BuildContext context, _TableLayout layout,
      Map<String, dynamic> row, int index, {bool hasSelectionCell = false}) {
    final scheme = _scheme(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onRowClick == null ? null : () => widget.onRowClick!(row, index),
      child: Container(
        height: widget.rowHeight,
        color: (widget.stripe && index.isOdd) ? scheme.filledContent : Colors.transparent,
        child: Row(
          children: [
            if (hasSelectionCell) _selectCell(context, index, selWidth: _selWidth()),
            for (final c in widget.columns) _cell(context, layout, c, row, index),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSelectionCells(BuildContext context, _TableLayout layout,
      Map<String, dynamic> row, int index) {
    if (!_hasSelection) return const [];
    return [_selectCell(context, index, selWidth: _selWidth())];
  }

  /// 主体表头行（含全部列；可选在最前插入选择列）。
  Widget _buildHeaderRow(BuildContext context, _TableLayout layout,
      {bool includeSelection = false, List<WotTableColumn>? cols}) {
    final scheme = _scheme(context);
    final columns = cols ?? widget.columns;
    return Container(
      height: widget.headerRowHeight,
      color: scheme.filledContent,
      child: Row(
        children: [
          if (includeSelection) _headerSelectionCell(context, selWidth: _selWidth()),
          for (final c in columns)
            _headerCell(context, layout, c),
        ],
      ),
    );
  }

  /// 表头选择列：多选显示全选复选框，单选显示空占位（保持列宽与边框）。
  Widget _headerSelectionCell(BuildContext context, {required double selWidth}) {
    if (widget.rowSelection != WotTableRowSelection.multiple) {
      final scheme = _scheme(context);
      return Container(
        width: selWidth,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: scheme.borderLight, width: 0.5),
            bottom: BorderSide(color: scheme.borderLight, width: 0.5),
          ),
        ),
      );
    }
    return _selectHeaderCell(context, selWidth: selWidth);
  }

  /// 固定层层表头（选择列 + 固定列，或仅固定列）。
  Widget _buildFixedHeaderRow(BuildContext context, _TableLayout layout,
      List<WotTableColumn> cols,
      {required bool alignRight}) {
    // 左侧固定层会额外加入选择列；右侧固定列不含选择列。
    final isLeft = !alignRight;
    final scheme = _scheme(context);
    return Container(
      height: widget.headerRowHeight,
      color: scheme.filledContent,
      child: Row(
        children: [
          if (isLeft && _hasSelection) _selectHeaderCell(context, selWidth: _selWidth()),
          for (final c in cols) _headerCell(context, layout, c),
        ],
      ),
    );
  }

  Widget _headerCell(BuildContext context, _TableLayout layout, WotTableColumn c) {
    final scheme = _scheme(context);
    final sorting = _sortProp == c.prop && _sortDirection != WotTableSortDirection.none;
    final hint = c.sortable
        ? (_sortDirection == WotTableSortDirection.ascending && _sortProp == c.prop
            ? ' ↑'
            : (_sortDirection == WotTableSortDirection.descending && _sortProp == c.prop
                ? ' ↓'
                : (_sortProp == c.prop ? ' ↕' : ' ⇅')))
        : null;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: c.sortable ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            '${c.label ?? c.prop}${hint ?? ''}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: sorting ? FontWeight.w700 : FontWeight.w600,
              color: scheme.textMain,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    final cell = _cellContainer(context, layout, c,
        c.sortable ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleHeaderSort(c),
              child: child,
            )
        : child);
    return cell;
  }

  Widget _buildFooter(BuildContext context, _TableLayout layout,
      {List<WotTableColumn>? cols, bool includeSelection = false}) {
    final scheme = _scheme(context);
    final columns = cols ?? widget.columns;
    return Container(
      height: widget.rowHeight,
      decoration: BoxDecoration(
        color: scheme.filledContent,
        // 顶边阴影：让合计行与上方数据行在视觉上明显区分开。
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 6,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 合计行的选择列占位：仅保持列宽与边框，不渲染复选控件。
          if (includeSelection && _hasSelection)
            Container(
              width: _selWidth(),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: scheme.borderLight, width: 0.5),
                  bottom: BorderSide(color: scheme.borderLight, width: 0.5),
                ),
              ),
            ),
          for (final c in columns)
            _cellContainer(
              context,
              layout,
              c,
              SizedBox(
                width: layout.widthOf(c),
                child: Text(
                  footerValue(c),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.textMain),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 读取某列对应的汇总值；无则空串。
  String footerValue(WotTableColumn c) {
    final pos = widget.columns.indexOf(c);
    return (widget.footer != null && pos < widget.footer!.length &&
            widget.footer![pos] != null)
        ? widget.footer![pos]!
        : '';
  }

  // ============================= 公共 =============================
  Widget _buildLoading(BuildContext context) => Container(
        height: 120,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2.5),
      );

  Widget _buildEmpty(BuildContext context) => Container(
        height: 120,
        alignment: Alignment.center,
        child: Text(
          widget.emptyText,
          style: TextStyle(color: _scheme(context).textAuxiliary, fontSize: 13),
        ),
      );

  Color _borderColor(BuildContext context) => _scheme(context).borderLight;

  WotScheme _scheme(BuildContext context) => context.wotScheme;

  _TableLayout _computeLayout(double maxWidth, List<WotTableColumn> cols) {
    if (!maxWidth.isFinite) maxWidth = 800.0; // 防御无界宽度
    const minFlexible = 60.0;
    double fixedTotal = 0;
    var flexible = 0;
    for (final c in cols) {
      if (c.width != null) {
        fixedTotal += c.width!;
      } else {
        flexible++;
      }
    }
    final double flexWidth;
    final double total;
    if (flexible == 0) {
      total = math.max(fixedTotal, maxWidth);
      return _TableLayout(total, (c) => c.width ?? 60);
    }
    final remaining = maxWidth - fixedTotal;
    flexWidth = flexible > 0
        ? math.max(minFlexible, (remaining / flexible).floorToDouble())
        : 60;
    total = fixedTotal + flexWidth * flexible;
    return _TableLayout(math.max(total, maxWidth), (c) => c.width ?? flexWidth);
  }
}

/// 计算各列宽度与总表宽。
class _TableLayout {
  _TableLayout(this.tableWidth, this._widthOf);
  final double tableWidth;
  final double Function(WotTableColumn) _widthOf;
  double widthOf(WotTableColumn c) => _widthOf(c);
}