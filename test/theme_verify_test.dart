import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() {
  test('浅色主题关键色与 wot light.scss 一致', () {
    final s = WotThemeData.light.scheme;
    expect(s.primaryOf(6), const Color(0xFF1C64FD)); // --wot-primary-6: blue6
    expect(s.dangerMain, const Color(0xFFF14646)); // --wot-danger-main: red6
    expect(s.successMain, const Color(0xFF12B886)); // --wot-success-main: green6
    expect(s.warningMain, const Color(0xFFF57F00)); // --wot-warning-main: orange6
    expect(s.textMain, const Color(0xFF1D1F29)); // --wot-text-main: coolgrey10
    expect(s.textSecondary, const Color(0xFF4E5369)); // coolgrey8
    expect(s.textAuxiliary, const Color(0xFF868A9C)); // coolgrey6
    expect(s.filledBottom, const Color(0xFFF7F8FA)); // --wot-filled-bottom: coolgrey1
    expect(s.filledContent, const Color(0xFFF2F3F5)); // coolgrey2
    expect(s.textWhite, const Color(0xFFFFFFFF));
  });

  test('深色主题关键色与 wot dark.scss 方向一致（主色反转、文字变浅、填充变深）', () {
    final s = WotThemeData.dark.scheme;
    expect(s.primaryOf(1), WotPalette.blue10); // dark primary 由深到浅
    expect(s.textMain, const Color(0xFFF7F8FA)); // coolgrey1 浅文字
    expect(s.filledBottom, const Color(0xFF1D1F29)); // coolgrey10 深底
  });

  test('copyWith 可一键换主色并逐项自定义其它色值', () {
    final s = WotThemeData.light.scheme;
    final rep = s.copyWith(
      primary: [for (var i = 1; i <= 10; i++) const Color(0xFF000000)],
      dangerMain: const Color(0xFFFF00FF),
      textMain: const Color(0xFF123456),
    );
    expect(rep.primaryOf(3), const Color(0xFF000000));
    expect(rep.dangerMain, const Color(0xFFFF00FF));
    expect(rep.textMain, const Color(0xFF123456));
    // 未覆盖字段保持不变
    expect(rep.successMain, s.successMain);
    expect(rep.warningMain, s.warningMain);
  });
}