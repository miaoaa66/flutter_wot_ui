/// 公共 props 与合并工具，对应 wot `common/props.ts` 与 `common/util.ts`。
///
/// 说明：Vue 环境区分 `undefined` 与 `null`；Dart 仅有一个空值 [Null]。
/// 鉴于 wot 组件 props 的可选语义，本项目以 `null` 统一视为"未提供"，
/// 与 wot `omitBy(input, isUndefined)` 的剔除语义对齐。
library;

/// 值是否非空（null 视为空）。
bool isDef<T>(T? v) => v != null;

/// 值是否为空（null 视为空）。
bool isNvl<T>(T? v) => v == null;

/// 剔除 [map] 中满足 [predicate] 的键，返回新 Map。
Map<K, V> omitBy<K, V>(Map<K, V> map, bool Function(V value) predicate) {
  final result = <K, V>{};
  for (final e in map.entries) {
    if (!predicate(e.value)) result[e.key] = e.value;
  }
  return result;
}

/// 键值桶合并，对应 wot `mergeBucket`：
/// `base` + `override`（忽略 `override` 中为 null 的键），无 override 时返回 `base`。
Map<K, V> mergeBucket<K, V>(Map<K, V> base, Map<K, V>? override) {
  if (override == null || override.isEmpty) return base;
  final result = <K, V>{...base};
  for (final e in override.entries) {
    if (e.value != null) result[e.key] = e.value;
  }
  return result;
}