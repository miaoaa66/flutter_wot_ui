import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotPopover 气泡弹层示例页。
///
/// 覆盖点：
/// - `placement` 全部 8 个取值（原先只演示了 bottom / top 两个）
/// - `showArrow`（A 类死参数 #10，原先是死参数，现已真正绘制箭头）
/// - `trigger` 三种模式：`click` / `hover` / `manual`
/// - `mask` / `closeOnClickOverlay`
/// - 受控 `visible` + 外部 setState —— 这一块专门验证 `didUpdateWidget`，
///   且 `onOpen` / `onClose` 里会 setState，能暴露「build 阶段回调」类崩溃
class WotPopoverPage extends StatefulWidget {
  const WotPopoverPage({super.key});

  @override
  State<WotPopoverPage> createState() => _WotPopoverPageState();
}

class _WotPopoverPageState extends State<WotPopoverPage> {
  bool _arrow = true;
  bool _flip = true;
  bool _mask = false;
  bool _closeOnOverlay = true;
  bool _controlledOpen = false;
  bool _manualOpen = false;
  String _log = '（暂无）';

  void _push(String msg) {
    // 回调里 setState：若组件在 build 阶段同步回调，这里会直接抛
    // 「setState() or markNeedsBuild() called during build」。
    setState(() => _log = msg);
  }

  /// 8 个 placement 的中文标注。
  static const _placements = <(WotPopoverPlacement, String)>[
    (WotPopoverPlacement.top, 'top'),
    (WotPopoverPlacement.bottom, 'bottom'),
    (WotPopoverPlacement.left, 'left'),
    (WotPopoverPlacement.right, 'right'),
    (WotPopoverPlacement.topLeft, 'topLeft'),
    (WotPopoverPlacement.topRight, 'topRight'),
    (WotPopoverPlacement.bottomLeft, 'bottomLeft'),
    (WotPopoverPlacement.bottomRight, 'bottomRight'),
  ];

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotPopover 气泡弹层',
      children: [
        demoSection('基础（content / onSelect / onClick）'),
        demoBlock('点击弹出选项，选中后回写到下方日志',
            WotPopover(
              content: const [Text('选项一'), Text('选项二'), Text('选项三')],
              child: WotButton(text: '弹出气泡', size: WotButtonSize.small),
              onSelect: (i) => _push('onSelect: $i'),
              onClick: (i) => demoToast(context, 'onClick $i'),
            )),
        demoBlock('回调日志：$_log', WotText(_log, type: WotTextType.wotDefault)),

        demoSection('位置（placement，8 个取值全覆盖）'),
        demoBlock('居中一列演示，避免按钮贴边触发自动翻转；'
            '关闭「自动翻转」可看真实方位',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('自动翻转 ', style: TextStyle(fontSize: 12)),
                  WotSwitch(
                    modelValue: _flip,
                    onChange: (v) => setState(() => _flip = v),
                  ),
                ]),
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final e in _placements)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: WotPopover(
                            placement: e.$1,
                            flip: _flip,
                            content: [Text('placement: ${e.$2}')],
                            child: WotButton(text: e.$2, size: WotButtonSize.small),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )),

        demoSection('箭头（showArrow，A 类死参数 #10 已实现）'),
        demoBlock('showArrow: $_arrow（现场切换，验证参数现在真的生效）',
            Row(children: [
              WotPopover(
                showArrow: _arrow,
                placement: WotPopoverPlacement.bottom,
                content: [Text('showArrow: $_arrow')],
                child: WotButton(text: '打开气泡', size: WotButtonSize.small),
              ),
              const SizedBox(width: 12),
              WotSwitch(
                modelValue: _arrow,
                onChange: (v) => setState(() => _arrow = v),
              ),
            ])),

        demoSection('遮罩（mask / closeOnClickOverlay）'),
        demoBlock('mask: $_mask，closeOnClickOverlay: $_closeOnOverlay',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WotPopover(
                mask: _mask,
                closeOnClickOverlay: _closeOnOverlay,
                content: [Text('mask: $_mask')],
                child: WotButton(text: '打开气泡', size: WotButtonSize.small),
              ),
              const SizedBox(height: 8),
              Row(children: [
                const Text('mask ', style: TextStyle(fontSize: 12)),
                WotSwitch(modelValue: _mask, onChange: (v) => setState(() => _mask = v)),
                const SizedBox(width: 16),
                const Text('点遮罩关闭 ', style: TextStyle(fontSize: 12)),
                WotSwitch(
                    modelValue: _closeOnOverlay,
                    onChange: (v) => setState(() => _closeOnOverlay = v)),
              ]),
            ])),

        demoSection('触发方式（trigger）'),
        demoBlock('trigger: hover —— 鼠标移入即弹出（桌面端生效）',
            WotPopover(
              trigger: WotTriggerMode.hover,
              content: const [Text('移入弹出')],
              child: WotButton(text: '悬浮触发', size: WotButtonSize.small),
            )),
        demoBlock('trigger: manual —— 只能由外部 visible 控制，点锚点无效',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WotPopover(
                trigger: WotTriggerMode.manual,
                visible: _manualOpen,
                content: const [Text('仅受控显示')],
                // 受控用法：onChange 必须回写 state，否则外部 visible 恒为 true，
                // 关闭后会被重新打开（即「能打开关不掉」）。
                onChange: (v) => setState(() => _manualOpen = v),
                child: WotButton(
                    text: '点击锚点应无反应',
                    size: WotButtonSize.small,
                    type: WotButtonType.info),
              ),
              const SizedBox(height: 12),
              WotButton(
                text: _manualOpen ? '外部关闭（manual）' : '外部打开（manual）',
                size: WotButtonSize.small,
                onClick: () => setState(() => _manualOpen = !_manualOpen),
              ),
            ])),

        demoSection('受控（visible + 外部 setState）'),
        demoBlock(
            '当前 visible: $_controlledOpen —— 外部切换后气泡应随之开合，'
                '且 onOpen / onClose 回写到日志',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WotPopover(
                trigger: WotTriggerMode.manual,
                visible: _controlledOpen,
                placement: WotPopoverPlacement.bottom,
                content: const [Text('受控气泡')],
                onOpen: () => _push('onOpen'),
                onClose: () => _push('onClose'),
                // 受控用法：onChange 必须回写 state，否则外部 visible 恒为 true，
                // 点遮罩关闭后会被 didUpdateWidget 重新打开（表现为「能打开关不掉」）。
                onChange: (v) {
                  setState(() => _controlledOpen = v);
                  _push('onChange: $v');
                },
                child: WotButton(text: '受控锚点', size: WotButtonSize.small),
              ),
              const SizedBox(height: 100),
              WotButton(
                text: _controlledOpen ? '外部关闭' : '外部打开',
                size: WotButtonSize.small,
                type: WotButtonType.primary,
                onClick: () => setState(() => _controlledOpen = !_controlledOpen),
              ),
            ])),
      ],
    );
  }
}
