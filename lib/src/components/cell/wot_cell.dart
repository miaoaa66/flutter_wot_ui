import 'package:flutter/material.dart';

import '../../theme/wot_state.dart';
import '../../theme/wot_theme.dart';
import '../cell_group/wot_cell_group.dart';
import '../icon/wot_icon.dart';

/// 单元格布局方向，对应 wot `layout`。
enum WotCellLayout { horizontal, vertical }

/// 单元格右侧箭头方向，对应 wot `arrow-direction`。
enum WotArrowDirection { right, up, down, left }

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
    this.placeholder,
    this.layout = WotCellLayout.horizontal,
    this.padding,
    this.arrowDirection = WotArrowDirection.right,
    this.titleStyle,
    this.labelStyle,
    this.valueStyle,
    this.descStyle,
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

  /// 值为空时显示的占位文案（D 类 P1），以辅助色渲染。
  final String? placeholder;

  /// 布局方向（D 类 P1）：horizontal 标题左值右（默认），
  /// vertical 标题在上、值与描述在下（对应 wot `layout: vertical`）。
  final WotCellLayout layout;

  /// 自定义内边距，缺省为水平 10、垂直 10。
  final EdgeInsetsGeometry? padding;

  /// 右侧箭头方向（D 类 P1），默认朝右。
  final WotArrowDirection arrowDirection;

  /// 标题文本样式（D 类 P1），与三态默认样式按字段合并（传入字段优先）。
  final TextStyle? titleStyle;

  /// 辅助说明文本样式，合并规则同 [titleStyle]。
  final TextStyle? labelStyle;

  /// 值文本样式，合并规则同 [titleStyle]。
  final TextStyle? valueStyle;

  /// 描述文本样式，合并规则同 [titleStyle]。
  final TextStyle? descStyle;

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

    // 分割线（D 类 P1 分组属性继承）：显式 border 参数 > 分组下发 >
    // 默认 true。处于 WotCellGroup 内且组 bordered=false 时跟随组隐藏分割线。
    final groupScope = WotCellGroupScope.of(context);
    final border =
        this.border && (groupScope?.bordered ?? true);

    // 禁用态不可点击。
    final clickable =
        !disabled && (this.clickable ?? (onClick != null || isLink));

    // 左侧「标题组」内容：title（上）+ label（下）。横向布局包 Expanded，
    // 纵向布局由标题行包裹。文本样式与三态默认色按字段合并（传入字段优先）。
    final leftContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          _text(
            title!,
            width: titleWidth,
            style: TextStyle(fontSize: 14, color: style.label).merge(titleStyle),
          ),
        if (label != null) ...[
          const SizedBox(height: 4),
          _text(
            label!,
            style: TextStyle(fontSize: 12, color: subColor).merge(labelStyle),
          ),
        ],
      ],
    );

    // 值为空时回落到占位文案（D 类 P1），占位恒用辅助色（不随 error 变危险色）。
    final hasValue = value != null && value!.isNotEmpty;
    final shownValue = hasValue ? value! : placeholder;

    // 右侧「值组」内容：value（上，对齐 title）+ desc（下，对齐 label）。
    final rightContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shownValue != null)
          _text(
            shownValue,
            style: TextStyle(fontSize: 13, color: hasValue ? valueColor : subColor)
                .merge(valueStyle),
          ),
        if (desc != null) ...[
          const SizedBox(height: 4),
          _text(
            desc!,
            style: TextStyle(fontSize: 13, color: subColor).merge(descStyle),
          ),
        ],
      ],
    );

    final arrowIcon = switch (arrowDirection) {
      WotArrowDirection.right => 'arrow-right',
      WotArrowDirection.up => 'arrow-up',
      WotArrowDirection.down => 'arrow-down',
      WotArrowDirection.left => 'arrow-left',
    };

    final Widget body;
    if (layout == WotCellLayout.vertical) {
      // 纵向布局（D 类 P1）：标题行（必填 / 图标 / 标题 + 箭头）在上，
      // 值与描述在下，尾部内容跟随其后。
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Expanded(child: leftContent),
              if (isLink) ...[
                const SizedBox(width: 6),
                WotIcon(
                  name: arrowIcon,
                  size: 14,
                  color: disabled ? scheme.iconDisabled : scheme.iconAuxiliary,
                ),
              ],
            ],
          ),
          if (shownValue != null || desc != null) ...[
            const SizedBox(height: 6),
            rightContent,
          ],
          if (trailing != null) ...[
            const SizedBox(height: 8),
            trailing!,
          ],
        ],
      );
    } else {
      body = Row(
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
          Expanded(child: leftContent),
          rightContent,
          if (isLink) ...[
            const SizedBox(width: 6),
            WotIcon(
              name: arrowIcon,
              size: 14,
              color: disabled ? scheme.iconDisabled : scheme.iconAuxiliary,
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      );
    }

    final cell = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: body,
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