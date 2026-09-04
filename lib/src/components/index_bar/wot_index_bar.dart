import 'package:flutter/material.dart';

import '../../theme/wot_scheme.dart';
import '../../theme/wot_theme.dart';

/// 默认字母索引列表：A..Z。
///
/// 可在 [WotIndexBar.indexList] 中整体替换为自定义的字母/字符数组。
const List<String> kWotIndexBarDefaultList = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
];

/// 索引锚点分组标题，对应 wot `wd-index-anchor`。
///
/// 应作为滚动视口内容的一部分，与其所属分组一起放入用户自己的
/// `ListView` / `SingleChildScrollView` 等可滚动列表内，通常配合
/// [WotIndexBar] 使用（见该类中「索引条 + 锚点联动」的用法说明）。
///
/// 当它处于 [WotIndexBar] 的作用域内，且当前激活索引与其 [index] 一致时，
/// 会以激活态高亮展示标题，实现右侧索引条与左侧锚点的「联动」高亮。
class WotIndexBarAnchor extends StatelessWidget {
  /// 创建一个锚点分组标题组件。
  const WotIndexBarAnchor({
    super.key,
    required this.index,
    this.title,
    this.child,
  });

  /// 所属索引字符（如 `'A'`），须与 [WotIndexBar.indexList] 中的某一项一致，
  /// 用于和右侧索引条的激活态做匹配联动。
  final String index;

  /// 分组标题文本。为空时不显示标题文字，但保留左侧索引标识条。
  final String? title;

  /// 该分组的内容（紧随标题下方的列表项等）。为空时仅显示标题头部。
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scope = _WotIndexBarScope.maybeOf(context);
    final scheme = context.wotScheme;
    final active = scope?.activeIndex == index;
    final activeColor = scope?.activeColor ?? scheme.primaryOf(6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          color: active ? scheme.filledStrong : scheme.filledContent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // 左侧索引标识条。
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: active ? activeColor : scheme.borderMain,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title ?? index,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: active ? activeColor : scheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ?child,
      ],
    );
  }
}

/// 索引栏（右侧字母条），对应 wot `wd-index-bar` 的侧边索引栏。
///
/// 用于列表的索引分类显示和快速定位。组件为**纯自绘**实现，不依赖第三方包，
/// 颜色统一取自 [WotScheme]（主色/文字/背景等语义令牌）。
///
/// ## 索引条 + 锚点联动
///
/// 该组件不负责滚动视口本身，用户需自行把内容放入滚动视口，再叠加本组件，
/// 典型用法如下（右侧索引条会与 [WotIndexBarAnchor] 做激活高亮联动）：
///
/// ```dart
/// final map = <String, Offset>{};
/// // 分组：{'A': [cityList], 'B': [cityList], ...}
/// final Map<String, List<String>> groups = {...};
///
/// Stack(
///   alignment: Alignment.centerRight,
///   children: [
///     // 用户自己的滚动列表，内含锚点分组。
///     ListView(
///       controller: _controller,
///       children: [
///         for (final entry in groups.entries)
///           WotIndexBarAnchor(
///             index: entry.key,
///             title: entry.key,
///             child: Column(
///               children: [
///                 for (final city in entry.value)
///                   WotCell(
///                     title: city,
///                     clickable: true,
///                     onTap: () {},
///                   ),
///               ],
///             ),
///           ),
///       ],
///     ),
///     // 右侧索引条，放在 Stack 顶层。
///     WotIndexBar(
///       activeColor: Color(0xFF4D80F0),
///       onSelect: (index) {
///         // 此处由用户自行发明：根据 index 查找到对应锚点的位置并滚动。
///         // 例如为每个 WotIndexBarAnchor 挂 GlobalKey 后，
///         // 通过 key.currentContext.findRenderObject() 获取偏移：
///         // _controller.animateTo(offset.dy, ...);
///       },
///     ),
///   ],
/// )
/// ```
///
/// > 说明：本例未实现 wot 中的「跟随手指的居中提示气泡」（`current-index`），
/// > 该效果需要 overlay/浮层介入，本实现刻意保持纯自绘，如需可自行扩展。
class WotIndexBar extends StatefulWidget {
  /// 创建一个索引栏组件。
  const WotIndexBar({
    super.key,
    this.indexList = kWotIndexBarDefaultList,
    this.activeColor,
    this.itemSize = 20,
    this.onSelect,
    this.child,
  });

  /// 索引字符数组，决定右侧字母条显示哪些字母，默认 [kWotIndexBarDefaultList]
  /// （A..Z）。可按需替换为自定义字符列表。
  final List<String> indexList;

  /// 激活索引项的强调色（高亮色/文字色），默认使用主题主色 `primaryOf(6)`。
  final Color? activeColor;

  /// 单个索引项（字母格）的宽高，单位逻辑像素，默认 20。
  final double itemSize;

  /// 选中索引项回调，参数为选中的字母字符串（来自 [indexList]）。
  final ValueChanged<String>? onSelect;

  /// 可选的滚动视口内容（通常为含 [WotIndexBarAnchor] 的列表）。
  ///
  /// 传入后，[WotIndexBar] 会用 `Stack` 包裹该内容并提供激活索引作用域，
  /// 使内部的 [WotIndexBarAnchor] 能读取当前激活索引做「联动」高亮。
  final Widget? child;

  @override
  State<WotIndexBar> createState() => _WotIndexBarState();
}

class _WotIndexBarState extends State<WotIndexBar> {
  /// 当前激活的索引字符。拖拽/点击字母时更新，并同步作用域给锚点做联动。
  String? _active;

  /// 鼠标悬停的索引项下标（仅桌面端 hover 使用），用于展示悬停背景。
  int? _hoverIndex;

  /// 字母条渲染盒，用于把屏幕坐标转换到本地以计算命中的字母。
  final GlobalKey _barKey = GlobalKey();

  /// 生效的索引列表（过滤空串后的只读视图）。
  List<String> get _indexList =>
      widget.indexList.where((e) => e.isNotEmpty).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final activeColor = widget.activeColor ?? scheme.primaryOf(6);
    final letters = _indexList;

    final bar = MouseRegion(
      onHover: (event) {
        final idx = (event.localPosition.dy / widget.itemSize).floor();
        if (idx >= 0 && idx < letters.length) {
          if (_hoverIndex != idx) setState(() => _hoverIndex = idx);
        } else if (_hoverIndex != null) {
          setState(() => _hoverIndex = null);
        }
      },
      onExit: (_) {
        if (_hoverIndex != null) setState(() => _hoverIndex = null);
      },
      child: GestureDetector(
        key: _barKey,
        behavior: HitTestBehavior.opaque,
        // 点击即选中。
        onTapDown: (d) => _selectFromGlobal(d.globalPosition),
        // 支持手指/鼠标拖拽连续高亮并回调。
        onVerticalDragStart: (d) => _selectFromGlobal(d.globalPosition),
        onVerticalDragUpdate: (d) => _selectFromGlobal(d.globalPosition),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: scheme.filledContent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < letters.length; i++)
                _buildIndexItem(letters[i], i, activeColor, scheme),
            ],
          ),
        ),
      ),
    );

    final content = Stack(
      alignment: Alignment.centerRight,
      textDirection: TextDirection.ltr,
      children: [
        if (widget.child != null)
          Positioned.fill(
            child: widget.child!,
          ),
        Align(alignment: Alignment.centerRight, child: bar),
      ],
    );

    return _WotIndexBarScope(
      activeIndex: _active,
      activeColor: activeColor,
      child: content,
    );
  }

  /// 构建单个索引字母格。
  Widget _buildIndexItem(
    String letter,
    int index,
    Color activeColor,
    WotScheme scheme,
  ) {
    final active = letter == _active;
    final hovered = index == _hoverIndex;
    return Container(
      width: widget.itemSize,
      height: widget.itemSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active
            ? activeColor
            : (hovered ? scheme.feedbackHover : Colors.transparent),
        borderRadius: BorderRadius.circular(widget.itemSize / 2),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: widget.itemSize * 0.7,
          fontWeight: FontWeight.w500,
          color: active ? scheme.textWhite : scheme.textAuxiliary,
        ),
      ),
    );
  }

  /// 根据屏幕坐标命中字母索引并更新激活态。
  void _selectFromGlobal(Offset global) {
    final box = _barKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(global);
    final idx = (local.dy / widget.itemSize).floor();
    if (idx < 0 || idx >= _indexList.length) return;
    final letter = _indexList[idx];
    if (letter == _active) return;
    setState(() => _active = letter);
    widget.onSelect?.call(letter);
  }
}

/// [WotIndexBar] 向内部 [WotIndexBarAnchor] 传递激活态的继承作用域数据。
class _WotIndexBarScope extends InheritedWidget {
  const _WotIndexBarScope({
    required this.activeIndex,
    required this.activeColor,
    required super.child,
  });

  /// 当前激活索引字符。
  final String? activeIndex;

  /// 激活强调色（已由主色解析），供锚点复用保持视觉一致。
  final Color activeColor;

  /// 读取当前索引栏作用域，无父级时返回 null。
  static _WotIndexBarScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_WotIndexBarScope>();
  }

  @override
  bool updateShouldNotify(_WotIndexBarScope oldWidget) =>
      activeIndex != oldWidget.activeIndex ||
      activeColor != oldWidget.activeColor;
}