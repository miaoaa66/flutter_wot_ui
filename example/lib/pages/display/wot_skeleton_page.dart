import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSkeleton 骨架屏示例页。
///
/// 覆盖：loading / avatar / avatarSize / avatarShape / title / row /
/// rowWidth（百分比与像素）/ rowHeight / **animate（A 类死参数 #16）** /
/// hideTitles / child，以及 WotSkeletonItem 四种类型。
class WotSkeletonPage extends StatefulWidget {
  const WotSkeletonPage({super.key});

  @override
  State<WotSkeletonPage> createState() => _WotSkeletonPageState();
}

class _WotSkeletonPageState extends State<WotSkeletonPage> {
  bool _loading = true;
  bool _animate = true;
  bool _avatar = true;
  bool _title = true;
  int _row = 3;
  WotSkeletonAvatarShape _shape = WotSkeletonAvatarShape.round;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSkeleton 骨架屏',
      children: [
        demoSection('基础（loading / avatar / title / row）'),
        demoBlock(
          'loading 切换骨架与真实内容。loading: false 时直接渲染 child；'
          'child 为 null 则渲染一个空的 SizedBox。',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WotButton(
                text: _loading ? '显示内容' : '显示骨架',
                size: WotButtonSize.small,
                onClick: () => setState(() => _loading = !_loading),
              ),
              const SizedBox(height: 8),
              WotSkeleton(
                loading: _loading,
                avatar: true,
                title: true,
                row: 3,
                rowWidth: '100%',
                child: const Text('加载完成后的内容'),
              ),
            ],
          ),
        ),

        demoSection('动画（animate，A 类死参数 #16）'),
        demoBlock(
          'animate: true 时占位块做 1.2s 往复的透明度呼吸；'
          'animate: false 时是静止的纯色块。'
          'WotSkeletonItem 的 animate 原先接收后完全没用上（一直静止），'
          '修复后才真正生效——下面两组可对比。',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('animate: '),
                  WotSwitch(
                    modelValue: _animate,
                    onChange: (v) => setState(() => _animate = v),
                  ),
                  Text('$_animate', style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('WotSkeleton（整块）',
                  style: TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              WotSkeleton(
                loading: true,
                animate: _animate,
                avatar: true,
                title: true,
                row: 2,
              ),
              const SizedBox(height: 16),
              const Text('WotSkeletonItem（独立元素）',
                  style: TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                children: [
                  WotSkeletonItem(
                      type: WotSkeletonItemType.circular, animate: _animate),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WotSkeletonItem(
                            width: 120, height: 14, animate: _animate),
                        const SizedBox(height: 8),
                        WotSkeletonItem(animate: _animate),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        demoSection('WotSkeletonItem 四种类型'),
        demoBlock('text（默认，高 14）/ rect（高 18）/ image（按 size）/ circular（圆）',
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final t in [
                  WotSkeletonItemType.text,
                  WotSkeletonItemType.rect,
                  WotSkeletonItemType.image,
                  WotSkeletonItemType.circular,
                ])
                  Expanded(
                    child: Column(
                      children: [
                        WotSkeletonItem(type: t, size: 36, animate: _animate),
                        const SizedBox(height: 4),
                        Text(t.name, style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
              ],
            )),

        demoSection('头像（avatar / avatarSize / avatarShape）'),
        demoBlock(
          'avatarShape: round（圆）/ square（圆角方）。'
          '不传 avatar 时头像占位整块消失，文本区占满整行。',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  WotButton(
                    text: 'avatar: $_avatar',
                    size: WotButtonSize.small,
                    onClick: () => setState(() => _avatar = !_avatar),
                  ),
                  WotButton(
                    text: _shape == WotSkeletonAvatarShape.round ? '圆' : '方',
                    size: WotButtonSize.small,
                    onClick: () => setState(() => _shape = _shape ==
                            WotSkeletonAvatarShape.round
                        ? WotSkeletonAvatarShape.square
                        : WotSkeletonAvatarShape.round),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              WotSkeleton(
                loading: true,
                animate: _animate,
                avatar: _avatar,
                avatarSize: 48,
                avatarShape: _shape,
                title: true,
                row: 2,
              ),
            ],
          ),
        ),

        demoSection('文本行（title / row / rowWidth / rowHeight）'),
        demoBlock(
          'rowWidth 既可传百分比字符串（如 "60%"），也可传具体像素数。'
          '传像素数时所有行同宽；传百分比时按骨架容器宽度换算。',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('行数 '),
                  Expanded(
                    child: Slider(
                      value: _row.toDouble(),
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: '$_row',
                      onChanged: (v) => setState(() => _row = v.round()),
                    ),
                  ),
                  Text('$_row'),
                ],
              ),
              WotButton(
                text: 'title: $_title',
                size: WotButtonSize.small,
                onClick: () => setState(() => _title = !_title),
              ),
              const SizedBox(height: 8),
              const Text('rowWidth: "60%"', style: TextStyle(fontSize: 12)),
              WotSkeleton(
                  loading: true,
                  animate: _animate,
                  title: _title,
                  row: _row,
                  rowWidth: '60%'),
              const SizedBox(height: 12),
              const Text('rowWidth: 180（像素）', style: TextStyle(fontSize: 12)),
              WotSkeleton(
                  loading: true,
                  animate: _animate,
                  title: _title,
                  row: _row,
                  rowWidth: 180,
                  rowHeight: 10),
            ],
          ),
        ),

        demoSection('hideTitles（仅保留头像）'),
        demoBlock(
          'hideTitles: true 会同时屏蔽标题行与所有文本行，'
          '只留头像占位——适合「头像已加载、文案待加载」的分阶段占位。',
          WotSkeleton(
            loading: true,
            animate: _animate,
            avatar: true,
            title: true,
            row: 3,
            hideTitles: true,
          ),
        ),
      ],
    );
  }
}
