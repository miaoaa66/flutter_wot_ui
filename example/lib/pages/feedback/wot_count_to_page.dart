import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotCountTo 数字滚动示例页。
///
/// 覆盖：modelValue / prefix / suffix / duration / **speed（A#11）** /
/// decimals / thousands / autoplay / onChange。
class WotCountToPage extends StatefulWidget {
  const WotCountToPage({super.key});

  @override
  State<WotCountToPage> createState() => _WotCountToPageState();
}

class _WotCountToPageState extends State<WotCountToPage> {
  num _target = 1234567;
  String _log = '—';

  /// 重放：换一个目标值即可触发 didUpdateWidget → 重新滚动。
  void _replay(num v) => setState(() {
        _target = v;
        _log = '—';
      });

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotCountTo 数字滚动',
      children: [
        demoSection('基础（modelValue / prefix / suffix）'),
        demoBlock('金额滚动',
            const WotCountTo(modelValue: 1234567, prefix: '¥ ', suffix: ' 元')),

        demoSection('速度（speed，A 类死参数 #11）'),
        demoBlock(
          'speed 指定「每秒递增多少」，总时长 = |目标值| / speed。'
          '下面两个同为 1000：speed=200 → 5s；speed=2000 → 0.5s。'
          '点下方按钮重放对比。',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('speed: 200（慢 · 5s）',
                            style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        WotCountTo(
                          key: ValueKey('slow$_target'),
                          modelValue: _target,
                          speed: 200,
                          textStyle: const TextStyle(fontSize: 22),
                          onChange: (v) =>
                              setState(() => _log = v.toStringAsFixed(0)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('speed: 2000（快 · 0.5s）',
                            style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        WotCountTo(
                          key: ValueKey('fast$_target'),
                          modelValue: _target,
                          speed: 2000,
                          textStyle: const TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  WotButton(
                      text: '重放 1000',
                      size: WotButtonSize.small,
                      onClick: () => _replay(1000)),
                  WotButton(
                      text: '重放 5000',
                      size: WotButtonSize.small,
                      onClick: () => _replay(5000)),
                  WotButton(
                      text: '重放 20000',
                      size: WotButtonSize.small,
                      onClick: () => _replay(20000)),
                ],
              ),
              const SizedBox(height: 4),
              Text('onChange 最新值：$_log',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        demoBlock(
          'speed 未指定时回退到 duration（默认 3000ms）。'
          'speed 传 0 或负数同样回退——不会除零。',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('speed: 0（非法值 → 用 duration 3s）',
                  style: TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              WotCountTo(
                key: ValueKey('zero$_target'),
                modelValue: _target,
                speed: 0,
                textStyle: const TextStyle(fontSize: 22),
              ),
            ],
          ),
        ),

        demoSection('时长（duration）'),
        demoBlock('5 秒缓动',
            const WotCountTo(modelValue: 9999, duration: Duration(seconds: 5))),
        demoBlock('500 毫秒（几乎瞬间完成）',
            const WotCountTo(modelValue: 9999, duration: Duration(milliseconds: 500))),

        demoSection('小数位（decimals）与千分位（thousands）'),
        demoBlock('decimals: 2 —— 注意千分位仅对「整数部分」生效',
            const WotCountTo(modelValue: 1234567.891, decimals: 2)),
        demoBlock('decimals: 2 + thousands: false —— 不做分隔',
            const WotCountTo(modelValue: 1234567.891, decimals: 2, thousands: false)),
        demoBlock('decimals: 3',
            const WotCountTo(modelValue: 3.14159, decimals: 3)),

        demoSection('自动播放（autoplay）'),
        demoBlock(
          'autoplay: false 直接显示目标值，不做滚动动画；'
          '改为 true 后重新挂载才会滚动。',
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('autoplay: false', style: TextStyle(fontSize: 12)),
                    WotCountTo(modelValue: 8888, autoplay: false),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('autoplay: true（默认）', style: TextStyle(fontSize: 12)),
                    WotCountTo(modelValue: 8888),
                  ],
                ),
              ),
            ],
          ),
        ),
        demoSection('新增（D 类 P1）：startVal 起始数值'),
        demoBlock('从 1000 滚动到 9999（startVal）',
            WotCountTo(modelValue: 9999, startVal: 1000, duration: const Duration(milliseconds: 2500))),
        demoBlock('startVal + decimals 小数', WotCountTo(modelValue: 99.5, startVal: 20, decimals: 1, duration: const Duration(milliseconds: 2000))),
      ],
    );
  }
}
