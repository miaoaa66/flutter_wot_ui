import 'package:flutter_wot_ui/src/theme/wot_theme_data.dart';
import 'package:flutter_wot_ui/src/util/props.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('props.dart', () {
    test('isDef/isNvl', () {
      expect(isDef(1), isTrue);
      expect(isDef(null), isFalse);
      expect(isNvl(null), isTrue);
      expect(isNvl(''), isFalse);
    });

    test('omitBy 剔除满足条件的键', () {
      final src = <String, int?>{'a': 1, 'b': null, 'c': 3};
      final result = omitBy(src, (v) => v == null);
      expect(result.keys, ['a', 'c']);
      expect(src, contains('b')); // 原 map 不被改动
    });

    test('mergeBucket 忽略 null 值键且不污染 base', () {
      final base = <String, String>{'size': 'medium', 'type': 'primary'};
      final override = <String, String>{'type': 'danger', 'round': 'true'};
      final merged = mergeBucket(base, override);
      expect(merged['size'], 'medium');
      expect(merged['type'], 'danger');
      expect(merged['round'], 'true');
      expect(base['type'], 'primary'); // base 不变
    });

    test('mergeBucket 空 override 返回 base', () {
      final base = <String, String>{'a': '1'};
      expect(mergeBucket(base, null), same(base));
      expect(mergeBucket(base, const {}), same(base));
    });
  });

  group('component defaults 级联合并', () {
    test('WotButtonDefaults.merge 非空字段覆盖父级', () {
      final parent = const WotButtonDefaults(size: 'medium', type: 'primary', round: false);
      final child = const WotButtonDefaults(type: 'danger');
      final merged = parent.merge(child);
      expect(merged.size, 'medium');
      expect(merged.type, 'danger');
      expect(merged.round, isFalse);
    });

    test('WotButtonDefaults.merge null override 返回自身', () {
      const parent = WotButtonDefaults(size: 'large');
      expect(identical(parent.merge(null), parent), isTrue);
    });

    test('WotTagDefaults.merge', () {
      const parent = WotTagDefaults(size: 'small', variant: 'light');
      const child = WotTagDefaults(round: true);
      final merged = parent.merge(child);
      expect(merged.size, 'small');
      expect(merged.variant, 'light');
      expect(merged.round, isTrue);
    });
  });
}