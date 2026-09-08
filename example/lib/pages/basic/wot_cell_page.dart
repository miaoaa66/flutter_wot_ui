import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCell 单元格示例页。
class WotCellPage extends StatelessWidget {
  const WotCellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCell 单元格',
      children: [
        demoSection('基础（title / label / value）'),
        demoBlock('title + value',
            const Column(children: [
              WotCell(title: '单元格', value: '内容'),
              WotCell(title: '较长的单元格标题', value: '内容'),
            ])),
        demoSection('标题辅助与图标（icon / label / desc）'),
        demoBlock('icon + label',
            const Column(children: [
              WotCell(title: '带图标', icon: 'star', value: '5.0'),
              WotCell(title: '带辅助说明', icon: 'info', label: '下方辅助文案', value: 'value 文案'),
              WotCell(title: '带描述 desc', icon: 'settings', value: '值', desc: 'desc 描述'),
            ])),
        demoSection('链接与必填（isLink / required）'),
        demoBlock('箭头链接 / 必填星号',
            Column(children: [
              WotCell(title: '带箭头', isLink: true, onClick: () => demoToast(context, '点击了 Cell')),
              const WotCell(title: '必填项', value: '请输入', required: true),
            ])),
        demoSection('样式（center / border / titleWidth）'),
        demoBlock('垂直居中 center',
            const WotCell(title: '居中标题', value: '值', center: true, label: '多行 label 用来测居中')),
        demoBlock('border=false 无边框', const WotCell(title: '无边框', value: '值', border: false)),
        demoSection('尾部插槽（trailing）'),
        demoBlock(
            '自定义尾部',
            WotCell(title: '自定义尾部', value: '只读', trailing: const WotTag(text: '只读', type: WotTagType.primary), border: false)),
      ],
    );
  }
}