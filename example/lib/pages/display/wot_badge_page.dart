import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotBadge 徽标示例页。
class WotBadgePage extends StatefulWidget {
  const WotBadgePage({super.key});

  @override
  State<WotBadgePage> createState() => _WotBadgePageState();
}

class _WotBadgePageState extends State<WotBadgePage> {
  bool _hidden = false;

  Widget _box(BuildContext context) => Container(
        width: 40,
        height: 40,
        color: context.wotScheme.filledStrong,
      );

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotBadge 徽标',
      children: [
        demoSection('数字徽标（modelValue / max）'),
        demoBlock('默认 / 超 max 显示 99+ / 点状',
            Wrap(spacing: 24, runSpacing: 16, children: [
              WotBadge(modelValue: 5, child: _box(context)),
              WotBadge(modelValue: 120, max: 99, child: _box(context)),
              WotBadge(isDot: true, child: _box(context)),
            ])),
        demoSection('位置（badgePosition）'),
        demoBlock('9 宫格位置',
            Wrap(spacing: 24, runSpacing: 16, children: [
              WotBadge(modelValue: 1, badgePosition: WotBadgePosition.topLeft, child: _box(context)),
              WotBadge(modelValue: 2, badgePosition: WotBadgePosition.topCenter, child: _box(context)),
              WotBadge(modelValue: 3, badgePosition: WotBadgePosition.topRight, child: _box(context)),
              WotBadge(modelValue: 4, badgePosition: WotBadgePosition.middleLeft, child: _box(context)),
              WotBadge(modelValue: 5, badgePosition: WotBadgePosition.middleCenter, child: _box(context)),
              WotBadge(modelValue: 6, badgePosition: WotBadgePosition.middleRight, child: _box(context)),
              WotBadge(modelValue: 7, badgePosition: WotBadgePosition.bottomLeft, child: _box(context)),
              WotBadge(modelValue: 8, badgePosition: WotBadgePosition.bottomCenter, child: _box(context)),
              WotBadge(modelValue: 9, badgePosition: WotBadgePosition.bottomRight, child: _box(context)),
            ])),
        demoSection('隐藏（hidden）与插槽（slot）'),
        demoBlock('点击切换 hidden',
            WotBadge(
              hidden: _hidden,
              modelValue: 10,
              child: InkWell(
                onTap: () => setState(() => _hidden = !_hidden),
                child: _box(context),
              ),
            )),
        demoBlock('slot 自定义图标角标',
            WotBadge(slot: const Icon(Icons.star, color: Colors.amber, size: 18), child: _box(context))),
        demoSection('新增（D 类 P1）：type 预设色 / shape / text / offset'),
        demoBlock(
            'type 预设配色',
            Wrap(spacing: 24, runSpacing: 16, children: [
              WotBadge(modelValue: 3, type: WotBadgeType.primary, child: const Icon(Icons.message, size: 28)),
              WotBadge(modelValue: 5, type: WotBadgeType.success, child: const Icon(Icons.shopping_cart, size: 28)),
              WotBadge(modelValue: 9, type: WotBadgeType.warning, child: const Icon(Icons.notifications, size: 28)),
              WotBadge(modelValue: 12, type: WotBadgeType.info, child: const Icon(Icons.mail, size: 28)),
            ])),
        demoBlock(
            'text 纯文本角标 / square 形状 / offset 微调',
            Wrap(spacing: 24, runSpacing: 16, children: [
              WotBadge(text: 'NEW', child: const Icon(Icons.star, size: 28)),
              WotBadge(modelValue: 6, shape: WotBadgeShape.square, child: const Icon(Icons.folder, size: 28)),
              WotBadge(modelValue: 8, offset: const Offset(4, -4), child: const Icon(Icons.chat_bubble, size: 28)),
            ])),
      ],
    );
  }
}
