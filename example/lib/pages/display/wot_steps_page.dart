import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSteps 步骤条示例页。
class WotStepsPage extends StatefulWidget {
  const WotStepsPage({super.key});

  @override
  State<WotStepsPage> createState() => _WotStepsPageState();
}

class _WotStepsPageState extends State<WotStepsPage> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return WotDemoScaffold(
      title: 'WotSteps 步骤条',
      children: [
        demoSection('水平（active / onChange / activeColor）'),
        demoBlock('可点击切换步骤',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WotSteps(
                active: _step,
                activeColor: scheme.primaryOf(6),
                onChange: (i) => setState(() => _step = i),
                children: [
                  WotStep(data: const WotStepData(title: '第一步', description: '填写信息')),
                  WotStep(data: const WotStepData(title: '第二步', description: '确认订单')),
                  WotStep(data: const WotStepData(title: '第三步', description: '完成支付')),
                ],
              ),
              const SizedBox(height: 6),
              WotText('当前步骤：第 ${_step + 1} 步，点击步骤可切换', type: WotTextType.wotDefault),
            ])),
        demoSection('垂直（direction: vertical）'),
        demoBlock('垂直排列 + 成功色',
            WotSteps(
              direction: WotStepsDirection.vertical,
              active: 2,
              activeColor: scheme.successMain,
              children: const [
                WotStep(data: WotStepData(title: '查收快递', description: '物流已出发')),
                WotStep(data: WotStepData(title: '打包中', description: '正在打包商品')),
                WotStep(data: WotStepData(title: '下单成功', description: '订单已确认')),
                WotStep(data: WotStepData(title: '待付款', description: '等待支付')),
              ],
            )),
      ],
    );
  }
}