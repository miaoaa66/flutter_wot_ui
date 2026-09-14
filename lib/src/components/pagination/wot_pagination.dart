import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/wot_theme.dart';
import '../../theme/wot_scheme.dart';

/// 分页模式。
enum WotPaginationMode { multi, button, simple }

/// 分页组件，对应 wot `wd-pagination`。受控（v-model:value）。
class WotPagination extends StatefulWidget {
  const WotPagination({
    super.key,
    this.modelValue = 1,
    this.onChange,
    this.total = 0,
    this.pageSize = 10,
    this.pagerCount = 5,
    this.mode = WotPaginationMode.multi,
    this.prevText,
    this.nextText,
    this.color,
    this.hideIfSinglePage = false,
    this.showSettings = false,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.showPageSizeOptions = true,
    this.onPageSizeChange,
    this.showJumper = false,
    this.onJump,
  });

  /// 当前页（从 1 开始，v-model:value）。
  final num modelValue;

  /// 页码变化时回调，参数为切换后的页码。
  final ValueChanged<int>? onChange;

  /// 总条数。
  final num total;

  /// 每页条数。
  final num pageSize;

  /// 显示的页码按钮数量。
  final num pagerCount;

  /// 显示模式。
  final WotPaginationMode mode;

  /// 上一页文字。
  final String? prevText;

  /// 下一页文字。
  final String? nextText;

  /// 主色（页码按钮高亮色）。
  final Color? color;

  /// 仅一页时是否隐藏。
  final bool hideIfSinglePage;

  /// 是否显示设置按钮，点击弹出设置弹框。
  final bool showSettings;

  /// 可选的每页条数列表。
  final List<int> pageSizeOptions;

  /// 是否在设置弹框中显示每页条数选项列表。
  final bool showPageSizeOptions;

  /// 每页条数变化回调。
  final ValueChanged<int>? onPageSizeChange;

  /// 是否在设置弹框中显示跳转页码输入。
  final bool showJumper;

  /// 跳转页码回调（不传时内部直接调用 onChange）。
  final ValueChanged<int>? onJump;

  @override
  State<WotPagination> createState() => _WotPaginationState();
}

class _WotPaginationState extends State<WotPagination> {
  int get _pageCount {
    if (widget.total <= 0 || widget.pageSize <= 0) return 0;
    return (widget.total / widget.pageSize).ceil();
  }

  void _change(int page) {
    if (page < 1) return;
    final n = _pageCount;
    if (n > 0 && page > n) return;
    widget.onChange?.call(page);
  }

  void _showSettingsDialog() {
    final scheme = context.wotScheme;
    final primary = widget.color ?? scheme.primaryOf(6);
    showDialog(
      context: context,
      builder: (ctx) => _SettingsDialogContent(
        total: widget.total.toInt(),
        pageSize: widget.pageSize.toInt(),
        pageCount: _pageCount,
        currentPage: widget.modelValue.toInt().clamp(1, _pageCount == 0 ? 1 : _pageCount),
        pageSizeOptions: widget.pageSizeOptions,
        showPageSizeOptions: widget.showPageSizeOptions,
        showJumper: widget.showJumper,
        primary: primary,
        onConfirm: (newPageSize, jumpPage) {
          if (newPageSize != widget.pageSize.toInt()) {
            widget.onPageSizeChange?.call(newPageSize);
          }
          if (jumpPage != null && jumpPage != widget.modelValue.toInt()) {
            if (widget.onJump != null) {
              widget.onJump!.call(jumpPage);
            } else {
              _change(jumpPage);
            }
          }
        },
      ),
    );
  }

  Widget _nav(IconData data, VoidCallback? onTap, WotScheme scheme) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(data, size: 16, color: onTap == null ? scheme.iconAuxiliary : null),
      ),
    );
  }

  Widget _buildSimple(WotScheme scheme, Color primary, int current, int pageCount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _nav(Icons.chevron_left, current > 1 ? () => _change(current - 1) : null, scheme),
        Text('$current / ${pageCount == 0 ? 0 : pageCount}',
            style: const TextStyle(fontSize: 14)),
        _nav(
          Icons.chevron_right,
          (pageCount > 0 && current < pageCount)
              ? () => _change(current + 1)
              : null,
          scheme,
        ),
      ],
    );
  }

  Widget _buildButtons(WotScheme scheme, Color primary, int current, int pageCount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(widget.prevText ?? '上一页', primary, current > 1 ? () => _change(current - 1) : null, scheme),
        const SizedBox(width: 8),
        _button(
          widget.nextText ?? '下一页',
          primary,
          (pageCount > 0 && current < pageCount) ? () => _change(current + 1) : null,
          scheme,
        ),
      ],
    );
  }

  Widget _buildMulti(WotScheme scheme, Color primary, int current, int pageCount) {
    if (pageCount == 0) return const SizedBox.shrink();

    final pc = widget.pagerCount.toInt();
    final half = (pc / 2).floor();
    var start = (current - half).clamp(1, (pageCount - pc + 1).clamp(1, current));
    final end = (start + pc - 1).clamp(1, pageCount).toInt();
    start = (end - pc + 1).clamp(1, pageCount).toInt();

    final pages = <Widget>[
      _nav(Icons.chevron_left, current > 1 ? () => _change(current - 1) : null, scheme),
      for (var p = start; p <= end; p++)
        _pageNum(p, current, primary),
      _nav(
        Icons.chevron_right,
        current < pageCount ? () => _change(current + 1) : null,
        scheme,
      ),
    ];

    return Wrap(spacing: 8, runSpacing: 8, children: pages);
  }

  Widget _pageNum(int num, int current, Color primary) {
    final active = num == current;
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: active ? null : () => _change(num),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? primary : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$num',
          style: TextStyle(
            fontSize: 13,
            color: active ? kWhite : null,
          ),
        ),
      ),
    );
  }

  Widget _button(String text, Color primary, VoidCallback? onTap, WotScheme scheme) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.borderMain),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: TextStyle(fontSize: 13, color: onTap == null ? scheme.textDisabled : null)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = widget.color ?? scheme.primaryOf(6);
    final pageCount = _pageCount;
    final current = widget.modelValue.toInt().clamp(1, pageCount == 0 ? 1 : pageCount);
    final single = pageCount <= 1;

    if (widget.hideIfSinglePage && single) return const SizedBox.shrink();

    final pagination = switch (widget.mode) {
      WotPaginationMode.simple => _buildSimple(scheme, primary, current, pageCount),
      WotPaginationMode.button => _buildButtons(scheme, primary, current, pageCount),
      WotPaginationMode.multi => _buildMulti(scheme, primary, current, pageCount),
    };

    if (!widget.showSettings) return pagination;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        pagination,
        const SizedBox(width: 8),
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: _showSettingsDialog,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(Icons.settings, size: 18, color: scheme.iconAuxiliary),
          ),
        ),
      ],
    );
  }
}

/// 设置弹框内容组件。
/// 弹框内的修改不影响外部页面，只有点击确定且校验通过后才通过回调通知外部。
class _SettingsDialogContent extends StatefulWidget {
  const _SettingsDialogContent({
    required this.total,
    required this.pageSize,
    required this.pageCount,
    required this.currentPage,
    required this.pageSizeOptions,
    required this.showPageSizeOptions,
    required this.showJumper,
    required this.primary,
    required this.onConfirm,
  });

  final int total;
  final int pageSize;
  final int pageCount;
  final int currentPage;
  final List<int> pageSizeOptions;
  final bool showPageSizeOptions;
  final bool showJumper;
  final Color primary;
  final void Function(int newPageSize, int? jumpPage) onConfirm;

  @override
  State<_SettingsDialogContent> createState() => _SettingsDialogContentState();
}

class _SettingsDialogContentState extends State<_SettingsDialogContent> {
  late int _selectedPageSize;
  final TextEditingController _jumpController = TextEditingController();
  String? _jumpError;

  /// 根据当前选中的 pageSize 实时计算总页数。
  int get _currentPageCount {
    if (widget.total <= 0 || _selectedPageSize <= 0) return 0;
    return (widget.total / _selectedPageSize).ceil();
  }

  @override
  void initState() {
    super.initState();
    _selectedPageSize = widget.pageSize;
  }

  @override
  void dispose() {
    _jumpController.dispose();
    super.dispose();
  }

  /// 切换 pageSize 时重新校验跳转页码（如果已输入）。
  void _onPageSizeSelected(int option) {
    setState(() {
      _selectedPageSize = option;
      // 切换 pageSize 后总页数变化，清空跳转页码输入和错误提示。
      _jumpController.clear();
      _jumpError = null;
    });
  }

  /// 校验当前输入框中的跳转页码，返回错误信息或 null。
  String? _validateJumpInput() {
    final text = _jumpController.text.trim();
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null) return '请输入有效数字';
    final pc = _currentPageCount;
    if (pc > 0 && (parsed < 1 || parsed > pc)) {
      return '请输入 1~$pc 之间的页码';
    }
    return null;
  }

  void _handleConfirm() {
    final pageCount = _currentPageCount;

    // 校验跳转页码。
    int? jumpPage;
    if (widget.showJumper) {
      final text = _jumpController.text.trim();
      if (text.isNotEmpty) {
        final parsed = int.tryParse(text);
        if (parsed == null) {
          setState(() => _jumpError = '请输入有效数字');
          return;
        }
        if (pageCount > 0 && (parsed < 1 || parsed > pageCount)) {
          setState(() => _jumpError = '请输入 1~$pageCount 之间的页码');
          return;
        }
        jumpPage = parsed;
      }
    }

    // 校验通过，回调外部并关闭弹窗。
    widget.onConfirm(_selectedPageSize, jumpPage);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final cancelBg = scheme.filledContent;
    final pageCount = _currentPageCount;

    return Dialog(
      backgroundColor: scheme.filledOppo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题
                Text(
                  '分页设置',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: scheme.textMain,
                  ),
                ),
                const SizedBox(height: 16),
                // 统计信息（随 pageSize 实时更新）
                Text(
                  '共 ${widget.total} 条，共 $pageCount 页',
                  style: TextStyle(fontSize: 14, color: scheme.textSecondary),
                ),
                const SizedBox(height: 16),
                // 每页条数选项
                if (widget.showPageSizeOptions && widget.pageSizeOptions.isNotEmpty) ...[
                  Text(
                    '每页显示',
                    style: TextStyle(fontSize: 14, color: scheme.textMain, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  for (final option in widget.pageSizeOptions)
                    InkWell(
                      onTap: () => _onPageSizeSelected(option),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              _selectedPageSize == option ? Icons.radio_button_checked : Icons.radio_button_off,
                              size: 20,
                              color: _selectedPageSize == option ? widget.primary : scheme.iconAuxiliary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$option 条/页',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedPageSize == option ? widget.primary : scheme.textMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
                // 跳转页码
                if (widget.showJumper) ...[
                  Text(
                    '跳转到',
                    style: TextStyle(fontSize: 14, color: scheme.textMain, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('第', style: TextStyle(fontSize: 14, color: scheme.textMain)),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _jumpController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                          textAlign: TextAlign.center,
                          onChanged: (_) {
                            // 输入变化时实时清除或更新错误。
                            setState(() => _jumpError = _validateJumpInput());
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: _jumpError != null ? scheme.dangerMain : scheme.borderMain,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: _jumpError != null ? scheme.dangerMain : scheme.borderMain,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: _jumpError != null ? scheme.dangerMain : widget.primary,
                                width: 1.5,
                              ),
                            ),
                            hintText: '1-$pageCount',
                            hintStyle: TextStyle(fontSize: 13, color: scheme.textAuxiliary),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('页', style: TextStyle(fontSize: 14, color: scheme.textMain)),
                    ],
                  ),
                  if (_jumpError != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _jumpError!,
                      style: TextStyle(fontSize: 12, color: scheme.dangerMain),
                    ),
                  ],
                ],
                const SizedBox(height: 20),
                // 按钮（自行控制，不使用 WotDialogView 的内置按钮）
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: cancelBg,
                            foregroundColor: scheme.textMain,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('取消', style: TextStyle(color: scheme.textMain)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: widget.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: _handleConfirm,
                          child: const Text('确定'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 关闭按钮
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(Icons.close, size: 18, color: scheme.iconAuxiliary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

const Color kWhite = Color(0xFFFFFFFF);
