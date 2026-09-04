import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../../theme/wot_scheme.dart';

/// 分页模式。
enum WotPaginationMode { multi, button, simple }

/// 分页组件，对应 wot `wd-pagination`。受控（v-model:value）。
class WotPagination extends StatelessWidget {
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

  int get _pageCount {
    if (total <= 0 || pageSize <= 0) return 0;
    return (total / pageSize).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = color ?? scheme.primaryOf(6);
    final pageCount = _pageCount;
    final current = modelValue.toInt().clamp(1, pageCount == 0 ? 1 : pageCount);
    final single = pageCount <= 1;

    if (hideIfSinglePage && single) return const SizedBox.shrink();

    return switch (mode) {
      WotPaginationMode.simple => _buildSimple(scheme, primary, current, pageCount),
      WotPaginationMode.button => _buildButtons(scheme, primary, current, pageCount),
      WotPaginationMode.multi => _buildMulti(scheme, primary, current, pageCount),
    };
  }

  void _change(int page) {
    if (page < 1) return;
    final n = _pageCount;
    if (n > 0 && page > n) return;
    onChange?.call(page);
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
        _button(prevText ?? '上一页', primary, current > 1 ? () => _change(current - 1) : null, scheme),
        const SizedBox(width: 8),
        _button(
          nextText ?? '下一页',
          primary,
          (pageCount > 0 && current < pageCount) ? () => _change(current + 1) : null,
          scheme,
        ),
      ],
    );
  }

  Widget _buildMulti(WotScheme scheme, Color primary, int current, int pageCount) {
    if (pageCount == 0) return const SizedBox.shrink();

    final pc = pagerCount.toInt();
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
          // 按钮边框：随明暗用主题描边色
          border: Border.all(color: scheme.borderMain),
          borderRadius: BorderRadius.circular(4),
        ),
        // 禁用态文字：随明暗用主题禁用文字色
        child: Text(text, style: TextStyle(fontSize: 13, color: onTap == null ? scheme.textDisabled : null)),
      ),
    );
  }
}

const Color kWhite = Color(0xFFFFFFFF);