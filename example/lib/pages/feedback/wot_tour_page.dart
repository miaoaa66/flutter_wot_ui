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

  void _start([WotTourPlacement? placement]) {
    WotTour.show(
      context,
      steps: [
        WotTourStep(
          target: _k1,
          title: '第一步 · 轻提示',
          description: '点击文本按钮触发 WotToast。'
              '${placement == null ? '' : '（气泡方位：${placement.name}）'}',
          placement: placement,
          scrollController: _ctl,
        ),
        WotTourStep(
          target: _k2,
          title: '第二步 · 确认框',
          description: '通过 WotDialog.confirm 弹出确认框。',
          placement: placement,
          scrollController: _ctl,
          onEnter: () => demoToast(context, '第二步进入'),
        ),
      ],
      onFinish: () => demoToast(context, '引导完成'),
      onSkip: () => demoToast(context, '已跳过引导'),
    );
  }

  /// 高级参数演示：蒙层交互 + 自定义按钮文案 + 步骤级回调。
  void _startAdvanced() {
    WotTour.show(
      context,
      steps: [
        WotTourStep(
          target: _k1,
          title: '第一步 · 自定义高亮',
          description: 'maskPadding 外扩 12px；离开本步触发 onLeave。',
          maskPadding: 12,
          onLeave: () => demoToast(context, 'onLeave：离开第一步'),
        ),
        WotTourStep(
          target: _k2,
          title: '第二步 · 滚动对齐',
          description: 'autoScroll: false 时引导不自动滚动到目标；'
              'targetScrollOffset 可指定滚动落点偏移（本例目标可见，效果一致）。',
          autoScroll: false,
        ),
      ],
      showMask: true,
      closeOnClickMask: true,
      clickMaskNext: true,
      maxWidth: 240,
      skipButtonText: '跳过',
      prevButtonText: '上一项',
      nextButtonText: '下一项',
      finishButtonText: '完成引导',
      onChange: (i) => demoToast(context, 'onChange：第 ${i + 1} 步'),
      onNext: (i) => demoToast(context, 'onNext：进入第 ${i + 1} 步'),
      onPrev: (i) => demoToast(context, 'onPrev：回到第 ${i + 1} 步'),
      onFinish: () => demoToast(context, '引导完成'),
      onSkip: () => demoToast(context, '已跳过'),
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
        demoBlock('依次高亮上方两个目标并说明（默认方位 auto）',
            WotButton(text: '开始引导', size: WotButtonSize.small, type: WotButtonType.primary, onClick: _start)),
        demoSection('气泡方位（placement，per-step 可配）'),
        demoBlock(
            'auto（四周最大空间）/ top / bottom / left / right——'
            '左右方位在窄屏空间不足时组件会自动翻转',
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final p in WotTourPlacement.values)
                WotButton(
                  text: p.name,
                  size: WotButtonSize.small,
                  onClick: () => _start(p),
                ),
            ])),
        demoSection('高级参数（蒙层交互 / 按钮文案 / 步骤回调）'),
        demoBlock(
            'closeOnClickMask 点蒙层关闭 + clickMaskNext 点蒙层下一步（关闭优先）+ '
            'skip/prev/next/finish 四按钮文案自定义 + maxWidth: 240 + '
            'onChange/onNext/onPrev/onLeave；step 级 maskPadding 外扩高亮区、autoScroll 控制滚动对齐',
            WotButton(text: '高级引导', size: WotButtonSize.small, onClick: _startAdvanced)),
        demoBlock('说明',
            const WotText('点击“开始引导”后，会依次高亮上方的「轻提示」「确认框」两个按钮，并自动滚动到目标。')),
      ],
    );
  }
}