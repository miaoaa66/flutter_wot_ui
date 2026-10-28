// WotDropMenu 浮层锚定回归测试：
// 1) 展开后镜像菜单栏必须与真实菜单栏矩形重合（回归 bug：theater tight 全屏约束吞掉
//    SizedBox 宽度，镜像栏被拉成全屏宽导致内容错位）；
// 2) 展开状态下滚动页面，镜像栏持续跟随真实菜单栏；
// 3) direction: up 时面板在菜单栏上方，锚定同样重合。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

Widget _panel(String tag) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final t in ['综合', '销量', '价格'])
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('$t-$tag'),
              ),
            ),
        ],
      ),
    );

/// [padding] 模拟页面内边距；[direction] 覆盖 down/up 两种展开方向。
Widget _host({
  double horizontalPadding = 16,
  WotDropMenuDirection direction = WotDropMenuDirection.down,
  bool closeOnClickOverlay = true,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 120), // 顶部留白，模拟页面滚动场景
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: WotDropMenu(
              direction: direction,
              closeOnClickOverlay: closeOnClickOverlay,
              menus: [
                WotDropMenuItem(
                  title: '综合排序',
                  panel: _panel('p1'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 600),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('展开后镜像栏与真实菜单栏矩形重合，面板在栏下方', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host());
    await tester.pump();

    await tester.tap(find.text('综合排序'));
    await tester.pumpAndSettle();

    final bars = find.text('综合排序');
    expect(bars, findsNWidgets(2), reason: '展开后应有真实栏标题 + 浮层镜像标题');

    final realRect = tester.getRect(bars.first);
    final mirrorRect = tester.getRect(bars.last);
    expect((mirrorRect.top - realRect.top).abs(), lessThan(0.5),
        reason: '镜像栏必须与真实菜单栏垂直重合');
    expect((mirrorRect.left - realRect.left).abs(), lessThan(0.5),
        reason: '镜像栏必须与真实菜单栏水平重合（regression: theater tight 约束吞宽度）');
    expect((mirrorRect.width - realRect.width).abs(), lessThan(0.5),
        reason: '镜像栏必须与真实菜单栏等宽');

    final firstOption = tester.getRect(find.text('综合-p1'));
    expect(firstOption.top, greaterThan(realRect.bottom),
        reason: '面板第一项必须在菜单栏下方');
    final secondOption = tester.getRect(find.text('销量-p1'));
    expect(firstOption.left, secondOption.left, reason: '面板选项左对齐');
  });

  testWidgets('direction: up 时镜像栏重合且面板在菜单栏上方', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(direction: WotDropMenuDirection.up));
    await tester.pump();

    await tester.tap(find.text('综合排序'));
    await tester.pumpAndSettle();

    final bars = find.text('综合排序');
    expect(bars, findsNWidgets(2));
    final realRect = tester.getRect(bars.first);
    final mirrorRect = tester.getRect(bars.last);
    expect((mirrorRect.top - realRect.top).abs(), lessThan(0.5),
        reason: 'up 方向镜像栏同样必须与真实菜单栏重合');
    expect((mirrorRect.left - realRect.left).abs(), lessThan(0.5));

    final firstOption = tester.getRect(find.text('综合-p1'));
    expect(firstOption.bottom, lessThanOrEqualTo(realRect.top),
        reason: 'up 方向面板必须在菜单栏上方');
  });

  testWidgets('无蒙层时展开状态下滚动列表，镜像栏持续跟随真实菜单栏', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(closeOnClickOverlay: false));
    await tester.pump();

    await tester.tap(find.text('综合排序'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -80));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    final bars = find.text('综合排序');
    expect(bars, findsNWidgets(2));
    final realRect = tester.getRect(bars.first);
    final mirrorRect = tester.getRect(bars.last);
    expect((mirrorRect.top - realRect.top).abs(), lessThan(0.5),
        reason: '滚动后镜像栏仍须与真实菜单栏垂直重合');
    expect((mirrorRect.left - realRect.left).abs(), lessThan(0.5),
        reason: '滚动后镜像栏仍须与真实菜单栏水平重合');
  });
}
