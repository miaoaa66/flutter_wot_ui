/// wot-ui 数值/布尔工具函数，对应 `common/util.ts`。
///
/// 谓词（isDef/omitBy）与键值合并（mergeBucket）见 `props.dart`。
library;

/// 布尔归一化：兼容数字/字符串/空值。
bool toBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final s = value.toString().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}

/// 数字字符串解析，失败回退 [fallback]。
double toDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

/// 整数解析，失败回退 [fallback]。
int toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString()) ?? fallback;
}

/// 归一化数值（限制在 [min]~[max] 内）。
double clampDouble(double value, {double min = double.negativeInfinity, double max = double.infinity}) {
  return value.clamp(min, max).toDouble();
}