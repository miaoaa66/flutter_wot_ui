import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSlider 滑块示例页。
class WotSliderPage extends StatefulWidget {
  const WotSliderPage({super.key});

  @override
  State<WotSliderPage> createState() => _WotSliderPageState();
}

class _WotSliderPageState extends State<WotSliderPage> {
  num _v1 = 40;
  num _v2 = 30;
  num _v3 = 60;
  num _v4 = 50;
  num _low = 20;
  num _high = 80;
  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSlider 滑块',
      children: [
        demoSection('基础用法（modelValue / onChange）'),
        demoBlock('基础滑块（当前$_v1）', WotSlider(modelValue: _v1, onChange: (v) => setState(() => _v1 = v))),
        demoSection('范围与步进（min / max / step）'),
        demoBlock('step=10 min=0 max=100',
            WotSlider(modelValue: _v2, min: 0, max: 100, step: 10, onChange: (v) => setState(() => _v2 = v))),
        demoSection('提示（showTip / tipFormatter / showMinMax）'),
        demoBlock(
            'showTip + tipFormatter',
            WotSlider(
              modelValue: _v3,
              showTip: true,
              tipFormatter: (v) => '当前 $v',
              onChange: (v) => setState(() => _v3 = v),
            )),
        demoBlock(
            'showMinMax 两端显示最值',
            WotSlider(modelValue: _v4, min: 0, max: 100, step: 5, showMinMax: true, showValueInThumb: true, onChange: (v) => setState(() => _v4 = v))),
        demoSection('区间（range / valueStart / onChangeRange）'),
        demoBlock(
            '区间选择',
            WotSlider(
              range: true,
              valueStart: _low,
              modelValue: _high,
              step: 5,
              showTip: true,
              showMinMax: true,
              showValueInThumb: true,
              onChangeRange: (v) => setState(() {
                _low = v.first;
                _high = v.last;
              }),
            )),
        demoSection('状态（disabled）'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用', WotSlider(modelValue: _v1, disabled: _disabled, onChange: (v) => setState(() => _v1 = v))),
        demoSection('颜色（activeColor / inactiveColor）'),
        demoBlock('自定义颜色滑块',
            WotSlider(modelValue: _v2, activeColor: const Color(0xFF12B886), inactiveColor: const Color(0xFFD0D0D0), onChange: (v) => setState(() => _v2 = v))),
      ],
    );
  }
}