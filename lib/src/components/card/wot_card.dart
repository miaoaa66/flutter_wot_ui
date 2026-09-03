import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 卡片，对应 wot `wd-card`。
class WotCard extends StatelessWidget {
  const WotCard({
    super.key,
    this.title,
    this.description,
    this.image,
    this.price,
    this.currency = '¥',
    this.onClick,
    this.showFooter = false,
    this.footer,
    this.children,
  });

  final String? title;
  final String? description;
  final String? image;
  final String? price;
  final String currency;
  final VoidCallback? onClick;
  final bool showFooter;
  final Widget? footer;
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
                        style: TextStyle(fontSize: 14, color: scheme.textMain)),
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
        if (showFooter) ...[
          const SizedBox(height: 10),
          footer ?? Container(),
        ],
      ],
    );

    final card = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.filledOppo,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: children ?? body,
    );

    if (onClick == null) return card;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onClick, child: card);
  }
}