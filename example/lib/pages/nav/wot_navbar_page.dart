import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotNavbar 顶部导航栏示例页。
class WotNavbarPage extends StatelessWidget {
  const WotNavbarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotNavbar 顶部导航栏',
      children: [
        demoSection('基础用法'),
        demoBlock('leftArrow: true（显示返回箭头）+ 标题 + 右侧文字',
            WotNavbar(
              title: '导航栏标题',
              leftArrow: true,
              rightText: '分享',
              onClickLeft: () => demoToast(context, '返回'),
              onClickRight: () => demoToast(context, '右侧'),
            )),
        demoSection('自定义标题（titleWidget）'),
        demoBlock('图标 + 文字自定义标题',
            WotNavbar(
              titleWidget: const Row(mainAxisSize: MainAxisSize.min, children: [
                WotIcon(name: 'search', size: 16),
                SizedBox(width: 6),
                Text('搜索'),
              ]),
              background: context.wotScheme.primaryOf(6),
              color: Colors.white,
              bordered: true,
            )),
        demoSection('左右文字区 + 事件'),
        demoBlock('leftText + rightText',
            WotNavbar(
              title: '左右区演示',
              leftText: '取消',
              rightText: '分享',
              leftArrow: false,
              background: const Color(0xFF36A3F7),
              color: Colors.white,
              bordered: true,
              onClickLeft: () => demoToast(context, '左侧'),
              onClickRight: () => demoToast(context, '右侧'),
            )),
        demoSection('胶囊（capsule / capsuleText）'),
        demoBlock('胶囊导航（左右半区可独立点击）',
            WotNavbar(
              title: '胶囊导航',
              capsule: true,
              capsuleText: '咨询',
              background: context.wotScheme.primaryOf(6),
              color: Colors.white,
              onCapsuleLeft: () => demoToast(context, '胶囊左侧'),
              onCapsuleRight: () => demoToast(context, '胶囊右侧'),
              onClickLeft: () => demoToast(context, '返回'),
            )),
        demoSection('样式（background / color / bordered）'),
        demoBlock('无边框默认', const WotNavbar(title: '默认样式', leftArrow: false)),
        demoSection('高度与尺寸（height / preferredSize）'),
        demoBlock('height: 64（内容区高度可配）',
            const WotNavbar(title: 'height=64', leftArrow: true, height: 64)),
        demoBlock(
            '作为 Scaffold.appBar：safeArea=false + topPadding',
            // 实现 PreferredSizeWidget 后可直接放进 appBar。
            // 关键：Scaffold 已自行避让状态栏，故必须 safeArea: false，
            // 否则会出现双份顶部留白；topPadding 只用于让 preferredSize 算准。
            SizedBox(
              height: 44 + MediaQuery.of(context).padding.top + 16,
              child: Scaffold(
                appBar: WotNavbar(
                  title: '我是 appBar',
                  leftArrow: true,
                  bordered: true,
                  safeArea: false,
                  topPadding: MediaQuery.of(context).padding.top,
                  onClickLeft: () => demoToast(context, 'appBar 返回'),
                ),
                body: Center(
                  child: Text(
                    'preferredSize = ${WotNavbar(title: '', safeArea: false, topPadding: MediaQuery.of(context).padding.top).preferredSize}',
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}