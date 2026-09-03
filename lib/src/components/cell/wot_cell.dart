import 'package:flutter/material.dart';

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
  });

  final String? title;
  final String? value;
  final String? label;
  final String? desc;
  final String? icon;
  final bool center;
  final bool? clickable;
  final bool isLink;
  final bool required;
  final bool border;
  final double? titleWidth;
  final VoidCallback? onClick;
  final VoidCallback? onTap;
  final CrossAxisAlignment titleAlign;
  final CrossAxisAlignment valueAlign;
  final CrossAxisAlignment descAlign;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final clickable = this.clickable ?? (onClick != null || isLink);
    final cell = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: center
            ? CrossAxisAlignment.center
            : titleAlign,
        children: [
          if (required) ...[
            Text(
              '*',
              style: TextStyle(color: scheme.dangerMain, fontSize: 14),
            ),
          ],
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: WotIcon(name: icon, size: 16, color: scheme.iconMain),
            ),
          ],
          if (title != null) ...[
            titleWidth == null
                ? Flexible(
                    child: Text(
                      title!,
                      style: TextStyle(fontSize: 14, color: scheme.textMain),
                    ),
                  )
                : SizedBox(
                    width: titleWidth,
                    child: Text(
                      title!,
                      style: TextStyle(fontSize: 14, color: scheme.textMain),
                    ),
                  ),
          ],
          if (label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                label!,
                style: TextStyle(fontSize: 12, color: scheme.textAuxiliary),
              ),
            ),
          ],
          const Spacer(),
          if (desc != null) ...[
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  desc!,
                  style:
                      TextStyle(fontSize: 13, color: scheme.textAuxiliary),
                ),
              ),
            ),
          ],
          if (value != null) ...[
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value!,
                  style: TextStyle(fontSize: 13, color: scheme.textAuxiliary),
                ),
              ),
            ),
          ],
          if (isLink) ...[
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: WotIcon(name: 'arrow-right', size: 14, color: scheme.iconAuxiliary),
            ),
          ],
          if (trailing != null) ...[
            Padding(padding: const EdgeInsets.only(left: 8), child: trailing),
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
}