import 'package:flutter/material.dart';

import '../../theme/wot_state.dart';
import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 单元格，对应 wot `wd-cell`。
class WotCell extends StatelessWidget {
  const WotCell({
    super.key,
    this.title,
    this.value,
    this.icon,
    this.label,
    this.center = false,
    this.clickable,
    this.isLink = false,
    this.required = false,
    this.border = true,
    this.titleWidth,
    this.onClick,
    this.titleAlign = CrossAxisAlignment.start,
    this.valueAlign = CrossAxisAlignment.end,
    this.desc,
    this.descAlign = CrossAxisAlignment.end,
    this.onTap,
    this.trailing,
    this.disabled = false,
    this.error = false,
  });

  /// 左侧标题文案。
  final String? title;

  /// 右侧值文案。
  final String? value;

  /// 标题下方的辅助说明文案。
  final String? label;

  /// 值下方的描述文案。
  final String? desc;

  /// 左侧图标名称。
  final String? icon;

  /// 是否垂直居中，默认 false。
  final bool center;

  /// 是否可点击（高亮），缺省时由 [onClick]/[isLink] 决定。
  final bool? clickable;

  /// 是否显示右侧箭头（链接样式），默认 false。
  final bool isLink;

  /// 是否为必填项，展示红色「*」，默认 false。
  final bool required;

  /// 是否显示底部分割线，默认 true。
  final bool border;

  /// 标题占位宽度，用于固定标题列宽。
  final double? titleWidth;

  /// 点击单元格时触发的回调。
  final VoidCallback? onClick;

  /// 点击回调，与 [onClick] 等价。
  final VoidCallback? onTap;

  /// 标题对齐方式。
  final CrossAxisAlignment titleAlign;

  /// 值对齐方式。
  final CrossAxisAlignment valueAlign;

  /// 描述对齐方式。
  final CrossAxisAlignment descAlign;

  /// 右侧自定义尾部内容。
  final Widget? trailing;

  /// 是否禁用。禁用时整体灰化（标题 / 值 / 说明 / 图标 / 箭头）且不响应点击。
  final bool disabled;

  /// 是否处于校验失败态。命中时标题与值转为危险色。
  final bool error;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;

    // 三态：cell 是展示类，三态映射为「正常 / 禁用（灰化）/ 校验失败（值转危险色）」。
    // 显式 disabled 优先，其次取父级 WotFieldScope 下发（如 WotFormItem(disabled: true)）。
    final scope = WotFieldScope.of(context);
    final disabled = this.disabled || (scope?.state == WotFieldState.disabled);
    final error = this.error || (scope?.error ?? false);
    final style = wotFieldStyle(
      scheme,
      disabled ? WotFieldState.disabled : WotFieldState.editable,
      error: error,
    );
    // 标题走三态标签色；值与说明沿用较浅的辅助色——禁用灰化、失败仅值转危险色。
    final valueColor = disabled
        ? scheme.textDisabled
        : error
            ? scheme.dangerMain
            : scheme.textAuxiliary;
    final subColor = disabled ? scheme.textDisabled : scheme.textAuxiliary;

    // 禁用态不可点击。
    final clickable =
        !disabled && (this.clickable ?? (onClick != null || isLink));

    // 左侧「标题组」：title（上）+ label（下），纵向、左对齐，弹性占满剩余，
    // 把右侧内容推到最右。
    Widget left = const SizedBox.shrink();
    if (title != null || label != null) {
      left = Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              titleWidth == null
                  ? _text(
                      title!,
                      width: null,
                      style: TextStyle(fontSize: 14, color: style.label),
                    )
                  : _text(
                      title!,
                      width: titleWidth,
                      style: TextStyle(fontSize: 14, color: style.label),
                    ),
            if (label != null) ...[
              const SizedBox(height: 4),
              _text(
                label!,
                width: null,
                style: TextStyle(fontSize: 12, color: subColor),
              ),
            ],
          ],
        ),
      );
    }

    // 右侧「值组」：value（上，对齐 title）+ desc（下，对齐 label），纵向、左对齐。
    Widget right = const SizedBox.shrink();
    if (desc != null || value != null) {
      right = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (value != null)
            _text(
              value!,
              width: null,
              style: TextStyle(fontSize: 13, color: valueColor),
            ),
          if (desc != null) ...[
            const SizedBox(height: 4),
            _text(
              desc!,
              width: null,
              style: TextStyle(fontSize: 13, color: subColor),
            ),
          ],
        ],
      );
    }

    final cell = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (required) ...[
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                '*',
                style: TextStyle(
                  color: disabled ? scheme.textDisabled : scheme.dangerMain,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: WotIcon(name: icon, size: 16, color: style.icon),
            ),
          ],
          left,
          right,
          if (isLink) ...[
            const SizedBox(width: 6),
            WotIcon(
              name: 'arrow-right',
              size: 14,
              color: disabled ? scheme.iconDisabled : scheme.iconAuxiliary,
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );

    Widget result = cell;
    if (border) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: scheme.dividerLight)),
        ),
        child: result,
      );
    }
    if (clickable) {
      result = InkWell(onTap: onClick ?? onTap, child: result);
    }
    return result;
  }

  /// 单行文本：限定单行、超长省略，避免挤压兄弟节点。
  Widget _text(String s, {double? width, required TextStyle style}) {
    final text = Text(
      s,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    return width == null ? text : SizedBox(width: width, child: text);
  }
}