import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotIndexBar 索引栏示例页（右侧索引 + 锚点联动滚动）。
class WotIndexBarPage extends StatefulWidget {
  const WotIndexBarPage({super.key});

  @override
  State<WotIndexBarPage> createState() => _WotIndexBarPageState();
}

class _WotIndexBarPageState extends State<WotIndexBarPage> {
  static const List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F'];
  static const Map<String, List<String>> _cities = {
    'A': ['安康', '安庆', '安阳'],
    'B': ['北京', '保定', '包头'],
    'C': ['长春', '长沙', '重庆'],
    'D': ['大连', '大庆', '德阳'],
    'E': ['鄂尔多斯', '恩施'],
    'F': ['福州', '抚顺', '阜阳'],
  };

  final ScrollController _controller = ScrollController();
  final Map<String, GlobalKey> _keys = {
    for (final l in _letters) l: GlobalKey(),
  };
  bool _persist = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _jump(String index) {
    final ctx = _keys[index]?.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox) return;
    final anchorTop = box.localToGlobal(Offset.zero).dy;
    final viewBox = _controller.position.context.storageContext.findRenderObject() as RenderBox?;
    if (viewBox == null) return;
    final viewportTop = viewBox.localToGlobal(Offset.zero).dy;
    final target = _controller.offset + (anchorTop - viewportTop);
    _controller.animateTo(
      target.clamp(0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotIndexBar 索引栏',
      children: [
        demoSection('锚点联动（indexList / onSelect / WotIndexBarAnchor）'),
        demoBlock('城市列表 + 右侧索引',
            SizedBox(
              height: 320,
              child: WotIndexBar(
                indexList: _letters,
                activeColor: context.wotScheme.primaryOf(6),
                persistentHighlight: _persist,
                onSelect: _jump,
                child: ListView(
                  controller: _controller,
                  cacheExtent: 2000,
                  children: [
                    for (final e in _cities.entries)
                      WotIndexBarAnchor(
                        key: _keys[e.key],
                        index: e.key,
                        title: e.key,
                        child: Column(
                          children: [
                            for (final city in e.value)
                              InkWell(
                                onTap: () => demoToast(context, '选中 $city'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(children: [
                                    const WotIcon(name: 'location', size: 16),
                                    const SizedBox(width: 8),
                                    Text(city),
                                  ]),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            )),
        demoSection('persistentHighlight（常驻选中色）'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _persist = !_persist), child: Text('persistentHighlight: $_persist'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('开启后选中索引会常驻高亮',
            const WotText('拖动右侧索引条体验锚点定位；开启 persistentHighlight 后选中色常驻。')),
      ],
    );
  }
}