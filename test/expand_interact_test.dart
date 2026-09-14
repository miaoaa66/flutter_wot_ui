import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() {
  const longText =
      '这是一段很长很长很长很长很长很长很长很长很长很长很长很长很长很长的内容，'
      '超过默认显示高度后会显示查看全部按钮，点击展开全部内容，再次点击收起。'
      '继续补充一些文字确保高度足够，超过五十个逻辑像素高度。'
      '床前明月光，疑是地上霜，举头望明月，低头思故乡。'
      '白日依山尽，黄河入海流，欲穷千里目，更上一层楼。'
      '红豆生南国，春来发几枝，愿君多采撷，此物最相思。'
      '锄禾日当午，汗滴禾下土，谁知盘中餐，粒粒皆辛苦。';

  Widget build({bool collapsible = true, Widget? child}) {
    return WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WotExpand(
              height: 50,
              collapsible: collapsible,
              child: child ?? const Text(longText),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('内容超高时显示查看全部，点击展开再点收起', (tester) async {
    await tester.pumpWidget(build());
    // 等待首帧后的测量完成（postFrameCallback + setState）
    await tester.pumpAndSettle();
    expect(find.text('查看全部'), findsOneWidget);

    final before = tester.getSize(find.byType(WotExpand));
    await tester.tap(find.text('查看全部'));
    await tester.pumpAndSettle();
    expect(find.text('收起'), findsOneWidget);
    final after = tester.getSize(find.byType(WotExpand));
    expect(after.height, greaterThan(before.height));

    await tester.tap(find.text('收起'));
    await tester.pumpAndSettle();
    expect(find.text('查看全部'), findsOneWidget);
    expect(find.text('收起'), findsNothing);
  });

  testWidgets('collapsible=false 展开后无收起按钮', (tester) async {
    await tester.pumpWidget(build(collapsible: false));
    await tester.pumpAndSettle();
    expect(find.text('查看全部'), findsOneWidget);

    await tester.tap(find.text('查看全部'));
    await tester.pumpAndSettle();
    expect(find.text('收起'), findsNothing);
  });

  testWidgets('内容不足限高时不显示按钮', (tester) async {
    await tester.pumpWidget(build(child: const Text('短内容')));
    await tester.pumpAndSettle();
    expect(find.text('查看全部'), findsNothing);
    expect(find.text('收起'), findsNothing);
  });

  testWidgets('展开后完整文案不被底部按钮遮挡', (tester) async {
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    await tester.tap(find.text('查看全部'));
    await tester.pumpAndSettle();

    // 可视内容底部不高于「收起」按钮顶部：按钮不再悬浮遮挡内容
    final textRect = tester.getRect(find.text(longText).first);
    final collapseRect = tester.getRect(find.text('收起'));
    expect(textRect.bottom, lessThanOrEqualTo(collapseRect.top + 0.01));

    // 展开后组件高度不小于内容自然高度（内容完整布局）
    final expandedSize = tester.getSize(find.byType(WotExpand));
    expect(expandedSize.height, greaterThanOrEqualTo(textRect.height));
  });
  testWidgets('ListView 中多个 WotExpand 展开后仍可正常滚动到底并回滚', (tester) async {
    await tester.pumpWidget(
      WotConfigProvider(
        wotTheme: WotThemeData.light,
        child: MaterialApp(
          home: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var i = 0; i < 6; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('label $i', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
                          child: WotExpand(child: const Text(longText)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
    final position = scrollable.position;
    expect(position.maxScrollExtent, greaterThan(0));

    // 逐个展开所有 WotExpand（先滚动到可视区域再点击）
    while (find.text('查看全部').evaluate().isNotEmpty) {
      final btn = find.text('查看全部').first;
      await tester.ensureVisible(btn);
      await tester.pumpAndSettle();
      await tester.tap(btn);
      await tester.pumpAndSettle();
    }
    expect(find.text('收起'), findsWidgets);

    // 滚动到底部
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    final bottomPixels = position.pixels;
    expect(bottomPixels, greaterThan(0));

    // 向上拖动应能回滚（没有被额外内容拽住）
    await tester.drag(find.byType(ListView), const Offset(0, 600));
    await tester.pumpAndSettle();
    expect(position.pixels, lessThan(bottomPixels));
  });
  testWidgets('首帧测量前不显示完整内容高度，避免页面跳动', (tester) async {
    await tester.pumpWidget(build());
    // pumpWidget 完成首帧布局时测量尚未生效（heightFactor=0 占位），高度应为 0 而非内容完整高度
    final firstHeight = tester.getSize(find.byType(WotExpand)).height;
    expect(firstHeight, lessThanOrEqualTo(1));

    // 测量完成并重建后：组件高度收敛为限高（约 50），而非内容完整高度
    await tester.pumpAndSettle();
    final settledHeight = tester.getSize(find.byType(WotExpand)).height;
    expect(settledHeight, lessThanOrEqualTo(51));
    expect(settledHeight, greaterThan(0));
  });}