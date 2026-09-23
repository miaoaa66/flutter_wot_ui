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

        demoSection('步骤状态（WotStepData.status，A 类死参数 #15 已实现）'),
        demoBlock('waiting 视为「未指定」：仍按 active 索引推导（下面 active: 1）',
            WotSteps(
              active: 1,
              children: const [
                WotStep(data: WotStepData(title: '已完成', description: 'status 未指定 → 索引 < active')),
                WotStep(data: WotStepData(title: '进行中', description: 'status 未指定 → 索引 == active')),
                WotStep(data: WotStepData(title: '未开始', description: 'status 未指定 → 索引 > active')),
              ],
            )),
        demoBlock('显式指定四个状态：finished / process / error / waiting',
            WotSteps(
              active: 1,
              children: const [
                WotStep(data: WotStepData(title: 'finished', status: WotStepDataStatus.finished)),
                WotStep(data: WotStepData(title: 'process', status: WotStepDataStatus.process)),
                WotStep(data: WotStepData(title: 'error', status: WotStepDataStatus.error)),
                WotStep(data: WotStepData(title: 'waiting', status: WotStepDataStatus.waiting)),
              ],
            )),
        demoBlock(
            '对照：下面同样 active: 1，但第二项显式写 process、第三项写 finished —— '
            '显式状态会覆盖索引推导的结果',
            WotSteps(
              active: 1,
              children: const [
                WotStep(data: WotStepData(title: '第一项', description: '索引 0 < active → 完成')),
                WotStep(data: WotStepData(title: '第二项', description: '显式 process', status: WotStepDataStatus.process)),
                WotStep(data: WotStepData(title: '第三项', description: '显式 finished，覆盖「未开始」推导', status: WotStepDataStatus.finished)),
              ],
            )),

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
        demoBlock('垂直 + 显式状态（error 会显示红色）',
            WotSteps(
              direction: WotStepsDirection.vertical,
              active: 2,
              inactiveColor: scheme.textSecondary,
              children: const [
                WotStep(data: WotStepData(title: '提交订单', status: WotStepDataStatus.finished)),
                WotStep(data: WotStepData(title: '支付', status: WotStepDataStatus.error, description: '支付失败，请重试')),
                WotStep(data: WotStepData(title: '发货', status: WotStepDataStatus.waiting)),
              ],
            )),
      ],
    );
  }
}
