import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() {
  testWidgets('水印绘制不越出容器边界', (tester) async {
    // 将水印放入一个 120 高的小容器，抓取其绘制层的裁剪是否生效（无 overflow 异常）。
    await tester.pumpWidget(WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 120,
            child: WotWatermark(
              content: 'Wot UI Flutter',
              fontSize: 14,
              child: SizedBox.expand(),
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull, reason: '水印不应触发溢出/布局异常');
  });

  testWidgets('水位线 CustomPaint 绘制范围被 clip 到容器内', (tester) async {
    await tester.pumpWidget(WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 100,
            height: 60,
            child: WotWatermark(content: '很长的水印文字内容让旋转后探出边界', rotate: -22),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull, reason: '长水印文字旋转后不应溢出/越界');
  });
}