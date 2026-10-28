import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_tour_page.dart';

void main() {
  testWidgets('触发 WotTour 后气泡可交互、可退出', (tester) async {
    await tester.pumpWidget(WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: const MaterialApp(home: WotTourPage(), debugShowCheckedModeBanner: false),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(find.text('开始引导'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('开始引导'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final ex = tester.takeException();
    if (ex != null) fail('触发引导异常: $ex');

    // 气泡必须出现（否则只剩灰蒙层无法操作）。
    final hasNext = find.text('下一步').evaluate().isNotEmpty;
    final hasSkip = find.text('跳过').evaluate().isNotEmpty;
    debugPrint('气泡按钮：下一步=$hasNext 跳过=$hasSkip');
    expect(hasNext || hasSkip, isTrue, reason: '引导应有可交互按钮，否则用户无法退出');

    // 点击跳过退出。
    if (hasSkip) {
      await tester.tap(find.text('跳过'));
    } else {
      await tester.tap(find.text('下一步'));
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('气泡按钮行窄 maxWidth + 长文案不溢出（回归：Row 溢出 1.8px）', (tester) async {
    late BuildContext pageContext;
    await tester.pumpWidget(WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: MaterialApp(
        home: Builder(
          builder: (ctx) {
            pageContext = ctx;
            return const SizedBox.shrink();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    ));

    // 行宽 = 240 - 24(卡片左右 padding) = 216。测试字体下各字符宽度 = 字号：
    // 旧实现按钮行总宽 = 跳过(94) + 上一步(55) + 间距(8) + 完成(84) = 241 > 216 必溢出；
    // 新实现仅“跳过”为 Expanded（94→69 省略），其余固定宽 147 ≤ 216 不溢出。
    WotTour.show(
      pageContext,
      steps: const [
        WotTourStep(title: '第一步', description: '说明'),
        WotTourStep(title: '第二步', description: '说明'),
      ],
      maxWidth: 240,
      skipButtonText: '跳过引导流程',
      prevButtonText: '上一步',
      finishButtonText: '完成引导',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull, reason: '第一步（无上一步）按钮行不应溢出');

    // 进入最后一步：跳过 + 上一步 + 完成三按钮同行，最易触发溢出。
    await tester.tap(find.text('下一步'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('完成引导'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: '最后一步按钮行不应溢出');
  });
}