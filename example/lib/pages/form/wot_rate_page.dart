import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotRate 评分示例页。
class WotRatePage extends StatefulWidget {
  const WotRatePage({super.key});

  @override
  State<WotRatePage> createState() => _WotRatePageState();
}

class _WotRatePageState extends State<WotRatePage> {
  double _v1 = 3;
  double _v2 = 2;
  double _v3 = 5;
  double _v4 = 4;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotRate 评分',
      children: [
        demoSection('基础用法（modelValue / onChange）'),
        demoBlock('基础 5 星（当前${_v1.toStringAsFixed(1)}）', WotRate(modelValue: _v1, onChange: (v) => setState(() => _v1 = v))),
        demoSection('数量与尺寸（count / size / gutter）'),
        demoBlock('count=8 size=20 gutter=8',
            WotRate(modelValue: _v2, count: 8, size: 20, gutter: 8, onChange: (v) => setState(() => _v2 = v))),
        demoSection('图标（icon / activeIcon）'),
        demoBlock('自定义图标（爱心）+ count=6',
            WotRate(modelValue: _v3, count: 6, icon: Icons.favorite_border, activeIcon: Icons.favorite, onChange: (v) => setState(() => _v3 = v))),
        demoSection('颜色（color / activeColor）'),
        demoBlock('自定义未选中/选中颜色',
            WotRate(modelValue: _v4, color: Colors.grey, activeColor: const Color(0xFF12B886), onChange: (v) => setState(() => _v4 = v))),
        demoSection('特性（allowHalf / disabled / readonly / error）'),
        demoBlock('allowHalf 允许半选（当前${_v2.toStringAsFixed(1)}）', WotRate(modelValue: _v2, size: 55, allowHalf: true, onChange: (v) => setState(() => _v2 = v))),
        demoBlock('disabled 禁用（已选中图标灰化）',
            WotRate(modelValue: _v1, disabled: true, onChange: (v) => setState(() => _v1 = v))),
        demoBlock('readonly 只读（锁交互、保持正常配色 —— 区别于 disabled 的灰化）',
            WotRate(modelValue: _v3, readonly: true, onChange: (v) => setState(() => _v3 = v))),
        demoBlock('error 校验失败（已选中图标转危险色）',
            WotRate(modelValue: _v3, error: true, onChange: (v) => setState(() => _v3 = v))),
      ],
    );
  }
}
