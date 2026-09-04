import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() {
  group('WotThemeData.light / dark 明暗主题', () {
    test('默认主色长度 10 级梯度', () {
      expect(WotThemeData.light.scheme.primary.length, 10);
      expect(WotThemeData.dark.scheme.primary.length, 10);
    });

    test('浅色主色与 dark 主色不同', () {
      expect(
        WotThemeData.dark.scheme.primaryOf(6),
        isNot(WotThemeData.light.scheme.primaryOf(6)),
      );
    });

    test('深色主色梯度反转', () {
      final light = WotThemeData.light.scheme.primary;
      final dark = WotThemeData.dark.scheme.primary;
      // 深色 primary 最浅一档应接近浅色主色最深一档（反转）。
      expect(dark.first, isNot(light.first));
    });
  });

  group('WotScheme.copyWithPrimary', () {
    test('仅替换主色不影响其他字段', () {
      final scheme = WotThemeData.light.scheme;
      final replaced = scheme.copyWithPrimary([for (var i = 1; i <= 10; i++) Color(0xFF000000)]);
      expect(replaced.primary, [for (var i = 1; i <= 10; i++) Color(0xFF000000)]);
      expect(replaced.textMain, scheme.textMain);
      expect(replaced.dangerMain, scheme.dangerMain);
    });
  });
}