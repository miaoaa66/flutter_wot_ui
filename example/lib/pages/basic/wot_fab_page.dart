import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotFab 悬浮按钮示例页。
class WotFabPage extends StatefulWidget {
  const WotFabPage({super.key});

  @override
  State<WotFabPage> createState() => _WotFabPageState();
}

class _WotFabPageState extends State<WotFabPage> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotFab 悬浮按钮',
      children: [
        demoSection('基础（icon / text / type / label）'),
        demoBlock('带文字 + label',
            SizedBox(
              height: 120,
              child: Align(
                alignment: Alignment.bottomRight,
                child: WotFab(icon: 'add', text: '新建', label: '新建', labelHidden: false,
                    onClick: () => demoToast(context, '点击主按钮')),
              ),
            )),
        demoSection('动作菜单（actions / active 受控 / onActiveChange）'),
        demoBlock('展开动作列表',
            SizedBox(
              height: 240,
              child: Align(
                alignment: Alignment.bottomRight,
                child: WotFab(
                  icon: 'add',
                  text: '菜单',
                  active: _active,
                  onActiveChange: (v) => setState(() => _active = v),
                  actions: [
                    WotFabAction(icon: 'star', text: '收藏', onClick: () => demoToast(context, '收藏')),
                    WotFabAction(icon: 'user', text: '用户', onClick: () => demoToast(context, '用户')),
                    WotFabAction(icon: 'close', text: '关闭', onClick: () => demoToast(context, '关闭')),
                  ],
                ),
              ),
            )),
        demoSection('类型（type）预设色平铺'),
        demoBlock(
            '默认 primary / success / info / warning / danger',
            Wrap(spacing: 12, runSpacing: 12, children: [
              WotFab(icon: 'add', onClick: () => demoToast(context, 'primary FAB')),
              WotFab(icon: 'heart', type: WotFabType.success, onClick: () => demoToast(context, 'success FAB')),
              WotFab(icon: 'chat', type: WotFabType.info, onClick: () => demoToast(context, 'info FAB')),
              WotFab(icon: 'message', type: WotFabType.warning, onClick: () => demoToast(context, 'warning FAB')),
              WotFab(icon: 'close', type: WotFabType.danger, onClick: () => demoToast(context, 'danger FAB')),
            ])),
        demoSection('定位（position / customPosition，需外层 Stack 承载）'),
        demoBlock(
            'position: custom + customPosition（左上角）与 bottom + right（右下角）'
            '——WotFab 生成 Positioned，必须放在 Stack 内',
            SizedBox(
              height: 140,
              child: Stack(children: [
                const Positioned.fill(child: ColoredBox(color: Color(0x08000000))),
                WotFab(icon: 'add', position: WotFabPosition.custom, customPosition: const Offset(16, 16)),
                WotFab(icon: 'heart', type: WotFabType.success, bottom: 16, right: 16),
              ]),
            )),
        demoSection('新增（D 类 P1）：disabled 禁用'),
        demoBlock('disabled：主按钮与动作列表均不可点，整体半透明',
            WotFab(disabled: true, icon: 'add')),
      ],
    );
  }
}