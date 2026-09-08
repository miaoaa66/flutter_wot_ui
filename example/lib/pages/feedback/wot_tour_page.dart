import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotTour 新手引导示例页（高亮页内控件并自动滚动到目标）。
class WotTourPage extends StatefulWidget {
  const WotTourPage({super.key});

  @override
  State<WotTourPage> createState() => _WotTourPageState();
}

class _WotTourPageState extends State<WotTourPage> {
  final GlobalKey _k1 = GlobalKey();
  final GlobalKey _k2 = GlobalKey();
  final ScrollController _ctl = ScrollController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _start() {
    WotTour.show(
      context,
      steps: [
        WotTourStep(target: _k1, title: '第一步 · 轻提示', description: '点击文本按钮触发 WotToast。', scrollController: _ctl),
        WotTourStep(target: _k2, title: '第二步 · 确认框', description: '通过 WotDialog.confirm 弹出确认框。', scrollController: _ctl, onEnter: () => demoToast(context, '第二步进入')),
      ],
      onFinish: () => demoToast(context, '引导完成'),
      onSkip: () => demoToast(context, '已跳过引导'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotTour 新手引导',
      children: [
        demoSection('目标①：WotToast'),
        demoBlock('轻提示按钮', WotButton(
            text: '轻提示', key: _k1, size: WotButtonSize.small, onClick: () => WotToast.text(context, '轻提示'))),
        demoSection('目标②：WotDialog'),
        demoBlock('确认框按钮', WotButton(
            text: '确认框', key: _k2, size: WotButtonSize.small, onClick: () => WotDialog.confirm(context, message: '确定删除？'))),
        demoSection('启动引导'),
        demoBlock('依次高亮上方两个目标并说明',
            WotButton(text: '开始引导', size: WotButtonSize.small, type: WotButtonType.primary, onClick: _start)),
        demoBlock('说明',
            const WotText('点击“开始引导”后，会依次高亮上方的「轻提示」「确认框」两个按钮，并自动滚动到目标。')),
      ],
    );
  }
}