import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import 'basic/basic_page.dart';
import 'nav/nav_page.dart';
import 'form/form_page.dart';
import 'feedback/feedback_page.dart';
import 'display/display_page.dart';

/// 示例 App 首页：按 wot 分组（基础/导航/录入/反馈/展示）列出各组件入口。
class WotIndexPage extends StatelessWidget {
  const WotIndexPage({
    super.key,
    required this.dark,
    required this.variant,
    required this.onToggleDark,
    required this.onSelectVariant,
  });

  final bool dark;
  final WotThemeVariant variant;
  final VoidCallback onToggleDark;
  final ValueChanged<WotThemeVariant> onSelectVariant;

  @override
  Widget build(BuildContext context) {
    final groups = [
      _Group('基础 Basic', [
        _Entry('Button', '按钮', () => _push(context, const WotBasicPage())),
        _Entry('Icon', '图标', () => _push(context, const WotBasicPage())),
        _Entry('Text', '文本', () => _push(context, const WotBasicPage())),
        _Entry('Cell', '单元格', () => _push(context, const WotBasicPage())),
        _Entry('Overlay', '遮罩', () => _push(context, const WotBasicPage())),
        _Entry('Loading', '加载', () => _push(context, const WotBasicPage())),
      ]),
      _Group('导航 Navigation', [
        _Entry('Navbar', '顶部导航栏', () => _push(context, const WotNavPage())),
      ]),
      _Group('录入 Form', [
        _Entry('Form/Input/选择器', '表单·输入·选择', () => _push(context, const WotFormPage())),
      ]),
      _Group('反馈 Feedback', [
        _Entry('Toast/Notify/Dialog', '命令式反馈', () => _push(context, const WotFeedbackPage())),
      ]),
      _Group('展示 Display', [
        _Entry('Tag/Avatar/Card', '标签·头像·卡片', () => _push(context, const WotDisplayPage())),
        _Entry('Grid/Collapse/Steps', '宫格·折叠·步骤', () => _push(context, const WotDisplayPage())),
        _Entry('Swiper/Table/QrCode', '轮播·表格·二维码', () => _push(context, const WotDisplayPage())),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wot UI Flutter'),
        actions: [
          PopupMenuButton<WotThemeVariant>(
            icon: const Icon(Icons.palette_outlined),
            tooltip: '切换主题',
            initialValue: variant,
            onSelected: onSelectVariant,
            itemBuilder: (_) => [
              for (final v in WotThemeVariant.values)
                PopupMenuItem(
                  value: v,
                  child: Text(v.label),
                ),
            ],
          ),
          Row(
            children: [
              const Text('Dark'),
              Switch(value: dark, onChanged: (_) => onToggleDark()),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          for (final g in groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: WotText(g.title, size: 14, strong: true, type: WotTextType.secondary),
            ),
            if (g.entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: WotText('待实现（后续 Phase 补充）', type: WotTextType.disabled, size: 13),
              )
            else
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final e in g.entries)
                      ListTile(
                        leading: const WotIcon(name: 'arrow-right', size: 16),
                        title: Text(e.name),
                        subtitle: Text(e.desc),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: e.onTap,
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _Group {
  const _Group(this.title, this.entries);
  final String title;
  final List<_Entry> entries;
}

class _Entry {
  const _Entry(this.name, this.desc, this.onTap);
  final String name;
  final String desc;
  final VoidCallback onTap;
}