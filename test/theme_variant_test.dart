import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() {
  group('WotThemeData.ofVariant 多主题变体', () {
    test('默认主色长度 10 级梯度', () {
      final t = WotThemeData.ofVariant(WotThemeVariant.shadcn);
      expect(t.scheme.primary.length, 10);
    });

    test('不同变体主色不同', () {
      final vant = WotThemeData.ofVariant(WotThemeVariant.vant);
      final tdesign = WotThemeData.ofVariant(WotThemeVariant.tdesign);
      expect(vant.scheme.primaryOf(6), isNot(tdesign.scheme.primaryOf(6)));
      expect(vant.scheme.primaryOf(6), isNot(WotThemeData.light.scheme.primaryOf(6)));
    });

    test('保留危险/成功/警告等语义令牌', () {
      final t = WotThemeData.ofVariant(WotThemeVariant.nutui);
      expect(t.scheme.dangerMain, WotThemeData.light.scheme.dangerMain);
      expect(t.scheme.successMain, WotThemeData.light.scheme.successMain);
      expect(t.scheme.textMain, WotThemeData.light.scheme.textMain);
    });

    test('深色主色梯度反转', () {
      final light = WotThemeData.ofVariant(WotThemeVariant.vant);
      final dark = WotThemeData.ofVariant(WotThemeVariant.vant, dark: true);
      // 深色 primary 最浅一档应接近浅色主色中点。
      expect(dark.scheme.primaryOf(1), isNot(light.scheme.primaryOf(1)));
    });

    test('feedbackAccent 随主色更新', () {
      final t = WotThemeData.ofVariant(WotThemeVariant.illustration);
      expect(t.scheme.feedbackAccent, isNot(WotThemeData.light.scheme.feedbackAccent));
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