/// 手势辅助，对应 wot `useTouch` 组合式的纯数学部分（滑移量/方向/钳制）。
library;

import 'dart:math' as math;
import 'dart:ui' show Offset, Size;

/// 触控/手势状态数据。
class TouchData {
  Offset start = Offset.zero;
  Offset delta = Offset.zero;
  bool moved = false;

  /// 单轴滚动钳制：把 [delta] 的纵轴限制到 [max][max] 范围内（惯性/边界吸附用）。
  void clampVertical(double min, double max) {
    delta = Offset(delta.dx, delta.dy.clamp(min, max).toDouble());
  }
}

/// 计算自 [start] 到当前点的位移增量。
Offset touchDelta(Offset start, Offset current) => current - start;

/// 计算单指拖动相对 [start] 的偏移；超过 [slop] 视为"已移动"。
TouchData resolveGesture({
  required Offset start,
  required Offset current,
  double slop = 8.0,
}) {
  final delta = current - start;
  return TouchData()
    ..start = start
    ..delta = delta
    ..moved = delta.distance > slop;
}

/// 纵向滑移方向：返回 `-1`(上滑)/`0`(未定)/`1`(下滑)。
int verticalDirection(double dy, {double threshold = 0}) {
  if (dy.abs() <= threshold) return 0;
  return dy > 0 ? 1 : -1;
}

/// 将 [value] 钳制到圆环 [0, max) 内（进度/循环使用）。
double wrap(double value, double max) {
  final m = max <= 0 ? 1.0 : max;
  final v = value % m;
  return v < 0 ? v + m : v;
}

/// 依据手势位移计算横向滑屏当前 index（[itemExtent] 为单页/单项宽度）。
int pageFromOffset(double translation, double itemExtent, int length) {
  if (itemExtent <= 0 || length <= 1) return 0;
  final raw = (-translation / itemExtent).round();
  return raw.clamp(0, length - 1);
}

/// 是否在 [bounds] 内包含 [offset]。
bool containsOffset(Size bounds, Offset offset) =>
    offset.dx >= 0 &&
    offset.dy >= 0 &&
    offset.dx <= bounds.width &&
    offset.dy <= bounds.height;

/// 求两点间角度（弧度），用于拨盘/滑杆等。
double angleOf(Offset center, Offset point) =>
    math.atan2(point.dy - center.dy, point.dx - center.dx);