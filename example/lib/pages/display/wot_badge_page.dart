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
        demoBlock('topRight / topLeft / bottomRight',
            Wrap(spacing: 24, runSpacing: 16, children: [
              WotBadge(modelValue: 8, child: _box(context)),
              WotBadge(modelValue: 8, badgePosition: WotBadgePosition.topLeft, child: _box(context)),
              WotBadge(modelValue: 8, badgePosition: WotBadgePosition.bottomRight, child: _box(context)),
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
      ],
    );
  }
}