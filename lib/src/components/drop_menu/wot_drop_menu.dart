import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 下拉菜单，对应 wot `wd-drop-menu`。
///
/// 顶部菜单项，点击下弹出对应的 [WotDropMenu] 高度内容面板；支持遮罩关闭。
class WotDropMenu extends StatefulWidget {
  const WotDropMenu({
    super.key,
    this.menuBarHeight = 40,
    this.activeColor,
    this.duration = const Duration(milliseconds: 200),
    this.direction = 'down',
    this.closeOnClickOverlay = true,
    required this.menus,
  });

  final double menuBarHeight;
  final Color? activeColor;
  final Duration duration;
  final String direction;
  final bool closeOnClickOverlay;

  /// 子项：[WotDropMenuItem]（含名称）+ 对应展开内容。
  final List<Widget> menus;

  @override
  State<WotDropMenu> createState() => _WotDropMenuState();
}

/// 下拉菜单项：标题 + 展开内容。
class WotDropMenuItem extends StatelessWidget {
  const WotDropMenuItem({super.key, required this.title, required this.panel});
  final String title;
  final Widget panel;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _WotDropMenuState extends State<WotDropMenu> {
  int? _open;

  void _toggle(int index) {
    setState(() => _open = _open == index ? null : index);
  }

  void close() => setState(() => _open = null);

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final active = widget.activeColor ?? scheme.primaryOf(6);
    final menus = widget.menus;

    final titles = [
      for (final m in menus)
        if (m is WotDropMenuItem) m.title,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 菜单栏。
        Container(
          height: widget.menuBarHeight,
          decoration: BoxDecoration(
            color: scheme.filledOppo,
            border: Border(bottom: BorderSide(color: scheme.borderLight, width: 0.5)),
          ),
          child: Row(
            children: [
              for (var i = 0; i < menus.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => _toggle(i),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            i < titles.length ? titles[i] : '',
                            style: TextStyle(
                              fontSize: 14,
                              color: _open == i ? active : scheme.textMain,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _open == i ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            size: 16,
                            color: _open == i ? active : scheme.iconAuxiliary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // 展开区。
        if (_open != null && _open! < menus.length)
          _buildPanel(context, menus[_open!], _open!),
      ],
    );
  }

  Widget _buildPanel(BuildContext context, Widget menu, int index) {
    final scheme = context.wotScheme;
    Widget panel;
    if (menu is WotDropMenuItem) {
      panel = menu.panel;
    } else {
      panel = const SizedBox.shrink();
    }
    return Material(
      color: scheme.filledOppo,
      child: panel,
    );
  }
}