// themeVars（WotScheme.applyVars）单元 + 级联测试：
// 锁定「覆盖生效 / 未识别 key 忽略 / 空表原样 / 父子级联合并子级优先」四条不变式。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() {
  group('WotScheme.applyVars', () {
    test('覆盖语义令牌且不影响其他字段', () {
      final base = WotThemeData.light.scheme;
      final s = base.applyVars({
        '--wot-text-main': const Color(0xFF123456),
      });
      expect(s.textMain, const Color(0xFF123456));
      expect(s.dangerMain, base.dangerMain);
      expect(s.borderLight, base.borderLight);
    });

    test('未识别 key 静默忽略', () {
      final base = WotThemeData.light.scheme;
      final s = base.applyVars({
        '--wot-unknown-key': const Color(0xFF000000),
      });
      expect(s.textMain, base.textMain);
    });

    test('空 map 原样返回（identical）', () {
      final base = WotThemeData.light.scheme;
      expect(identical(base.applyVars(const {}), base), isTrue);
    });

    test('多 key 同时覆盖', () {
      final s = WotThemeData.light.scheme.applyVars({
        '--wot-danger-main': const Color(0xFF000001),
        '--wot-border-light': const Color(0xFF000002),
        '--wot-opac-main-cover': const Color(0xFF000003),
      });
      expect(s.dangerMain, const Color(0xFF000001));
      expect(s.borderLight, const Color(0xFF000002));
      expect(s.opacMainCover, const Color(0xFF000003));
    });
  });

  group('WotConfigProvider.themeVars 级联', () {
    testWidgets('父级 + 子级合并，子级优先，未覆盖字段沿用父级', (tester) async {
      WotScheme? outerScheme;
      WotScheme? innerScheme;
      await tester.pumpWidget(WotConfigProvider(
        themeVars: const {
          '--wot-text-main': Color(0xFFAAAAAA),
          '--wot-danger-main': Color(0xFFBBBBBB),
        },
        child: Builder(builder: (context) {
          outerScheme = context.wotScheme;
          return WotConfigProvider(
            themeVars: const {
              '--wot-text-main': Color(0xFFCCCCCC),
            },
            child: Builder(builder: (context) {
              innerScheme = context.wotScheme;
              return const SizedBox();
            }),
          );
        }),
      ));
      // 外层：textMain 被 A 覆盖，danger 被 B 覆盖。
      expect(outerScheme!.textMain, const Color(0xFFAAAAAA));
      expect(outerScheme!.dangerMain, const Color(0xFFBBBBBB));
      // 内层：textMain 被子级 C 覆盖（子级优先），danger 沿用父级 B。
      expect(innerScheme!.textMain, const Color(0xFFCCCCCC));
      expect(innerScheme!.dangerMain, const Color(0xFFBBBBBB));
    });
  });
}
