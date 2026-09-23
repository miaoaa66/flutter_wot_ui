import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 卡片类型。
enum WotCardType { basic, rectangle }

/// 卡片，对应 wot `wd-card`。
class WotCard extends StatelessWidget {
  const WotCard({
    super.key,
    this.type = WotCardType.basic,
    this.title,
    this.description,
    this.image,
    this.price,
    this.currency = '¥',
    this.round = true,
    this.border = true,
    this.onClick,
    this.showFooter = false,
    this.footer,
    this.children,
  });

  /// 卡片类型，可选 `basic`/`rectangle`，默认 basic。rectangle 为直角无阴影矩形卡片。
  final WotCardType type;

  /// 卡片标题。
  final String? title;

  /// 卡片描述文字。
  final String? description;

  /// 卡片图片地址。
  final String? image;

  /// 价格文案。
  final String? price;

  /// 货币符号前缀，默认 `¥`。
  final String currency;

  /// 是否圆角（basic 类型默认 true；rectangle 类型忽略，始终直角），默认 true。
  final bool round;

  /// 是否绘制边框（basic 类型默认 true 以替代/补充阴影；rectangle 类型恒为 true），默认 true。
  final bool border;

  /// 点击卡片时触发的回调。
  final VoidCallback? onClick;

  /// 是否展示卡片底部区域；默认 false，但传入 [footer] 时自动展示。
  final bool showFooter;

  /// 卡片底部自定义内容（wot `footer` 插槽）。
  final Widget? footer;

  /// 自定义卡片内容（wot 默认插槽），提供时覆盖内置图文布局。
  final Widget? children;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  image!,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 90,
                    height: 90,
                    color: scheme.filledStrong,
                    child: const Center(child: WotIcon(name: 'image', size: 24)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: scheme.textMain, fontWeight: FontWeight.w500)),
                  if (description != null) ...[
                    const SizedBox(height: 6),
                    Text(description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: scheme.textAuxiliary)),
                  ],
                  if (price != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$currency$price',
                      style: TextStyle(fontSize: 14, color: scheme.dangerMain, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (showFooter || footer != null) ...[
          const SizedBox(height: 10),
          footer ?? Container(),
        ],
      ],
    );

    final isRect = type == WotCardType.rectangle;
    final radius = (isRect || !round) ? BorderRadius.zero : BorderRadius.circular(8);
    final borderLine = (border || isRect)
        ? Border.all(color: scheme.borderLight, width: 1)
        : Border.all(color: Colors.transparent);

    final card = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.filledOppo,
        borderRadius: radius,
        border: borderLine,
        boxShadow: isRect
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: children ?? body,
    );

    if (onClick == null) return card;
    // 无障碍：整卡可点，补 button 角色 + 点按动作（卡内文本读屏已可读）。
    return Semantics(
      button: true,
      onTap: onClick,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque, onTap: onClick, child: card),
    );
  }
}