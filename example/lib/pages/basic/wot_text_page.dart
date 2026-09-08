import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotText 文本示例页。
class WotTextPage extends StatelessWidget {
  const WotTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotText 文本',
      children: [
        demoSection('主题类型（type）'),
        demoBlock('五种主题色',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              WotText('默认 default', size: 16),
              SizedBox(height: 6),
              WotText('主色 primary', type: WotTextType.primary, size: 16),
              WotText('成功 success', type: WotTextType.success, size: 16),
              WotText('警告 warning', type: WotTextType.warning, size: 16),
              WotText('错误 error', type: WotTextType.error, size: 16),
            ])),
        demoSection('尺寸 / 加粗 / 颜色（size / bold / color）'),
        demoBlock('size 12/16/20 + bold',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              WotText('小字号 12', size: 12),
              WotText('普通 16', size: 16),
              WotText('大字号 20', size: 20),
              WotText('加粗文本', size: 16, bold: true),
              WotText('自定义颜色', size: 16, color: Color(0xFF12B886)),
            ])),
        demoSection('行数与省略（lines）'),
        demoBlock('lines=1 单行省略',
            const WotText('超长文本超长文本超长文本超长文本超长文本超长文本超长文本', size: 14, lines: 1)),
        demoSection('装饰（decoration）'),
        demoBlock('下划线 / 中划线',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              WotText('下划线', size: 16, decoration: TextDecoration.underline),
              WotText('中划线', size: 16, decoration: TextDecoration.lineThrough),
            ])),
        demoSection('前后缀 / 对齐（prefix / suffix / textAlign）'),
        demoBlock('prefix + suffix',
            const WotText('带前后缀', size: 16, prefix: '【', suffix: '】')),
        demoBlock('textAlign 居中',
            const WotText('居中文本', size: 16, textAlign: TextAlign.center)),
        demoSection('事件（onTap）'),
        demoBlock('可点击文本',
            WotText('点击我（触发反馈）', type: WotTextType.primary, bold: true, decoration: TextDecoration.underline, onTap: () => demoToast(context, '点击了 WotText'))),
      ],
    );
  }
}