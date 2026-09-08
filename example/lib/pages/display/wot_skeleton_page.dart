import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSkeleton 骨架屏示例页。
class WotSkeletonPage extends StatefulWidget {
  const WotSkeletonPage({super.key});

  @override
  State<WotSkeletonPage> createState() => _WotSkeletonPageState();
}

class _WotSkeletonPageState extends State<WotSkeletonPage> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSkeleton 骨架屏',
      children: [
        demoSection('基础（loading / avatar / title / row）'),
        demoBlock('头像 + 标题 + 3 行列',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WotButton(text: _loading ? '显示内容' : '显示骨架', size: WotButtonSize.small, onClick: () => setState(() => _loading = !_loading)),
              const SizedBox(height: 8),
              WotSkeleton(
                loading: _loading,
                avatar: true,
                title: true,
                row: 3,
                rowWidth: '100%',
                child: const Text('加载完成后的内容'),
              ),
            ])),
      ],
    );
  }
}