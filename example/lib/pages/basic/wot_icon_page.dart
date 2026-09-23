import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotIcon 图标示例页。
class WotIconPage extends StatelessWidget {
  const WotIconPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotIcon 图标',
      children: [
        demoSection('基础图标（name / size / color）'),
        demoBlock('常用图标集合',
            Wrap(spacing: 12, runSpacing: 12, children: const [
              WotIcon(name: 'add', size: 24),
              WotIcon(name: 'close', size: 24),
              WotIcon(name: 'star', size: 24, color: Color(0xFFFAAD14)),
              WotIcon(name: 'heart', size: 24, color: Color(0xFFFF357C)),
              WotIcon(name: 'search', size: 24),
              WotIcon(name: 'arrow-left', size: 24),
              WotIcon(name: 'arrow-right', size: 24),
              WotIcon(name: 'arrow-down', size: 24),
              WotIcon(name: 'success', size: 24, color: Color(0xFF12B886)),
              WotIcon(name: 'info', size: 24, color: Color(0xFF2683F0)),
            ])),

        demoSection('名称归一化（A 类死参数 #6 已修复）'),
        demoBlock(
            '原先解析里写的是 name.replaceAll("-", "-")——中划线替换为中划线，'
            '无效自替换，导致下划线/空格/大写写法全部解析失败落到兜底图标。'
            '现在统一 trim + `_`/空格→`-` + 转小写，'
            '下面 4 种写法应渲染成同一个 arrow-left',
            Wrap(
              spacing: 18,
              runSpacing: 12,
              children: [
                for (final n in ['arrow-left', 'arrow_left', 'arrow left', 'ARROW-LEFT'])
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WotIcon(name: n, size: 28),
                      const SizedBox(height: 4),
                      Text(n, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
              ],
            )),
        demoBlock('大小写 + 下划线混写：Arrow_Left / STAR / HeArt',
            Wrap(
              spacing: 18,
              runSpacing: 12,
              children: [
                for (final n in ['Arrow_Left', 'STAR', 'HeArt'])
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WotIcon(name: n, size: 28, color: const Color(0xFFF14646)),
                      const SizedBox(height: 4),
                      Text(n, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
              ],
            )),
        demoBlock('未知名称落到兜底图标（不崩溃）',
            Wrap(spacing: 18, children: const [
              WotIcon(name: 'not-exist-icon', size: 28),
              WotIcon(name: '', size: 28),
              WotIcon(size: 28),
            ])),

        demoSection('颜色'),
        demoBlock('默认 / 自定义颜色',
            Wrap(spacing: 12, runSpacing: 12, children: const [
              WotIcon(name: 'settings', size: 24),
              WotIcon(name: 'user', size: 24, color: Color(0xFFF14646)),
              WotIcon(name: 'warning', size: 24, color: Color(0xFFFAAD14)),
            ])),

        demoSection('尺寸'),
        demoBlock('不同 size（16 / 24 / 32 / 48）',
            Wrap(spacing: 16, runSpacing: 12, children: const [
              WotIcon(name: 'add', size: 16),
              WotIcon(name: 'add', size: 24),
              WotIcon(name: 'add', size: 32),
              WotIcon(name: 'add', size: 48, color: Color(0xFF12B886)),
            ])),

        demoSection('事件（onClick）'),
        demoBlock('点击图标弹 toast（onClick 为空时不包 GestureDetector，点击无反馈）',
            WotIcon(name: 'star', size: 32, onClick: () => demoToast(context, '点击了 star'))),
        demoBlock('对照：不传 onClick 的同款图标，点击应无反应',
            const WotIcon(name: 'star', size: 32)),
      ],
    );
  }
}
