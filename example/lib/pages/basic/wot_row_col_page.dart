import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotRow / WotCol 栅格示例页。
class WotRowColPage extends StatelessWidget {
  const WotRowColPage({super.key});

  Widget _box(BuildContext context, String text, {bool strong = false}) {
    return Container(
      height: 36,
      alignment: Alignment.center,
      color: strong ? context.wotScheme.filledStrong : context.wotScheme.filledContent,
      child: WotText(text, size: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotRow / WotCol 栅格',
      children: [
        demoSection('基础栅格（span）'),
        demoBlock('三列三等分（span=8）',
            WotRow(gutter: 8, children: [
              WotCol(span: 8, child: _box(context, 'span=8')),
              WotCol(span: 8, child: _box(context, 'span=8')),
              WotCol(span: 8, child: _box(context, 'span=8')),
            ])),
        demoBlock('非等比 span',
            WotRow(gutter: 8, children: [
              WotCol(span: 16, child: _box(context, 'span=16')),
              WotCol(span: 8, child: _box(context, 'span=8')),
            ])),
        demoSection('偏移（offset）'),
        demoBlock('offset=4 偏移（左空 4/24，块占 8/24，右侧空 12/24）',
            WotRow(gutter: 8, children: [
              WotCol(span: 8, offset: 4, child: _box(context, 'span=8 offset=4')),
            ])),
        demoBlock('对照：offset=0（块贴左，占 8/24）',
            WotRow(gutter: 8, children: [
              WotCol(span: 8, child: _box(context, 'span=8')),
            ])),
        demoSection('间距（gutter）'),
        demoBlock('gutter=16',
            WotRow(gutter: 16, children: [
              WotCol(span: 8, child: _box(context, 'span=8')),
              WotCol(span: 16, child: _box(context, 'span=16')),
            ])),
        demoSection('布局（justify）'),
        demoBlock('justify 分布',
            WotRow(justify: MainAxisAlignment.spaceBetween, children: [
              WotCol(span: 8, child: _box(context, '左')),
              WotCol(span: 8, child: _box(context, '右')),
            ])),
      ],
    );
  }
}