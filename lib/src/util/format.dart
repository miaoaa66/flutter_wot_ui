/// 纯 Dart 格式化工具（日期/数字/补零），对应数据展示类组件的常用需求。
///
/// 避免引入重型日期库；字符串解析/格式化用 [intl]（官方 Dart 团队）。
library;

import 'package:intl/intl.dart' show DateFormat, NumberFormat;

/// 将 [DateTime] 格式化为 wot 兼容的日期字符串。
/// 默认 `yyyy-MM-dd`；[pattern] 支持 DateFormat 占位，如 `yyyy/MM/dd HH:mm`。
String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
  return DateFormat(pattern).format(date);
}

/// 解析日期字符串为 [DateTime]，失败返回 null（兼容 yyyy-MM-dd / yyyy/MM/dd）。
DateTime? tryParseDate(String input) {
  final d = DateTime.tryParse(input);
  if (d != null) return d;
  // 兼容 '/' 分隔：常见场景 yyyy/MM/dd
  if (input.contains('/')) {
    return DateTime.tryParse(input.replaceAll('/', '-'));
  }
  return null;
}

/// 左侧补零到 [width] 位。
String pad2(num v, [int width = 2]) =>
    v.toInt().toString().padLeft(width, '0');

/// 时分秒补零，如 `12:05:09`。
String formatHms(Duration d) =>
    '${pad2(d.inHours)}:${pad2(d.inMinutes % 60)}:${pad2(d.inSeconds % 60)}';

/// 数字千分位格式化（可选小数位）。
String formatNumber(num value, {int? fractionDigits}) {
  if (fractionDigits == null) return NumberFormat().format(value);
  return NumberFormat('0.${'0' * fractionDigits}').format(value);
}

/// 单位换算展示：如字节数转 KB/MB/GB，用于上传/体积类展示。
String formatBytes(num bytes, {int fractionDigits = 1}) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var v = bytes.toDouble();
  var i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  final s = i == 0 ? v.toInt().toString() : v.toStringAsFixed(fractionDigits);
  return '$s ${units[i]}';
}