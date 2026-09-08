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
        demoSection('类型（type）'),
        demoBlock('success 类型',
            SizedBox(
              height: 120,
              child: Align(
                alignment: Alignment.bottomRight,
                child: WotFab(icon: 'heart', type: WotFabType.success,
                    onClick: () => demoToast(context, 'success FAB')),
              ),
            )),
      ],
    );
  }
}