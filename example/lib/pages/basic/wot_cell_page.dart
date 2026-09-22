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
        demoSection('三态（disabled / error）'),
        demoBlock(
            'disabled：整体灰化且不可点（标题 / 值 / 图标 / 箭头 / 必填星号一并灰化）',
            const Column(children: [
              WotCell(title: '禁用单元格', value: '不可用', icon: 'info', disabled: true),
              WotCell(title: '禁用 + 箭头（不可点）', value: '值', isLink: true, disabled: true),
              WotCell(title: '禁用 + 必填', value: '值', required: true, disabled: true),
            ])),
        demoBlock('error：标题与值转危险色',
            const Column(children: [
              WotCell(title: '校验失败', value: '格式不正确', error: true),
              WotCell(title: 'error + 必填', value: '', required: true, error: true),
            ])),
        demoBlock('对照：正常态', const WotCell(title: '正常', value: '内容', icon: 'info')),
        demoSection('样式（center / border / titleWidth）'),
        demoBlock('垂直居中 center',
            const WotCell(title: '居中标题', value: '值', center: true, label: '多行 label 用来测居中')),
        demoBlock('border=false 无边框', const WotCell(title: '无边框', value: '值', border: false)),
        demoSection('尾部插槽（trailing）'),
        demoBlock(
            '自定义尾部',
            WotCell(title: '自定义尾部', value: '只读', trailing: const WotTag(text: '只读', type: WotTagType.primary), border: false)),
        demoSection('新增（D 类 P1）：placeholder / layout / 箭头方向 / 样式合并'),
        WotCell(title: '占位符', placeholder: '暂无数据'),
        WotCell(
          title: '纵向布局',
          value: '标题在上、值在下',
          layout: WotCellLayout.vertical,
          isLink: true,
        ),
        WotCell(
          title: '箭头方向',
          value: '向下',
          isLink: true,
          arrowDirection: WotArrowDirection.down,
        ),
        WotCell(
          title: '自定义标题样式',
          value: '仅覆盖字号，颜色保留三态默认',
          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          isLink: true,
          arrowDirection: WotArrowDirection.up,
        ),
      ],
    );
  }
}