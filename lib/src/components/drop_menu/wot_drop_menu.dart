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

  /// 顶部菜单栏高度（逻辑像素），默认 40。
  final double menuBarHeight;

  /// 激活菜单项的高亮颜色；为空时取主题主色。
  final Color? activeColor;

  /// 展开/收起动画时长，默认 200ms。
  final Duration duration;

  /// 菜单展开方向：'down' 向下 / 'up' 向上，默认 'down'。
  final String direction;

  /// 点击遮罩是否关闭菜单；默认 true。
  final bool closeOnClickOverlay;

  /// 子项：[WotDropMenuItem]（含名称）+ 对应展开内容。
  final List<Widget> menus;

  @override
  State<WotDropMenu> createState() => _WotDropMenuState();
}

/// 下拉菜单选项（对齐 wot `wd-drop-menu-item` 的 `options` 项结构）。
class WotDropMenuOption {
  const WotDropMenuOption({required this.label, this.value, this.tip});

  /// 选项显示文本。
  final String label;

  /// 选项值。
  final dynamic value;

  /// 选项补充说明（可选，展示在文本右侧）。
  final String? tip;
}

/// 下拉菜单项：标题 + 展开内容。
///
/// 两种用法：
/// - 自定义内容：传入 [panel]（此时 [options] 为空）。
/// - 选项列表：传入 [options]/[modelValue]/[onChange]，展开区自动渲染选项列表，勾选当前选中值。
class WotDropMenuItem extends StatelessWidget {
  const WotDropMenuItem({
    super.key,
    this.title,
    this.panel = const SizedBox.shrink(),
    this.modelValue,
    this.options = const <WotDropMenuOption>[],
    this.onChange,
    this.closeOnClick = true,
    this.disabled = false,
  });

  /// 菜单项标题；不传时在 [options] 下取当前选中项 [label] 展示。
  final String? title;

  /// 展开时显示的面板内容（自定义内容场景）。
  final Widget panel;

  /// 当前选中值。
  final dynamic modelValue;

  /// 选项列表（对齐 wot `options`）。
  final List<WotDropMenuOption> options;

  /// 选中值变化回调，参数为选中项的 [WotDropMenuOption.value]（对齐 wot `change`）。
  final ValueChanged<dynamic>? onChange;

  /// 选中选项后是否自动收起菜单；默认 true。
  final bool closeOnClick;

  /// 是否禁用该菜单项，禁用后不可点击；默认 false。
  final bool disabled;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _WotDropMenuState extends State<WotDropMenu> {
  int? _open;

  void _toggle(int index) {
    final m = index < widget.menus.length ? widget.menus[index] : null;
    if (m is WotDropMenuItem && m.disabled) return;
    setState(() => _open = _open == index ? null : index);
  }

  void close() => setState(() => _open = null);

  /// 计算单个菜单项的标题（自定义 title 优先，否则取 options 选中项 label）。
  String _titleOf(WotDropMenuItem m) {
    if (m.title != null) return m.title!;
    for (final o in m.options) {
      if (o.value == m.modelValue) return o.label;
    }
    return '';
  }

  /// 是否展示选项列表（非自定义内容）。
  bool _isOptions(WotDropMenuItem m) => m.options.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final active = widget.activeColor ?? scheme.primaryOf(6);
    final menus = widget.menus;

    final titles = [
      for (final m in menus) if (m is WotDropMenuItem) _titleOf(m),
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
    final active = widget.activeColor ?? scheme.primaryOf(6);
    Widget panel;
    if (menu is WotDropMenuItem && _isOptions(menu)) {
      panel = _buildOptions(context, menu, active);
    } else if (menu is WotDropMenuItem) {
      panel = menu.panel;
    } else {
      panel = const SizedBox.shrink();
    }
    return Material(
      color: scheme.filledOppo,
      child: panel,
    );
  }

  /// 渲染选项列表：点击选中项触发 [WotDropMenuItem.onChange]，并按 [closeOnClick] 决定是否收起。
  Widget _buildOptions(
      BuildContext context, WotDropMenuItem menu, Color active) {
    final scheme = context.wotScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < menu.options.length; i++) ...[
          InkWell(
            onTap: () {
              final value = menu.options[i].value;
              menu.onChange?.call(value);
              if (menu.closeOnClick) close();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  top: i == 0
                      ? BorderSide(color: scheme.borderLight, width: 0.5)
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      menu.options[i].label,
                      style: TextStyle(
                        fontSize: 14,
                        color: menu.options[i].value == menu.modelValue
                            ? active
                            : scheme.textMain,
                      ),
                    ),
                  ),
                  if (menu.options[i].tip != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      menu.options[i].tip!,
                      style: TextStyle(
                          fontSize: 13, color: scheme.textAuxiliary),
                    ),
                  ],
                  if (menu.options[i].value == menu.modelValue)
                    Icon(Icons.check, size: 16, color: active),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}