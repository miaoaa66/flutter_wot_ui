import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotExpand 展开更多容器示例页。
class WotExpandPage extends StatefulWidget {
  const WotExpandPage({super.key});

  @override
  State<WotExpandPage> createState() => _WotExpandPageState();
}

class _WotExpandPageState extends State<WotExpandPage> {
  bool _controlled = false;

  final String _longText =
      '春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。'
      '床前明月光，疑是地上霜。举头望明月，低头思故乡。'
      '白日依山尽，黄河入海流。欲穷千里目，更上一层楼。'
      '红豆生南国，春来发几枝。愿君多采撷，此物最相思。';

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotExpand 展开更多',
      children: [
        demoSection('默认效果（height: 50）'),
        demoBlock(
          '内容超高时底部渐隐遮罩 + 查看全部，点击展开/收起',
          WotExpand(
            child: WotText(_longText, type: WotTextType.wotDefault, lineHeight: 1.6),
          ),
        ),
        demoSection('自定义高度与文案'),
        demoBlock(
          'height: 80 / 展开更多 / 收起',
          WotExpand(
            height: 80,
            expandText: '展开更多',
            collapseText: '收起',
            child: WotText(_longText, type: WotTextType.wotDefault, lineHeight: 1.6),
          ),
        ),
        demoSection('collapsible=false（展开后不可收起）'),
        demoBlock(
          '展开后底部不显示收起按钮',
          WotExpand(
            collapsible: false,
            child: WotText(_longText, type: WotTextType.wotDefault, lineHeight: 1.6),
          ),
        ),
        demoSection('内容不足限高（不显示按钮）'),
        demoBlock(
          '短内容高度小于 height 时不显示查看全部',
          WotExpand(
            child: WotText(
              '这是一段较短的内容，未超过限高，底部不会出现操作按钮。',
              type: WotTextType.wotDefault,
            ),
          ),
        ),
        demoSection('自定义内容'),
        demoBlock(
          '列表内容',
          WotExpand(
            height: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < 10; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: WotText('第 ${i + 1} 条列表数据', type: WotTextType.wotDefault),
                  ),
              ],
            ),
          ),
        ),
        demoSection('受控模式（expanded / onChange）'),
        demoBlock(
          '外部按钮控制展开状态',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WotExpand(
                expanded: _controlled,
                onChange: (v) => setState(() => _controlled = v),
                child: WotText(_longText, type: WotTextType.wotDefault, lineHeight: 1.6),
              ),
              const SizedBox(height: 8),
              WotButton(
                text: _controlled ? '收起' : '展开',
                size: WotButtonSize.small,
                onClick: () => setState(() => _controlled = !_controlled),
              ),
            ],
          ),
        ),
      ],
    );
  }
}