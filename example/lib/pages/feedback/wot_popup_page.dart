import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotPopup 弹出层示例页（弹层作为全屏覆盖层叠在列表上方）。
///
/// 覆盖点：
/// - `position` 全部 5 个取值（原先只有 bottom / center）
/// - `duration`（A 类死参数 #1，弹层本体动画原先恒为终态，现已由 AnimationController 驱动）
/// - `modal` / `round` / `closeOnClickOverlay`
/// - `safeArea` / `safeAreaInsetBottom`（新发现的死参数，已修复）
/// - `overlayStyle` 自定义遮罩色
/// - `onOpen` / `onClose` / `onClickOverlay` 回写到页面日志
class WotPopupPage extends StatefulWidget {
  const WotPopupPage({super.key});

  @override
  State<WotPopupPage> createState() => _WotPopupPageState();
}

class _WotPopupPageState extends State<WotPopupPage> {
  /// 当前打开的弹层标识（同一时刻只允许一个，避免多层遮罩互相遮挡）。
  String? _open;

  bool _round = true;
  bool _modal = true;
  bool _closeOnOverlay = true;
  bool _safeArea = false;
  bool _fast = true;
  String _log = '（暂无）';

  void _push(String msg) {
    // 回调里 setState：若组件在 build 阶段同步回调，这里会直接抛
    // 「setState() or markNeedsBuild() called during build」。
    setState(() => _log = msg);
  }

  void _show(String slot) => setState(() => _open = slot);

  bool _isOpen(String slot) => _open == slot;

  /// 统一的弹层包裹：全屏 Stack 提供有界约束。
  Widget _layer(String slot, {required WotPopupPosition position, required Widget child}) {
    return Positioned.fill(
      child: WotPopup(
        visible: _isOpen(slot),
        position: position,
        round: _round,
        modal: _modal,
        closeOnClickOverlay: _closeOnOverlay,
        safeArea: _safeArea,
        duration: _fast ? const Duration(milliseconds: 250) : const Duration(milliseconds: 1200),
        onClose: () => setState(() {
          _open = null;
          _log = 'onClose（$slot）';
        }),
        onOpen: () => _push('onOpen（$slot）'),
        onClickOverlay: () => _push('onClickOverlay（$slot）'),
        child: child,
      ),
    );
  }

  // 注意：弹层必须「常驻挂载、仅切换 visible」才看得到动画——
  // WotPopup 的入场动画由 didUpdateWidget 里 _controller.forward() 驱动、
  // 遮罩由 AnimatedOpacity 的透明度变化驱动，二者都只在 visible 变化（而非首次挂载）时触发。
  // 早期这页用 `if (_isOpen)` 按需挂载，导致 initState 直接停在终态、完全看不到动画。
  // 因此这里保持全部弹层常驻挂载，只让 visible 随 _open 切换（入场/退场动画都可见）。

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('WotPopup 弹出层')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              demoSection('全局开关（对下面所有弹层生效）'),
              demoBlock(
                  'round: $_round｜modal: $_modal｜点遮罩关闭: $_closeOnOverlay｜'
                  'safeArea: $_safeArea｜动画: ${_fast ? "250ms" : "1200ms"}',
                  Wrap(spacing: 14, runSpacing: 6, children: [
                    _switchRow('round', _round, (v) => setState(() => _round = v)),
                    _switchRow('modal', _modal, (v) => setState(() => _modal = v)),
                    _switchRow('点遮罩关闭', _closeOnOverlay, (v) => setState(() => _closeOnOverlay = v)),
                    _switchRow('safeArea', _safeArea, (v) => setState(() => _safeArea = v)),
                    _switchRow('慢速动画', !_fast, (v) => setState(() => _fast = !v)),
                  ])),

              demoSection('位置（position，5 个取值全覆盖）'),
              demoBlock('逐个点击打开，观察滑入方向',
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    for (final e in <(WotPopupPosition, String)>[
                      (WotPopupPosition.bottom, 'bottom'),
                      (WotPopupPosition.top, 'top'),
                      (WotPopupPosition.left, 'left'),
                      (WotPopupPosition.right, 'right'),
                      (WotPopupPosition.center, 'center'),
                    ])
                      WotButton(
                        text: e.$2,
                        size: WotButtonSize.small,
                        onClick: () => _show(e.$2),
                      ),
                  ])),

              demoSection('动画时长（duration，A 类死参数 #1）'),
              demoBlock(
                  '当前 ${_fast ? "250ms（默认）" : "1200ms"}——把「慢速动画」打开再触发弹层，'
                      '应能明显看到滑入/缩放过程；修复前弹层本体是恒终态，改 duration 毫无变化',
                  WotButton(
                      text: '打开底部弹层看动画', size: WotButtonSize.small, onClick: () => _show('bottom'))),

              demoSection('安全区（safeArea / safeAreaInsetBottom，新修复的死参数）'),
              demoBlock(
                  'safeArea 由上方开关控制：true 时四边统一避让，false 时只避让贴边侧。'
                      '下面的弹层固定 safeAreaInsetBottom: true 以单独演示底边',
                  WotButton(
                      text: '打开（强制 bottom 内缩）',
                      size: WotButtonSize.small,
                      type: WotButtonType.primary,
                      onClick: () => _show('safe'))),

              demoSection('回调（onOpen / onClose / onClickOverlay）'),
              demoBlock('回调日志：$_log', WotText(_log, type: WotTextType.wotDefault)),
            ],
          ),
        ),

        // ---- 覆盖层：全部常驻挂载，仅切换 visible（动画由组件驱动）----
        _layer('bottom',
            position: WotPopupPosition.bottom,
            child: const SizedBox(
                height: 200, width: double.infinity, child: Center(child: WotText('底部弹出内容')))),
        _layer('top',
            position: WotPopupPosition.top,
            child: const SizedBox(
                height: 200, width: double.infinity, child: Center(child: WotText('顶部弹出内容')))),
        _layer('left',
            position: WotPopupPosition.left,
            child: const SizedBox(
                width: 220, height: double.infinity, child: Center(child: WotText('左侧弹出内容')))),
        _layer('right',
            position: WotPopupPosition.right,
            child: const SizedBox(
                width: 220, height: double.infinity, child: Center(child: WotText('右侧弹出内容')))),
        _layer('center',
            position: WotPopupPosition.center,
            child: const Padding(
                padding: EdgeInsets.all(24), child: WotText('居中弹出内容'))),
        Positioned.fill(
          child: WotPopup(
            visible: _isOpen('safe'),
            position: WotPopupPosition.bottom,
            round: _round,
            modal: _modal,
            closeOnClickOverlay: _closeOnOverlay,
            safeAreaInsetBottom: true,
            onClose: () => setState(() => _open = null),
            child: const SizedBox(
                height: 180, width: double.infinity, child: Center(child: WotText('强制底部内缩'))),
          ),
        ),
      ],
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 4),
      WotSwitch(modelValue: value, onChange: onChanged),
    ]);
  }
}
