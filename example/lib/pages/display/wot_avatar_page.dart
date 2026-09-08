import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotAvatar / WotAvatarGroup 头像示例页（部分为网络图，加载失败由冒烟测试容错）。
class WotAvatarPage extends StatelessWidget {
  const WotAvatarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return WotDemoScaffold(
      title: 'WotAvatar 头像',
      children: [
        demoSection('基础（name 文字 / src 图片 / shape）'),
        demoBlock('文字/图片/方形',
            Wrap(spacing: 12, runSpacing: 12, children: [
              const WotAvatar(name: '张'),
              WotAvatar(src: 'https://picsum.photos/seed/a/80', size: 48),
              WotAvatar(shape: WotAvatarShape.square, name: '李', size: 48),
              const WotAvatar(name: '王', size: 48, icon: 'user'),
            ])),
        demoSection('尺寸 / 颜色（size / bgColor / color）'),
        demoBlock('不同 size',
            Wrap(spacing: 12, runSpacing: 12, children: const [
              WotAvatar(name: 'S', size: 32),
              WotAvatar(name: 'M', size: 40),
              WotAvatar(name: 'L', size: 56),
            ])),
        demoBlock('自定义底色/文字色/图标',
            Wrap(spacing: 12, runSpacing: 12, children: [
              WotAvatar(name: '方', size: 48, shape: WotAvatarShape.square, round: true, bgColor: scheme.primaryOf(6), color: Colors.white),
              WotAvatar(icon: 'star', size: 48, bgColor: const Color(0xFFFFE4B5), color: Colors.deepOrange),
            ])),
        demoSection('头像组（avatarList / max / size）'),
        demoBlock('max 超出显示 +N',
            Wrap(spacing: 12, runSpacing: 12, children: [
              WotAvatarGroup(
                avatarList: [
                  'https://picsum.photos/seed/a1/80',
                  'https://picsum.photos/seed/a2/80',
                  'https://picsum.photos/seed/a3/80',
                ],
                max: 3,
              ),
              WotAvatarGroup(
                avatarList: [
                  'https://picsum.photos/seed/g1/80',
                  'https://picsum.photos/seed/g2/80',
                  'https://picsum.photos/seed/g3/80',
                  'https://picsum.photos/seed/g4/80',
                  'https://picsum.photos/seed/g5/80',
                  'https://picsum.photos/seed/g6/80',
                ],
                max: 5,
                size: 44,
              ),
            ])),
      ],
    );
  }
}