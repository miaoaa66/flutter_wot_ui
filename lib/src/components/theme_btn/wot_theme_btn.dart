import 'package:flutter/material.dart';

/// 明暗主题切换按钮（复刻 `明暗主体切换按钮/index.html`）。
///
/// 设计基准尺寸为 314 x 120（宽 x 高），通过 [size] 参数等比缩放。
///
/// **颜色约定**：本组件所有颜色均使用字面值硬编码（蓝天数 / 星空数 / 月亮灰），
/// 不读取 `context.wotScheme`、也不依赖任何主题，`因此不受组件库当前主题（浅色/深色）控制`，
/// 无论外层如何切换主题，按钮配色始终保持固定。
///
/// 可通过 [shadow] 在组件圆角边缘外加外阴影（[WotThemeBtnShadow.dark] 用于浅色背景、
/// [WotThemeBtnShadow.light] 用于深色背景），默认 [WotThemeBtnShadow.none] 不显示。
///
/// 用法：
/// ```dart
/// WotThemeBtn(
///   value: isDark,                 // true = 夜间（右侧月亮）
///   onChanged: (v) => setState(() => isDark = v),
///   size: 240,                     // 可选：组件宽度，高度按比例自适应
/// )
/// ```
/// 边缘外阴影类型。
///
/// - [none]：不显示（默认）。
/// - [dark]：深色阴影，适用于浅色页面背景。
/// - [light]：浅色阴影，适用于深色页面背景。
enum WotThemeBtnShadow {
  none,
  dark,
  light,
}

class WotThemeBtn extends StatelessWidget {
  const WotThemeBtn({
    super.key,
    this.value = false,
    this.onChanged,
    this.size = 240,
    this.disabled = false,
    this.duration,
    this.shadow = WotThemeBtnShadow.none,
  });

  /// 当前是否为夜间（暗黑）模式，true 时圆形滑到右侧并变为月亮。
  final bool value;

  /// 状态变化回调，参数为最新状态（true = 夜间）。
  final ValueChanged<bool>? onChanged;

  /// 组件宽度（逻辑像素），高度按 120/314 比例自适应。默认 240。
  final double size;

  /// 是否禁用，默认 false。禁用时不可点击且整体半透明。
  final bool disabled;

  /// 动画时长，缺省轨道/光晕 500ms、圆形滑动 250ms。
  final Duration? duration;

  /// 边缘外阴影类型，默认 [WotThemeBtnShadow.none]（不显示）。
  /// [dark] 用于浅色背景，[light] 用于深色背景。
  final WotThemeBtnShadow shadow;

  @override
  Widget build(BuildContext context) {
    final night = value;
    final s = size / 314; // 缩放系数
    final w = size;
    final h = size * 120 / 314;
    final dur = duration ?? const Duration(milliseconds: 500);

    // 轨道：白天蓝、夜间黑，圆角胶囊
    final track = Positioned.fill(
      child: AnimatedContainer(
        duration: dur,
        decoration: BoxDecoration(
          color: night ? Colors.black : const Color(0xFF0068DE),
          borderRadius: BorderRadius.circular(100 * s),
        ),
      ),
    );

    // 轨道内阴影（顶部压暗，模拟 inset box-shadow）
    final insetShadow = Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100 * s),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.black.withValues(alpha: 0.25), Colors.transparent],
          ),
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : () => onChanged?.call(!night),
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100 * s),
            boxShadow: _edgeShadow(s),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100 * s),
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  track,
                  insetShadow,
                  // 绘制顺序须与原 HTML 一致：light3 → light2 → light1（最浅的 light1 最后绘制、叠在最上层）
                  _buildLight(_kLights[2], night, s, dur),
                  _buildLight(_kLights[1], night, s, dur),
                  _buildLight(_kLights[0], night, s, dur),
                  _buildClouds(back: true, s: s),
                  _buildClouds(back: false, s: s),
                  _buildStars(night, s),
                  _buildCircle(night, s),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 边缘外阴影（按 [shadow] 选择颜色）：dark 用黑影（浅背景）、light 用白影（深背景）。
  List<BoxShadow>? _edgeShadow(double s) {
    switch (shadow) {
      case WotThemeBtnShadow.none:
        return null;
      case WotThemeBtnShadow.dark:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10 * s,
            offset: Offset(0, 4 * s),
          ),
        ];
      case WotThemeBtnShadow.light:
        return [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 10 * s,
            offset: Offset(0, 4 * s),
          ),
        ];
    }
  }

  /// 背景三团光晕（白天蓝、夜间深灰），夜间向右滑动。
  Widget _buildLight(_LightData l, bool night, double s, Duration dur) {
    final left = (night ? l.nightLeft : l.dayLeft) * s;
    final top = (night ? l.nightTop : l.dayTop) * s;
    final color = night ? l.night : l.day;
    return AnimatedPositioned(
      duration: dur,
      left: left,
      top: top,
      width: 216 * s,
      height: 216 * s,
      child: AnimatedContainer(
        duration: dur,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  /// 云层：前景纯白、背景半透明白并整体偏移；白天夜间一致。
  Widget _buildClouds({required bool back, required double s}) {
    final color = back ? Colors.white.withValues(alpha: 0.5) : Colors.white;
    final offset = back ? Offset(-10 * s, -15 * s) : Offset.zero;
    return Transform.translate(
      offset: offset,
      child: Stack(
        children: [
          for (final c in _kClouds)
            Positioned(
              left: c.left * s,
              top: c.top * s,
              child: Container(
                width: c.w * s,
                height: c.h * s,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }

  /// 星空：仅夜间显示，白色四角星（sparkle）。
  Widget _buildStars(bool night, double s) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: night ? 1 : 0,
      child: Stack(
        children: [
          for (final st in _kStars)
            Positioned(
              left: st.left * s,
              top: st.top * s,
              width: 20 * s,
              height: 20 * s,
              child: CustomPaint(painter: _StarPainter(Colors.white, s)),
            ),
        ],
      ),
    );
  }

  /// 可滑动圆形：白天为黄色太阳，夜间滑到右侧并变为灰色月亮（带月坑）。
  Widget _buildCircle(bool night, double s) {
    final left = (night ? 210.0 : 15.0) * s;
    final top = 15.0 * s;
    final color = night ? const Color(0xFFCCCCCC) : const Color(0xFFFFC300);
    const dur = Duration(milliseconds: 250);
    return AnimatedPositioned(
      duration: dur,
      left: left,
      top: top,
      width: 90 * s,
      height: 90 * s,
      child: AnimatedContainer(
        duration: dur,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4 * s,
              offset: Offset(0, 2 * s),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 高光：复刻 CSS 「inset 5px 5px 8px 0 rgba(255,255,255,1)」
            // 顶部偏左的满白内阴影（玻璃球质感），不是整片洗白，而是贴着边缘的局部高光。
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.72, -0.72),
                  radius: 1.1,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: 0.55),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            // 月坑：仅夜间显示
            AnimatedOpacity(
              duration: dur,
              opacity: night ? 1 : 0,
              child: Stack(
                children: [
                  _crater(55, 56, 16, s),
                  _crater(15, 39, 25, s),
                  _crater(51, 21, 12, s),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crater(double l, double t, double d, double s) => Positioned(
        left: l * s,
        top: t * s,
        child: Container(
          width: d * s,
          height: d * s,
          decoration: BoxDecoration(
            color: const Color(0xFFA8A8A8),
            shape: BoxShape.circle,
            // 月坑：复刻 CSS 「inset 0 0 2px rgba(0,0,0,0.25)」的凹陷暗边
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.25),
              width: 1 * s,
            ),
          ),
        ),
      );
}

class _LightData {
  const _LightData({
    required this.day,
    required this.night,
    required this.dayLeft,
    required this.dayTop,
    required this.nightLeft,
    required this.nightTop,
  });
  final Color day;
  final Color night;
  final double dayLeft;
  final double dayTop;
  final double nightLeft;
  final double nightTop;
}

class _CloudData {
  const _CloudData(this.left, this.top, this.w, this.h);
  final double left;
  final double top;
  final double w;
  final double h;
}

class _StarData {
  const _StarData(this.left, this.top);
  final double left;
  final double top;
}

// 三团光晕（白天蓝 / 夜间深灰，夜间整体右移）
const List<_LightData> _kLights = [
  _LightData(
    day: Color(0xFF3091FF),
    night: Color(0xFF555555),
    dayLeft: -49,
    dayTop: -48,
    nightLeft: 146,
    nightTop: -48,
  ),
  _LightData(
    day: Color(0xFF1D82F5),
    night: Color(0xFF333333),
    dayLeft: -6,
    dayTop: -50,
    nightLeft: 109,
    nightTop: -50,
  ),
  _LightData(
    day: Color(0xFF1074E6),
    night: Color(0xFF222222),
    dayLeft: 38,
    dayTop: -44,
    nightLeft: 68,
    nightTop: -44,
  ),
];

// 云朵（7 个圆堆叠）
const List<_CloudData> _kClouds = [
  _CloudData(13, 95, 65, 65),
  _CloudData(71, 95, 51, 51),
  _CloudData(115, 73, 76, 76),
  _CloudData(174, 90, 76, 76),
  _CloudData(201, 70, 72, 68),
  _CloudData(252, 36, 136, 136),
  _CloudData(278, 0, 136, 136),
];

// 星星位置（仅夜间显示）
const List<_StarData> _kStars = [
  _StarData(50, 50),
  _StarData(30, 20),
  _StarData(120, 20),
  _StarData(150, -15),
  _StarData(135, -55),
];

/// 四角星（sparkle），复刻 CSS `clip-path: path(...)`，坐标按 [s] 缩放。
class _StarPainter extends CustomPainter {
  _StarPainter(this.color, this.s);
  final Color color;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path();
    p.moveTo(5 * s, 0);
    p.cubicTo(5 * s, 5 * s, 4 * s, 10 * s, 0, 10 * s);
    p.cubicTo(4 * s, 10 * s, 5 * s, 15 * s, 5 * s, 20 * s);
    p.cubicTo(5 * s, 15 * s, 6 * s, 10 * s, 10 * s, 10 * s);
    p.cubicTo(6 * s, 10 * s, 5 * s, 5 * s, 5 * s, 0);
    p.close();
    canvas.drawPath(p, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) =>
      old.color != color || old.s != s;
}
